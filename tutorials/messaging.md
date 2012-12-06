---
title: Messaging
sequence: 2
description: "Simple creation and usage of distributed queues and topics"
date: 2012-12-06
---

In this tutorial, we'll explore the [messaging] features available to
your Clojure applications when deployed on Immutant. Because Immutant
is built atop [JBoss AS7][as7], it includes the excellent [HornetQ]
messaging service baked right in. Hence, there is nothing extra to
install or configure in order for your applications to benefit from
asynchronous messaging.

## Destinations are either Queues or Topics

Two types of message destinations, or endpoints, are supported:
**queues** and **topics**. A queue exhibits *point-to-point*
semantics: a message sent to a queue will be delivered to a single
recipient. A *topic* provides *publish-subscribe* semantics: messages
sent to a topic will be delivered to all subscribed recipients. In
both cases, the message producers have no direct knowledge of the
message consumers.

Use the `start` function to create a messaging destination. A simple
naming convention designates an endpoint as either a queue or a topic:
if its name contains `queue`, it's a queue; if it contains
`topic`, it's a topic.

<pre class="syntax clojure">(require '[immutant.messaging :as msg])
(msg/start "queue.work")   ; to start a queue
(msg/start "topic.news")   ; to start a topic
</pre>

You can invoke `start` from anywhere in your application, e.g. the
`src/immutant/init.clj` initialization file, as described in
[the deployment tutorial][deploying].

While `start` has a complement, `stop`, you needn't call it
directly. It will be invoked when your application is undeployed. And
it's important to note that `start` is idempotent: if an endpoint has
already been started, likely by a cooperating application, the call is
effectively a no-op. Similarly, a call to `stop` will silently fail if
the endpoint is in use by any other application. The last to leave
will turn the lights out.

## Only One Way to Produce Messages

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
(msg/publish "queue.work" "simple string")
;; Notify everyone something interesting just happened
(msg/publish "topic.news" {:event "VISIT" :url "/sales-inquiry"})
;; Move this message to the front of the line
(msg/publish "queue.work" some-message :priority :high :ttl 1000)
;; Make messages as complex as necessary
(msg/publish "queue.work" {:a "b" :c [1 2 3 {:foo 42}]})
;; Make messages consumable by a Ruby app
(msg/publish "queue.work" {:a "b" :c [1 2 3 {:foo 42}]} :encoding :json)
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
(let [task (msg/receive "queue.work")]
  (perform task))

;; Case-sensitive work queues?
(msg/listen "/queue/lower" #(msg/publish "/queue/upper" (.toUpperCase %)))

;; Contrived laziness
(let [messages (message-seq queue)]
  (doseq [i (range 4)] (publish queue i))
  (= (range 4) (take 4 messages)))
</pre>

## Synchronous request/respond

Immutant provides an implementation of the request/response pattern, a
popular means of synchronous work distribution. Clients can publish a
message, i.e. make a request, and then block awaiting a response
without knowing exactly which consumer returns the response. For
example,

<pre class="syntax clojure">(require '[immutant.messaging :as msg])

;; setup a responder
(msg/respond "queue.work" (partial apply +))

;; send a request
(let [result (msg/request "queue.work" [1 2 3])]
  (println @result)) ;; => 6
</pre>

See the [manual][messaging] for more options and examples.

[messaging]: http://immutant.org/builds/LATEST/html-docs/messaging.html
[as7]: http://www.jboss.org/jbossas
[HornetQ]: http://hornetq.org
[javax.jms.Message]: http://java.sun.com/javaee/5/docs/api/javax/jms/Message.html
[deploying]: ../deploying/
