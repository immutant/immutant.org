---
title: Immutant 2 (The Deuce) Beta2 Released
author: The Immutant Team
version: 2.0.0-beta2
layout: release
tags: [ releases ]
---

We're [just bananas](https://www.youtube.com/watch?v=nTqn72B2Ajk) to
announce *The Deuce's* second beta: Immutant **2.0.0-beta2**. At this
point, we feel pretty good about the stability of the API, the
performance, and the compatibility with both WildFly 8 and the
forthcoming WildFly 9.

We expect a final release before spring (in the Northern
Hemisphere). We would appreciate all interested parties to try out
this release and submit whatever issues you find. And again, big
thanks to all our early adopters who provided invaluable feedback on
the alpha, beta, and incremental releases.

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

The biggest change in this release is a [new API] for communicating
with web clients asynchronously, either via an [HTTP stream], over a
[WebSocket], or using [Server-Sent Events]. As part of this change,
the `immutant.web.websocket` namespace has been removed, but
`wrap-websocket` still exists, and has been moved to
[immutant.web.middleware]. For more details, see the [web guide].

In conjunction with this new API, we've submitted changes to [Sente]
that will allow you to use its next release with Immutant.

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
add the relevant dependency to your project as shown on [Clojars]. See
the [installation guide] for more details.

## Get In Touch

If you have any questions, issues, or other feedback about Immutant,
you can always find us on [#immutant on freenode](/community/) or
[our mailing lists](/community/mailing_lists).


## Issues resolved in 2.0.0-beta2

<ul>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-439'>IMMUTANT-439</a>] -         Provide SSE support in web</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-515'>IMMUTANT-515</a>] -         Add :servlet-name to the options for run to give the servlet a meaningful name</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-517'>IMMUTANT-517</a>] -         Allow undertow-specific options to be passed directly to web/run</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-518'>IMMUTANT-518</a>] -         Error logged for every websocket/send!</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-520'>IMMUTANT-520</a>] -         WunderBoss Options don&#39;t load properly under clojure 1.7.0</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-521'>IMMUTANT-521</a>] -         Add API for async channels</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-524'>IMMUTANT-524</a>] -         immutant.web/run no longer accepts a Var as the handler</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-526'>IMMUTANT-526</a>] -         Improve the docs for messaging/subscribe to clarify subscription-name</li>
</ul>

[Clojars]: https://clojars.org/org.immutant/immutant
[apidoc]: /documentation/2.0.0-beta2/apidoc/
[migration guide]: /documentation/2.0.0-beta2/apidoc/guide-migration.html
[installation guide]: /documentation/2.0.0-beta2/apidoc/guide-installation.html
[WildFly]: http://wildfly.org/
[Feature Demo]: https://github.com/immutant/feature-demo
[Infinispan]: http://infinispan.org
[HornetQ]: http://hornetq.org
[Undertow]: http://undertow.io
[Quartz]: http://quartz-scheduler.org/
[current issues]: https://issues.jboss.org/browse/IMMUTANT
[Narayana]: http://www.jboss.org/narayana
[new API]: /documentation/2.0.0-beta2/apidoc/immutant.web.async.html
[Sente]: https://github.com/ptaoussanis/sente
[WebSocket]: http://en.wikipedia.org/wiki/WebSocket
[Server-Sent Events]: http://www.w3.org/TR/eventsource/
[HTTP stream]: http://en.wikipedia.org/wiki/Chunked_transfer_encoding
[immutant.web.middleware]: /documentation/2.0.0-beta2/apidoc/immutant.web.middleware.html
[web guide]: /documentation/2.0.0-beta2/apidoc/guide-web.html
