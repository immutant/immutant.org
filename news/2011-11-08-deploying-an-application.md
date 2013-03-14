---
title: "Getting Started: Deploying a Web Application"
author: Toby Crawley
layout: news
sequence: 1
tags: [ lein, deploy, tutorial, getting-started, ring ]
---

Welcome back! This article covers creating a basic [Ring] web application and deploying 
to an Immutant. It is the second installment in a 
[series of tutorials on getting started][getting-started] with Immutant. If you haven't
read the [first installment][installing], go do so now, since it covers installation
and setup. This tutorial assumes you are on a *nix system.

## Creating an Immutant Clojure application

In our [previous article][installing], we installed the [lein plugin]. Let's take another
look at the tasks it provides:

    ~/immutant $ lein immutant
    Manage the deployment lifecycle of an Immutant application.

    Subtasks available:
    new        Create a new project skeleton initialized for immutant.
    init       Adds a sample immutant.clj configuration file to an existing project
    deploy     Deploys the current project to the Immutant specified by $IMMUTANT_HOME
    undeploy   Undeploys the current project from the Immutant specified by $IMMUTANT_HOME
    run        Starts up the Immutant specified by $IMMUTANT_HOME, displaying its console output

We talked about `run` last time. This time, we'll cover `new` and `deploy`. To do so, 
we'll build a basic application that demonstrates the current web features. To get
started, let's create an Immutant project:

    ~/immutant $ lein immutant new immutant-demo
    Created new project in: /Users/tobias/immutant/immutant-demo
    Look over project.clj and start coding in immutant_demo/core.clj
    Wrote sample immutant.clj
    
The `new` task creates a [Leiningen] project and gives it a sample Immutant configuration
file (`immutant.clj`). It is equivalent to calling:

    ~/immutant $ lein new immutant-demo && cd immutant-demo && lein immutant init

We'll come back to `immutant.clj` in a sec. Now, let's add a ring handler to our core namespace:

<pre class="syntax clojure">(ns immutant-demo.core)

(defn ring-handler [request]
  {:status 200
    :headers {"Content-Type" "text/html"}
    :body "Hello from Immutant!" })
</pre>

## Configuring the application for Immutant
    
When the Immutant deploys an application, it looks for a file named `immutant.clj` 
at the root and evaluates it if it exists. This file is used to configure the
Immutant services you want your application to consume. It's the single place you 
defines all the components required by your application, and saves you from having to
keep external configuration files in sync (crontabs, message queue definitions, init scripts, etc).

The file has example code for configuring web endpoints and messaging services, but we're
just going to deal with web endpoints in this article. Edit your `immutant.clj` so it 
looks like:

<pre class="syntax clojure">(ns immutant-demo.init
  (:use immutant-demo.core)
  (:require [immutant.messaging :as messaging]
            [immutant.web :as web]))

(web/start "/" #'ring-handler)
</pre>

We'll come back to what `web/start` is doing after we get the application running.

## Deploying your application

Before we can start up an Immutant, we need to tell it about our application. We do that
by deploying (for this to work, you need to have `IMMUTANT_HOME` set - see the 
[previous article][installing] for details):

    ~/immutant/immutant-demo $ lein immutant deploy
    Deployed immutant-demo to /Users/tobias/immutant/current/jboss/standalone/deployments/immutant-demo.clj

This writes a *deployment descriptor* to Immutant's deploy directory which points back
to the application's root directory. Now the Immutant can find your application - so let's 
fire it up.

## Starting Immutant

To launch an Immutant, use the `lein immutant run` command. This will
start the Immutant's JBoss server, and will run in the foreground displaying the console log.
You'll see lots of log messages that you can ignore - the
one to look for should be the last message, and should tell you the app was deployed:

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

Remember our call to `web/start` earlier? Let's talk about what that is doing. To 
do that, however, we need to first talk about *context paths*. The context path is 
the portion of the URL between the hostname and the routes within the application.
It basically tells Immutant which requests to route to a particular application.

An Immutant can host multiple applications at the same time, but each application must 
have a unique context path. If no context path is provided when an application
is deployed, it defaults to one based on the name of the deployment. The 
deployment name is taken from the name of the deployment descriptor, which
in turn is taken from the name of the project given to `defproject` in
`project.clj`. So for our sample app above, the context path defaults to 
`/immutant-demo`. You can override this default by specifying
a `:context-path` within an `:immutant` map in your `project.clj`. Let's
go ahead and do that:

<pre class="syntax clojure">(defproject immutant-demo "1.0.0-SNAPSHOT"
  :description "A basic demo"
  :dependencies [[org.clojure/clojure "1.2.1"]]
  :immutant {:context-path "/"})
</pre>

Now, when you call `lein immutant deploy`, the context path will be picked up
from your `project.clj` and included in the deployment descriptor and any
web endpoints your application stands up will be accessible under that
context path.

Which brings us back to `web/start`. `web/start` stands up a web endpoint
for you, and takes two arguments: a *sub-context path* and a [Ring] handler
function. The sub-context path is relative to the application's context
path, so a context path of "/ham" and a sub-context path of "/" makes
the handler function available at `/ham`, whereas a sub-context path
of "/biscuits" makes the handler function available at `/ham/biscuits`.
Make sense?

You can register as many web endpoints as you like within an application -
they just each need an application unique sub-context path. If we add 
this to our `core.clj`:

<pre class="syntax clojure">(defn another-ring-handler [request]
  {:status 200
   :headers {"Content-Type" "text/html"}
   :body "Pssst! Over here!"})
</pre>

And this to our `immutant.clj`:

<pre class="syntax clojure">(web/start "/biscuits" #'another-ring-handler)</pre>

Redeploy the application to pick up the `:context-path` from `immutant.clj`:

    ~/immutant/immutant-demo $ lein immutant deploy
    Deployed immutant-demo to /Users/tobias/immutant/current/jboss/standalone/deployments/immutant-demo.clj

Then fire an Immutant up again with `lein immutant run`, we can see they
both work:

    ~ $ curl http://localhost:8080
    Hello from Immutant!
    ~ $ curl http://localhost:8080/biscuits
    Pssst! Over here!

`web/start` has a companion function for shutting down a web endpoint:
`web/stop`. It takes the sub-context path for the endpoint, and can
be called from anywhere. You aren't required to shut down your endpoints -
Immutant will do that on your behalf when it is shut down or the application 
is undeployed.

## Wrapping up

I hope you've enjoyed this quick run-through of deploying a web application
to Immutant. Since Immutant is still in a pre-alpha state, none of what I
said above is set in stone. If anything does change, I'll edit this post
to keep it accurate. I've posted the [demo application] we've built if you want
to download it. 

If you have any feedback or questions, [get in touch]! And stay tuned - our next 
tutorial will cover using Immutant's messaging features. 

[Ring]: https://github.com/mmcgrana/ring
[getting-started]: /news/tags/getting-started/
[installing]: /news/2011/11/08/installing/
[lein plugin]: https://github.com/immutant/lein-immutant/
[Leiningen]: https://github.com/technomancy/leiningen
[demo application]: https://github.com/immutant/immutant-basic-web-demo
[get in touch]: /community







