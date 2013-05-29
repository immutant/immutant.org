---
title: Clustering
sequence: 5
description: "How your apps benefit when Immutants form a cluster"
date: 2013-05-29
---

One of the primary benefits provided by the [JBoss AS7][as7]
application server, upon which Immutant is built, is clustering. The
Immutant libraries are orthogonal to clustering, but each library is
automatically enhanced with certain features inside a cluster:

### immutant.web

In a cluster, HTTP session data is automatically replicated. When
coupled with the JBoss [mod_cluster] load-balancer, this enables
transparent failover and fine-grained, dynamic configuration and
control of your web applications.

### immutant.messaging

[HornetQ] is cluster-aware, so load balancing and failover of message
consumers within a cluster are automatic and require no extra
configuration on your part.

### immutant.cache

[Infinispan] caches adhere to a particular [mode] of operation. In a
non-clustered, standalone Immutant, `:local` is the **only** supported
mode. But when clustered, you have other options.

* `:invalidated` -- This is the default clustered mode. It doesn't
   actually share any data at all, so it's very "bandwidth friendly".
   Whenever data is changed in a cache, other caches in the cluster
   are notified that their copies are now stale and should be evicted
   from memory.
* `:replicated` -- In this mode, entries added to any cache instance
   will be copied to all other cache instances in the cluster, and can
   then be retrieved locally from any instance.  Though simple, it's
   impractical for clusters of any significant size (>10), and its
   capacity is equal to the amount of RAM in its smallest peer.
* `:distributed` -- This mode is what enables Infinispan clusters to
   achieve "linear scalability". Cache entries are copied to a fixed
   number of cluster nodes (default is 2) regardless of the cluster
   size.  Distribution uses a consistent hashing algorithm to
   determine which nodes will store a given entry.

### immutant.jobs

By default, scheduled jobs are *singletons*, but this term only has
relevance in a cluster. It means that your job will only execute on
one node in the cluster, and if it can't, it will failover to the next
available node until successful.

### immutant.daemons

Similar to jobs, long-running services are also *singletons*, by
default. A singleton daemon will only be started on one node in your
cluster, and should that node crash, it will be automatically started
on another node, enabling you to create robust, highly-available
services.

## Forming a cluster

By passing the `--clustered` option when you start Immutant, you
configure it as a node that will automatically discover other nodes
(via multicast, by default) to form a cluster:

    lein immutant run --clustered

It's just that simple.

But it can become complicated in environments where multicast isn't
enabled, e.g. Amazon's EC2. There are alternative configurations
available, of course, but for this tutorial we're going to demonstrate
how to simulate a cluster on a single machine so that you can
experiment with the features listed above.

## Simulating a Cluster

### TL;DR

To run two immutant instances on a single machine, fire up two shells and...

In one shell, run:
    cp -r ~/.immutant/current/ /tmp/node2 
    lein immutant run --clustered

In another shell, run:
    rm -rf /tmp/node2/jboss/standalone/data
    IMMUTANT_HOME=/tmp/node2 lein immutant run --clustered -Djboss.node.name=two -Djboss.socket.binding.port-offset=100

And BAM, you're a cluster!

### TL;DR for Mac users

If you're on a Mac, the above may not work. Try IP aliases instead:
    for i in {1,2}; do sudo ifconfig en1 inet 192.168.6.20${i}/32 alias; done
    lein immutant run --clustered -b 192.168.6.201
    IMMUTANT_HOME=/tmp/node2 lein immutant run --clustered -Djboss.node.name=two -b 192.168.6.202

Note that IP aliases obviate the need for a port offset -- your web
servers will be available at 192.168.6.201:8080 and 192.168.6.202:8080
-- but you still need a unique node name for each instance.

### Details

It is possible to run a test cluster out of one Immutant install, but
you can get strange results if multiple nodes in the cluster share the
same deployments directory. So, we make a copy of the Immutant install
to `/tmp`. The `/` on the end of the `current` path is important -
without it, `cp` will just copy the symbolic link instead of the
directory it points to.

We then have to clear the new node's data directory - the AS caches a
UUID-based node id there, and if we don't clear it, both nodes will
end up with the same id, resulting in some nasty log messages.

Each cluster node requires a unique name, which is usually derived
from the hostname, but since our Immutants are on the same host, we
set the `jboss.node.name` property on our second node to prevent a
conflict.

JBoss listens for various types of connections on a few ports. One
obvious solution to the potential conflicts is to bind each Immutant
to a different interface, which we could specify using the `-b`
option. 

But rather than go through a platform-specific example of creating an
IP alias (unless you're on a Mac, see above), I'm going to take
advantage of another JBoss feature: the
`jboss.socket.binding.port-offset` property will cause each default
port number to be incremented by a specified amount.

So for the second Immutant, I set the offset to 100, resulting in its
HTTP service, for example, listening on 8180 instead of the default
8080, on which the first Immutant is listening.

## Deploy an Application 

With any luck at all, you have two Immutants running locally, both
hungry for an app to deploy, so let's create one.

We've been over how to [deploy] an application before, and we're going
to use what we learned there to creae a simple app:

    lein immutant new cluster-example
    cd cluster-example
    
Next, edit the Immutant application bootstrap file,
`src/immutant/init.clj`, and replace its contents with:


<pre class="syntax clojure">(ns immutant.init
  (:require [immutant.messaging :as messaging]
            [immutant.daemons :as daemon]))

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
(daemon/daemonize "counter" start stop)
</pre>

We've defined a message queue, a message listener, and a daemon
service that, once started, publishes messages to the queue every
second. 

Daemons require a name (for referencing as a JMX MBean), a start
function to be invoked asynchronously, and a stop function that will
be automatically invoked when your app is undeployed, allowing you to
cleanly teardown any resources used by your service. By default, our
daemon is a *singleton*, meaning it will only ever run on one node in
your cluster.

In the `cluster-example` directory, deploy to our first node:

    lein immutant deploy
    
And to our second:

    IMMUTANT_HOME=/tmp/node2 lein immutant deploy
    
Now watch the output of the shells in which your Immutants are
running. You should see the daemon start up on only one of them, but
both should be receiving messages. This is the automatic load
balancing of message consumers.

Now kill the Immutant running the daemon. Watch the other one to see
that the daemon will start there within seconds. There's your
automatic HA service failover. Restart the killed Immutant to see him
start to receive messages again. It's fun, right? :)

## Domain Mode

AS7 features a brand new way of configuring and managing clusters
called *Domain Mode*, but unfortunately its documentation is still
evolving. If you insist, try [this][intro] or possibly [this][howto].

*Domain Mode* is not required for clustering, but it is an option for
easier cluster management. We hope to better document its use with
respect to Immutant in the future.

[deploy]: ../deploying/
[as7]: http://www.jboss.org/jbossas
[howto]: https://docs.jboss.org/author/display/AS71/AS7+Cluster+Howto
[intro]: http://xebee.xebia.in/2011/11/01/all-about-managed-domain-jboss-as7/
[mod_cluster]: http://www.jboss.org/mod_cluster
[Infinispan]: http://infinispan.org
[HornetQ]: http://hornetq.org
[mode]: https://docs.jboss.org/author/display/ISPN/Clustering+modes
