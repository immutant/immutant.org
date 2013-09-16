---
title: 'WebSockets and SockJS with Immutant and Vert.x'
author: Toby Crawley
layout: news
tags: [ messaging, daemons, vertx, websockets, sockjs ]
---

Currently, Immutant doesn't provide any native WebSockets
support. However, it is possible to use another WebSockets-capable
server from within an Immutant [daemon]. There are quite a few
well-known options in the Clojure ecosystem that we could use here,
like [Aleph], [http-kit], or raw [Jetty] or [Netty]. Instead, we're
going to use a relative newcomer to the Clojure space: [Vert.x].

## What is Vert.x?

Vert.x is an asynchronous polyglot application platform built on top
of Netty that has been around for a while, but just recently gained
[Clojure support]. It includes it's own message passing system (the
[EventBus]) which we can easily bridge to the Immutant [messaging]
system, and provides a [SockJS] implementation that allows browser
clients to participate as peers in the EventBus over WebSockets or
other fallback protocols {{more on fallback}}. SockJS and an EventBus
that is bridged to the client abstracts away some of the complexity of
managing dynamic updates to the browser, and is the primary reason
we're using Vert.x over some of the alternatives mentioned above.

We're going to take a look at some code in a minute, but we need to
cover some terminology first. In Immutant, messaging endpoints are
built on top of JMS, so we use JMS terminology: endpoints are
*destinations*, and can either be *topics* (broadcast), or *queues*
(single-receiver) {{describe betterer}}. The Vert.x EventBus is not
built on JMS, but provides similar abstractions: endpoints are known
as *addresses*, and support broadcast or single-receiver semantics,
which is specified by the message sender instead of the endpoint. In
both systems, you can register *listeners* on endpoints to process
incoming messages.

## Our application

