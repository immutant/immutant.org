---
title: Deployment
sequence: 1
description: "Covers the creation and deployment of a basic application"
date: 2013-02-01
---

This tutorial covers creating a basic [Ring] web application and deploying 
to an Immutant. If you haven't read the [installation tutorial][installing], 
go do so now, since you'll need Immutant and the lein-immutant plugin 
installed. This tutorial assumes you are on a *nix system.

## Creating an Immutant Clojure application

In our [installation tutorial][installing], we installed the [lein
plugin]. Let's take another look at the tasks it provides:

    ~/immutant $ lein immutant
    undeploy   Undeploys a project from the current Immutant
    new        Creates a new project skeleton initialized for Immutant
    archive    Creates an Immutant archive from a project
    deploy     Deploys a project to the current Immutant
    run        Starts up the current Immutant, displaying its console output
    env        Displays paths to the Immutant that the plugin is currently using
    overlay    Overlays a feature set onto the current Immutant
    init       Adds a sample immutant.init namespace to the current project
    test       Runs a project's tests inside the current Immutant
    version    Prints version info for the current Immutant
    install    Downloads and installs an Immutant version

    Run `lein help immutant $SUBTASK` for subtask details.


In this tutorial we'll cover the `new` and `deploy` tasks. To do so,
we'll build a basic application that demonstrates the current web
features. To get started, let's create an Immutant project:

    ~/immutant $ lein new immutant immutant-demo
    Generating a project called immutant-demo based on the 'immutant' template.
    
The `new` task creates a [Leiningen] project and gives it a sample
Immutant bootstrap namespace (`src/immutant/init.clj`). Alternatively,
you can use the `init` task to initialize a pre-existing [Leiningen]
project:

    ~/immutant $ lein new immutant-demo && cd immutant-demo && lein immutant init

We'll come back to `src/immutant/init.clj` in a sec. Now, let's add a
ring handler to our core namespace:

<pre class="syntax clojure">(ns immutant-demo.core)

(defn ring-handler [request]
  {:status 200
    :headers {"Content-Type" "text/html"}
    :body "Hello from Immutant!" })
</pre>

## Configuring the application for Immutant
    
An application can be bootstrapped when deployed to Immutant in a
number of ways, one of which is the `immutant.init` namespace. It can
be used to configure the Immutant services you want your application
to consume. It provides a single place for you to define all the
components required by your application, and saves you from having to
keep external configuration files in sync (crontabs, message queue
definitions, init scripts, etc). Anything you create within
`src/immutant/init.clj` can instead be created anywhere in your
application, of course - it just provides a convenient place to do so.

The file has example code for configuring web endpoints and messaging
services, but we're just going to deal with web endpoints in this
article. Edit your `src/immutant/init.clj` so it looks like:

<pre class="syntax clojure">(ns immutant.init
  (:use immutant-demo.core)
  (:require [immutant.web :as web]))

(web/start #'ring-handler)
</pre>

We'll come back to what `web/start` is doing after we get the
application running.

## Deploying your application

Before we can start up an Immutant, we need to tell it about our
application. We do that by deploying:

    ~/immutant/immutant-demo $ lein immutant deploy
    Deployed immutant-demo to /Users/tobias/immutant/current/jboss/standalone/deployments/immutant-demo.clj

This writes a *deployment descriptor* to Immutant's deploy directory
which points back to the application's root directory. Now the
Immutant can find your application - so let's fire it up.

## Starting Immutant

To launch an Immutant, use the `lein immutant run` command. This will
start the Immutant's JBoss server, and will run in the foreground
displaying the console log.  You'll see lots of log messages that you
can ignore - the one to look for should be the last message, and
should tell you the app was deployed:

    ~/immutant/immutant-demo $ lein immutant run
    Starting Immutant via /Users/tobias/immutant/current/jboss/bin/standalone.sh
    ...
    (a plethora of log messages deleted)
    ...
    13:04:39,888 INFO  [org.jboss.as.server.controller] (DeploymentScanner-threads - 2) Deployed "immutant-demo.clj"
    
Now, let's verify that our app is really there. Immutant runs on port 8080 by default, so 
let's hit it and see what happens:

    ~ $ curl http://localhost:8080/immutant-demo/
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
  :dependencies [[org.clojure/clojure "1.3.0"]]
  :immutant {:context-path "/"})
</pre>

Now, when your app is deployed the context path will be picked up from
your `project.clj` and any web endpoints your application stands up
will be accessible under that context path.

If you want to set the context path for a particular deployment of a
project instead of globally, you can set the context path in the
deployment descriptor via the `--context-path` option to the deploy
command:

    ~/immutant/immutant-demo $ lein immutant deploy --context-path /

Which brings us back to `web/start`. `web/start` stands up a web
endpoint for you, and takes one or two arguments: an optional
*sub-context path* and a [Ring] handler function. The sub-context path
is relative to the application's context path, so a context path of
"/ham" and a sub-context path of "/" makes the handler function
available at `/ham`, whereas a sub-context path of "/biscuits" makes
the handler function available at `/ham/biscuits`.  If no sub-context
path is provided, it is assumed to be "/". Make sense?

You can register as many web endpoints as you like within an
application - they just each need an application unique sub-context
path. If we add this to our `core.clj`:

<pre class="syntax clojure">(defn another-ring-handler [request]
  {:status 200
   :headers {"Content-Type" "text/html"}
   :body "Pssst! Over here!"})
</pre>

And this to our `immutant.clj`:

<pre class="syntax clojure">(web/start "/biscuits" #'another-ring-handler)</pre>

Then fire an Immutant up again with `lein immutant run`, we can see
they both work:

    ~ $ curl http://localhost:8080
    Hello from Immutant!
    ~ $ curl http://localhost:8080/biscuits
    Pssst! Over here!

`web/start` has a companion function for shutting down a web endpoint:
`web/stop`. It takes an optional sub-context path for the endpoint,
and can be called from anywhere. If no sub-context path is provided,
"/" is assumed.  You aren't required to shut down your endpoints -
Immutant will do that on your behalf when it is shut down or the
application is undeployed.

## Wrapping up

We hope you've enjoyed this quick run-through of deploying a web
application to Immutant. Since Immutant is still in an alpha state,
none of what I said above is set in stone. If anything does change,
We'll edit this tutorial to keep it accurate. We've posted the [demo
application] we've built if you want to download it.

If you have any feedback or questions, [get in touch]! 

[Ring]: https://github.com/ring-clojure/ring
[installing]: ../installation/
[lein plugin]: https://github.com/immutant/lein-immutant/
[Leiningen]: http://leiningen.org/
[demo application]: https://github.com/immutant/immutant-basic-web-demo
[get in touch]: /community







