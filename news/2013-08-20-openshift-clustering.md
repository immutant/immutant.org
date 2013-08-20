---
title: 'Clustering Immutants on OpenShift'
author: Jim Crossley
layout: news
tags: [ openshift, tutorial, clustering, messaging, caching, daemons, scheduled-jobs, ring ]
---

Lately I've been spending a lot of time on [OpenShift], building and
testing a [cartridge] for Immutant that will properly form a cluster
across multiple OpenShift [gears]. In this post, I'll go through the steps
of deploying a simple application that demonstrates all of the
Immutant clustering features running on the three small gears you get
for free on OpenShift.

Here are the features we'll be demonstrating:

- Load-balanced message distribution with automatic peer discovery
- Replicated caching
- Highly-Available, long-running daemons
- HA scheduled jobs
- Web load balancing and session replication

If you haven't already, go [set up an OpenShift account] and update
your `rhc` gem to the latest version. I used 1.12.4 for this article.
Below you'll see references to *$namespace* -- this corresponds to
your OpenShift domain name, set by running `rhc setup`.

## Create a scaled OpenShift app

The Immutant cartridge is available here:
<https://github.com/immutant/openshift-immutant-cart>. As described in
its README, we create our app using the following command:

    rhc app-create -s demo https://raw.github.com/immutant/openshift-immutant-cart/master/metadata/manifest.yml

We're calling our app *demo* and we're passing the `-s` option to
make our app scalable. Notice that we're passing a raw URL to the
cartridge's `manifest.yml`.

Small gears are pretty slow, but when `app-create` finally completes,
you'll have a bare-bones, standard Leiningen application beneath the
`demo/` directory. At this point, you might tail your app's logs or
ssh into your gear:

    rhc tail demo
    rhc ssh demo

The critical log file for Immutant on OpenShift is
`immutant/logs/server.log`. Monitor this file until you eventually see
the line, *Deployed "your-clojure-application.clj"*. Then point a
browser at <http://demo-$namespace.rhcloud.com> to see a simple
welcome page.

Now we'll put some meat on our bare-bones app!

## Push Me, Pull You 

Typically, you will add the remote git repository for your real
application to the local OpenShift repository you just created. We're
going to use <https://github.com/immutant/cluster-demo> as our "real"
application.

    git remote add upstream -m master git@github.com:immutant/cluster-demo.git

Deployment of your app to OpenShift amounts to pulling from your real
repository and pushing to OpenShift's.

    git pull -s recursive -X theirs upstream master
    git push

While waiting for that to complete, run `rhc tail demo` in another
shell to monitor your log. This time, the *Deployed
"your-clojure-application.clj"* message is going to scroll off the
screen as the cluster-demo app starts logging its output. Eventually,
the app should settle into a steady state looking something like this:

<img src="/images/news/demo-log.png"/>

## The cluster-demo app

If you can ignore the inconsistent thread identifiers in the above
output, you'll notice there are exactly four types of messages:
**send**, **recv**, **web**, and **job**. Noting the timestamps in the
left column, a **send** is logged every 5 seconds, as is its
corresponding **recv**, a **web** logged every 2 seconds, and a
**job** every 20 seconds.

The cluster-demo app is comprised of the following:

- A message queue named */queue/msg*
- A distributed cache named *counters*
- A listener for the queue that prints the received message and the
  current contents of the cache
- An HA daemon named *counter* that queues a cached value and
  increments it every 5 seconds
- An HA scheduled job named *ajob* that increments another counter in
  the cache every 20 seconds
- A web request handler mounted at **/** that logs its `:path-info`
  and returns the current values of the two cached counters
- Another request handler mounted at **/count** that increments a
  counter in the user's web session.

All the code (~60 lines) is [contained in a single file].

## Programming is hard, let's build a cluster!

Now we're ready to form a cluster by adding a gear to our app:

    rhc scale-cartridge immutant -a demo 2

Again, this will take a few minutes. If you're still monitoring your
log, you'll eventually see the gears discover each other. You can run
the following to see the state of your gears:

    rhc show-app --gears

This also gives you the SSH URL's for your two gears. Fire up two
shells and ssh into each of your gears using those SSH URL's. Then
tail the log on each:

    tail -f immutant/logs/server.log

