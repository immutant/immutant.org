---
title: 'Introducing Immutant'
author: Jim Crossley
tags: [ announcement, first, beginning ]
---

# Introducing Immutant

So we should probably officially announce the Immutant
project. Immutant is going to be for Clojure what TorqueBox is for
Ruby: a true, enterprise-grade application server, encapsulating the
robust services provided by JBoss AS7 within intuitive Clojure API's.

Further, Immutant has inspired us to attempt to achieve a sort of
"polyglot cafeteria plan" of app serving. For example, your
"application" might consist of a Ruby web app in the front and Clojure
data mining services in the rear, loosely but securely coupled via
JSON-encoded asynchronous messages. You choose the JVM-based languages
and frameworks that make the most sense for each of your application
components. And Immutant will provide a uniform deployment platform
and the "glue", i.e. those critical enterprisey services like
messaging, security, transactions, clustering, etc. that all
successful applications eventually require.

# Why?

Because learning new programming languages is fun. Because no one
language is good for everything a non-trivial application needs to
do. Because JBoss wants to be "everywhere".

But mostly because we want to.

App servers get a bad rap -- and bad app servers deserve it -- but
simple deployment, clustering and messaging are all good
things. Embracing polyglot and enabling the choice of the right
language/framework for a specific job is a good thing. We hope to
deliver that goodness via Immutant.

# An Invitation

We just got started with this, and though still Clojure noobs, we're
learning fast. We have a lot to do, and we'd love to have you help
shape Immutant into something that'll best serve your needs.

In the coming weeks, we'll be publishing more articles about Immutant,
such as:

 - How to deploy your Clojure apps (hint: Leiningen plugin)
 - How to configure Immutant to serve both Ruby and Clojure apps
 - How to pass messages between Ruby and Clojure components
 - How to distribute Clojure message handlers across a cluster

Please join the mailing lists and hang out on IRC. It'll be fun!
