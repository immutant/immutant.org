---
title: Web
sequence: 1.5
description: "Deploying web apps built with popular Clojure libraries"
date: 2014-06-23
---

The `org.immutant/web` library changed quite a bit from Immutant 1.x
to 2.x, both its API and its foundation: the [Undertow] web server.
Among other things, this resulted in
[much better performance](https://github.com/ptaoussanis/clojure-web-server-benchmarks)
(~35% more throughput than v1.1.1) and built-in support for
websockets.

## The Web API

The API for [immutant.web] is small, just two functions and a
convenient macro:

* `run` - runs your handler in a specific environment, responding to
  web requests matching a given host, port, path and virtual host. The
  handler may be either a Ring function, Servlet instance, or Undertow
  HttpHandler.
* `run-dmc` - runs your handler in *Development Mode* (the 'C' is silent)
* `stop` - stops your handler[s]

If you haven't already, you should read through the [installation]
tutorial and require the `immutant.web` namespace at a REPL to follow
along:

<pre class="syntax clojure">(require '[immutant.web :refer :all])</pre>

### Common Usage

First, you'll need a [Ring] handler. If you generated your app using a
template from [Compojure], [Luminus], [Caribou] or some other
Ring-based library, yours will be associated with the `:handler` key
of your `:ring` map in your `project.clj` file. Of course, a far less
fancy handler will suffice:

<pre class="syntax clojure">(defn app [request]
  {:status 200
   :body "Hello world!"})
</pre>

To make the app available at <http://localhost:8080/>, do this:

<pre class="syntax clojure">(run app)</pre>

Which, if we make the default values explicit, is equivalent to this:

<pre class="syntax clojure">(run app {:host "localhost" :port 8080 :path "/"})</pre>

Or, since `run` takes options as either an explicit map or keyword
arguments (kwargs), this:

<pre class="syntax clojure">(run app :host "localhost" :port 8080 :path "/")</pre>

The options passed to `run` determine the URL used to invoke your
handler: `http://{host}:{port}{path}`

To replace your `app` handler with another, just call run again with
the same options, and it'll replace the old handler with the new:

<pre class="syntax clojure">(run (fn [_] {:status 200 :body "hi!"}))</pre>

To stop the handler, do this:

<pre class="syntax clojure">(stop)</pre>

Which is equivalent to this:

<pre class="syntax clojure">(stop {:host "localhost" :port 8080 :path "/"})</pre>

Or, if you prefer kwargs, this:

<pre class="syntax clojure">(stop :host "localhost" :port 8080 :path "/")</pre>

Alternatively, you can save run's return value and pass it to stop to
stop your handler.

<pre class="syntax clojure">(def server (run app {:port 4242 :path "/hello"}))
...
(stop server)
</pre>

Stopping your handlers isn't strictly necessary if you're content to
just let the JVM exit, but it can be handy at a REPL.

### Virtual Hosts

The `:host` option denotes the IP interface to which the web server is
bound, which may not be publicly accessible. You can extend access to
other hosts using the `:virtual-host` option, which takes either a
single hostname or multiple:

<pre class="syntax clojure">(run app :virtual-host "yourapp.com")
(run app :virtual-host ["app.io" "app.us"])</pre>

Multiple applications can run on the same `:host` and `:port` as long
as each has a unique combination of `:virtual-host` and `:path`.

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
from the `ring-devel` library (which must be included among your
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
  (web/run
    (ws/create-handler {:on-message (fn [c m] (ws/send! c (upper-case m)))})
    {:path "/websocket"}))
</pre>

Another function, `immutant.websocket/create-servlet`, can be used to
create a [JSR 356] Endpoint. The channel passed to the callbacks is an
instance of `javax.websocket.Session`, extended to the
`immutant.websocket.Channel` protocol.


[immutant.web]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/lastSuccessfulBuild/artifact/target/apidocs/immutant.web.html
[immutant.websocket]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/lastSuccessfulBuild/artifact/target/apidocs/immutant.websocket.html
[Undertow]: http://undertow.io/
[Ring]: https://github.com/ring-clojure/ring/wiki
[installation]: /tutorials/installation/
[Pedestal]: https://github.com/pedestal/pedestal
[JSR 356]: https://jcp.org/en/jsr/detail?id=356
[Compojure]: https://github.com/weavejester/compojure
[Luminus]: http://www.luminusweb.net/
[Caribou]: http://let-caribou.in/
