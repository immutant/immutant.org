---
title: Survey, etc
author: Jim Crossley
layout: news
tags: [ web, survey, luminus ]
---

Just a few quick notes on recent Immutant happenings...

### Survey

Yesterday we published a [short survey](http://t.co/EmWguwQvXh) to
help us gauge how folks have been using Immutant. Please take a few
moments to complete it if you haven't already.

### Luminus

The [Luminus](http://www.luminusweb.net/) web toolkit now includes an
Immutant [profile](http://www.luminusweb.net/docs/profiles.md) in its
Leiningen project template, so you can now do this:

    $ lein new luminus yourapp +immutant
    $ cd yourapp
    $ lein run -dev

That `-dev` option is triggering the use of
[immutant.web/run-dmc](http://immutant.org/documentation/current/apidoc/immutant.web.html#var-run-dmc)
instead of
[immutant.web/run](http://immutant.org/documentation/current/apidoc/immutant.web.html#var-run)
so it should plop you in your browser with code-reloading enabled. You
can pass most of the other `run` options on the command line as well,
e.g.

    $ lein run port 3000

### Beta2 bugs

In our last release,
[2.0.0-beta2](/news/2015/02/09/announcing-2-beta2/), we updated our
dependency on the excellent
[potemkin](https://github.com/ztellman/potemkin) library to
version 0.3.11. Unfortunately, that exposed
[a bug](https://issues.jboss.org/browse/IMMUTANT-533) whenever
`clojure.core/find` was used on our Ring request map. Fortunately, it
was already fixed in potemkin's HEAD, and Zach was kind enough to
release 0.3.12. We've bumped up to that in our
[incrementals](http://immutant.org/builds/2x/) and hence our next
release.

We've also fixed a
[thing](https://issues.jboss.org/browse/IMMUTANT-532) or
[two](https://issues.jboss.org/browse/IMMUTANT-529) to improve async
support when running inside WildFly.

### Plans

We're still hoping to release 2.0.0-Final within a month or so. Now
would be a great time to kick the tires on beta2 or the latest
incremental to ensure it's solid when we do!
