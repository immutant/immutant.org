---
title: Deployment
sequence: 1
description: "Covers the creation and deployment of a basic application"
date: 2013-10-10
---

This tutorial covers the creation and deployment of a basic
[Leiningen] app to an Immutant. If you haven't read the
[installation tutorial][installing], go do so now, since you'll need
Immutant and the [lein-immutant plugin][lein plugin] installed. This
tutorial assumes you are on a *nix system.

## Creating an Immutant Clojure application

In our [installation tutorial][installing], we installed the [lein
plugin]. Recall how to list all the subtasks it supports:

    $ lein immutant

In this tutorial we'll cover the basic project layout and the `deploy`
subtask. To do so, we'll build a basic application that demonstrates
some web features. To get started, let's create a Leiningen project:

    $ lein new immutant-demo
    $ cd immutant-demo
    
Now, let's add a ring handler to our core namespace:

<pre class="syntax clojure">(ns immutant-demo.core)

(defn ring-handler [request]
  {:status 200
    :headers {"Content-Type" "text/html"}
    :body "Hello from Immutant!\n" })
</pre>

## Configuring the application for Immutant
    
An application can be bootstrapped when deployed to Immutant in a
number of ways, the simplest of which uses the `:ring` map in
`project.clj`, as described in the [web tutorial]. Another option is
the `immutant.init` namespace. It can be used to configure the
Immutant services you want your application to consume. It provides a
single place for you to define all the components required by your
application, and saves you from having to keep external configuration
files in sync (crontabs, message queue definitions, init scripts,
etc). Anything you create within `src/immutant/init.clj` can instead
be created anywhere in your application, of course - it just provides
a convenient place to do so.

Create a `src/immutant/init.clj` that looks like:

<pre class="syntax clojure">(ns immutant.init
  (:use immutant-demo.core)
  (:require [immutant.web :as web]))

(web/start ring-handler)
</pre>

We'll come back to what `web/start` is doing after we get the
application running.

## Deploying your application

Before we can start up an Immutant, we need to tell it about our
application. We do that by deploying:

    $ lein immutant deploy

This writes a *deployment descriptor* to Immutant's deploy directory
which points back to the application's root directory. Now the
Immutant can find your application - so let's fire it up.

## Starting Immutant

To launch an Immutant, use the `lein immutant run` command. This will
start the Immutant's JBoss server, and will run in the foreground
displaying the console log.  You'll see lots of log messages that you
can ignore - the one to look for should be the last message, and
should tell you the app was deployed:

    $ lein immutant run
    Starting Immutant via /Users/tobias/immutant/current/jboss/bin/standalone.sh
    ...
    (a plethora of log messages deleted)
    ...
    13:04:39,888 INFO  [org.jboss.as.server.controller] (DeploymentScanner-threads - 2) Deployed "immutant-demo.clj"
    
Now, let's verify that our app is really there. Immutant runs on port 8080 by default, so 
let's hit it and see what happens:

    $ curl http://localhost:8080/immutant-demo/
    Hello from Immutant!

Yay!

You can kill the Immutant with Ctrl-C.

## Context Paths

Remember our call to `web/start` earlier? Let's talk about what that
is doing. To do that, however, we need to first talk about *context
paths*. The context path is the portion of the URL between the
hostname and the routes (aka 'path info') within the application. It
basically tells Immutant which requests to route to a particular
application.

An Immutant can host multiple applications at the same time, but each
application must have a unique context path. If no context path is
provided when an application is deployed, it defaults to one based on
the name of the deployment. The deployment name is taken from the name
of the deployment descriptor, which in turn is taken from the name of
the project given to `defproject` in `project.clj` (you can override
this via the `--name` argument to the deploy command).  So for our
sample app above, the context path defaults to `/immutant-demo`. You
can override this default by specifying a `:context-path` within an
`:immutant` map in your `project.clj`. Let's go ahead and do that:

<pre class="syntax clojure">(defproject immutant-demo "1.0.0-SNAPSHOT"
  :description "A basic demo"
  :dependencies [[org.clojure/clojure "1.5.1"]]
  :immutant {:context-path "/"})
</pre>

Now, when your app is deployed the context path will be picked up from
your `project.clj` and any web endpoints your application stands up
will be accessible under that context path.

If you want to set the context path for a particular deployment of a
project instead of globally, you can set the context path in the
deployment descriptor via the `--context-path` option to the deploy
command:

    $ lein immutant deploy --context-path /

Which brings us back to `web/start`. `web/start` stands up a web
endpoint for you, and takes one or two arguments: an optional
*sub-context path* and a [Ring] handler function. The sub-context path
is relative to the application's context path, so a context path of
"/ham" and a sub-context path of "/" makes the handler function
available at `/ham`, whereas a sub-context path of "/biscuits" makes
the handler function available at `/ham/biscuits`.  If no sub-context
path is provided, it is assumed to be "/". Make sense?

You can register as many web endpoints as you like within an
application - each requires an application-unique sub-context path. If
we add this to our `core.clj`:

<pre class="syntax clojure">(defn another-ring-handler [request]
  {:status 200
   :headers {"Content-Type" "text/html"}
   :body "Pssst! Over here!\n"})
</pre>

And this to our `init.clj`:

<pre class="syntax clojure">(web/start "/biscuits" another-ring-handler)</pre>

Then fire an Immutant up again with `lein immutant run`, we can see
they both work:

    $ curl http://localhost:8080
    Hello from Immutant!
    $ curl http://localhost:8080/biscuits
    Pssst! Over here!

`web/start` has a complement function for shutting down a web
endpoint: `web/stop`. It takes an optional sub-context path for the
endpoint, and can be called from anywhere. If no sub-context path is
provided, "/" is assumed. You aren't required to shut down your
endpoints - Immutant will do that on your behalf when it is shut down
or the application is undeployed.

## Wrapping up

We hope you've enjoyed this quick run-through of deploying a web
application to Immutant. We've posted the [demo
application] we've built if you want to download it.

If you have any feedback or questions, [get in touch]! 

[Ring]: https://github.com/ring-clojure/ring
[installing]: ../installation/
[web tutorial]: ../web/
[lein plugin]: https://github.com/immutant/lein-immutant/
[Leiningen]: http://leiningen.org/
[demo application]: https://github.com/immutant/immutant-basic-web-demo
[get in touch]: /community





