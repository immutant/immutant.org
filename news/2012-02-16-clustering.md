---
title: 'Getting Started: Simulated Clustering'
author: Jim Crossley
layout: news
tags: [ clustering, tutorial, getting-started, daemons ]
---

For this installment of our [getting started series][getting-started]
we'll experiment a bit with clustering, one of the primary benefits
provided by the [JBoss AS7][as7] application server, upon which
Immutant is built. AS7 features a brand new way of configuring and
managing clusters called *Domain Mode*, but unfortunately its
documentation is still evolving. If you insist, try [this][intro] or
possibly [this][howto].

We'll save *Domain Mode* with respect to Immutant for a future
post. It's not required to form a cluster, only to more easily manage
them. In this post, we'll reveal a trick to simulate a cluster on your
development box so that you can experiment with Immutant clustering
features, which we should probably enumerate now:

* Automatic load balancing and failover of message consumers
* HTTP session replication
* Fine-grained, dynamic configuration and control via [mod_cluster]
* Efficiently-replicated distributed caching
* Singleton scheduled jobs
* Automatic failover of singleton daemons

## Running an Immutant

As you know, [installing] Immutant is simple:

    $ lein plugin install lein-immutant 0.4.1
    $ lein immutant install

And running an Immutant is, too:

    $ lein immutant run

By passing the `--clustered` option, you configure the Immutant as a
node that will discover other nodes (via multicast, by default) to
form a cluster:

    $ lein immutant run --clustered

From the first line of its output, you can see what that command is
really running:

    $ $JBOSS_HOME/bin/standalone.sh --server-config=standalone-ha.xml

Any options passed to `lein immutant run` are forwarded to
`standalone.sh`, so run the following to see what those are:

    $ lein immutant run --help

## Simulating a Cluster

**TL;DR** 

To run two immutant instances on a single machine...

In one shell, run:

    $ lein immutant run --clustered -Djboss.node.name=one -Djboss.server.data.dir=/tmp/one

In another shell, run:

    $ lein immutant run --clustered -Djboss.node.name=two -Djboss.server.data.dir=/tmp/two -Djboss.socket.binding.port-offset=100

Boom, you're a cluster!

Each cluster node requires a unique name, which is usually derived
from the hostname, but since our Immutants are on the same host, we
set the `jboss.node.name` property uniquely.

Each Immutant will attempt to persist its runtime state to the same
files. Hijinks will ensue. We prevent said hijinks by setting the
`jboss.server.data.dir` property uniquely.

JBoss listens for various types of connections on a few ports. One
obvious solution to the potential conflicts is to bind each Immutant
to a different interface, which we could specify using the `-b`
option. 

But rather than go through a platform-specific example of creating an
IP alias, I'm going to take advantage of another JBoss feature: the
`jboss.socket.binding.port-offset` property will cause each default
port number to be incremented by a specified amount.

So for the second Immutant, I set the offset to 100, resulting in its
HTTP service, for example, listening on 8180 instead of the default
8080, on which the first Immutant is listening.

## Deploy an Application 

With any luck at all, you have two Immutants running locally, both
hungry for an app to deploy, so let's create one.

We've been over how to [deploy] an application before, but this time
we're gonna keep it real simple: create a new directory and add two
files.

First, you'll need a `project.clj`

<pre class="syntax clojure">(defproject example "1.0.0-SNAPSHOT"
  :dependencies [[org.clojure/clojure "1.3.0"]])
</pre>

Next, the Immutant app bootstrap file, `immutant.clj` into which we'll
put all our code for this example.

<pre class="syntax clojure">(ns example.init
  (:require [immutant.messaging :as messaging]
            [immutant.daemons :as daemon])

;; Create a message queue
(messaging/start "/queue/msg")
;; Define a consumer for our queue
(def listener (messaging/listen "/queue/msg" #(println "received:" %)))

;; Controls the state of our daemon
(def done (atom false))

;; Our daemon's start function
(defn start []
  (reset! done false)
  (loop [i 0]
    (Thread/sleep 1000)
    (when-not @done
      (println "sending:" i)
      (messaging/publish "/queue/msg" i)
      (recur (inc i)))))

;; Our daemon's stop function
(defn stop []
  (reset! done true))

;; Register the daemon
(daemon/start "counter" start stop :singleton true)
</pre>

We've defined a message queue, a message listener, and a daemon
service that, once started, publishes messages to the queue every
second. 

Daemons require a name (for referencing it as a JMX MBean), a start
function to be invoked asynchronously, and a stop function that will
be automatically invoked when your app is undeployed, allowing you to
cleanly teardown any resources used by your service. Optionally, you
can declare the service to be a *singleton* which means it will only
be started on one node in your cluster, and should that node crash, it
will be automatically started on another node, essentially giving you
a robust, highly-available service.

In the same directory that contains your files, run this:

    $ lein immutant deploy

Then watch the output of the shells in which your Immutant servers are
running. You should see the daemon start up on only one of them, but
both should be receiving messages. This is the automatic load
balancing of message consumers.

Now kill the Immutant running the daemon. Watch the other one to see
that the daemon will start there within seconds. There's your
automatic failover. Restart the killed Immutant to see him start to
receive messages again. It's fun, right? :)

## Whew!

So that's probably enough to show for now. Give it a try, and let us
know if it worked for you the very first time. If it doesn't, please
reach out to us [in the usual ways][community] and we'll be happy to
get you going. Above all, have fun!


[installing]: /news/2011/12/21/installing-redux/
[deploy]: /news/2011/11/08/deploying-an-application/
[community]: http://immutant.org/community/
[as7]: http://www.jboss.org/jbossas
[getting-started]: /news/tags/getting-started/
[howto]: https://docs.jboss.org/author/display/AS71/AS7+Cluster+Howto
[intro]: http://xebee.xebia.in/2011/11/01/all-about-managed-domain-jboss-as7/
[mod_cluster]: http://www.jboss.org/mod_cluster
