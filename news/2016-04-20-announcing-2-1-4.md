---
title: Immutant 2.1.4 Release
author: The Immutant Team
version: 2.1.4
layout: release
tags: [ releases ]
---

We just released Immutant 2.1.4. There are just a couple of small
changes in this release, only one of which is notable: you can now
provide a handler deal with any errors that occur when writing the
ring response. For details, see the [immutant.web/run docstring] and
the example in [IMMUTANT-615].

## What is Immutant?

Immutant is an integrated suite of [Clojure](http://clojure.org)
libraries backed by [Undertow] for web, [HornetQ] for messaging,
[Infinispan] for caching, [Quartz] for scheduling, and [Narayana] for
transactions. Applications built with Immutant can optionally be
deployed to a [WildFly] cluster for enhanced features. Its fundamental
goal is to reduce the inherent
[incidental complexity](http://en.wikipedia.org/wiki/Accidental_complexity)
in real world applications.

## Get In Touch

As always, if you have any questions, issues, or other feedback about
Immutant, you can always find us on
[#immutant on freenode](/community/) or
[our mailing lists](/community/mailing_lists).

## Issues resolved in 2.1.4

<ul>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-613'>IMMUTANT-613</a>] -         Add boot-immutant to WildFly guide
</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-614'>IMMUTANT-614</a>] -         Using a dev war prints out a deprecation warning for app-relative
</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-615'>IMMUTANT-615</a>] -         User can&#39;t catch errors that occur when writing the ring response
</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-616'>IMMUTANT-616</a>] -         Allow adding extensions to undertow&#39;s WebSocket handshake handler
</li>
</ul>

[immutant.web/run docstring]: /documentation/2.1.4/apidoc/immutant.web.html#var-run
[IMMUTANT-615]: https://issues.jboss.org/browse/IMMUTANT-615?focusedCommentId=13194024&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-13194024
[WildFly]: http://wildfly.org/
[Infinispan]: http://infinispan.org
[HornetQ]: http://jboss.org/hornetq/
[Undertow]: http://undertow.io
[Quartz]: http://quartz-scheduler.org/
[Narayana]: http://www.jboss.org/narayana
