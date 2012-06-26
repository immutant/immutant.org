---
title: 'Introducing Distributed XA Transaction Support'
author: Jim Crossley
layout: news
tags: [ transactions, xa ]
---

[bear]: http://www.youtube.com/watch?v=v6cY0zz-958

In anticipation of our upcoming 0.2.0 release, we're as happy as a
[bear in a koi pond][bear] to announce support for Distributed (XA)
Transactions in Immutant.

Messaging and Caching in Immutant are now automatically transactional
and XA capable. And we make it easy for you to define DataSources for
your XA compliant SQL databases so that you can then define
transactions incorporating all three types of resources in your
Clojure applications.

# What is XA?

It's a standard protocol for allowing multiple, independent data
resources to participate in a single, distributed transaction.

# Why XA?

Your application stores data in more than one place. So when a
function in your application writes data to two databases, XA can
ensure that you don't leave your data in an inconsistent state when
one of the databases fails. Either every write succeeds or every write
fails.

Your message producers and consumers require a consistent view of your
application data.

# Why not XA?

Past implementations were slow, heavyweight and hard to configure,
thereby garnering XA a reputation that often drove some architects to
build comparatively complex "home grown" alternatives that were
arguably just as resource-intensive and often more error prone.

We believe JBoss AS7 -- along with HornetQ, Infinispan and Clojure
itself -- makes XA more appealing.

But you may not need it. Most applications don't. If yours stores its
data in one database and has lenient or no messaging requirements, XA
is overkill.

Developers who need XA know exactly why they do.

