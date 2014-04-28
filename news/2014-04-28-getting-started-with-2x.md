---
title: Getting Started With Immutant 2
author: The Immutant Team
layout: news
tags: [ thedeuce, getting-started, tutorial ]
---

We're [hard at work](http://i.imgur.com/cSSB8Dx.jpg) on
[Immutant 2.0][the-deuce], and have a ways to go before we reach
feature parity with 1.x. But if you are interested in playing with
what we have now, then this article is for you!

## Getting Immutant

Our CI server publishes an [incremental release][builds] for each
successful build. In order to use an incremental build, you'll need to
add a repository and dependencies to your `project.clj`. Currently,
only our `scheduling` and `web` artifacts contain implementations, so
let's add those:

<pre class="syntax clojure">(defproject some-project "1.2.3"
  ...
  :dependencies [...
                 [org.immutant/scheduling "2.x.incremental.BUILD_NUM"]
                 [org.immutant/web        "2.x.incremental.BUILD_NUM"]]
  :repositories [["Immutant 2.x incremental builds"
                  "http://downloads.immutant.org/incremental/"]])
</pre>

replacing `BUILD_NUM` with the build number for the version you want
to use. You can get the build number from our [builds] page - the
latest build number is 57 as of this article.

*Note:* We're bringing in the artifacts piecemeal above, but we also provide
an aggregate artifact that brings in all of the Immutant dependencies
in one shot if you'd rather use that: `org.immutant/immutant`.

That's it! If you are used to Immutant 1.x, you'll notice that there
is no download or install step - Immutant 2 is usable as a set of
libraries that you consume just like any other Clojure library.

## What's in those artifacts?

Along with the artifacts, each CI build publishes the API docs for all
of the Immutant namespaces. You can see the docs for
[a specific build][api] (build #57 in this case), or the
[latest build][latest-api].

If you start playing with any of that API, be aware that it is
currently in a pre-alpha state, and may change dramatically at any
time.

## What's next?

We plan on publishing articles in the near future focusing on using
the web and scheduling namespaces, followed by articles on websockets,
messaging, and caching as soon as we get those implementations off of
the ground. We'll also cover using those same namespaces within a
[WildFly] container, taking advantage of the clustering features the
container provides.

Once we have most of our namespaces in semi-decent shape, we'll
release our first alpha, probably in mid to late June.

As always, if you have any questions, comments, or other feedback, feel
free to [get in touch](/community).

[builds]: http://immutant.org/builds/2x/
[Undertow]: http://undertow.io/
[the-deuce]: /news/2014/04/02/the-deuce/
[api]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/57/artifact/target/apidocs/index.html
[latest-api]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/lastSuccessfulBuild/artifact/target/apidocs/index.html
[WildFly]: http://wildfly.org/
