---
title: Immutant 1.0.0.beta2 Released
author: The Immutant Team
version: 1.0.0.beta2
layout: release
tags: [ releases ]
---

[Fressian codec]: https://github.com/vitalreactor/immutant-fressian
[fntest]: https://github.com/immutant/fntest
[lein-immutant]: https://github.com/immutant/lein-immutant

We're as proud as
[this kid's](http://www.youtube.com/watch?v=CQoE4bnpBCk) parents to
release our second beta. We fixed a few bugs and added a few minor
features, but most changes were external to Immutant proper. As
always, view our road map
[here](https://issues.jboss.org/browse/IMMUTANT).

## What is Immutant?

Immutant is an application server for [Clojure](http://clojure.org).
It's an integrated platform built on
[JBoss AS7](http://www.jboss.org/as7) that aims to reduce the inherent
[incidental complexity](http://en.wikipedia.org/wiki/Accidental_complexity)
in real world applications.

## What's in this release?

* Our slim build is even slimmer now (44mb - beta1 was 68mb)!
* You can now make message listeners non-transactional by passing `:xa
  false` to `immutant.messaging/listen`. This may interest you if your
  handlers take longer than a minute or so and you don't require
  rollbacks if your handler tosses an exception.
* We now allow messages and cache contents to be encoded to byte
  arrays, mostly to support Ian Eslick's new [Fressian codec].

See the complete list of changes below.

## A new plugin release

We've also released a new [lein-immutant] plugin, primarily to show off
a
[nice contribution](https://github.com/immutant/fntest/commits?author=pjlegato)
to our [fntest] library from Paul Legato: the `test` task of the
plugin will now test any [Midje](https://github.com/marick/Midje)
facts it finds in your project.

We had intended to synchronize the versions of Immutant and
lein-immutant, releasing both as *beta2* today, but we discovered a
bug soon after releasing the plugin and had to bump it to *beta3*.

So be sure and update your `~/.lein/profiles.clj` with
`[lein-immutant "1.0.0.beta3"]`.

## Get It

The simplest way to install or upgrade to 1.0.0.beta2 is via our
[Leiningen plugin](https://clojars.org/lein-immutant):

    $ lein immutant install 1.0.0.beta2

See our [install page](/install/) for more details. Once you have it
installed, take a look at our [tutorials](/tutorials/).

## Get In Touch

If you have any questions, issues, or other feedback about Immutant,
you can always find us on [#immutant on freenode](/community/) or
[our mailing lists](/community/mailing_lists). 

## Issues resolved in 1.0.0.beta2

<ul>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-229'>IMMUTANT-229</a>] -         Remove dist-bin references in favor of dist-slim, dist-full</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-239'>IMMUTANT-239</a>] -         Remove support for deprecated jobs/schedule signature</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-289'>IMMUTANT-289</a>] -         msg/start throws a CCE if used on a destination defined in xml</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-290'>IMMUTANT-290</a>] -         Switch to real slim build</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-294'>IMMUTANT-294</a>] -         Provide an option to make listeners non-transactional (:xa false)</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-295'>IMMUTANT-295</a>] -         Immutant does not handle development network changes easily</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-296'>IMMUTANT-296</a>] -         Update to core.memoize 0.5.5</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-299'>IMMUTANT-299</a>] -         Update to lein-core 2.2.0</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-301'>IMMUTANT-301</a>] -         Cut a polyglot release before we release</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-302'>IMMUTANT-302</a>] -         Support the caching of byte[]&#39;s</li>
</ul>
