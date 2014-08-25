---
title: WildFly
sequence: 5
description: "Deploying your app to WildFly"
date: 2014-08-25
---

One of [the primary goals for The Deuce](/news/2014/04/02/the-deuce/)
was the removal of the old, stanky-ass AS7 fork we lugged around in
Immutant 1.x. This eliminates the need to install and deploy your apps
into a "container" to use the Immutant libraries.

But here's the trade-off: app server containers can simplify the
configuration of features -- e.g. security, monitoring, clustering --
for all the applications deployed to it.

And since each Immutant library automatically benefits in some way
from being clustered, we wanted to *facilitate* app server deployment
but not actually *require* it. Further, we didn't want to require any
tweaking of the stock "vanilla" configuration provided by app server.
This meant using the standard deployment protocol for all Java app
servers: war files.

Theoretically, this implies you could stick the Immutant jars in any
ol' war file and deploy them to any ol' Java app server.
Unfortunately, Immutant's ability to work both outside and inside a
container requires some "glue code" that must be aware of the
container's implementation.

For this reason, Immutant intentionally uses the same services as
[WildFly], the JBoss application server.


[WildFly]: http://wildfly.org

