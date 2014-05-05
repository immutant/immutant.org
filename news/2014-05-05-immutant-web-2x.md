---
title: A Closer Look at Immutant Web in 2x
author: Jim Crossley
layout: news
tags: [ thedeuce, getting-started, tutorial, web ]
---

Our `org.immutant/web` library has changed quite a bit in 2x, both its
API and its foundation: the [Undertow] web server. Among other things,
this gives us
[much better performance](https://github.com/ptaoussanis/clojure-web-server-benchmarks)
(~35% more throughput than v1.1.1) and built-in support for
websockets.

## The API

The [API] for `immutant.web` is small, just two functions and a
convenient macro:

* `run` - runs your handler in a specific environment, responding to
  web requests matching a given host, port, and url path. The handler
  may be either a Ring function, Servlet instance, or Undertow
  HttpHandler.
* `stop` - stops your handler[s]
* `run-dmc` - runs your handler in *Development Mode* (the 'C' is silent)

The following code fragments assume you've read through the
[getting started] post and required the `immutant.web` namespace, e.g.
at a REPL:

<pre class="syntax clojure">(require '[immutant.web :refer :all])</pre>

### Common Usage

First, we'll need a [Ring] handler. Yours is probably fancier, but
this will do:

<pre class="syntax clojure">(defn app [request]
  {:status 200
   :body "Hello world!"})
</pre>

To make the app available at <http://localhost:8080/>, do this:

<pre class="syntax clojure">(run app)</pre>

Which is equivalent to this:

<pre class="syntax clojure">(run {:host "localhost" :port 8080 :path "/"} app)</pre>

The options passed to `run` in its `env` map (its first argument)
determine the URL used to invoke your handler: `http://{host}:{port}{path}`

To replace your `app` handler with another, just call run again with
the same settings, and it'll replace the old handler with the new:

<pre class="syntax clojure">(run (fn [_] {:status 200 :body "hi!"}))</pre>

To stop the handler, do this:

<pre class="syntax clojure">(stop)</pre>

Which, of course, is equivalent to this:

<pre class="syntax clojure">(stop {:host "localhost" :port 8080 :path "/"})</pre>

Alternatively, you can save run's return value and pass it to stop
when your app shuts down.

<pre class="syntax clojure">(def server (run {:port 4242 :path "/hello"} app))
...
(stop server)
</pre>

That's pretty much all there is to it.

You don't even really need to stop your handlers if you're content to
just let the JVM exit, but it can be handy at a REPL.

### Advanced Usage

You'll notice we pass the server options as the first argument, which
is unusual compared to other Ring adapters which take the handler
first and the options last. We chose to do it to support threading run
calls, useful if your application runs multiple handlers. For example,

<pre class="syntax clojure">(-> (run hello)
  (assoc :path "/howdy")
  (run howdy))
  (merge {:path "/" :port 8081})
  (run ola)))
</pre>

This actually creates two Undertow web server instances: one serving
requests for the `hello` and `howdy` handlers on port 8080, and one
serving `ola` responses on port 8081. Consequently, you could stop the
`ola` handler like so:

<pre class="syntax clojure">(stop {:path "/" :port 8081})</pre>

You could even omit `:path` since "/" is the default.

Or, if you assigned the result of the threaded call to say,
`everything`, you could stop both servers in one shot:

<pre class="syntax clojure">(stop everything)</pre>

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

## Websockets

Included in the `org.immutant/web` library is the `immutant.websocket`
namespace.

[immutant.web]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/lastSuccessfulBuild/artifact/target/apidocs/immutant.web.html
[immutant.websocket]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/lastSuccessfulBuild/artifact/target/apidocs/immutant.websocket.html
[Undertow]: http://undertow.io/
[Ring]: https://github.com/ring-clojure/ring/wiki
[getting started]: /news/2014/04/28/getting-started-with-2x/
