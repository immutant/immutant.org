---
title: Immutant 2 (The Deuce) Final Released
author: The Immutant Team
version: 2.0.0
layout: release
tags: [ releases ]
---

{{this section needs a rewrite}}
We're {{something something}} to
announce *The Deuce's* official release: Immutant **2.0.0**. At this
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

{{stuff}}

For a full list of changes, see the issue list below.

## lein-immutant 2.0.0

We've also moved [lein-immutant] out of beta. The only changes
in 2.0.0 over 2.0.0-beta1 are:

* `lein immutant war` now properly honors a `:main` that points to a
  fully-qualified function in addition to a namespace
* The `test` profile is now active when running `lein immutant test`

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


## Issues resolved in 2.0.0

<ul>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-261'>IMMUTANT-261</a>] -         add cluster tests</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-514'>IMMUTANT-514</a>] -         Notes for improving the migration guide</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-525'>IMMUTANT-525</a>] -         wrap-resource from ring 1.3.2 breaks requests to / in WildFly</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-527'>IMMUTANT-527</a>] -         Session cookie attributes ignored in-container</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-528'>IMMUTANT-528</a>] -         Update docs to cover the whys and hows of destination creation in WF</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-529'>IMMUTANT-529</a>] -         Websocket On-Close is Not Called in All Cases</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-531'>IMMUTANT-531</a>] -         Expose Undertow&#39;s AJP listener</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-532'>IMMUTANT-532</a>] -         HTTP streams close after 30 seconds inside WildFly</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-533'>IMMUTANT-533</a>] -         ring request maps fail when used with clojure.core/find</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-534'>IMMUTANT-534</a>] -         Fix web/run options when they are passed as strings (ala lein run)</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-535'>IMMUTANT-535</a>] -         Completed scheduled jobs never go away</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-536'>IMMUTANT-536</a>] -         WildFly module should transitively depend on tools.nrepl</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-537'>IMMUTANT-537</a>] -         request/response times out when used against multiple remote servers with the same queue name</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-538'>IMMUTANT-538</a>] -         Review guides before release</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-539'>IMMUTANT-539</a>] -         Multiple schedulers with different options cannot be created</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-540'>IMMUTANT-540</a>] -         Expose internal quartz scheduler</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-543'>IMMUTANT-543</a>] -         :on-close callback for web.async channel not firing when client disappears </li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-544'>IMMUTANT-544</a>] -         Throw when immutant.messaging.hornetq/set-address-settings is called in-container</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-545'>IMMUTANT-545</a>] -         Rename msg/context&#39;s :subscription-name back to :client-id</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-546'>IMMUTANT-546</a>] -         Calling immutant.scheduling/stop with no args throws NPE</li>
</ul>

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
[current issues]: https://issues.jboss.org/browse/IMMUTANT
[Narayana]: http://www.jboss.org/narayana
[new API]: /documentation/2.0.0/apidoc/immutant.web.async.html
[Sente]: https://github.com/ptaoussanis/sente
[WebSocket]: http://en.wikipedia.org/wiki/WebSocket
[Server-Sent Events]: http://www.w3.org/TR/eventsource/
[HTTP stream]: http://en.wikipedia.org/wiki/Chunked_transfer_encoding
[immutant.web.middleware]: /documentation/2.0.0/apidoc/immutant.web.middleware.html
[web guide]: /documentation/2.0.0/apidoc/guide-web.html
