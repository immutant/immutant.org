---
title: Immutant 1.0.0.beta1 Released
author: The Immutant Team
version: 1.0.0.beta1
layout: release
tags: [ releases ]
---

<a href="http://www.youtube.com/watch?v=HOX6MiKsqJo"><img src="/images/news/two-as.png" alt="[Did you clean the sink?]" class="alignright" style="width: 40%"/></a>

We're as happy as
[a boy with two A's](http://www.youtube.com/watch?v=HOX6MiKsqJo) to
announce another alpha release of Immutant: version **_1.0.0.beta1_**.
"Another alpha? I thought you guys would be in beta by now!" We hear
you. But when you ignore accomplishments, you rob yourself of some
very satisfying moments. As always, view our road map
[here](https://issues.jboss.org/browse/IMMUTANT).

## What is Immutant?

Immutant is an application server for [Clojure](http://clojure.org).
It's an integrated platform built on
[JBoss AS7](http://www.jboss.org/as7) that aims to reduce the inherent
[incidental complexity](http://en.wikipedia.org/wiki/Accidental_complexity)
in real world applications.

## Where is 1.0.0.Beta1?

We've been saying for a while that the release after 0.9.0 would be
1.0.0.Beta1, and that was our intention until last week. After
reviewing some of the changes going in to this release, we decided
to do at least one more alpha to let you warm up to them. 

These changes include:

* The
  [immutant.messaging/listen](#{api_doc_for_version('1.0.0.beta1','messaging','listen')})
  function is now asynchronous, so you must deref its result to make
  it synchronous. The only reason you might need to do this is when
  publishing to a topic immediately after calling
  `listen`. [<a href='https://issues.jboss.org/browse/IMMUTANT-217'>IMMUTANT-217</a>]
* We've deprecated the `immutant.cache/cache` function, replacing it
  with two functions:
  [create](#{api_doc_for_version('1.0.0.beta1','cache','create')}) (to
  which `cache` is aliased) and
  [lookup](#{api_doc_for_version('1.0.0.beta1','cache','lookup')}). We also
  exposed some eviction-related
  options. [<a href='https://issues.jboss.org/browse/IMMUTANT-263'>IMMUTANT-263</a>]
  [<a href='https://issues.jboss.org/browse/IMMUTANT-265'>IMMUTANT-265</a>]
* The [Pedestal project](http://pedestal.io) inspired us to add the
  [immutant.web/start-servlet](#{api_doc_for_version('1.0.0.beta1','web','start-servlet')})
  function, providing a means to mount any servlet (not just a Ring
  handler) on a web context.
* To match conventions established by
  [ring-server](https://github.com/weavejester/ring-server#usage), we
  renamed the `:reload` option for
  [immutant.web/start](#{api_doc_for_version('1.0.0.beta1','web','start')})
  to `:auto-reload?` and better still -- we fixed it! We also honor
  the `:reload-paths` and `:stacktraces?` options. And since their
  default values are based on whether the `:dev` profile is active,
  things should "just work".
  [<a href='https://issues.jboss.org/browse/IMMUTANT-241'>IMMUTANT-241</a>]
* We've exposed some of the underlying session options. You can now
  control the session timeout via
  [immutant.web.session/set-session-timeout!](#{api_doc_for_version('1.0.0.beta1','web.session','set-session-timeout!')}),
  and control the session cookie name & other attributes via
  [immutant.web.session/set-session-cookie-attributes!](#{api_doc_for_version('1.0.0.beta1','web.session','set-session-cookie-attributes!')}).
  [<a href='https://issues.jboss.org/browse/IMMUTANT-267'>IMMUTANT-267</a>]
* Previously, we only activated the `:dev` profile at deployment, by
  default. Now we activate `:dev`, `:user`, and `:base`. Use
  Leiningen's `with-profile` higher order task to
  override. [<a href='https://issues.jboss.org/browse/IMMUTANT-270'>IMMUTANT-270</a>]

If folks are happy with the changes in this release, we'll roll
out a 1.0.0.Beta1 "soon".

## What else is in this release?

Other notable changes include:

* Singleton at-style jobs now behave properly in a cluster. [<a href='https://issues.jboss.org/browse/IMMUTANT-146'>IMMUTANT-146</a>]
* Immutant will now add any
  [checkout dependencies]([<a href='https://issues.jboss.org/browse/IMMUTANT-257'>IMMUTANT-257</a>])
  to the application's effective
  classpath. [<a href='https://issues.jboss.org/browse/IMMUTANT-257'>IMMUTANT-257</a>]
* When you set the `:nrepl-port` option, we write its value to
  `target/nrepl-port` in your project. This enables you to
  automatically discover the nREPL port when you set `:immutant
  {:nrepl-port 0}` in `~/.lein/profiles.clj`, obviating the need to
  add extra config to all of your projects. Keep an eye out for a blog
  post on this technique
  soon. [<a href='https://issues.jboss.org/browse/IMMUTANT-255'>IMMUTANT-255</a>]
* 1.0.0.beta1 has been tested with and supports Clojure 1.3.0, 1.4.0,
  and 1.5.1, and we've made 1.5.1 the default version for applications
  that don't provide a Clojure dependency. <a href='https://issues.jboss.org/browse/IMMUTANT-246'>IMMUTANT-246</a>]
  
## Get It

The simplest way to install or upgrade to 1.0.0.beta1 is via our
[Leiningen plugin](https://clojars.org/lein-immutant):

    $ lein immutant install 1.0.0.beta1

See our [install page](/install/) for more details. Once you have it
installed, take a look at our [tutorials](/tutorials/).

## Get In Touch

If you have any questions, issues, or other feedback about Immutant,
you can always find us on [#immutant on freenode](/community/) or
[our mailing lists](/community/mailing_lists). 

## Issues resolved in 1.0.0.beta1

<ul>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-82'>IMMUTANT-82</a>] -         Add clustering chapter to docs</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-175'>IMMUTANT-175</a>] -         implement dynapath&#39;s add-classpath-url</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-271'>IMMUTANT-271</a>] -         Evaluate and possibly eliminate reflection in web.session/session-cookie-attributes</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-274'>IMMUTANT-274</a>] -         sign clojars artifacts before releasing</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-276'>IMMUTANT-276</a>] -         publish dists with the type in the dir name (slim/full)</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-277'>IMMUTANT-277</a>] -         Get immutant.xa working with clojure.java.jdbc 0.3.x</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-278'>IMMUTANT-278</a>] -         Add a util function to return the effective classpath of an app</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-279'>IMMUTANT-279</a>] -         Add get-queue function to immutant.messaging</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-281'>IMMUTANT-281</a>] -         Update to nrepl 0.2.3</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-282'>IMMUTANT-282</a>] -         Remove util/if-in-immutant</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-283'>IMMUTANT-283</a>] -         Add convenient keyword aliases and military time assumptions to job/schedule</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-284'>IMMUTANT-284</a>] -         Configure messaging (HornetQ) to cluster via JGroups</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-286'>IMMUTANT-286</a>] -         Add a note about how dynamic jobs behave in a cluster</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-287'>IMMUTANT-287</a>] -         proofread and update the docs</li>
<li>[<a href='https://issues.jboss.org/browse/IMMUTANT-288'>IMMUTANT-288</a>] -         Modify cache/create to support :ttl [1 :second] as well as :ttl 1 :units :seconds</li>
</ul>                
