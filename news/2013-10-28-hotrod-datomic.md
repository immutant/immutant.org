---
title: Immutant as a Datomic Storage Service
author: Jim Crossley
layout: news
tags: [ datomic, hotrod, overlay, infinispan ]
---

In this post, I'm going to show you how to configure an Immutant
cluster as a [Datomic] storage service and test it with an example
application. 

Datomic prescribes a [unique architecture] in which database concepts
-- [transactions, queries, and storage][overview] -- are separated. It
treats external storage engines much the same way a traditional
database treats a file system. And one of its supported engines is
[Infinispan], which just so happens to be included in Immutant!

But there's a catch. Immutant only provides in-process access to
Infinispan. And the Datomic [transactor][overview] is a standalone
application meant to run in its own process, so it expects to access
Infinispan via a [HotRod] server, which is not provided by Immutant...

### *...until now!*

As of version 1.1.0 of the [lein-immutant] plugin, it's possible to
overlay [the HotRod modules and configuration][hotrod-overlay] onto an
installation of a recent Immutant incremental build.

I need to stress ***incremental build*** here. This effort exposed a bug
in Infinispan 5.3.0, the version included in the official Immutant
1.0.x releases, that prevented the durability of any data written via
HotRod. So we upgraded to Infinispan 6.0, but that's currently only
available in our [incremental builds].

Installing an incremental build is easy. Just pass `LATEST` (or a
specific build number) for the version:

    $ lein immutant install LATEST

## Why?

Before we get started, we should have reasons for doing so.

If you already have some idea of the benefits of either Datomic or
Immutant or Infinispan, the benefits of combining them may be
apparent, but let's be specific:

- **Simpler deployment** There is no external storage service process
  to manage: it's contained within Immutant.
- **Simpler configuration** Because your Datomic peers are colocated
  with their storage service, the connection URI is always the same on
  any node in the cluster: `datomic:inf://localhost:11222/<DB_NAME>`
- **Robust high availability** As we'll see below, once a transactor
  connects to a HotRod peer, it becomes "topology-aware" and remains
  connected as long as there is at least one node in the cluster,
  whether the original peer crashes or not.
- **Linear scalability** Infinispan's [distributed replication] limits
  copies of writes to a fixed number of nodes (default 2) regardless
  of cluster size, so database capacity is increased by increasing the
  size of your cluster. A consistent hashing algorithm is used to
  determine which nodes will store a given entry, and the HotRod
  client is aware of the hash distribution, enabling it to use the
  most appropriate remote server for each operation.

## HotRod

Using version 1.1.0 (or higher) of the [lein-immutant] plugin,
here's how to add HotRod to your Immutant:

    $ lein immutant overlay hotrod

That's it! The next time you run Immutant, you'll have a HotRod
service awaiting connections on port 11222 with a cache named
`datomic` configured for synchronous, distributed replication,
persisting its contents to
`$IMMUTANT_HOME/jboss/standalone/data/infinispan/polyglot/datomic.dat`

## Datomic

Datomic comes in two flavors: [Free and Pro]. Infinispan storage
support is only included in Datomic Pro, so you'll need to
[obtain a license](http://www.datomic.com/get-datomic.html). BTW, much
thanks to [Stuart Halloway] for hooking me up with one to get this
stuff working.

I've been testing successfully with version `0.8.4218`, available
[here](http://downloads.datomic.com/pro.html). Once you download and
unzip it, cd to its directory and install the peer library to your
local Maven repo:

    $ bin/maven-install

This isn't required for Immutant itself, but we'll need it for our
example app described below. Finally, install your license key. Use
the provided sample template for Infinispan:

    $ cp config/samples/inf-transactor-template.properties config/immutant.properties

And update the `license-key` property in `config/immutant.properties`.
That's it! You're ready to run!

In one shell, fire up Immutant:

    $ lein immutant run

And in another shell, fire up the Datomic transactor:

    $ bin/transactor config/immutant.properties

If you don't see any error stack traces in either shell, [yay]!

## Counting on ACID

To demonstrate some features, we need an example app. Here's one:
<https://github.com/jcrossley3/datomic-counter>:

    $ git clone git@github.com:jcrossley3/datomic-counter.git
    $ cd datomic-counter

As its name implies, it counts. But it does this using a pretty cool
Datomic feature: [transaction functions][txfn].

Before we deploy it, let's highlight a few things. First, notice that
we added dependencies in [project.clj] for our storage service and the
Datomic peer library (that we installed above):

<pre class="syntax clojure">  :dependencies [[org.clojure/clojure "1.5.1"]
                 [org.infinispan/infinispan-client-hotrod "6.0.0.CR1"]
                 [com.datomic/datomic-pro "0.8.4218"]]
  :immutant {:init counter.core/start}
</pre>

And we configured an `:init` function to be called when the app
deploys: `start` from the [counter.core] namespace. It has two duties:
1) initialize our Datomic database and b) schedule a job to increment
a counter every couple of seconds.

<pre class="syntax clojure">(defn start
  "Initialize the database and schedule the counter"
  []
  (try
    (db/init)
    (job/schedule "counter" work, :every [2 :seconds], :singleton false)
    (catch Exception e
      (println "Check the transactor, retrying in 10 seconds")
      (future (Thread/sleep 10000) (start)))))</pre>

We log and increment the counter in the `work` function. Note the job
sets `:singleton false` so it'll run on all nodes in a cluster,
introducing the potential for race conditions as multiple processes
attempt to increment a shared counter.

We naively assume any exception is due to the `transactor` not being
around, so we log a warning, wait a bit, and retry. We do that in a
separate thread so as not to lock up the Immutant deployer. Now let's
take a closer look at the `init` function from [counter.db]:

