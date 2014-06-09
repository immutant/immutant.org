---
title: Messaging with The Deuce
author: Toby Crawley
layout: news
tags: [ thedeuce, getting-started, tutorial, messaging ]
---

<a href="https://flic.kr/p/Ea16j"><img src="/images/news/mailboxes.jpg" alt="[mailboxes]" class="alignleft"/></a>

In this installment of our series on
[getting started with Immutant 2](/news/tags/thedeuce/), we'll take a
detailed look at the API of our library for messaging, and show
a few examples of usage.

If you're coming from Immutant 1.x, you may notice that the artifact
has been renamed (`org.immutant/immutant-messaging` is now
`org.immutant/messaging`), and the API has changed a bit. We'll point
out the notable API changes as we go.

## The API

The messaging [API](#{api_doc_for_2x_version('LATEST')})
 is backed by [HornetQ], which is an implementation
of [JMS]. JMS provides two primary destination types: *queues* and
*topics*. Queues represent point-to-point destinations, and topics
publish/subscribe.

To use a destination, we need to get a reference to one via the
[queue](#{api_doc_for_2x_version('LATEST', 'messaging', 'queue')}) or
[topic](#{api_doc_for_2x_version('LATEST', 'messaging', 'topic')})
functions, depending on the type required. This will create the
destination if it does not already exist. This is a bit different than
the 1.x API, which provided a single `start` function for this, and
determined the type of destination based on conventions around the
provided name. In 2.x, we've removed those naming conventions.

Once we have a reference to a destination, we can operate on it with
the following functions:

* [publish](#{api_doc_for_2x_version('LATEST', 'messaging', 'publish')}) -
  sends a message to the destination
* [receive](#{api_doc_for_2x_version('LATEST', 'messaging', 'receive')}) -
  receives a single message from the destination
* [listen](#{api_doc_for_2x_version('LATEST', 'messaging', 'listen')}) -
  registers a function to be called each time a message
  arrives at the destination

If the destination is a queue, we can to synchronous messaging
([request-response]):

* [respond](#{api_doc_for_2x_version('LATEST', 'messaging', 'respond')}) -
  registers a function that receives each request, and the
  returned value will be sent back to the requester
* [request](#{api_doc_for_2x_version('LATEST', 'messaging', 'request')}) -
  sends a message to the responder

Finally, to deregister listeners, responders, and destinations, we
provide a single
[stop](#{api_doc_for_2x_version('LATEST','messaging', 'stop')})
function. This is another difference from 1.x -
the `unlisten` and `stop` functions have been collapsed to `stop`.

### Some Examples

The following code fragments were tested against
[2.x.incremental.133](http://immutant.org/builds/2x/). You should
follow the instructions in the [getting started] post to set up a
project using Immutant 2.x, and add
`[org.immutant/messaging "2.x.incremental.133"]` and
`[cheshire "5.3.1"]` to the project dependencies. Then, fire up a
REPL, and require the `immutant.messaging` namespace to follow along:

<pre class="syntax clojure">(require '[immutant.messaging :refer :all])</pre>

First, let's create a queue:

<pre class="syntax clojure">(queue "my-queue")</pre>

That will create the queue in the HornetQ broker for us. We'll need a
reference to that queue to operate on it. Let's go ahead and store
that reference in a var:

<pre class="syntax clojure">(def q (queue "my-queue"))</pre>

We can call `queue` any number of times - if the queue already exists,
we're just grabbing a reference to it.

Now, let's register a listener on our queue. Let's just print every
message we get:

<pre class="syntax clojure">(def listener (listen q println))</pre>

We can publish to that queue, and see that the listener gets called:

<pre class="syntax clojure">(publish q {:hi :there})</pre>

You'll notice that we're publishing a map there - we can publish
pretty much any data structure as a message. By default, that message
will be encoded using [edn]. We also support other encodings, namely:
`:clojure`, `:fressian`, `:json`, and `:text`. We can choose a
different encoding by passing an :encoding option to `publish`:

<pre class="syntax clojure">(publish q {:hi :there} :encoding :json)</pre>

Out of the box, we provide full support for the `:clojure`, `:edn`,
and `:text` encodings. If you want to use `:fressian` or `:json`,
you'll need to add `org.clojure/data.fressian` or `cheshire` to your
dependencies to enable them, respectively.

We passed our options to `publish` as keyword arguments, but they can
also be passed as a map:

<pre class="syntax clojure">(publish q {:hi :there} {:encoding :json})</pre>

This holds true for any of the messaging functions that take options.

We're also passing the destination reference to `publish` instead of the
destination name. That's a departure from 1.x, where you could just pass the
destination name. Since we no longer have conventions about how queues and
topics should be named, we can no longer determine the type of the
destination from the name alone.

We can deregister the listener by either passing it to `stop` or
calling `.close` on it:

<pre class="syntax clojure">(stop listener)
;; identical to
(.close listener)</pre>

Now let's take a look at synchronous messaging. Let's create a new
queue for this and register a responder that just increments the
request:

<pre class="syntax clojure">(def sync-q (queue "sync"))

(def responder (respond sync-q inc))</pre>

Then, we make a request, which returns a [Future] that we can
dereference:

<pre class="syntax clojure">@(request sync-q 1)</pre>

The responder is just a fancy listener, and can be deregistered the
same way as a listener.

## That's not all...

That was just a brief introduction to the messaging API. There are
features we've yet to cover (durable topic subscriptions,
connection/session sharing, transactional sessions, remote
connections), but it's getting late, so we'll save those for another
time.

## Try it out!

As always, we'd love to incorporate your feedback. Find us via our
[community] page and join the fun!

*Thanks to [John Lillis](https://flic.kr/p/6ZpegH) for the image, used under [CC BY-NC-ND](https://creativecommons.org/licenses/by-nc-nd/2.0/)*

[HornetQ]: http://hornetq.jboss.org/
[JMS]: https://en.wikipedia.org/wiki/Java_Message_Service
[getting started]: /news/2014/04/28/getting-started-with-2x/
[request-response]: https://en.wikipedia.org/wiki/Request-response
[community]: http://immutant.org/community/
[Future]: http://docs.oracle.com/javase/7/docs/api/java/util/concurrent/Future.html
