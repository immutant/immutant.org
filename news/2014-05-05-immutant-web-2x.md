---
title: A Closer Look at Immutant Web in 2x
author: The Immutant Team
layout: news
tags: [ thedeuce, getting-started, tutorial, web ]
---

Our `immutant.web` library has changed quite a bit in 2x, both its API
and its foundation: the [Undertow] web server. Among other things,
this gives us
[much better performance](https://github.com/ptaoussanis/clojure-web-server-benchmarks)
(~35% more throughput than v1.1.1) and built-in support for
websockets.

## The API

The [Web API] is small, just two functions and a convenient macro:

* `run` - runs your handler in a specific environment, responding to
  web requests matching a given host, port, and url path. The handler
  may be either a Ring function, Servlet instance, or Undertow
  HttpHandler.
* `stop` - stops your handler[s]
* `run-dmc` - runs your handler in *Development Mode* (the 'C' is silent)

The following code fragments assume you've read through the
[getting started] post and required the `immutant.web` namespace,
typically at a REPL, i.e.

<pre class="syntax clojure">(require '[immutant.web :refer :all])</pre>

### Common Usage

First, we'll need a [Ring] handler. Yours is probably fancier, but
this will do:

<pre class="syntax clojure">(defn app [request]
  {:status 200
   :body "Hello world!" })
</pre>

To make the app available at <http://localhost:8080/>, do this:

<pre class="syntax clojure">(run app)</pre>

To stop it, do this:

<pre class="syntax clojure">(stop)</pre>

To make it available at <http://some.other.pi:9000/hello>, do this:

<pre class="syntax clojure">(run {:host "some.other.ip" :port 9000 :path "/hello"} app)</pre>

And to stop it:

<pre class="syntax clojure">(stop {:host "some.other.ip" :port 9000 :path "/hello"})</pre>

As an alternative, you can save run's return value and pass it to stop
when your app shuts down.

<pre class="syntax clojure">(def server (run {:port 4242} app))
...
(stop server)
</pre>

### Advanced Usage

You'll notice we pass the server options as the first argument, which
is unusual compared to other Ring adapters which take the handler
first and the options last. We chose to do it to support threading run
calls, useful when an app runs multiple handlers. For example,

<pre class="syntax clojure">(-> (run hello)
  (assoc :path "/howdy")
  (run howdy))
  (merge {:path "/" :port 8081})
  (run ola)))
</pre>

This actually creates two Undertow web server instances: one serving
requests for the hello and howdy handlers on port 8080, and one
serving ola responses on port 8081. Subsequently, you could stop the
ola handler like so:

<pre class="syntax clojure">(stop {:path "/" :port 8081})</pre>

You could even omit `:path` since "/" is the default.

Or, if you assigned the result of the threaded call to say,
`everything`, you could stop both servers in one shot:

<pre class="syntax clojure">(stop everything)</pre>


### Development Mode

## Websockets

Included in the `immutant.web` library is the immutant.websocket
namespace.

[Web API]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/lastSuccessfulBuild/artifact/target/apidocs/immutant.web.html
[Undertow]: http://undertow.io/
[Ring]: https://github.com/ring-clojure/ring/wiki
[getting started]: /news/2014/04/28/getting-started-with-2x/
