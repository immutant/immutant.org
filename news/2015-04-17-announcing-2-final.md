---
title: Immutant 2.0.0 Released (FINALLY!)
author: The Immutant Team
version: 2.0.0
layout: release
tags: [ releases ]
---

It was just last April that
[we announced our plans](/news/2014/04/02/the-deuce/) for the second
major release of Immutant, code-named *The Deuce*. And today, a year
later, we're happy to announce the end of our beta cycle and the first
official release of [Immutant 2.0.0][apidoc].

We'd like to send out a big, fat **THANK YOU!** to all our early
adopters who provided invaluable feedback on the alpha, beta, and
incremental releases. It was a total community effort.

From this point forward, we're going to stick to the 3-digit release
naming convention, so no more `-alphaX` or `-betaX` suffixes, just
`{major}.{minor}.{patch}` numbers.

## What is Immutant?

In case you didn't know...

Immutant is an integrated suite of [Clojure](http://clojure.org)
libraries backed by [Undertow] for web, [HornetQ] for messaging,
[Infinispan] for caching, [Quartz] for scheduling, and [Narayana] for
transactions. Applications built with Immutant can optionally be
deployed to a [WildFly] cluster for enhanced features. Its fundamental
goal is to reduce the inherent
[incidental complexity](http://en.wikipedia.org/wiki/Accidental_complexity)
in real world applications.

## What's changed in this release?

The only change in this release since [beta3] is a fix for a [race
condition] in scheduling that generally only manifests on slow
systems.

## How to try it

There is no longer any "installation" step as there was in 1.x. Simply
add the relevant dependency to your project as shown on [Clojars]. See
the [installation guide] for more details.

The guides included in the [apidoc] are the best source of
information, and our [Feature Demo] application provides working code
samples demonstrating all the Immutant namespaces. Its `README`
includes simple instructions for getting started at a REPL or command
line, packaging and various deployment options, e.g. a standalone
"uberjar", a [WildFly] cluster, Heroku and OpenShift.

If you're already familiar with Immutant 1.x, you should probably take
a look at our [migration guide].

## Get In Touch

If you have any questions, issues, or other feedback about Immutant,
you can always find us on [#immutant on freenode](/community/) or
[our mailing lists](/community/mailing_lists).

[Clojars]: https://clojars.org/org.immutant/immutant
[apidoc]: /documentation/2.0.0/apidoc/
[migration guide]: /documentation/2.0.0/apidoc/guide-migration.html
[installation guide]: /documentation/2.0.0/apidoc/guide-installation.html
[WildFly]: http://wildfly.org/
[Feature Demo]: https://github.com/immutant/feature-demo
[Infinispan]: http://infinispan.org
[HornetQ]: http://hornetq.org
[Undertow]: http://undertow.io
[Quartz]: http://quartz-scheduler.org/
[Narayana]: http://www.jboss.org/narayana
[beta3]: /news/2015/04/13/announcing-2-beta3/
[race condition]: https://issues.jboss.org/browse/IMMUTANT-557