<pre class="syntax clojure">(defn init
  "Create the database, load the schema, initialize counter, and
  define transaction function named :increment"
  []
  (when (d/create-database uri)
    @(d/transact @conn (read-string (slurp (io/resource "schema.dtm"))))
    @(d/transact @conn [{:db/id :counter :value 0}
                        {:db/id (d/tempid :db.part/user)
                         :db/ident :increment
                         :db/fn (d/function
                                 {:lang "clojure"
                                  :params '[db]
                                  :code '(let [v (:value (d/entity db :counter))]
                                           (println "incrementing" v)
                                           [{:db/id :counter
                                             :value (inc v)}])})}])))</pre>

Note that we rely on the return value of [create-database] to ensure
that only one node in our cluster loads
[our very simple schema][schema] and initializes our counter.

The `:increment` entity is an example of a Datomic
[transaction function][txfn]. It runs inside the transactor, which
serializes all writes to the database, and eliminates the potential
for the race conditions mentioned above. Note that the `println`
output should appear in the transactor's stdout.

Go ahead and deploy it:

    $ lein immutant deploy

Monitor the shells in which you started Immutant and the Datomic
transactor to see the expected output once the counting commences.

## Cluster Time!

Now the fun begins. I'm going to assume you don't have a spare server
lying around, virtual or otherwise, but discoverable via multicast, on
which you can install immutant and deploy the app, but if you did,
you'd simply pass the `--clustered` option when you fire up the
Immutants on both hosts:

    $ lein immutant run --clustered

But it's never that easy, is it? ;)

Instead, I'm going to show you how to create a cluster of Immutants on
your laptop using a port offset. First, kill the Immutant and
transactor processes (Ctrl-c) you started earlier, make sure you have
the app deployed, clean the runtime state, and replicate our Immutant
installation:

    $ lein immutant deploy /path/to/datomic-counter
    $ rm -rf ~/.immutant/current/jboss/standalone/data
    $ cp -R ~/.immutant/current/ /tmp/node1
    $ cp -R ~/.immutant/current/ /tmp/node2

We're going to use two system properties to simulate our cluster:

- **jboss.node.name** Every node in a cluster must have a unique
  identifier, which defaults to `hostname`, which will be the same for
  both of our Immutants, so we'll override it on one of them.
- **jboss.socket.binding.port-offset** To avoid port conflicts, all
  socket bindings will be incremented by this value, which defaults to
  0.

In one shell, fire up *node1*:

    $ IMMUTANT_HOME=/tmp/node1 lein immutant run --clustered -Djboss.node.name=node1

And in another shell, fire up *node2*:

    $ IMMUTANT_HOME=/tmp/node2 lein immutant run --clustered -Djboss.socket.binding.port-offset=100

Assuming you have lots of RAM and disk and generous `ulimit` settings,
you can fire up as many of these as you like, e.g.

    $ cp -R ~/.immutant/current/ /tmp/node3
    $ IMMUTANT_HOME=/tmp/node3 lein immutant run --clustered \
      -Djboss.node.name=node3 \
      -Djboss.socket.binding.port-offset=200

At this point, your Immutants should be complaining about the lack of
a running transactor, so go back to your transactor shell and restart
it:

    $ bin/transactor config/immutant.properties

After a few seconds, you should see expected log output from the two
"nodes" and the transactor. 

To see some failover, recall that the transactor is configured to
connect to port `11222`, which is the *node1* Immutant. The *node2*
Immutant with the port offset is listening on port `11322`. Go back to
your *node1* shell and hit Ctrl-c to kill it. Observe that the
transactor doesn't miss a beat because it's already aware of *node2*'s
membership in the cluster. The transactor only needed *node1* up long
enough to bootstrap itself into the cluster. The database remains
consistent as long as there's at least one node present thereafter.

Now restart *node1* and kill the transactor using Ctrl-c. You should
see some errors in the output of the Immutants, but they'll recover
gracefully whenever you restart the transactor, whose output should
pick up right where it left off when you killed it.

## Feedback

It's still early days, obviously, and I can't yet articulate the
trade-offs, but I feel confident enough after my limited testing to
invite others to kick the tires, especially those with more Datomic
expertise than me. I suspect there are opportunities for tuning, and
we need to define some best practices around deployment, maybe come up
with some [Docker] container images, for example.

As always, feel free to reach out in the [usual ways] and feedback us!

[Datomic]: http://www.datomic.com/
[overview]: http://www.datomic.com/overview.html
[unique architecture]: http://docs.datomic.com/architecture.html
[Free and Pro]: http://www.datomic.com/pricing.html
[create-database]: http://docs.datomic.com/clojure/index.html#datomic.api/create-database
[txfn]: http://docs.datomic.com/database-functions.html
[Infinispan]: http://infinispan.org/
[Docker]: https://www.docker.io/
[HotRod]: http://infinispan.org/docs/6.0.x/user_guide/user_guide.html#_server_modules
[hotrod-overlay]: https://github.com/immutant/hotrod-overlay
[incremental builds]: http://immutant.org/builds/
[lein-immutant]: https://github.com/immutant/lein-immutant
[Stuart Halloway]: https://twitter.com/stuarthalloway
[yay]: https://www.youtube.com/watch?v=b4810hS8weQ
[project.clj]: https://github.com/jcrossley3/datomic-counter/blob/master/project.clj
[counter.core]: https://github.com/jcrossley3/datomic-counter/blob/master/src/counter/core.clj
[counter.db]: https://github.com/jcrossley3/datomic-counter/blob/master/src/counter/db.clj
[schema]: https://github.com/jcrossley3/datomic-counter/blob/master/resources/schema.dtm
[distributed replication]: http://infinispan.org/docs/6.0.x/user_guide/user_guide.html#_distribution_mode
[usual ways]: /community
