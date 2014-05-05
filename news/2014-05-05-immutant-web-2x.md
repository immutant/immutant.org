---
title: Tangled in the Web of The Deuce
author: Jim Crossley
layout: news
tags: [ thedeuce, getting-started, tutorial, web ]
---

Our `org.immutant/web` library has changed quite a bit in Immutant 2,
both its API and its foundation: the [Undertow] web server. Among
other things, this gives us
[much better performance](https://github.com/ptaoussanis/clojure-web-server-benchmarks)
(~35% more throughput than v1.1.1) and built-in support for
websockets.

We've given a lot of thought to the API, specifically argument names,
types, order, and return values. We're reasonably happy with what we
have at this point, but still very much open to suggestions for
improvements.

## The Web API

The API for [immutant.web] is small, just two functions and a
convenient macro:

* `run` - runs your handler in a specific environment, responding to
  web requests matching a given host, port, and path. The handler may
  be either a Ring function, Servlet instance, or Undertow
  HttpHandler.
* `run-dmc` - runs your handler in *Development Mode* (the 'C' is silent)
* `stop` - stops your handler[s]

The following code fragments assume you've read through the
[getting started] post and required the `immutant.web` namespace, e.g.
at a REPL:

<pre class="syntax clojure">(require '[immutant.web :refer :all])</pre>

### Common Usage

First, we'll need a [Ring] handler. Yours is probably fancier, but
this one will do:

<pre class="syntax clojure">(defn app [request]
  {:status 200
   :body "Hello world!"})
</pre>

To make the app available at <http://localhost:8080/>, do this:

<pre class="syntax clojure">(run app)</pre>

Which, if we make the default values explicit, is equivalent to this:

<pre class="syntax clojure">(run app :host "localhost" :port 8080 :path "/")</pre>

Or, since `run` takes options as either keyword arguments (kwargs) or
an explicit map, this:

<pre class="syntax clojure">(run app {:host "localhost" :port 8080 :path "/"})</pre>

The options passed to `run` determine the URL used to invoke your
handler: `http://{host}:{port}{path}`

To replace your `app` handler with another, just call run again with
the same options, and it'll replace the old handler with the new:

<pre class="syntax clojure">(run (fn [_] {:status 200 :body "hi!"}))</pre>

To stop the handler, do this:

<pre class="syntax clojure">(stop)</pre>

Which, of course, is equivalent to this:

<pre class="syntax clojure">(stop :host "localhost" :port 8080 :path "/")</pre>

Or, if you prefer an explicit map to kwargs, this:

<pre class="syntax clojure">(stop {:host "localhost" :port 8080 :path "/"})</pre>

Alternatively, you can save run's return value and pass it to stop
when your application shuts down.

<pre class="syntax clojure">(def server (run {:port 4242 :path "/hello"} app))
...
(stop server)
</pre>

That's pretty much all there is to it.

You don't even really need to stop your handlers if you're content to
just let the JVM exit, but it can be handy at a REPL.

### Advanced Usage

The `run` function returns a map that includes the options passed to
it, so you can thread `run` calls together, useful when your
application runs multiple handlers. For example,

<pre class="syntax clojure">(def everything (-> (run hello)
                  (assoc :path "/howdy")
                  (->> (run howdy))
                  (merge {:path "/" :port 8081})
                  (->> (run ola))))
</pre>

The above actually creates two Undertow web server instances: one
serving requests for the `hello` and `howdy` handlers on port 8080,
and one serving `ola` responses on port 8081.

You can stop all three apps (and shutdown the two web servers) like
so:

<pre class="syntax clojure">(stop everything)</pre>

Alternatively, you could stop only the `ola` app like so:

<pre class="syntax clojure">(stop {:path "/" :port 8081})</pre>

You could even omit `:path` since "/" is the default. And because ola
was the only app running on the web server listening on port 8081, it
will be shutdown automatically.

### Handler Types

Though the handlers you run will typically be Ring functions, you can
also pass any valid implementation of `javax.servlet.Servlet` or
`io.undertow.server.HttpHandler`. For an example of the former, here's
a very simple [Pedestal] service running on Immutant:

<pre class="syntax clojure">(ns testing.hello.service
  (:require [io.pedestal.service.http :as http]
            [io.pedestal.service.http.route.definition :refer [defroutes]]
            [ring.util.response :refer [response]]
            [immutant.web :refer [run]]))

(defn home-page [request] (response "Hello World!"))
(defroutes routes [[["/" {:get home-page}]]])
(def service {::http/routes routes})

(defn start [options]
  (run (::http/servlet (http/create-servlet service)) options))
</pre>

### Development Mode

The `run-dmc` macro resulted from a desire to provide a no-fuss way to
enjoy all the benefits of REPL-based development. Before calling
`run`, `run-dmc` will first ensure that your Ring handler is
var-quoted and wrapped in the `reload` and `stacktrace` middleware
from the `ring-devel` library (which should be included among your
`[:profiles :dev :dependencies]` in `project.clj`). It'll then open
your app in a browser.

Both `run` and `run-dmc` accept the same options. You can even mix
them within a single threaded call.

## The Websocket API

Also included in the `org.immutant/web` library is the
[immutant.websocket] namespace, which includes a `Channel` protocol
and the `create-handler` function. It accepts a map of callback
functions, invoked asynchronously during the lifecycle of a websocket.
The valid websocket event keywords and their corresponding callback
signatures are as follows:

<pre class="syntax clojure">  :on-message (fn [channel message])
  :on-open    (fn [channel])
  :on-close   (fn [channel {:keys [code reason]}])
  :on-error   (fn [channel throwable])
  :fallback   (fn [request] (response ...))
</pre>

To create your websocket endpoint, pass the result from
`create-handler` to `immutant.web/run`. Here's an example that
asynchronously returns the upper-cased equivalent of whatever message
it receives:

<pre class="syntax clojure">(ns whatever
  (:require [immutant.web :as web]
            [immutant.websocket :as ws]
            [clojure.string :refer [upper-case]]))

(defn create-websocket []
  (web/run {:path "/websocket"}
    (ws/create-handler {:on-message (fn [c m] (ws/send! c (upper-case m)))})))
</pre>

Another function, `immutant.websocket/create-servlet`, can be used to
create a [JSR 356] Endpoint. The channel passed to the callbacks is an
instance of `javax.websocket.Session`, extended to the
`immutant.websocket.Channel` protocol.

## Try it out!

We'd love to hear some feedback on this stuff. Find us on our
[community] page and join the fun!


[immutant.web]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/lastSuccessfulBuild/artifact/target/apidocs/immutant.web.html
[immutant.websocket]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/lastSuccessfulBuild/artifact/target/apidocs/immutant.websocket.html
[Undertow]: http://undertow.io/
[Ring]: https://github.com/ring-clojure/ring/wiki
[getting started]: /news/2014/04/28/getting-started-with-2x/
[Pedestal]: https://github.com/pedestal/pedestal
[JSR 356]: https://jcp.org/en/jsr/detail?id=356
[community]: http://immutant.org/community/
