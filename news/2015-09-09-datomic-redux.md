---
title: Using Datomic With Immutant Redux
author: The Immutant Team
layout: news
tags: [ datomic, messaging ]
---

A month ago, we [covered] how to use [Datomic] with Immutant. Now that
Immutant 2.1.0 has been [released], the process of using Immutant
messaging and Datomic in the same application is a bit simpler, so
we're covering just that here.

With Immutant 2.1.0, `org.immutant/messaging` can now work with the
HornetQ 2.3.x brought in by Datomic, you just have to have the proper
dependency inclusions/exclusions for it to work. The minimum to get
this working is:

<pre class="syntax clojure">
:dependencies [[org.immutant/immutant "2.1.0"]
               ;; Datomic transitively brings in HornetQ 2.3.17.Final, which
               ;; overrides the HornetQ 2.4.5.Final from org.immutant/messaging
               [com.datomic/datomic-pro "0.9.5206"]
               ;; org.immutant/messaging requires this, but Datomic doesn't
               ;; bring it in, so we have to depend on it explicitly
               [org.hornetq/hornetq-jms-server "2.3.17.Final"
                :exclusions [org.jboss.jbossts.jts/jbossjts-jacorb]]]
</pre>

But doing just that leads to lots of warnings in Leiningen's pedantic
report. Both Datomic and Immutant have large dependency trees, so
conflicts are inevitable. If you want to get rid of those warnings,
we've figured that out for you as well:

<pre class="syntax clojure">
:dependencies [[org.immutant/immutant "2.1.0"
                :exclusions [org.hornetq/hornetq-server
                             org.hornetq/hornetq-jms-server
                             org.hornetq/hornetq-journal
                             org.hornetq/hornetq-commons]]
               [com.datomic/datomic-pro "0.9.5206"
                :exclusions [org.slf4j/slf4j-nop
                             joda-time
                             commons-codec
                             org.jboss.logging/jboss-logging]]
               [org.hornetq/hornetq-jms-server "2.3.17.Final"
                :exclusions [org.jboss.spec.javax.transaction/jboss-transaction-api_1.1_spec
                             org.jboss.logging/jboss-logging
                             org.jboss/jboss-transaction-spi
                             org.jgroups/jgroups
                             org.jboss.jbossts.jts/jbossjts-jacorb]]]
</pre>

## Get In Touch

If you have any questions, issues, or other feedback about Datomic
with Immutant, you can always find us on
[#immutant on freenode](/community/#irc) or
[our mailing list](/community/#mailing-lists).

[covered]: /news/2015/08/03/datomic/
[Datomic]: http://www.datomic.com/
[HornetQ]: http://hornetq.org
[released]: /news/2015/09/01/announcing-2-1-0/
