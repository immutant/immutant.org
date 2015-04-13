---
title: Immutant 2 (The Deuce) Final Released
author: The Immutant Team
version: 2.0.0
layout: release
tags: [ releases ]
---

We're {{something something}} to
announce *The Deuce's* official release: Immutant **2.0.0**!

We want to thank of our early adopters who provided invaluable
feedback on the alpha, beta, and incremental releases - we couldn't
have done this without you.

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

We have quite a few fixes in this release, as well as changes to a few
things in the API that we wanted to get right before 2.0.0. The
notable API changes are:

* The concurrency for queue [listeners] now defaults to the number of
  cores to provide better messaging throughput out of the box (it was
  1). The default for topic listeners remains at 1.
* The `:subscription-name` option to [immutant.messaging/context] has
  been renamed to `:client-id` to remove confusion with the
  `:subscription-name` option to [immutant.messaging/subscribe]. Both
  are only used for durable topic subscribers.
* [immutant.messaging.pipeline/pipeline] error handlers now get passed
  the decoded message instead of the `Message` object, and there is
  now a [immutant.messaging.pipeline/retry] function to ease
  retrying messages from the error handler.
* You can now set the headers and status of an async HTTP channel
  response when calling [immutant.web.async/send!]. You can also now
  provide any valid Ring body type in addition to `String` and
  `byte[]` to `send!`.
* The `:on-complete` option to `immutant.web.async/send!` has been
  replaced with two separate callback options: `:on-success` and
  `:on-error`.

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
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-360'>IMMUTANT-360</a>] -         Consider defaulting listener :concurrency based on the number of cores</li>
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
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-543'>IMMUTANT-543</a>] -         :on-close callback for web.async channel not firing when client disappears</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-544'>IMMUTANT-544</a>] -         Throw when immutant.messaging.hornetq/set-address-settings is called in-container</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-545'>IMMUTANT-545</a>] -         Rename msg/context&#39;s :subscription-name back to :client-id</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-546'>IMMUTANT-546</a>] -         Calling immutant.scheduling/stop with no args throws NPE</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-547'>IMMUTANT-547</a>] -         Allow setting status and headers from async/send!</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-548'>IMMUTANT-548</a>] -         Transactions don&#39;t work from an uberjar</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-549'>IMMUTANT-549</a>] -         Allow sending ring bodies to channels</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-550'>IMMUTANT-550</a>] -         Replace :on-complete with :on-success &amp; :on-error for async/send!</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-553'>IMMUTANT-553</a>] -         Don&#39;t create a transaction manager at compile time</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-554'>IMMUTANT-554</a>] -         Concurrent ws requests can cause a channel to be used for multiple clients in-container</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-555'>IMMUTANT-555</a>] -         pipeline error-handlers should be passed the decoded mesage</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-556'>IMMUTANT-556</a>] -         pipeline error-handlers should be able to retry a message and still deliver to the caller&#39;s future</li>
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
[listeners]: /documentation/2.0.0/apidoc/immutant.messaging.html#var-listen
[immutant.messaging/context]: /documentation/2.0.0/apidoc/immutant.messaging.html#var-context
[immutant.messaging/subscribe]: /documentation/2.0.0/apidoc/immutant.messaging.html#var-subscribe
[immutant.messaging.pipeline/pipeline]: /documentation/2.0.0/apidoc/immutant.messaging.pipeline.html#var-pipeline
[immutant.messaging.pipeline/retry]: /documentation/2.0.0/apidoc/immutant.messaging.pipeline.html#var-retry
[immutant.web.async/send!]: /documentation/2.0.0/apidoc/immutant.web.async.html#var-send.21
[lein-immutant]: https://github.com/immutant/lein-immutant/
