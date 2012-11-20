---
title: Using Noir
sequence: 7
description: "Covers the creation and deployment of a basic Noir application"
date: 2012-11-20
author: Doug Selph
author_url: https://github.com/dougselph
---

This tutorial covers creating a basic [Noir] web application and deploying it 
to an Immutant application server. If you haven't read the [Installation][installing] and 
[Deployment][deployment] tutorials, go do so now, since you'll need Immutant 
and the lein-immutant plugin installed. This tutorial assumes you are on 
a *nix system.

## Creating a Noir application

Make sure you have the [lein noir plugin][lein-noir] installed in your leiningen profile,
and create an application named noirtant:

    ~/ $ lein new noir noirtant
    Generating a lovely new Noir project named noirtant...

You now have a skeleton noir application. Provided you don't currently have Immutant 
running on port 8080, you can start your app under Jetty to verify it is working:

     ~/ $ cd noirtant
     ~/noirtant $ lein run
     Compiling noirtant.server
     Starting server...
     2012-11-16 15:22:40.693:INFO::Logging to STDERR via org.mortbay.log.StdErrLog
     2012-11-16 15:22:40.693:INFO::jetty-6.1.25
     Server started on port [8080].
     You can view the site at http://localhost:8080
     #<Server Server@68acbd3a>
     2012-11-16 15:22:40.734:INFO::Started SocketConnector@0.0.0.0:8080

You can now see your application [here][noirtant]. When you're finished admiring your 
shiny app, stop Jetty with CTRL-c.

## Configure your application to run in immutant

You have a working noir application. Now let's make it work with Immutant.

    ~/noirtant $ lein immutant init
    Wrote sample immutant.clj

Your sample immutant.clj (which will be in the root directory of your noir 
application) will look like this:

<pre class="syntax clojure">(ns .init
  ;(:use .core)
  (:require [immutant.messaging :as messaging]
            [immutant.web :as web]
            [immutant.util :as util]))

;; This file will be loaded when the application is deployed to Immutant, and
;; can be used to start services your app needs. Examples:


;; Web endpoints need a context-path and ring handler function. The context
;; path given here is a sub-path to the global context-path for the app
;; if any.

; (web/start "/" my-ring-handler)
; (web/start "/foo" a-different-ring-handler)

;; To start a Noir app:
; (server/load-views (util/app-relative "src//views"))
; (web/start "/" (server/gen-handler {:mode :dev :ns '}))


;; Messaging allows for starting (and stopping) destinations (queues & topics)
;; and listening for messages on a destination.

; (messaging/start "/queue/a-queue")
; (messaging/listen "/queue/a-queue" #(println "received: " %))
</pre>

There are a few missing bits here, as the immutant plugin for lein doesn't know 
what sort of app you are preparing to deploy. You can simply replace the contents of 
your immutant.clj file with this file:

<pre class="syntax clojure">(ns noirtant.init
  (:require [immutant.messaging :as messaging]
            [immutant.web :as web]
            [immutant.util :as util]
            [noir.server :as server]))

;; This file will be loaded when the application is deployed to Immutant, and
;; can be used to start services your app needs. Examples:

;; To start a Noir app:
(server/load-views (util/app-relative "src/noirtant/views"))
(web/start "/" (server/gen-handler {:mode :dev :ns 'noirtant}))
</pre>

If you are familiar with noir already, the last two lines of your modified immutant.clj 
may raise some questions for you, as they look very similar to lines from your 
noirtant/src/noirtant/server.clj file. Because of the way Immutant initializes your 
application, this is not a problem. 

You can now start immutant and deploy your application:

    ~/noirtant $ lein immutant run
    Starting Immutant via ~/.lein/immutant/current/jboss/bin/standalone.sh
    ... 
    (a plethora of log messages deleted)
    ...
    18:07:58,706 INFO  [org.jboss.as] (Controller Boot Thread) JBAS015961: Http management interface listening on http://127.0.0.1:9990/management
    18:07:58,706 INFO  [org.jboss.as] (Controller Boot Thread) JBAS015951: Admin console listening on http://127.0.0.1:9990
    18:07:58,707 INFO  [org.jboss.as] (Controller Boot Thread) JBAS015874: JBoss AS 7.1.x.incremental.129 "Arges" started in 15449ms - Started 276 of 368 services (91 services are passive or on-demand)
    
Immutant will run in the foreground, so switch to another shell and run:

    ~/noirtant $ lein immutant deploy
    Deployed noirtant to ~/.lein/immutant/current/jboss/standalone/deployments/noirtant.clj

You application can now be accessed [here][noirtant-deployed]. Neat, huh? (Golf claps, 
everyone!) When you've had your fill of playing with noirtant, you can shut down your 
immutant with CTRL-c or undeploy noirtant:

    ~/noirtant $ lein immutant undeploy
    Undeployed noirtant from ~/.lein/immutant/current/jboss/standalone/deployments

## Wrapping up

We hope you've enjoyed this quick run-through of creating and deploying a noir 
web application to Immutant. Now go build your noir application, and enjoy running 
it on Immutant. Thanks to the fine folks on the Immutant team for their constant 
work on improving our experience using Immutant and JBoss.

If you have any feedback or questions, [get in touch]! 

[Noir]: https://github.com/noir-clojure/noir
[installing]: ../installation/
[deployment]: ../deploying/
[lein-noir]: https://github.com/ibdknox/lein-noir
[noirtant]: http://localhost:8080/
[noirtant-deployed]: http://localhost:8080/noirtant
[get in touch]: /community







