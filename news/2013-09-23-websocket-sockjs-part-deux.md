---
title: 'WebSockets and SockJS with Immutant and Vert.x - Part 2'
author: Toby Crawley
layout: news
tags: [ daemons, vertx, websockets, sockjs, messaging ]
---

This is a followup to our
[post last week on WebSockets with Vert.x][prior]. If you haven't read
it, you should do so now. In that post, we set up a simple echo
service in [Vert.x] that bridged the Vert.x [EventBus] to the
browser. But that echo service wasn't very useful - there was no way
to process incoming messages outside of the daemon, and no way to send
messages down to the browser client from other parts of the
application. Today, we're going to look at bridging the EventBus over
to [Immutant messaging], allowing us to actually interact with the
client from anywhere within our application.

## Our application

We'll be using the [same application][app] we used in the last post, but
will be working off of a [branch].

To get started, [clone the app][app] and run it:[^1]

    cd /path/to/simple-immutant-vertx-demo
    git checkout with-messaging
    lein do immutant deploy, immutant run
    
Then browse to <http://localhost:8080/>. You should see a UI that lets
you send messages and see those messages echoed back, but now they
come back in uppercase:

<img src="/images/news/sockjs2.png" alt="[UI activity]" class="bordered aligncenter"/>

## Let's see some code! 

Most of the application remains the same as it did before. But instead
of just copying messages from the request address to the response
address, we've now wired our
[`demo.bridge` namespace](https://github.com/immutant/simple-immutant-vertx-demo/blob/with-messaging/src/demo/bridge.clj)
to the Immutant messaging system. We now have functions that bridge
EventBus addresses to Immutant messaging destinations, and vice-versa,
and have modified the `init-bridge` function to map the appropriate
addresses and destinations:

<pre class="syntax clojure">(ns demo.bridge
  (:require [vertx.embed :as vembed :refer [with-vertx]]
            [vertx.http :as http]
            [vertx.http.sockjs :as sockjs]
            [vertx.eventbus :as eb]
            [immutant.messaging :as msg]))

(defn dest->eventbus
  "Sets up a bridge to copy messages from an Immutant messaging dest to a Vertx address."
  ([vertx dest address]
     (msg/listen dest #(with-vertx vertx
                         (eb/publish address %)))))

(defn eventbus->dest
  "Sets up a bridge to copy messages from a Vertx address to an Immutant messaging dest."
  [vertx address dest]
  (with-vertx vertx
    (eb/on-message address (partial msg/publish dest))))

(defn- start-sockjs-bridge
  "Creates a Vert.x http server, a sockjs server within that http
  server, then installs an eventbus bridge in the sockjs server."
  [vertx host port path]
  (println (format "Starting SockJS bridge at http://%s:%s%s" host port path))
  (with-vertx vertx
    (let [server (http/server)]
      (-> server
          (sockjs/sockjs-server)
          (sockjs/bridge {:prefix path} [{}] [{}]))
      (http/listen server port host))))

(defn init-bridge
  "Initializes the embedded vertx instance, bridges to Immutant destinations, and starts the sockjs bridge."
  [{:keys [request-dest response-dest]}]
  (let [vertx (vembed/vertx)]
    (eventbus->dest vertx "demo.request" request-dest)
    (dest->eventbus vertx response-dest "demo.response")
    {:vertx vertx
     :server (start-sockjs-bridge vertx "localhost" 8081 "/eventbus")}))
</pre>

Now that `demo.bridge` no longer echos, but instead expects something
on the other end of the `request-dest`, we need something listening on
the other end to do the work. We've added this to the
[`demo.init` namespace](https://github.com/immutant/simple-immutant-vertx-demo/blob/with-messaging/src/demo/init.clj),
which is also where we define the request/response destination
names. Our listener here just watches `queue.request`, uppercases each
message, and publishes it to `topic.response`. Since we have bridged
those same destinations in `demo.bridge`, we again have a completed
circle from the client and back:

<pre class="syntax clojure">(ns demo.init
  (:require [demo.web :as web]
            [demo.daemon :as daemon]
            [immutant.messaging :as msg]))

(def config {:response-dest "topic.response"
             :request-dest "queue.request"
             :process-fn (memfn toUpperCase)})

(defn init []
  (let [{:keys [request-dest response-dest process-fn]} config]
    (msg/start request-dest)
    (msg/start response-dest)
    (msg/listen request-dest
                #(msg/publish response-dest (process-fn %))))
  (web/start)
  (daemon/start config))
</pre>

## Touch the UI from anywhere

Now that we've bridged the EventBus to the Immutant messaging system,
we can interact with our client UI from anywhere within our
application. Just to beat the horse a bit more, let's do it from the
repl. Connect to the [nREPL endpoint] in the application running on
port `5309`[^2] using your favorite client, then try sending messages
directly to the response topic, or to the request queue to have them
uppercased first:

<pre class="syntax clojure">user&gt; (require '[immutant.messaging :as msg])
nil
user&gt; (msg/publish "topic.response" "ahoyhoy")
#&lt;HornetQTextMessage HornetQMessage[ID:8af51642-2478-11e3-9deb-25745b71356d]:PERSISTENT&gt;
user&gt; (msg/publish "queue.request" "ahoyhoy")
#&lt;HornetQTextMessage HornetQMessage[ID:90e4b5b8-2478-11e3-9deb-25745b71356d]:PERSISTENT&gt;
user&gt; 
</pre>

You can also send structured messages:

<pre class="syntax clojure">user&gt; (msg/publish "topic.response" {:x :y})
#&lt;HornetQTextMessage HornetQMessage[ID:e09bf794-2478-11e3-9deb-25745b71356d]:PERSISTENT&gt;
</pre>

And see them all displayed in the client UI:

<img src="/images/news/sockjs3.png" alt="[repl UI activity]" class="bordered aligncenter"/>

## Fare thee well

We've extended our [prior example][prior] to make it actually useful, and
maintained a separation of concerns within our application - code
outside of the `demo.bridge` namespace has no knowledge of Vert.x, nor
of the UI communication mechanism. We think this provides a compelling
way to provide dynamic updates to the browser, but if you don't, or
have any other questions, comments, or feedback, please
[get in touch](/community/).

<hr>
1. [^1] This assumes you have a recent Immutant
   [installed](/install/).
2. [^2] The demo application specifies `5309` as the `:nrepl-port` in
   its `project.clj`. If you have `:immutant {:nrepl-port some-port}`
   set in your `~/.lein/profiles.clj`, that will override `5309` and
   you'll need to connect to whatever port the endpoint is bound to.

[prior]: /news/2013/09/17/websocket-sockjs/
[Vert.x]: http://vertx.io/
[EventBus]: https://github.com/vert-x/mod-lang-clojure/blob/master/docs/core_manual_clojure.md#the-event-bus
[app]: https://github.com/immutant/simple-immutant-vertx-demo
[branch]: https://github.com/immutant/simple-immutant-vertx-demo/tree/with-messaging
[Immutant messaging]: /documentation/current/messaging.html
[nREPL endpoint]: /documentation/current/interactive.html#sec-2