To demonstrate this integration, we'll be using a simple stream
processing application called
[Rivulet](https://github.com/tobias/rivulet-immutant-vertx). It has a
[producer] that generates a stream of words to a destination
(`topic.stream`), and a message-based
[api](https://github.com/tobias/rivulet-immutant-vertx/blob/master/src/rivulet/control.clj)
(listening for requests on a control destination (`topic.commands`))
that registers regex filters against the stream. Each filter becomes a
listener on the stream which publishes matches to a results
destination (`topic.matches`) tagged with the `client-id` of the
filter's owner. All of that uses existing Immutant features, and is
really a stand-in for a potentially more complex process. Where the
app gets interesting is how we communicate with a browser UI. Vert.x
provides a [javascript EventBus client] that uses SockJS to allow the
browser to participate in the EventBus as a peer. The Vert.x Clojure
language module provides a [ClojureScript wrapper] around that
javascript client, which we use in Rivulet's ClojureScript client
implementation. This client communicates with a Vert.x instance
embedded inside an Immutant daemon, which bridges EventBus addresses
to Immutant messaging destinations.


To get started,
[clone the app](https://github.com/tobias/rivulet-immutant-vertx) and
run it:[^1]

    cd /path/to/rivulet-immutant-vertx
    lein do immutant deploy, immutant run
    
Then browse to <http://localhost:8080/>. You should see a UI that lets
you add and remove filters, and view the raw stream. 

Now let's see some code! The functions for bridging Immutant
messaging destinations to EventBus addresses are in the
[bridge namespace], and fairly simple. They just register listeners
that re-publish incoming messages to the correct destination or
address:[^2]

<pre class="syntax clojure">(require '[immutant.messaging :as msg]
         '[vertx.eventbus :as eb])
         
(defn dest->eventbus
  "Sets up a bridge to copy messages from an Immutant messaging dest to a Vertx address.
   If a selector string is provided, it will be applied to the
   listener, and only messages matching the selector will be copied."
  ([vertx dest address]
     (dest->eventbus vertx dest address nil))
  ([vertx dest address selector]
     (msg/listen dest #(with-vertx vertx
                         (eb/publish address %))
                 :selector selector)))

(defn eventbus->dest
  "Sets up a bridge to copy messages from a Vertx address to an Immutant messaging dest."
  [vertx address dest]
  (with-vertx vertx
    (eb/on-message address (partial msg/publish dest))))

</pre>
      
The [bridge namespace] also provides a function to start up a SockJS
server inside our vertx instance, and expose the EventBus bridge to
the client:[^3]

<pre class="syntax clojure">(require '[vertx.http :as http]
         '[vertx.http.sockjs :as sockjs])
         
(defn create-sockjs-server
  "Start a SockJS server at endpoint, and bridge the EventBus across it."
  [vertx {:keys [host port path url]} & hooks]
  (println "Starting SockJS bridge at" url)
  (with-vertx vertx
    (let [server (http/server)]
      (-> server
          (sockjs/sockjs-server)
          (as-> sock-serv
                (apply sockjs/set-hooks sock-serv hooks))
          (sockjs/bridge {:prefix path} [{}] [{}]))
      (http/listen server port host))))
</pre>

The application logic that is responsible for actually bridging the
messaging endpoints along with managing the lifecycle of the SockJS
server is in the [daemon namespace]:

<pre class="syntax clojure">(require '[rivulet.bridge :as bridge])
         
(defn- bridge-client-results
  "Sets up a bridge between the results topic and the results address
   requested by the client, with a selector based on the client id."
  [state vertx result-dest address]
  (if-let [id (second (re-find #"^results\.(.*)$" address))]
    (when-not (@state id)
      (swap! state assoc id
             (bridge/dest->eventbus vertx
                                    result-dest
                                    address
                                    (format "JMSCorrelationID='%s'" id))))))
                                    
(defn- start
  "Starts the SockJS server, and bridges the requested incoming and
   outgoing destionations to like named addresses. Registers a hook on
   the SockJS server that bridges the requested result address to the
   results topic, filtered by the client-id."
  [state destinations
   {:keys [incoming outgoing]}]
  (let [vertx (bridge/create-vertx)]
    (swap! state assoc
           :vertx vertx
           :server
           (bridge/create-sockjs-server vertx
                                        (endpoint)
                                        :post-register
                                        (fn [_ address]
                                          (bridge-client-results
                                           state vertx
                                           (:result-dest destinations)
                                           address))))
    (mapv #(bridge/eventbus->dest vertx % %)
          (map destinations incoming))
    (mapv #(bridge/dest->eventbus vertx % %)
          (map destinations outgoing))))
</pre>

The last piece is the [client-side ClojureScript]. It's fairly
standard [Enfocus] transformations, with EventBus calls mixed in. The
interesting parts are where we interact with the EventBus:

<pre class="syntax clojure">(require '[vertx.client.eventbus :as eb])

(defn open-eventbus
  "Opens a connection to the remote EventBus endpoint.
   See web.clj to see how sockjs_endpoint is injected."
  [on-open]
  (reset! eb (eb/eventbus js/sockjs_endpoint))
  (eb/on-open @eb #(.log js/console "eventbus opened"))
  (eb/on-open @eb on-open))

(defn send-command [command payload]
  (eb/publish @eb "topic.commands"
              {:command command :client-id client-id :payload payload}))
              
(defn attach-result-listener
  "Subscribes to the results.<client-id> address.
   On the server-side, this will trigger a bridge between
   results.<client-id> and the results destination, filtered by the
   client-id (see daemon.clj)."
  []
  (eb/on-message @eb (str "results." client-id) result-listener))
</pre>

# A nice, neat little package?

So, what have we done here? We've added dynamic updates over
WebSockets (with fallback) to an Immutant application, maintaining a
separation of concerns, without having to handle the minutiae of
bi-directional communication over WebSockets and any fallback
protocols. And since Vert.x allows the browser client to be an equal
peer in the EventBus, we were able to use the same API on the server
and client.

However, it's not all roses - there are some definite drawbacks to this
approach:

  * Since Immutant doesn't support WebSockets natively, we can't share
    the http port and upgrade connections to WebSockets on
    request. This means that any WebSockets solution we run as a
    daemon has to bind to its own port.
  * We're adding complexity by bringing in another messaging system,
    which is more the developer is required to understand.
    
This has been an exploration of one way to add simple dynamic
interaction to an Immutant application, and is certainly not the only
way. If you have any questions, comments, or feedback, please 
[get in touch](/community/).

1. [^1] This assumes you have a recent Immutant [installed](/install/).
2. [^2] Since we're using Vert.x in embedded mode, we have to bind to a particular vertx instance using [vertx.embed/with-vertx]. If we were using Vert.x as our container, this wouldn't be necessary.
3. [^3] For this example, we're not securing the EventBus bridge at all. [Doing so] is probably a good idea.

[daemon]: /documentation/current/daemons.html
[Aleph]: https://github.com/ztellman/aleph
[http-kit]: http://http-kit.org/
[Jetty]: http://www.eclipse.org/jetty/
[Netty]: http://netty.io/
[Vert.x]: http://vertx.io/
[Clojure support]: https://github.com/vert-x/mod-lang-clojure
[EventBus]: https://github.com/vert-x/mod-lang-clojure/blob/master/docs/core_manual_clojure.md#the-event-bus
[messaging]: /documentation/current/messaging.html
[SockJS]: http://sockjs.org
[producer]: https://github.com/tobias/rivulet-immutant-vertx/blob/master/src/rivulet/producer.clj
[javascript EventBus client]: https://github.com/eclipse/vert.x/blob/master/src/dist/client/vertxbus.js
[ClojureScript wrapper]: https://github.com/vert-x/mod-lang-clojure/blob/master/api/src/main/clojure/vertx/client/eventbus.cljs
[bridge namespace]: https://github.com/tobias/rivulet-immutant-vertx/blob/master/src/rivulet/bridge.clj
[daemon namespace]: https://github.com/tobias/rivulet-immutant-vertx/blob/master/src/rivulet/daemon.clj
[client-side ClojureScript]: https://github.com/tobias/rivulet-immutant-vertx/blob/master/src-cljs/rivulet/client.cljs
[Enfocus]: https://github.com/ckirkendall/enfocus
