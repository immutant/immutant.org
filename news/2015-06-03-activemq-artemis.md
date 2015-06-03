---
title: Using ActiveMQ Artemis With Immutant
author: Toby Crawley
layout: news
tags: [ messaging ]
---

[Artemis] is a "new" JMS2-compatible message broker based on a merging
of the [ActiveMQ] and [HornetQ] codebases, and represents the future
of both projects.

Immutant is built on an abstraction layer called [WunderBoss] in order
to share much of the implementation with our sibling project,
[TorqueBox]. An additional advantage of this layer is it allows us (in
theory) to easily switch out the underlying messaging
implementation while keeping the same . With the release of Artemis 1.0.0, we've now taken the
opportunity to test that theory.

## wunderboss-artemis

With only a couple of changes to WunderBoss that allow us to share the
bulk of the existing JMS2 implementation between the HornetQ and
Artemis adapters and make it easier to exclude the HornetQ
dependencies, we're now able to provide [wunderboss-artemis]. It
allows you to use Artemis instead of HornetQ as the message broker in
an embedded application (it doesn't yet support Artemis if you are
deploying to WildFly).

If you want to give it a try, you just need to depend on a recent
[incremental build] \(#585 or newer)
and make a few adjustments to your `:dependencies`:

    :dependencies [[org.immutant/messaging "2.x.incremental.585"
                    :exclusions [org.projectodd.wunderboss/wunderboss-messaging-hornetq]]
                   [org.projectodd.wunderboss/wunderboss-artemis "0.1.0"]]

If you then use messaging and see something like the following in your
log output, you're all set!

    14:12:44.471 INFO  [org.apache.activemq.artemis.core.server] (main) AMQ221020: Started Acceptor at localhost:5445 for protocols [CORE]
    14:12:44.471 INFO  [org.apache.activemq.artemis.core.server] (main) AMQ221007: Server is now live
    14:12:44.471 INFO  [org.apache.activemq.artemis.core.server] (main) AMQ221001: Apache ActiveMQ Artemis Message Broker version 1.0.0 [nodeID=2107a7c3-0a1c-11e5-955d-71ef037c4451]

Artemis is brand new - once it matures a bit, we may provide an
immutant-artemis lib that would bring in wunderboss-artemis and
provide an Artemis management namespace similar to the
[immutant.messaging.hornetq] we currently provide.

As always, if you have any issues or feedback, feel free to
[get in touch].

[Artemis]: http://activemq.apache.org/artemis/
[ActiveMQ]: http://activemq.apache.org/
[HornetQ]: http://hornetq.org/
[WunderBoss]: https://github.com/projectodd/wunderboss/
[TorqueBox]: http://torquebox.org/
[wunderboss-artemis]: https://github.com/projectodd/wunderboss-artemis/
[incremental build]: /builds/2x/
[immutant.messaging.hornetq]: http://immutant.org/documentation/current/apidoc/immutant.messaging.hornetq.html
[get in touch]: /community/
