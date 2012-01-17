---
title: 'Getting Started: Messaging'
author: Jim Crossley
layout: news
tags: [ messaging, tutorial, getting-started ]
---

Happy 2012! For the next installment of our
[getting started series][getting-started] we'll explore the
[messaging abstractions][immutant.messaging] available to your Clojure
apps when deployed on Immutant. Because Immutant is built atop
[JBoss AS7][as7], it includes the excellent [HornetQ] messaging
service built right in. Hence, there is nothing extra to install or
configure in order for your applications to benefit from asynchronous
messaging.

## Destinations are either Queues or Topics

Two types of message destinations, or endpoints, are supported:
**queues** and **topics**. A queue exhibits *point-to-point*
semantics: a message sent to a queue will be delivered to a single
recipient. A *topic* provides *publish-subscribe* semantics: messages
sent to a topic will be delivered to all subscribed recipients. In
both cases, the message producers have no direct knowledge of the
message consumers.

Use the `start` function to define a messaging destination. A simple
naming convention designates an endpoint as either a queue or a topic:
if its name begins with `/queue`, it's a queue; if it begins with
`/topic`, it's a topic.

<pre class="syntax clojure">(require '[immutant.messaging :as msg])
(msg/start "/queue/work")   ; to start a queue
(msg/start "/topic/news")   ; to start a topic
</pre>

You can invoke `start` from anywhere in your application, but
typically it's done in the `immutant.clj` initialization file, as
described in [an earlier tutorial][deploying].

While `start` has a complement, `stop`, you needn't call it
directly. It will be invoked when your application is undeployed. And
it's important to note that `start` is idempotent: if an endpoint has
already been started, likely by a cooperating application, the call is
effectively a no-op. Similarly, a call to `stop` will silently fail if
the endpoint is in use by any other application. The last to leave
will turn the lights out.

## One Way to Produce Messages

### publish

Messages are sent to a destination, whether queue or topic, via a
single function, `publish`, to which is passed the destination name
and the message content, which can be just about anything.  A number
of optional key-value parameters may be passed as well.

* `:encoding` may be either `:clojure` (the default), `:json` (useful
  with non-clojure consumers) or `:text` (no encoding)
* `:priority` may be an integer between 0-9, inclusive. Convenient
  keyword values `:low`, `:normal`, `:high` and `:critical` correspond
  to 0, 4, 7 and 9, respectively. 4 is the default.
* `:ttl` time-to-live may be specified in milliseconds, after which
  time the message is discarded if not consumed. Default is 0,
  i.e. forever.
* `:properties` is a hash of arbitrary message metadata upon which JMS
  selector expressions may be constructed to filter received messages.

Some examples:

<pre class="syntax clojure">;; A simple string
(msg/publish "/queue/work" "simple string")
;; Notify everyone something interesting just happened
(msg/publish "/topic/news" {:event "VISIT" :url "/sales-inquiry"})
;; Move this message to the front of the line
(msg/publish "/queue/work" some-message :priority :high :ttl 1000)
;; Make messages as complex as necessary
(msg/publish "/queue/work" {:a "b" :c [1 2 3 {:foo 42}]})
;; Make messages consumable by a Ruby app
(msg/publish "/queue/work" {:a "b" :c [1 2 3 {:foo 42}]} :encoding :json)
</pre>
    
## Three Ways to Consume Messages

### receive

Block on a call to `receive`, passing a destination name and
optionally, the following:

* `:timeout` an expiration in milliseconds, after which nil is
  returned. Default is 0, i.e. wait forever
* `:selector` a JMS expression used to filter messages according
  to the values of arbitrary `:properties`. For documentation on
  JMS selector syntax please see the javadoc for
  [javax.jms.Message].

### listen

Pass a destination name and function to `listen` and the decoded
content of a message sent to that destination will be passed to the
function. Options include:

* `:concurrency` the maximum number of listening threads that can
  simultaneouly call the function. Default is 1.
* `:selector` same as `:receive`

### message-seq

Create a lazy sequence of messages via `message-seq`, which accepts
the same options as `receive`.

Some examples:

<pre class="syntax clojure">;; Wait on a task
(let [task (msg/receive "/queue/work")]
  (perform task))

;; Case-sensitive work queues?
(msg/listen "/queue/lower" #(msg/publish "/queue/upper" (.toUpperCase %)))

;; Contrived laziness
(let [messages (message-seq queue)]
  (doseq [i (range 4)] (publish queue i))
  (= (range 4) (take 4 messages)))
</pre>

## Language Interop

One of our initial goals for Immutant messaging was simple interop
between Ruby and Clojure applications deployed on a single
platform. [TorqueBox] Ruby processors already grok the `:json`
encoding and will automatically decode the message into the analogous
Ruby data structures, so as long as you limit the content of your
messages to standard collections and types, they are transparently
interoperable between Clojure and Ruby in either direction. See the
[overlay] post for more details on TorqueBox/Immutant integration.

Of course, the `:json` encoding enables other JVM-based languages --
anything you could conceivably cram into a war file -- to join in the
fun, too. For non-JVM languages or external endpoints, something like
the Pipes and Filters API's provided by [Clamq] could be used since
we expose our JMS connection factory as
`immutant.messaging.core/connection-factory`.

## Anything Else?

Another advantage we get from AS7 is its clustering support. Once we
work out some small integration bits, message distribution across a
cluster of dynamic nodes will be automatically load-balanced and
fault-tolerant, with minimal to no configuration required.

Of course, we still have other messaging features on our roadmap,
e.g. XA transactions, durable subscribers and synchronous
request/response, and we're looking for ways to make container-based
deployment more developer-friendly, so there's still much to do. Feel
free to follow along on
[Twitter, IRC, or the mailing list][community].


[TorqueBox]: http://torquebox.org/
[immutant.messaging]: https://github.com/immutant/immutant/blob/master/modules/messaging/src/main/clojure/immutant/messaging.clj
[deploying]: /news/2011/11/08/deploying-an-application/
[overlay]: /news/2011/12/21/overlay/
[HornetQ]: http://hornetq.org
[javax.jms.Message]: http://java.sun.com/javaee/5/docs/api/javax/jms/Message.html
[community]: http://immutant.org/community/
[Clamq]: https://github.com/sbtourist/clamq
[as7]: http://www.jboss.org/jbossas
[getting-started]: /news/tags/getting-started/
