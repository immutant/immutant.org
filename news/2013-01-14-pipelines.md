---
title: Introducing Immutant Pipelines
author: Toby Crawley
layout: news
tags: [ pipelines, messaging, clustering ]
---

<img src="/images/news/pipeline.jpg" alt="[pipeline]" class="alignright"/>

Happy new year! We'd like to celebrate by announcing a new Immutant
feature: *pipelines*. Pipelines are compositions of functions, where
the functions are executed in individual threads (or thread pools),
potentially on different nodes in an Immutant cluster. They are built
on top of our
[messaging subsystem](#{doc_chapter_for_version('LATEST','messaging')}),
and were inspired by
[lamina's pipelines](https://github.com/ztellman/lamina/wiki/Pipelines-new).

## Usage

We'll walk through a simple (and simplistic) example to demonstrate
using a pipeline.

### Creation

The first thing we have to do is create a pipeline. We do that with a
call to the
[pipeline](#{api_doc_for_version('LATEST','pipeline','pipeline')})
function, giving it a name and some single-arity functions that form
the *steps* of the pipeline:

<pre class="syntax clojure">(require '[immutant.pipeline :as pl])

(defonce reverse-pl
  (pl/pipeline :reverse-a-string
    seq
    reverse
    (partial apply str)))
</pre>

This looks similar to a 'thread last' (`->>`), or a `comp` in
reverse. And for the functions we're using in this sample pipeline,
let's pretend that each of the functions we are using in the pipeline
are more computation and time intensive than they actually are.
            
### Putting data onto a pipeline 

So, moving right along. We now have a pipeline, but how do we put data
on it? The call to `pipeline` returns a function (we'll call it a
*pipeline-fn*) that places data onto the head of the pipeline. Let's
use it:

<pre class="syntax clojure">(let [result (reverse-pl "ham")]
  (deref result 1000 nil)) ;; => "mah"
</pre>

What's with the `deref`? The pipeline execution is asynchronous - the
pipeline-fn places the data onto the head of the pipeline, and
immediately returns a delay. We dereference the delay to synchronize
on the end of the pipeline, giving us the result. We're careful to use
the `deref` that takes a timeout - it's possible for errors to occur
during the pipeline execution, so we may never get a response (we'll
talk more about error handling in a bit).

### Raising the concurrency

By default, each step gets assigned one thread (per cluster node) to
handle its work. If our pipeline processes data at a rate that is
slower than the rate of insertion at the head of the pipeline, we can
increase the number of threads for each step with the `:concurrency`
option (options are passed as keyword arguments after the list of
functions). Let's alter our original pipeline definition to do that:

<pre class="syntax clojure">(require '[immutant.pipeline :as pl])

(defonce reverse-pl
  (pl/pipeline :reverse-a-string
    seq
    reverse
    (partial apply str)
    :concurrency 5)) ;; 5 threads per step
</pre>

But what if we have one step that is slower than the rest? Let's
assume that `reverse` is the slowpoke here, and raise the
`:concurrency` even higher for that step:

<pre class="syntax clojure">(defonce reverse-pl
  (pl/pipeline :reverse-a-string
    seq
    (pl/step reverse :concurrency 10) ;; 10 threads for this guy
    (partial apply str)
    :concurrency 5)) ;; 5 threads for each of the other steps
</pre>

Here we've used the
[step](#{api_doc_for_version('LATEST','pipeline','step')}) function
to attach options to a particular step. Options attached to steps will
override the corresponding pipeline option where it makes sense.

### Handling errors

Since pipelines are built on top of Immutant's
[message listeners](#{doc_chapter_for_version('LATEST','messaging','messaging-receiving')}),
the default error handling is what the messaging system provides: if
an exception occurs during the execution of a step, the delivery of
the data to that step is rolled back, and will be retried up to ten
times. If you need errors to be handled differently, you can provide
an error handler function that must take two arguments: the exception,
and the original argument passed to the step that threw the exception:

<pre class="syntax clojure">(pl/pipeline :do-something-on-the-network
    retrieve-a-url
    process-url-contents
    more-data-processing
    :error-handler (fn [ex v] 
                     (when (instance? ex SomeNetworkException)
                       (println "ERROR, skipping" pl/*current-step* ex)
                       (pl/*pipeline* v :step pl/*next-step*)))) ;; jump to the next step
</pre>

Above we have a simple error handler that demonstrates putting a value
back onto the pipeline. We do that using a few vars that are bound
during a pipeline execution:
* [\*pipeline\*](#{api_doc_for_version('LATEST','pipeline','*pipeline*')}) -
  bound to the currently active pipeline-fn
* [\*current-step\*](#{api_doc_for_version('LATEST','pipeline','*current-step*')}) -
  bound to the name of the currently active step
* [\*next-step\*](#{api_doc_for_version('LATEST','pipeline','*next-step*')})) -
  bound to the name of the next step

If the error handler doesn't put the data back on to the pipeline,
that particular pipeline execution is halted.

You can also specify an `:error-handler` for a particular step, which
will override the pipeline error handler.

Let's see the above example again, but with a step-specific error handler
that rethrows to trigger the default retry semantics:

<pre class="syntax clojure">(pl/pipeline :do-something-on-the-network
    (pl/step retrieve-a-url 
      :error-handler (fn [ex v] 
                       (if (instance? ex SomeNetworkException)
                         (println "ERROR retrieving url" v ", exiting:" ex) ;; exit the pipeline
                         (throw x)))) ;; retry
    process-url-contents
    more-data-processing
    :error-handler (fn [ex v] 
                     (when (instance? ex SomeNetworkException)
                       (println "ERROR, skipping" pl/*current-step* ex)
                       (pl/*pipeline* v :step pl/*next-step*))))
</pre>

### Pipelines within pipelines 

Pipeline-fn's are just functions that happen to return a delay. To
facilitate using pipelines within pipelines, any step result that can 
be dereferenced is, automatically:

<pre class="syntax clojure">(defonce rev-emb-pl 
  (pl/pipeline :reverse-and-embiggen
    reverse-pl 
    (memfn .toUpperCase) 
    #(str \¡ % \!)))

(deref (rev-emb-pl "tiucsib") 1000 nil) ;; => "¡BISCUIT!"
</pre>

Since it's possible for the result of a step to never arrive, you can
control how long this automatic `deref` waits:

<pre class="syntax clojure">(defonce rev-emb-pl 
  (pl/pipeline :reverse-and-embiggen
    reverse-pl 
    (memfn .toUpperCase) 
    #(str \¡ % \!)
    :step-deref-timeout 60000)) ;; in ms, default is 10 seconds
</pre>

Like `:concurrency` and `:error-handler`, `:step-deref-timeout` can be
overridden on a per-step basis.

## Availabilty

Pipelines are currently available in the latest Immutant
[incremental builds](/builds/), and will be part of 0.8.0, which
should be released today.

Pipeline support is an alpha feature at the moment, so its API is in flux. 

## Learning more

We haven't covered everything about pipelines here, see the
[documentation](#{doc_chapter_for_version('LATEST','messaging','messaging-pipelines')})
for more details, and [get in touch](/community/) if you have any
questions or comments.

*Image credit: [World Bank Photo Collection](http://www.flickr.com/photos/worldbank/7342211086)*
