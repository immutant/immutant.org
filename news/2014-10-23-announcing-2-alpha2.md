---
title: Immutant 2 (The Deuce) Alpha2 Released
author: The Immutant Team
version: 2.0.0-alpha2
layout: release
tags: [ releases ]
---

We're as happy as
[a cat getting vacuumed](https://www.youtube.com/watch?v=mrlkXEDGpIc)
to announce our second alpha release of *The Deuce*, Immutant
**2.0.0-alpha2**.

Big, special thanks to all our early adopters who provided invaluable
feedback on alpha1 and our incremental releases.

## What is Immutant?

Immutant is an integrated suite of [Clojure](http://clojure.org)
libraries backed by [Undertow] for web, [HornetQ] for messaging,
[Infinispan] for caching, [Quartz] for scheduling, and [Narayana] for
transactions. Applications built with Immutant can optionally be
deployed to a [WildFly] cluster for enhanced features. Its fundamental
goal is to reduce the inherent
[incidental complexity](http://en.wikipedia.org/wiki/Accidental_complexity)
in real world applications.

A few highlights of *The Deuce* compared to the previous 1.x series:

* It uses the [Undertow] web server -- it's much faster, with WebSocket support
* The source is licensed under the Apache Software License rather than LPGL
* It's completely functional "embedded" in your app, i.e. no app server required
* It may be deployed to latest [WildFly] for extra clustering features

## What's changed in this release?

* Though not strictly part of the release, we've significantly
  rearranged our documentation. The "tutorials" are now called
  "guides", and we publish them right along with the [apidoc]. This
  gives us a "one-stop doc shop" with better, cross-referenced
  content.
* We've introduced an `org.immutant/transactions` library to provide
  support for XA distributed transactions, a feature we had in
  Immutant 1.x, but only recently made available in The Deuce, both
  within WildFly and out of the container as well. The API is similar,
  with a few minor namespace changes, and all Immutant caches and
  messaging destinations are XA capable.
* We're now exposing flexible SSL configuration options through our
  `immutant.web.undertow` namespace, allowing you to set up an HTTPS
  listener with some valid combination of SSLContext, KeyStore,
  TrustStore, KeyManagers, or TrustManagers.
* We've made a large, breaking change to our messaging API. Namely,
  we've removed the `connection` and `session` abstractions, and
  replaced them with a single one: `context`. This is somewhat
  motivated by our implementation using the new JMS 2.0 api's.
* [Datomic] can now be used with an Immutant application when inside
  of WildFly without having to modify the WildFly configuration or add
  any exclusions. Unfortunately, you still cannot use Datomic with an
  application that uses `org.immutant/messaging` *outside* of WildFly,
  due to conflicts between the HornetQ version we depend on and the
  version Datomic depends on. See [IMMUTANT-497] for more details.
* HornetQ is now configured via standard configuration files instead
  of via static Java code, allowing you to alter that configuration if
  need be. See the [messaging guide] for details.

We've also released a new version of the [lein-immutant] plugin
(2.0.0-alpha2). You'll need to upgrade to that release if you will use
alpha2 of Immutant with WildFly.

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

We expect to release a beta fairly soon, once we ensure that
everything works well with the upcoming WildFly 9 release.

## Get In Touch

If you have any questions, issues, or other feedback about Immutant,
you can always find us on [#immutant on freenode](/community/) or
[our mailing lists](/community/mailing_lists).


## Issues resolved in 2.0.0-alpha2

<ul>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-466'>IMMUTANT-466</a>] -         App using datomic can&#39;t find javax.net.ssl.SSLException class in WildFly</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-467'>IMMUTANT-467</a>] -         Datomic HornetQ Conflicts with WildFly</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-473'>IMMUTANT-473</a>] -         web/run only works at deployment inside wildfly</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-474'>IMMUTANT-474</a>] -         See if we need to bring over any of the shutdown code from 1.x to use inside the container</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-475'>IMMUTANT-475</a>] -         Write tutorial on overriding logging settings in-container</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-477'>IMMUTANT-477</a>] -         Figure out how to get the web-context inside WildFly</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-478'>IMMUTANT-478</a>] -         Consider wrapping scheduled jobs in bound-fn</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-479'>IMMUTANT-479</a>] -         Get XA working in (and possibly out of) container</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-480'>IMMUTANT-480</a>] -         Immutant running out of a container does not handle laptop suspend gracefully</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-481'>IMMUTANT-481</a>] -         Expose way to set the global log level</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-482'>IMMUTANT-482</a>] -         Destinations with leading slashes fail to deploy in WildFly</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-483'>IMMUTANT-483</a>] -         Allow nil :body in ring response</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-484'>IMMUTANT-484</a>] -         app-uri has a trailing slash</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-485'>IMMUTANT-485</a>] -         The wunderboss-core jar file has a logback.xml file packaged inside of it which competes with a locally configured logback.xml</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-487'>IMMUTANT-487</a>] -         Enable explicit control of an embedded web server</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-488'>IMMUTANT-488</a>] -         Provide better SSL support than just through the Undertow.Builder</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-489'>IMMUTANT-489</a>] -         Re-running servlets yields IllegalStateException</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-490'>IMMUTANT-490</a>] -         Don&#39;t register fressian codec by default</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-491'>IMMUTANT-491</a>] -         at-exit handlers can fail if they refer to any wboss components</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-492'>IMMUTANT-492</a>] -         Expose HornetQ broker configuration options</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-493'>IMMUTANT-493</a>] -         Revert back to :host instead of :interface for nrepl options</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-494'>IMMUTANT-494</a>] -         Expose controlling the context mode to listen</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-496'>IMMUTANT-496</a>] -         Expose way to override HornetQ data directories</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-498'>IMMUTANT-498</a>] -         Replace connection and session with a single context abstraction</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-499'>IMMUTANT-499</a>] -         Consider renaming :client-id on context to :subscription-name</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-500'>IMMUTANT-500</a>] -         Throw if listen, queue, or topic is given a non-remote context</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-501'>IMMUTANT-501</a>] -         Running the standalone JAR with default &quot;/&quot; context path requires extra slash for inner routes</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-502'>IMMUTANT-502</a>] -         Rename caching/compare-and-swap! to swap-in!</li>
</ul>


[Clojars]: https://clojars.org/org.immutant/immutant
[apidoc]: /documentation/2.0.0-alpha2/apidoc/
[migration guide]: /documentation/2.0.0-alpha2/apidoc/guide-migration.html
[messaging guide]: /documentation/2.0.0-alpha2/apidoc/guide-messaging.html
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
