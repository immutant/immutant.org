---
title: "Getting Started: Scheduling Jobs"
author: Toby Crawley
layout: news
tags: [ tutorial, getting-started, scheduling, jobs ]
---


This article covers job schedulding in Immutant, and is part of our
[getting started series of tutorials][getting-started]. 

Jobs in Immutant are simply functions that execute on a recurring 
schedule. They fire asynchronously, outside of the thread where they are 
defined, and fire in the same runtime as the rest of the application, so 
have access to any shared state.

Jobs are built on top of the [Quartz] library, and support scheduling via a 
cron-like specification. 

## Why would I use this over quartz-clj or calling Quartz directly?

I'm glad you asked! There are several reasons:

* Immutant abstracts away the complexity of Quartz's internals, so you don't
  have to worry about managing [Schedulers] and creating [JobDetails], and
  provides enough functionality for a majority of use cases. For 
  cases where you need advanced scheduling functionality, you can still use
  quartz-clj or the Quartz classes directly.
* If you are using Immutant in a cluster, jobs that should fire only once per
  cluster (aka 'singleton jobs') are handled automatically (see below).
* When your application is undeployed, your jobs are automatically unscheduled.
  Note that if you use quartz-clj or Quartz directly from your application,
  you'll need  to clean up after yourself so you don't leave jobs lingering around 
  since Immutant can't automatically unschedule them for you.

## Scheduling Jobs

Scheduling a job is as simple as calling the `schedule`  function from the
`immutant.jobs` namespace:

<pre class="syntax clojure">(require '[immutant.jobs :as jobs])
(jobs/schedule "my-job-name" "*/5 * * * * ?" 
                #(println "I was called!"))</pre>

The `schedule` function requires three arguments:

* *name* - the name of the job.
  unscheduled and the new job will be scheduled in its place. 
* *spec* - the cron-style specification string (see below).
* *f* - the zero argument function that will be invoked each time the job fires.


Job scheduling is dynamic, and can occur anywhere in your application code. 
Jobs that share the lifecycle of your application are idiomatically placed in `immutant.clj`.

You can safely call `schedule` multiple times with the same job name - the named job will 
rescheduled.
  
## Cron Sytanx

The spec attribute should contain a crontab-like entry. This is similar to cron specifications
used by Vixie cron, anacron and friends, but includes an additional field for specifying seconds.
It is composed of 7 fields (6 are required):

<table class="fancy">
    <tr><th>Seconds</th><th>Minutes</th><th>Hours</th><th>Day of Month</th><th>Month</th><th>Day of Week</th><th>Year</th></tr>
    <tr><td>0-59</td><td>0-59</td><td>0-23</td><td>1-31</td><td>1-12 or JAN-DEC</td><td>1-7 or SUN-SAT</td><td>1970-2099 (optional)</td></tr>
</table>

For several fields, you may denote subdivision by using the forward-slash (/) character. To execute a job 
every 5 minutes, */5 in the minutes field would specify this condition.

Spans may be indicated using the dash (-) character. To execute a job Monday through Friday, MON-FRI 
should be used in the day-of-week field.

Multiple values may be separated using the comma (,) character. The specification of 1,15 in the 
day-of-month field would result in the job firing on the 1st and 15th of each month.

Either day-of-month or day-of-week must be specified using the ? character, since specifying
both is contradictory.

  See the [Quartz cron specification] for additional details.


## Unscheduling Jobs
  
Jobs can be unscheduled via the `unschedule` function:

<pre class="syntax clojure">(require '[immutant.jobs :as jobs])
    
(jobs/unschedule "my-job-name")</pre>

The `unschedule` function requires one argument:

* *name* - the name of a previously scheduled job.

If the given name resolves to an existing job, that job will be unscheduled and the call will
return `true`, otherwise `nil` is returned.

Jobs are automatically unscheduled when your application is undeployed.

## Clustering

When using Immutant in a cluster, you'll need to mark any jobs that should only be scheduled
once for the entire cluster with the `:singleton` option:

<pre class="syntax clojure">(require '[immutant.jobs :as jobs])
(jobs/schedule "my-job-name" "*/5 * * * * ?" 
                #(println "I only fire on one node")
                :singleton true)</pre>

If `:singleton` is `true`, the job will be scheduled to run on only one node in the cluster
at a time. If that node goes down, the job will automatically scheduled on another node, giving
you failover. If `:singleton` is `false` or not provided, the job will be scheduled to run on
all nodes where the `schedule` call is executed.

Look for a future post in our [Getting Started series][getting-started] on using Immutant in
a cluster.

## The Future

Currently, jobs can only be scheduled using [CronTrigger] functionality. We plan to add
support for [SimpleTrigger] (or 'at') functionality at some point in the future, 
allowing you to do something similar to:

<pre class="syntax clojure">(require '[immutant.jobs :as jobs])
(jobs/schedule "my-at-job" :every "3s" :times 5
                #(println "I fire 5 times, every 3 seconds"))</pre>

Since Immutant is still in a pre-alpha state, none of what I said above is set in stone. If 
anything does change, We'll update this post to keep it accurate. 

If you have any feedback or questions, [get in touch]! 

[getting-started]: /news/tags/getting-started/
[Quartz]: http://quartz-scheduler.org/
[Schedulers]: http://quartz-scheduler.org/api/1.8.5/org/quartz/Scheduler.html
[JobDetails]: http://quartz-scheduler.org/api/1.8.5/org/quartz/JobDetail.html
[CronTrigger]: http://quartz-scheduler.org/api/1.8.5/org/quartz/CronTrigger.html
[SimpleTrigger]: http://quartz-scheduler.org/api/1.8.5/org/quartz/SimpleTrigger.html
[Quartz cron specification]: http://www.quartz-scheduler.org/documentation/quartz-1.x/tutorials/TutorialLesson06
[get in touch]: /community






