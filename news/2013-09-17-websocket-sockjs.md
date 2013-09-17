---
title: 'WebSockets and SockJS with Immutant and Vert.x'
author: Toby Crawley
layout: news
tags: [ daemons, vertx, websockets, sockjs ]
---

Currently, Immutant doesn't provide any native WebSockets
support. However, it is possible to use another WebSockets-capable
server from within an [Immutant daemon]. There are quite a few
well-known options in the Clojure ecosystem that we could use here,
like [Aleph], [http-kit], or raw [Jetty] or [Netty]. Instead, we're
going to use a relative newcomer to the Clojure space: [Vert.x].

## What is Vert.x?

Vert.x is an asynchronous polyglot application platform built on top
of Netty that has been around for a while, but just recently gained
[Clojure support]. It provides (among other things) its own message
passing system (the [EventBus]), and provides a [SockJS]
implementation that allows browser clients to participate as peers in
the EventBus over WebSockets, falling back to other protocols as the
browser and network topology dictate. SockJS and an EventBus that is
bridged to the client abstracts away some of the complexity of
managing dynamic updates to the browser, and is the primary reason
we're using Vert.x over some of the alternatives mentioned above.

Vert.x includes a [javascript EventBus client] for use in client-side
code that allows the browser to participate in the EventBus as a
peer. The Vert.x Clojure language module includes a
[ClojureScript wrapper] around that javascript client, which we'll use
in a bit.

## Our application

To demonstrate using the Vert.x EventBus bridge from Immutant, we're
going to look at a simple application that embeds[^1] Vert.x into an
[Immutant daemon] to provide an echo service over the EventBus.

To get started,
[clone the app](https://github.com/immutant/simple-immutant-vertx-demo)
and run it:[^2]

    cd /path/to/simple-immutant-vertx-demo
    lein do immutant deploy, immutant run
    
Then browse to <http://localhost:8080/>. You should see a UI that lets
you send messages and see those messages echoed back. If you're using
a browser with a Network console, you should be able to see the
the SockJS WebSockets traffic, like so:

<img src="/images/news/sockjs.png" alt="[websocket activity]"/>


## Let's see some code! 

First, let's take a look at the [ClojureScript client]. It's fairly
standard [Enfocus] transformations, with EventBus calls mixed in. The
interesting parts are where we interact with the EventBus:

<pre class="syntax clojure">(require '[vertx.client.eventbus :as eb])

(def eb (atom nil))

(defn open-eventbus
  "Opens a connection to the remote EventBus endpoint."
  [on-open]
  (reset! eb (eb/eventbus "http://localhost:8081/eventbus"))
  (eb/on-open @eb #(.log js/console "eventbus opened"))
  (eb/on-open @eb on-open))

(defn send-message
  "Sends a message to the request address."
  [message]
  (eb/publish @eb "demo.request" message))

(defn attach-listeners
  "Attaches listeners to both the the request and response addresses,
   displaying the received messages in the appropriate divs."
  []
  (eb/on-message @eb "demo.request" (partial append-content "#sent"))
  (eb/on-message @eb "demo.response" (partial append-content "#rcvd")))

(defn init []
  (open-eventbus attach-listeners)
  (attach-send-click))
</pre>

On the server side, we start up the SockJS EventBus bridge as an
Immutant daemon in the
[`demo.daemon` namespace](https://github.com/immutant/simple-immutant-vertx-demo/blob/master/src/demo/daemon.cljs),
and is standard Immutant daemon management code.  The functions that
actually do the work of setting up the bridge are in the
[`demo.bridge` namespace](https://github.com/immutant/simple-immutant-vertx-demo/blob/master/src/demo/bridge.cljs):[^3]

<pre class="syntax clojure">(ns demo.bridge
  (:require [vertx.embed :as vembed :refer [with-vertx]]
            [vertx.http :as http]
            [vertx.http.sockjs :as sockjs]
            [vertx.eventbus :as eb]))

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
  "Initializes the embedded vertx instance, sets up our echo handler,
   and starts the sockjs bridge."
  []
  (let [vertx (vembed/vertx)]
    (with-vertx vertx
      (eb/on-message "demo.request"
                     (partial eb/publish "demo.response")))
    {:vertx vertx
     :server (start-sockjs-bridge vertx "localhost" 8081 "/eventbus")}))
</pre>

## A nice, neat little package?

So, what have we done here? We've added dynamic updates over
WebSockets (with fallback) to an Immutant application, without having
to handle the minutiae of bi-directional communication over WebSockets
and any fallback protocols. And since Vert.x allows the browser client
to be an equal peer in the EventBus, we were able to use a similar API
on the server and client.

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
way. Watch for a post in the future that presents a more complex
application that bridges the Vert.x EventBus to [Immutant messaging]
destinations. If you have any questions, comments, or feedback,
please [get in touch](/community/).

<hr>
1. [^1] Vert.x provides its own [application container], but we're
   using it embedded, which is an advanced usage.
2. [^2] This assumes you have a recent Immutant
   [installed](/install/).
3. [^3] For this example, we're not securing the EventBus bridge at
   all. [Doing so](https://github.com/vert-x/mod-lang-clojure/blob/master/docs/core_manual_clojure.md#securing-the-bridge) is probably a good idea.

[Immutant daemon]: /documentation/current/daemons.html
[Aleph]: https://github.com/ztellman/aleph
[http-kit]: http://http-kit.org/
[Jetty]: http://www.eclipse.org/jetty/
[Netty]: http://netty.io/
[Vert.x]: http://vertx.io/
[Clojure support]: https://github.com/vert-x/mod-lang-clojure
[EventBus]: https://github.com/vert-x/mod-lang-clojure/blob/master/docs/core_manual_clojure.md#the-event-bus
[SockJS]: http://sockjs.org
[javascript EventBus client]: https://github.com/eclipse/vert.x/blob/master/src/dist/client/vertxbus.js
[ClojureScript wrapper]: https://github.com/vert-x/mod-lang-clojure/blob/master/api/src/main/clojure/vertx/client/eventbus.cljs
[ClojureScript client]: https://github.com/immutant/simple-immutant-vertx-demo/blob/master/src-cljs/demo/client.cljs
[Enfocus]: https://github.com/ckirkendall/enfocus
[Immutant messaging]: /documentation/current/messaging.html
[application container]: http://vertx.io/manual.html#using-vertx-from-the-command-line
