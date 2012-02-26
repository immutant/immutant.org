---
title: 'Getting Started: Caching'
author: Jim Crossley
layout: narrow
tags: [ caching, infinispan, clustering, tutorial, getting-started ]
---

For our next [getting started series][getting-started] tutorial, we'll
explore Immutant's built-in caching service.

## Linfinispanity!

Yay, another Jeremy Lin pun! :)

[JBoss AS7][as7] -- and therefore, Immutant -- comes with the
[Infinispan] data grid baked right in, so there's no need to manage a
separate caching service for your application.

## The immutant.cache/InfinispanCache

## Memoization

## An Example

Let's ammend the example from [our clustering tutorial][clustering]
slightly to demonstrate a replicated cache. We'll create a simple web
app with a single request to which we'll pass an integer. The request
handler will pass that number to a very slow increment function: it'll
sleep for that number of seconds before returning its increment. For
us, this sleepy function represents a particularly time-consuming
operation that will benefit from memoization.

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

(defn slow-inc [t]
  (Thread/sleep (* t 1000))
  (inc t))

(def memoized (cache/memo slow-inc "sleepy" :replicated))

(defn handler [{params :params}]
  (let [t (Integer. (get params "t" 1))]
    (response (str "value=" (memoized t) "\n"))))

(web/start "/" (wrap-params handler))
</pre>



[clustering]: /news/2012/02/16/clustering/
[community]: http://immutant.org/community/
[as7]: http://www.jboss.org/jbossas
[getting-started]: /news/tags/getting-started/
[Infinispan]: http://infinispan.org
