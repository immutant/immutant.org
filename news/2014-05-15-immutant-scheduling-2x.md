---
title: Scheduling with The Deuce
author: Jim Crossley
layout: news
tags: [ thedeuce, getting-started, tutorial, scheduling ]
---

The "scheduled jobs" library in Immutant 2 has been renamed: what used
to be `org.immutant/immutant-jobs` is now `org.immutant/scheduling`.
It's still based on Quartz 2.2, though. In this post, we'll take a
detailed look at the API with a few examples.

## The API

At first glance, the API for [immutant.scheduling] appears bigger than
it really is. There are only two essential functions:

* `schedule` - for scheduling your jobs
* `stop` - for canceling them

All the other functions in the namespace are just syntactic sugar.
We'll get to them later, but first let's take a closer look at
`schedule`.

Your "job" will take the form of a plain ol' Clojure function taking
no arguments. The `schedule` function takes your job and a
*specification map* as arguments. The map determines when your
function gets called. It may contain any of the following keys:

* `:in` - a period after which your function will be called
* `:at` - an instant in time after which your function will be called
* `:every` - the period between calls 
* `:until` - stops the calls at a specific time
* `:limit` - limits the calls to a specific count
* `:cron` - calls your function according to a [Quartz-style] cron spec

Units for periods (`:in` and `:every`) are milliseconds, but can also
be represented as a keyword or a vector of number/keyword pairs, e.g.
`[1 :week, 4 :days, 2 :hours, 30 :minutes, 59 :seconds]`. Both
singular and plural keywords are valid.

Date/Time values (`:at` and `:until`) can be a `java.util.Date`,
millis-since-epoch, or a String in `HH:mm` format. The latter will be
interpreted as the next occurence of "HH:mm:00" in the currently
active timezone.

Two additional options may be passed in the spec map:

* :id - a unique identifier for the scheduled job
* :singleton - a boolean denoting the job's behavior in a cluster [true]

In Immutant 1, a name for the job was a required argument. In Immutant
2, the `:id` is optional: if not provided, a UUID will be generated.
If `schedule` is called with an `:id` for a job that has already been
scheduled, the prior job will be replaced.

The return value from `schedule` is a map of the options with any
missing defaults filled in, including a generated id if necessary.
This result can be passed to `stop` to cancel the job.

### Some Examples

The following code fragments were tested against
[2.x.incremental.115](http://immutant.org/builds/2x/). You should read
through the [getting started] post and require the `immutant.scheduling`
namespace at a REPL to follow along:

<pre class="syntax clojure">(require '[immutant.scheduling :refer :all])</pre>

## Try it out!

We'd love to hear some feedback on this stuff. Find us on our
[community] page and join the fun!


[immutant.scheduling]: https://projectodd.ci.cloudbees.com/job/immutant2-incremental/lastSuccessfulBuild/artifact/target/apidocs/immutant.scheduling.html
[Quartz-style]: http://quartz-scheduler.org/documentation/quartz-2.2.x/tutorials/tutorial-lesson-06
[getting started]: /news/2014/04/28/getting-started-with-2x/
[community]: http://immutant.org/community/
