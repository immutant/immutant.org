---
title: 'Installation'
sequence: 0
description: "Using the Immutant libraries in your application"
date: 2014-06-23
---

Installation of Immutant 1.x was atypical of most Clojure libraries,
because that distribution included a forked JBoss AS7 app server. In
Immutant 2.x, the app server is gone, so there is no installation step
for [The Deuce].

You simply declare the libraries as dependencies in your project, the
same way you would any other Clojure library. For example:

<pre class="syntax clojure">(defproject some-project "1.2.3"
  ...
  :dependencies [[org.immutant/web "2.0.0"]
                 [org.immutant/caching "2.0.0"]
                 [org.immutant/messaging "2.0.0"]
                 [org.immutant/scheduling "2.0.0"]])
</pre>

We're bringing in the artifacts piecemeal above, but we also provide
an aggregate that brings them all in transitively:

<pre class="syntax clojure">(defproject some-project "1.2.3"
  ...
  :dependencies [[org.immutant/immutant "2.0.0"]])
</pre>

<div class="notice big">
Immutant 2.0.0 has not been officially released yet, but incremental
builds are publicly available for you to try.
</div>

## Incremental Builds

Our CI server publishes an [incremental release][builds] for each
successful build. In order to use an incremental build, you'll need to
add a repository to your `project.clj`:

<pre class="syntax clojure">(defproject some-project "1.2.3"
  ...
  :dependencies [[org.immutant/immutant "2.x.incremental.{{BUILD_NUMBER}}"]]
  :repositories [["Immutant 2.x incremental builds"
                  "http://downloads.immutant.org/incremental/"]])
</pre>

You should replace **{{BUILD_NUMBER}}** with the actual build number
for the version you want to use. You can obtain this from our [builds]
page.

Along with the artifacts, each CI build publishes
[the API docs][latest-api] for all of the Immutant 2.x namespaces.


[builds]: http://immutant.org/builds/2x/
[latest-api]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/lastSuccessfulBuild/artifact/target/apidocs/index.html
[The Deuce]: /news/2014/04/02/the-deuce/
