---
title: Using Transit with Immutant 2
author: Toby Crawley
layout: news
tags: [ caching, messaging, transit ]
---

Out of the box, Immutant 2 has support for several data serialization
strategies for use with messaging and caching, namely: [EDN],
[Fressian], [JSON], and none (which falls back to Java
serialization). But what if you want to use another strategy? Luckily,
this isn't a closed set - Immutant allows us to add new
strategies. We took advantage of that and have created a separate
project that brings [Transit] support to Immutant -
[immutant-transit].

## What is Transit?

From the [Transit format] page:

> Transit is a format and set of libraries for conveying values
> between applications written in different programming languages.

It's similar in purpose to EDN, but leverages the speed of the
optimized JSON readers that most platforms provide.

## What does immutant-transit offer over using Transit directly?

immutant-transit provides an Immutant [codec] for Transit that allows
for transparent encoding and decoding of Transit data when using
Immutant's [messaging] and [caching] functionality. Without it, you would
need to set up the encode/decode logic yourself.

## Usage

**Note: immutant-transit won't work with Immutant 2.0.0-alpha1 -
 you'll need to use an [incremental build] \(#298 or newer).**

First, we need to add `org.immutant/immutant-transit` to our
application's dependencies:

<pre class="syntax clojure">
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [org.immutant/immutant "2.x.incremental.298"]
                 [org.immutant/immutant-transit "0.2.2"]]
</pre>

If you don't have `com.cognitect/transit-clj` in your dependencies,
immutant-transit will transitively bring in version 0.8.259. We've
tested against 0.8.255 and 0.8.259, so if you're running another
version and are seeing issues, [let us know].

Now, we need to register the Transit codec with Immutant:

<pre class="syntax clojure">
  (ns your.app
    (:require [immutant.codecs.transit :as it]))

  (it/register-transit-codec)
</pre>

This will register a vanilla JSON Transit codec that encodes to a
`byte[]` under the name `:transit` with the content-type
`application/transit+json` (Immutant uses the content-type to identify
the encoding for messages sent via HornetQ).

To use the codec, provide it as the `:encoding` option wherever an
encoding is used:

<pre class="syntax clojure">
  (immutant.messaging/publish some-queue {:a :message} :encoding :transit)

  (def transit-cache (immutant.caching/with-codec some-cache :transit))
  (immutant.caching/compare-and-swap! transit-cache a-key a-function)
</pre>

If you need to change the underlying format that Transit uses, or need
to provide custom read/write handlers, you can pass them as options to
[register-transit-codec]:

<pre class="syntax clojure">
  (it/register-transit-codec
    :type :json-verbose
    :read-handlers my-read-handlers
    :write-handlers my-write-handlers)
</pre>

The content-type will automatically be generated based on the `:type`,
and will be of the form `application/transit+<:type>`.

You can also override the name and content-type:

<pre class="syntax clojure">
  (it/register-transit-codec
    :name :transit-with-my-handlers
    :content-type "application/transit+json+my-stuff"
    :read-handlers my-read-handlers
    :write-handlers my-write-handlers)
</pre>

For more examples, see the [example project].

## Why is this a separate project from Immutant?

Transit's format and implementation are young, and are still in
flux. We're currently developing this as a separate project so we can
make releases independent of Immutant proper that track changes to
Transit. Once Transit matures a bit, we'll likely roll this in to
Immutant itself.

If you are interested in adding a codec of your own, take a look at
the [immutant-transit source] and at the
[immutant.codecs namespace][codec] to see how it's done.

## Get In Touch

If you have any questions, issues, or other feedback about mmutant-transit,
you can always find us on [#immutant on freenode](/community/) or
[our mailing lists](/community/mailing_lists).

[EDN]: https://github.com/edn-format/edn
[Fressian]: https://github.com/clojure/data.fressian
[JSON]: http://json.org/
[Transit]: https://github.com/cognitect/transit-clj
[immutant-transit]: https://github.com/immutant/immutant-transit
[Transit format]: https://github.com/cognitect/transit-format
[codec]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/lastSuccessfulBuild/artifact/target/apidocs/immutant.codecs.html
[messaging]: /tutorials/messaging/
[caching]: /tutorials/caching/
[let us know]: https://github.com/immutant/immutant-transit/issues
[incremental build]: /builds/2x/
[register-transit-codec]: https://github.com/immutant/immutant-transit/blob/0.2.2/src/immutant/codecs/transit.clj#L55
[example project]: https://github.com/immutant/immutant-transit/tree/master/example-app
[immutant-transit source]: https://github.com/immutant/immutant-transit/blob/0.2.2/src/immutant/codecs/transit.clj
