---
title: A slimmer, sexier Immutant
author: Toby Crawley
layout: news
tags: [ slim, distribution ]
---

Immutant just got a lot lighter!

Starting with recent [incremental builds][incremental], we're now
publishing two distributions: *slim* and *full*. We'll also be
producing two distributions for the 0.9.0 release (out later this
week), and all future releases.

## What's the difference between slim and full?

The *full* distribution is identical to the distributions we published
before this change - they contain the full JBossAS 7 application
server along with the add-ons that make it Immutant. The full
distribution can be used to run J2EE applications along side Clojure
applications. It currently weighs in at ~133 MB.

The *slim* distribution is basically a full distribution with all of
the JBossAS modules that aren't needed for Immutant functionality
removed. For Immutant Clojure applications, it should behave
identically to the full distribution, and includes full clustering
support. The only difference is it won't be able to support J2EE
applications. It currently weighs in at ~66 MB.

## How do I get one or the other?

If you are using the [Leiningen Immutant plugin][plugin], a call to `lein
immutant install` will install the *slim* version of the latest
[incremental build][incremental]. To get the *full* distribution, you'll need to
update to [version 0.16.0][0.16.0] or newer of the plugin, and pass the
`--full` option to the install subtask: `lein immutant install
--full`. Installing a [versioned release][release] with the plugin will behave
the same way for 0.9.0 or newer (once 0.9.0 is released, that is).

If you prefer to manuallyd download the zip distributions, you can find
links to them on the [incremental] and [release] pages.

Since the slim distribution is brand new, it may have issues - please
give it a try and [let us know](/community/) if you find any.

[incremental]: /builds/
[release]: /releases/
[plugin]: /install/
[0.16.0]: http://clojars.org/versions/0.16.0
