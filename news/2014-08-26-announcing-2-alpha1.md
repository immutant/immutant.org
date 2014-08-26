---
title: First Alpha of Immutant 2.x ("The Deuce") Released
author: The Immutant Team
version: 2.0.0-alpha1
layout: release
tags: [ releases ]
---

We're as excited as {{this very excited thing}} to *FINALLY* announce
our first release of *The Deuce*, Immutant **2.0.0-alpha1**.

This represents a significant milestone for us, as we've completely
removed the app server from Immutant. It's just jars now. We've put a
lot of thought into the API and performed enough integration testing
to feel confident putting an alpha out at this time.

## What is Immutant?

Immutant is an integrated suite of [Clojure](http://clojure.org)
libraries backed by [Undertow] for web, [HornetQ] for messaging,
[Infinispan] for caching, and [Quartz] for scheduling. Applications
built with Immutant can optionally be deployed to a [WildFly] cluster
for enhanced features. Its fundamental goal is to reduce the inherent
[incidental complexity](http://en.wikipedia.org/wiki/Accidental_complexity)
in real world applications.

## How to try it

If you're familiar with Immutant 1.x, you should take a look at our...
ahem... for lack of a better term... [migration guide]. It's our
attempt at keeping track of what we changed in the Clojure namespaces.

The [tutorials] are another good source of information, along with the
[apidoc].

For a working example, check out our [Feature Demo] application!

## Get It

There is no longer any "installation" step as there was in 1.x. Simply
add the relevant dependency to your project as shown on [Clojars].

## What's next?

For the first release, we focused on the API and on usage outside of a
container. For the next alpha, we plan on focusing on making
in-container behavior more robust. Take a look at our [current issues]
if you want to follow along.

## Get In Touch

If you have any questions, issues, or other feedback about Immutant,
you can always find us on [#immutant on freenode](/community/) or
[our mailing lists](/community/mailing_lists).


[Clojars]: https://clojars.org/org.immutant/immutant
[tutorials]: /tutorials/
[apidoc]: /documentation/
[migration guide]: https://github.com/immutant/immutant/blob/thedeuce/docs/migration-guide.md
[WildFly]: http://wildfly.org/
[Feature Demo]: https://github.com/immutant/feature-demo
[Infinispan]: http://infinispan.org
[HornetQ]: http://hornetq.org
[Undertow]: http://undertow.io
[Quartz]: http://quartz-scheduler.org/
[current issues]: https://issues.jboss.org/browse/IMMUTANT
