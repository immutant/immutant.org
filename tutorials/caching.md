---
title: Caching
sequence: 4
description: "In-memory memoization using a linearly-scalable data grid"
date: 2014-08-22
---

Immutant caching is provided by the [Infinispan] data grid, the
distributed features of which are available when deployed to a WildFly
or EAP cluster. But even in "local mode", i.e. not in a cluster but
locally embedded within your app, Infinispan caches offer features
such as eviction, expiration, persistence, and transactions that
aren't available in typical [ConcurrentMap] implementations.

This tutorial will explore the [immutant.caching] namespace, which
provides access to Infinispan, whether your app is deployed to a
WildFly/EAP cluster or not. The API has changed quite a bit in "The
Deuce" from 1.x, which we'll point out as we go along.

## Creation and Configuration

Caches are created, started, and referenced using the
`immutant.caching/cache` function. It accepts a number of optional
configuration arguments, but the only required one is a name, since
every cache must be uniquely named. If you pass the name of a cache
that already exists, a reference to the existing cache will be
returned, effectively ignoring any additional config options you might
pass. So two Immutant cache instances with the same name will be
backed by the same Infinispan cache.

If you wish to reconfigure an existing cache, you must stop it first
by calling `immutant.caching/stop`. This is a significant change from
1.x, which included `create`, `lookup`, and `lookup-or-create`
functions, but no `stop`. In 2.x, those have been replaced by `cache` and
`stop`.

Infinispan is a veritable morass of enterprisey configuration.
Immutant tries to strike a convention/configuration balance by
representing the more common options as keywords passed to the `cache`
function, while still supporting the more esoteric config via the
`builder` function and Java interop.

See the [immutant.caching/cache] apidoc for a list of its supported
options, passed as either an explicit map or "kwargs" (keyword
arguments).

## Example Usage

The following examples are taken from the Immutant
[Feature Demo][feature-demo] which you can clone and run locally at a
REPL if you're a "follow along" type.

Caches are inherently mutable. In 1.x, we provided a `Mutable`
protocol, the functions of which merely invoked the corresponding
[ConcurrentMap] methods implemented by the Infinispan caches. In *The
Deuce*, `Mutable` has been removed, as we felt it offered little value
over the simple Java interop Clojure provides anyway.

### Reading

Because they implement `java.util.Map`, Clojure's core functions are
all you need to read data from an Immutant cache.

<pre class="syntax clojure">
  (def bar (immutant.caching/cache "bar"))
  (.putAll bar {:a 1, :b {:c 3, :d 4}})

  ;; Use get to obtain associated values
  (get bar :a)                            ;=> 1
  (get bar :x)                            ;=> nil
  (get bar :x 42)                         ;=> 42

  ;; Symbols look up their value
  (:a bar)                                ;=> 1
  (:x bar 42)                             ;=> 42

  ;; Nested structures work as you would expect
  (get-in bar [:b :c])                    ;=> 3

  ;; Use find to return entries
  (find bar :a)                           ;=> [:a 1]

  ;; Use contains? to check membership
  (contains? bar :a)                      ;=> true
  (contains? bar :x)                      ;=> false
</pre>

### Writing

In addition to Java interop, [immutant.caching/compare-and-swap!] may
be used to cache entries atomically, providing a consistent view of
the cache to callers. Internally, it uses the [ConcurrentMap] methods,
`replace` to swap values with existing entries, and `putIfAbsent` when
the entry doesn't exist.

<pre class="syntax clojure">
  (def foo (cache "foo"))

  (compare-and-swap! foo :a (fnil inc 0))         ;=> 1
  (compare-and-swap! foo :b (constantly "foo"))   ;=> "foo"
  (compare-and-swap! foo :a inc)                  ;=> 2
</pre>

Of course, plain ol' interop works, too:

<pre class="syntax clojure">
  ;; Put an entry in the cache
  (.put foo :a 1)

  ;; Add all the entries in the map to the cache
  (.putAll foo {:b 2, :c 3})

  ;; Put it in only if key is not already present
  (.putIfAbsent foo :b 6)               ;=> 2
  (.putIfAbsent foo :d 4)               ;=> nil

  ;; Put it in only if key is already present
  (.replace foo :e 5)                   ;=> nil
  (.replace foo :b 6)                   ;=> 2

  ;; Replace for specific key and value (compare-and-set)
  (.replace foo :b 2 0)                 ;=> false
  (.replace foo :b 6 0)                 ;=> true
</pre>

### Removing

Of course, cache entries can be explicitly deleted using Java interop,
but they can also be subject to automatic expiration and eviction.

#### Expiration

By default, cached entries never expire, but you can trigger
expiration by passing the `:ttl` (time-to-live) and/or `:idle` options
to the `cache` function. Their units are milliseconds, but can also be
represented as a keyword or a vector of multiplier/keyword pairs, e.g.
`[1 :week, 4 :days, 2 :hours, 30 :minutes, 59 :seconds]`. Both
singular and plural keywords are valid.

If `:ttl` is specified, entries will be automatically deleted after
that amount of time elapses, starting from when the entry was added.
Effectively, this is the entry's "maximum lifespan". If `:idle` is
specified, the entry is deleted after the time elapses, but the
"timer" is reset each time the entry is accessed. If both are
specified, whichever elapses first "wins" and triggers expiration.

It's possible to vary the `:ttl` and `:idle` times among entries in a
single cache using the `with-expiration` function:

<pre class="syntax clojure">
  (def baz (cache "baz", :ttl [5 :minutes], :idle [1 :minute]))
  (.putAll baz {:a 1 :b 2 :c 3})
  (let [c (with-expiration baz :ttl [1 :hour] :idle [20 :minutes])]
    (compare-and-swap! c :a dec)
</pre>

#### Eviction

To avoid memory exhaustion, you can include the `:max-entries` option
to [immutant.caching/cache] as well as the `:eviction` policy to
determine which entries to evict. And if the `:persist` option is set,
evicted entries are not deleted but rather flushed to disk so that the
entries in memory are always a finite subset of those on disk.

The default eviction policy is [:lirs], which is an optimized version
of `:lru` (Least Recently Used).

<pre class="syntax clojure">
  (def baz (cache "baz", :max-entries 3))
  (.putAll baz {:a 1 :b 2 :c 3})
  (:a baz)                              ;=> 1
  (select-keys baz [:b :c])             ;=> {:c 3, :b 2}
  (.put baz :d 4)
  (:a baz)                              ;=> nil
</pre>

### Encoding

### Memoizing

## Clustering


[ConcurrentMap]: http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/ConcurrentMap.html
[Infinispan]: http://infinispan.org
[immutant.caching]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/lastSuccessfulBuild/artifact/target/apidocs/immutant.caching.html
[immutant.caching/cache]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/lastSuccessfulBuild/artifact/target/apidocs/immutant.caching.html#var-cache
[immutant.caching/compare-and-swap!]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/lastSuccessfulBuild/artifact/target/apidocs/immutant.caching.html#var-compare-and-swap.21
[feature-demo]: https://github.com/immutant/feature-demo/blob/thedeuce/src/demo/caching.clj
[:lirs]: http://en.wikipedia.org/wiki/LIRS_caching_algorithm
