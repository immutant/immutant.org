---
title: A slimmer, trimmer Immutant
author: Toby Crawley
layout: news
tags: [ slim, distribution ]
---

Immutant just got a lot lighter!

Starting with recent [incremental builds][incremental], we're now
publishing two distributions: *slim* and *full*. We'll also be
producing these two distributions for the 0.9.0 release (out later this
week), and all future releases.

## What's the difference between slim and full?

The *full* distribution is identical to the distributions we published
before this change - they contain the full JBossAS 7 application
server along with the add-ons that make it Immutant. The full
distribution can be used to run JavaEE applications alongside Clojure
applications. 

The *full* distribution currently weighs in at ~133 MB.

The *slim* distribution is a full distribution minus the JBossAS
modules that aren't required for Immutant Clojure applications.  The
only way you'll notice this change, other than a faster install, is if
you currently deploy JavaEE applications to your Immutant. The removed modules
include Hibernate, OSGi, EJB, JSF, JPA, and many other
[TLAs](http://en.wikipedia.org/wiki/Three-letter_acronym). If your
application needs any of those modules (or any of the other
[modules we remove](https://gist.github.com/5041818)), you'll want
to use the full distribution.

The *slim* distribution currently weighs in at ~66 MB.

## How do I get one or the other?

If you are using the [Leiningen Immutant plugin][plugin], a call to `lein
immutant install` will install the *slim* version of the latest
[incremental build][incremental]. To get the *full* distribution, you'll need to
update to [version 0.16.0][0.16.0] or newer of the plugin, and pass the
`--full` option to the install subtask: `lein immutant install
--full`. Installing a [versioned release][release] with the plugin will behave
the same way for 0.9.0 or newer (once 0.9.0 is released).

If you prefer to manually download the zip distributions, you can find
links to them on the [incremental] and [release] pages.

Since the slim distribution is brand new, it may have issues - please
give it a try and [let us know](/community/) if you find any.

[incremental]: /builds/
[release]: /releases/
[plugin]: /install/
[0.16.0]: http://clojars.org/versions/0.16.0
