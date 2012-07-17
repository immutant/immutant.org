---
title: Caching
sequence: 4
description: "In-memory memoization using a linearly-scalable data grid"
---

In this tutorial, we'll explore some of Immutant's [caching] features.
[JBoss AS7][as7] -- and therefore, Immutant -- comes with the
[Infinispan] data grid baked right in, obviating the need to manage a
separate caching service like Memcached for your applications.

Infinispan is a state-of-the-art, high-speed, low-latency, distributed
data grid. It is capable of efficiently replicating key-value stores
-- essentially souped-up [ConcurrentMap] implementations -- across a
cluster. But it can also serve as a capable in-memory data cache, too:
providing features such as write-through/write-behind persistence,
multiple eviction policies, and transactions.

## Creating a cache

Like most databases and caches, Immutant's `InfinispanCache` is
**mutable**. Infinispan uses many of the same techniques as Clojure
itself, e.g. MVCC, to provide "sane data management", enabling fast
reads of data that may have been put there by another -- possibly
remote -- process.

Caches are defined using the `immutant.cache/cache` function. Its only
required argument is a name. Creating two caches with the same name
means each is backed by the same Infinispan cache.

Options that determine clustering behavior and entry lifespan are
provided as well.

<pre class="syntax clojure">(use '[immutant.cache :only [cache]])

;; Define a cache named 'bob' whose entries will automatically expire
;; if either a) 10 minutes elapses since it was written or b) 1 minute
;; elapses since it was last accessed
(def c (cache "bob :ttl 10, :idle 1, :units :minutes))
</pre>

## Writing to a cache

Immutant caches implement the [immutant.cache/Mutable][mutable-api]
protocol, through which Infinispan's cache manipulation features are
exposed.

Data is inserted into an Immutant cache using one of the `put`
functions of the `Mutable` protocol. Each takes an optional hash of
lifespan-oriented parameters (:ttl :idle :units) that may be used to
override the values specified when the cache was created.

<pre class="syntax clojure">(require '[immutant.cache :as cache])

;;; Put an entry in the cache
(cache/put c :a 1)

;;; Override its time-to-live
(cache/put c :a 1 {:ttl 1, :units :hours})

;;; Add all the entries in the map to the cache
(cache/put-all c {:b 2, :c 3})

;;; Put it in only if key is not already present
(cache/put-if-absent c :b 6)                  ;=> 2
(cache/put-if-absent c :d 4)                  ;=> nil

;;; Put it in only if key is already present
(cache/put-if-present c :e 5)                 ;=> nil
(cache/put-if-present c :b 6)                 ;=> 2

;;; Put it in only if key is there and current matches old
(cache/put-if-replace c :b 2 0)               ;=> false
(cache/put-if-replace c :b 6 0)               ;=> true
(:b c)                                        ;=> 0
</pre>

## Reading from a cache

Data is read from an Immutant cache the same way data is read from any
standard Clojure map, i.e. using core Clojure functions.

<pre class="syntax clojure">
(def c (cache "baz" :seed {:a 1, :b {:c 3, :d 4}}))

;;; Use get to obtain associated values
(get c :a)                              ;=> 1
(get c :x)                              ;=> nil
(get c :x 42)                           ;=> 42

;;; Symbols look up their value
(:a c)                                  ;=> 1
(:x c 42)                               ;=> 42

;;; Nested structures work as you would expect
(get-in c [:b :c])                      ;=> 3

;;; Use find to return entries
(find c :a)                             ;=> [:a 1]

;;; Use contains? to check membership
(contains? c :a)                        ;=> true
(contains? c :x)                        ;=> false
</pre>

## Memoization

Memoization is an optimization technique associating a cache of
calculated values with a potentially expensive function, incurring the
expense only once, with subsequent calls retrieving the result from
the cache. The keys of the cache are the arguments passed to the
function.

Standards for caching and memoization in Clojure are emerging in the
form of [core.cache] and [core.memoize], respectively. Because the
`InfinispanCache` implements `clojure.core.cache/CacheProtocol` it can
act as an underlying implementation for
`clojure.core.memoize/PluggableMemoization`. Immutant includes a
higher-order `memo` function for doing exactly that:

<pre class="syntax clojure">(immutant.cache/memo a-slow-function "a name")</pre>

## An Example

We'll create a simple web app with a single request to which we'll
pass an integer. The request handler will pass that number to a very
slow increment function: it'll sleep for that number of seconds before
returning its increment. For us, this sleepy function represents a
particularly time-consuming operation that will benefit from
memoization.

Of course we'll need a `project.clj`

<pre class="syntax clojure">(defproject example "1.0.0-SNAPSHOT"
  :dependencies [[org.clojure/clojure "1.3.0"]])
</pre>

Next, the Immutant application bootstrap file, `immutant.clj`, into
which we'll put all our code for this example.

<pre class="syntax clojure">(ns example.init
  (:use [ring.util.response]
        [ring.middleware.params])
  (:require [immutant.cache :as cache]
            [immutant.web :as web]))

;; Our slow function
(defn slow-inc [t]
  (Thread/sleep (* t 1000))
  (inc t))

;; Our memoized version of the slow function
(def memoized-inc (cache/memo slow-inc "sleepy"))

;; Our Ring handler
(defn handler [{params :params}]
  (let [t (Integer. (get params "t" 1))]
    (response (str "value=" (memoized-inc t) "\n"))))

;; Start up our web app
(web/start "/" (wrap-params handler))
</pre>

Make sure you have a recent version of Immutant:

    $ lein immutant install

And cd to the directory containing the above two files and deploy your app:

    $ lein immutant deploy
    
Now run an Immutant in one shell:

    $ lein immutant run

In another shell, try:

    $ curl "http://localhost:8080/example/?t=5"

With any luck, that should return 6 after about 5 seconds. Now run it
again and it should return 6 immediately. 

Now fire off a request with `t=20` or so, and wait a few seconds, but
before it completes hit it again with the same `t` value. You'll
notice that the second request will not have to sleep for the full 20
seconds; it returns immediately after the first completes.

Immutant caching really shines in a cluster, taking advantage of the
Infinispan "data grid" features, but the API doesn't change, whether
your app is deployed to a cluster or not.

[caching]: http://immutant.org/builds/LATEST/html-docs/caching.html
[as7]: http://www.jboss.org/jbossas
[Infinispan]: http://infinispan.org
[ConcurrentMap]: http://docs.oracle.com/javase/6/docs/api/java/util/concurrent/ConcurrentMap.html
[core.cache]: https://github.com/clojure/core.cache
[core.memoize]: https://github.com/clojure/core.memoize
[mutable-api]: http://immutant.org/documentation/current/apidoc/immutant.cache-api.html#immutant.cache/Mutable
