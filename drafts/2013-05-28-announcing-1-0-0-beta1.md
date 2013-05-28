---
title: Immutant 1.0.0.beta1 Released
author: The Immutant Team
version: 1.0.0.beta1
tags: [ releases ]
---

We are almost as excited to announce our very first beta release of
Immutant as
[this guy is to see a train](http://www.youtube.com/watch?v=jUBRKyAHoOw).
And like that train, we expect our beta cycle to be short; our plan is
to have 1.0.0 out by the end of the summer, after which we'll begin to
incorporate new features from JBoss [Wildfly](http://www.wildfly.org)
for the next release. As always, view our road map
[here](https://issues.jboss.org/browse/IMMUTANT).

## What is Immutant?

Immutant is an application server for [Clojure](http://clojure.org).
It's an integrated platform built on
[JBoss AS7](http://www.jboss.org/as7) that aims to reduce the inherent
[incidental complexity](http://en.wikipedia.org/wiki/Accidental_complexity)
in real world applications.

## What's in this release?

We haven't changed a whole lot since 0.10.0. We wanted to spruce up
our docs and make sure we didn't have any glaring stability issues. We
made a couple of minor enhancements to the jobs and caching
namespaces, but nothing that isn't backwards compatible.

Cluster configuration should be simpler since we're now taking
advantage of HornetQ's ability to use JGroups. We added a
[Production Setup](http://staging.immutant.org/builds/LATEST/html-docs/production.html)
chapter to our manual which we hope to evolve as more Immutants are
put in production. Speaking of that, check out Damion's excellent
writeup of his experiences
[clustering Immutant and TorqueBox on Amazon's EC2](http://damionjunk.com/2013/05/20/awsimmutantclustering/).

See the complete list of changes below.

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