When the dust settles, you should see both gears logging **recv**
messages, one getting the even numbers and one getting the odd. This
is your automatic load-balanced message distribution. Note also that
the counters cache logged in the **recv** message is correct on both
gears, even though it's only being updated by one. This is our cache
replication at work.

## Let's break stuff!

And see how robust our cluster is!

### High Availability Daemons and Jobs

Of course, the **send** and **job** log entries should still only
appear on our original gear, because those are our HA singletons. If
that gear crashes, our daemon and job should migrate to the other
gear. While logged into the gear running your singletons, run this:

    immutant/bin/control stop

And watch the other gear's log to verify the daemon and job pick up
right where they left off, fetching their counters from the replicated
cache. That gear should be consuming all the queued messages, too. Now
start the original gear back up:

    immutant/bin/control start

Eventually, it'll start receiving half the messages again.

### Web 

You may be wondering about those **web** entries showing up in both
logs. They are "health check" requests from the [HAProxy] web load
balancer, automatically installed on your primary gear. You can always
check the state of your cluster from HAProxy's perspective by visiting
<http://demo-$namespace.rhcloud.com/haproxy-status>. If you see that
page without intending to, it means something about your app is
broken, so check `immutant/logs/server.log` for errors and make sure
your app responds to a request for the root context, i.e. "/".

Let's try some web stuff. Use curl to hit your app while observing the
logs on both gears:

    curl http://demo-$namespace.rhcloud.com/xxxxxxxxxxxxxxxxxxxx
    curl http://demo-$namespace.rhcloud.com/yyyyyyyyyyyyyyyyyyyy
    curl http://demo-$namespace.rhcloud.com/zzzzzzzzzzzzzzzzzzzz

Use an obnoxious path to distinguish your request from the health
checks. Repeat the command a few times to observe the gears taking
turns responding to your request. Now try it in a browser, and you'll
see the same gear handling your request every time you reload. This is
because HAProxy is setting cookies in the response to enable session
affinity, which your browser is probably sending back. And `curl`
didn't.

Speaking of session affinity, let's break that while we're at it, by
invoking our other web handler, the one that increments a counter in
the user's web session: <http://demo-$namespace.rhcloud.com/count>

You should see the counter increment each time you reload your
browser. (You'll need to give `curl` a cookie store to see it respond
with anything other than "1 times")

Pay attention to which gear is responding to the */count* request. Now
stop that gear like you did before. When you reload your browser, you
should see the other gear return the expected value. This is the
automatic session replication provided by
`immutant.web.session/servlet-store`.

Don't forget to restart that gear.

## The Hat Trick

Hey, OpenShift is giving us 3 free gears, we may as well use 'em all,
right?

    rhc scale-cartridge immutant -a demo 3

When the third one finally comes up, there are a couple of things you
may notice:

- The health checks will disappear from the primary gear as HAProxy
  takes it out of the rotation when 2 or more other gears are
  available. I'm not sure [why].
- Each cache key will only show up in the **recv** log messages on 2
  of the 3 gears. This is because Immutant caches default to
  Infinispan's `:distributed` replication mode in a cluster. This
  enables Infinispan clusters to achieve "linear scalability" as
  entries are copied to a fixed number of cluster nodes (default 2)
  regardless of the cluster size. Distribution uses a consistent
  hashing algorithm to determine which nodes will store a given entry.

## Now what?

Well, that was a lot to cover. I doubt many apps will use all these
features, but I think it's nice to have a free playground on which to
try them out, even with the resources as constrained as they are on a
small gear.

Regardless, I'm pretty happy that Immutant is finally feature-complete
on OpenShift now. :-)

As always, I had a lot of help getting things to this point. There is
a lot of expertise on the OpenShift and JBoss teams, but the "three
B's" deserve special mention: [Ben](https://twitter.com/bbrowning),
[Bela](http://belaban.blogspot.com/), and
[Bill](http://www.billdecoste.net/).

Thanks!

[cartridge]: https://www.openshift.com/developers/technologies
[OpenShift]: http://openshift.com/
[gears]: https://www.openshift.com/products/pricing
[set up an OpenShift account]: https://www.openshift.com/get-started#cli
[contained in a single file]: https://github.com/immutant/cluster-demo/blob/master/src/immutant/init.clj
[HAProxy]: https://www.openshift.com/blogs/how-haproxy-scales-openshift-apps
[why]: https://www.openshift.com/forums/openshift/why-doesnt-haproxy-put-the-local-gear-in-the-rotation
