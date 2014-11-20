---
title: Immutant 2 (The Deuce) Beta1 Released
author: The Immutant Team
version: 2.0.0-beta1
layout: release
tags: [ releases ]
---

We're as happy as {{something}} to announce *The Deuce's* transition
from "alpha" to "beta": Immutant **2.0.0-beta1**. At this point, we
feel pretty good about the stability of the API, the performance, and
the compatibility with both WildFly 8 and the forthcoming WildFly 9.

We expect a final release shortly after WF 9 is official. We would
appreciate all interested parties to try out this release and submit
whatever issues you find. And again, big thanks to all our early
adopters who provided invaluable feedback on the alpha and incremental
releases.

## What is Immutant?

Immutant is an integrated suite of [Clojure](http://clojure.org)
libraries backed by [Undertow] for web, [HornetQ] for messaging,
[Infinispan] for caching, [Quartz] for scheduling, and [Narayana] for
transactions. Applications built with Immutant can optionally be
deployed to a [WildFly] cluster for enhanced features. Its fundamental
goal is to reduce the inherent
[incidental complexity](http://en.wikipedia.org/wiki/Accidental_complexity)
in real world applications.

## What's changed in this release?

Bug fixes and docs, of course, plus:

* Infinispan provides a robust notifications API, invoking callback
  functions in response to various types of events occurring within a
  cache's lifecycle. Unfortunately, this API is exposed exclusively
  through Java annotations, which can be awkward in more dynamic JVM
  languages like Clojure. So we introduced
  `immutant.caching/add-listener!` as a means to engage the
  notifications API using keywords instead of annotations.
* By default, Immutant's embedded [Undertow] web server dispatches
  requests across a pool of worker threads, but this can adversely
  impact performance for compute-bound handlers. So we introduced a
  `:dispatch?` option for `immutant.web/run` that, when false, avoids
  the context switch by invoking the handler on the IO thread
  accepting the request.
* Configuration of the cookie identifying session data is now
  supported by the `immutant.web.middleware/wrap-session` function.
* Boolean options to all functions should be consistently suffixed
  with `?` now.

For a full list of changes, see the issue list below.

## How to try it

If you're already familiar with Immutant 1.x, you should take a look
at our [migration guide]. It's our attempt at keeping track of what we
changed in the Clojure namespaces.

The guides are another good source of information, along with the
rest of the [apidoc].

For a working example, check out our [Feature Demo] application!

## Get It

There is no longer any "installation" step as there was in 1.x. Simply
add the relevant dependency to your project as shown on [Clojars].

## What's next?

We expect to have a fairly short beta cycle, with a final release once
we ensure that everything works well with the upcoming WildFly 9
release.

## Get In Touch

If you have any questions, issues, or other feedback about Immutant,
you can always find us on [#immutant on freenode](/community/) or
[our mailing lists](/community/mailing_lists).


## Issues resolved in 2.0.0-beta1

<ul>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-399'>IMMUTANT-399</a>] -         Add listeners interface for InfiniSpan caches</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-468'>IMMUTANT-468</a>] -         Records can&#39;t be sent over pipeline when embedded, but work in-container</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-503'>IMMUTANT-503</a>] -         Figure out what we&#39;re missing from our poms that clojars promotion expects</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-504'>IMMUTANT-504</a>] -         :context passed to msg/topic is ignored</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-505'>IMMUTANT-505</a>] -         immutant.wildfly causes wildlfly deploy to fail</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-506'>IMMUTANT-506</a>] -         Set the character encoding correctly for response content</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-507'>IMMUTANT-507</a>] -         Add option to run compute-bound handlers on IO thread</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-508'>IMMUTANT-508</a>] -         immutant.web.middleware/wrap-session misbehaves outside of server context</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-510'>IMMUTANT-510</a>] -         Consider adding more options to immutant.web.middleware/wrap-session</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-511'>IMMUTANT-511</a>] -         Catch errors from browse-url in run-dmc</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-512'>IMMUTANT-512</a>] -         Make the usage of ?-suffixed keywords for boolean options consistent</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-513'>IMMUTANT-513</a>] -         add section about context modes to messaging guide</li>
</ul>

[Clojars]: https://clojars.org/org.immutant/immutant
[apidoc]: /documentation/2.0.0-beta1/apidoc/
[migration guide]: /documentation/2.0.0-beta1/apidoc/guide-migration.html
[messaging guide]: /documentation/2.0.0-beta1/apidoc/guide-messaging.html
[WildFly]: http://wildfly.org/
[Feature Demo]: https://github.com/immutant/feature-demo
[Infinispan]: http://infinispan.org
[HornetQ]: http://hornetq.org
[Undertow]: http://undertow.io
[Quartz]: http://quartz-scheduler.org/
[current issues]: https://issues.jboss.org/browse/IMMUTANT
[IMMUTANT-497]: https://issues.jboss.org/browse/IMMUTANT-497
[Narayana]: http://www.jboss.org/narayana
[Datomic]: http://www.datomic.com/
[lein-immutant]: https://github.com/immutant/lein-immutant/
