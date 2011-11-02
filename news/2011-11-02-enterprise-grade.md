---
title: 'WTF is an enterprise-grade app server?'
author: Jim Crossley
layout: news
tags: [ enterprise, app-server ]
---

[hn]: http://news.ycombinator.com/item?id=3184284
[TorqueBox]: http://torquebox.org
[company]: http://redhat.com
[jbossas]: https://github.com/jbossas/jboss-as
[fast]: http://torquebox.org/news/2011/10/06/torquebox-2x-performance/
[Heroku]: http://heroku.com
[EngineYard]: http://engineyard.com
[openshift]: https://openshift.redhat.com/

That's a great question. We get it a lot. It was [asked on Hacker News][hn]
in response to our birth announcement of Immutant yesterday.

So as someone who has worked in multiple enterprises, and now works
for a [company] whose primary customers *are* enterprises, and since I
routinely toss around the term like everyone knows what it means, and
since it's one of those awful terms that means something different to
everyone...

I'm compelled to answer the question, "WTF is an enterprise-grade
application server?"

The answer requires answering another question first: 

# What's an Enterprise? 

Here's my definition: it's a large organization of mostly-independent
development teams building and maintaining applications used by other
internal groups and external customers.

The key identifier of an enterprise is "a group of groups" in which
more than one of them builds software.

There's usually a single "system operations" group expected to cater
to the needs of all the other groups in the organization. Their life
is hell. They're ultimately responsibile for the security and
integrity of the organization's data and the lifecycles of all the
applications built for and used by all the other groups in the
organization.

Did I mention their life is hell?

They can't afford to support all the myriad message queues and web
frameworks each team might decide to build their apps around. Not to
mention supporting multiple languages! They prefer a single, "all in
the tin" solution. Sadly, that usually means .Net or Java.

So **enterprise-grade** implies a capacity for supporting these types
of environments. It usually involves, among other things,
**messaging** so that the disparate apps may communicate,
**transactions** to ensure the integrity of distributed data stores,
and **clustering**, not only for scalability, but also to allow the
lifecycles of the multiple versions of the apps to vary
independently. And oh yeah, it also has to stay up, all the time.

# What's an App Server?

An app server is a single product that provides all those
services. It's a multi-threaded process that, once started, provides
any app deployed to it with a web server, messaging, transactions,
scheduling, security, caching, clustering, and more. JBoss AS7 is one
such app server. It's [open-source][jbossas] and it's [fast].

Unfortunately, most popular commercial Java app servers provide those
robust enterprise services at a very high price. Not only in dollars,
but in the form of complex Java API's, overly-configured slow
implementations, vendor-negotiated standards and general "acronym
soup".

But it doesn't have to be that way. The Rails "convention over
configuration" mantra inspired the creation of [TorqueBox],
encapsulating the "enterprise-grade" services provided by JBoss AS7
behind simple Ruby API's. The goal for Immutant is to do the same with
Clojure.

But by integrating **any** JVM-based language with JBoss AS7, the
ultimate goal is to keep all the groups in an enterprise -- both
operations and development -- happy. Or at least significantly less
soul-sucky and hopefully more productive.

# But why should you care?

Maybe you shouldn't. Maybe you only need a web server and a database,
maybe just a JVM! Maybe you're not in a group of groups. Heck, maybe
you're not even in a group!

Maybe you're perfectly content being both developer and sys admin for
your apps and the various external processes on which they depend, or
you're quite happy delegating some of those responsibilities to the
fine folks at [Heroku], [EngineYard], or [someone else][openshift].

If that's the case, you are probably a very happy person, and I'm very
happy for you!

But if you feel you could benefit from a more integrated "all in the
tin" solution, and especially if you're thinking along polyglot lines,
I think TorqueBox (and Immutant, once it matures) is a compelling
alternative, whether you work in an enterprise or not.
