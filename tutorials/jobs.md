---
title: "Scheduling Jobs"
sequence: 4
description: "Covers adding cron-like scheduled jobs to an application."
---


This tutorial covers job schedulding in Immutant - functions that execute on a recurring 
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
  [quartz-clj] or the Quartz classes directly.
* If you are using Immutant in a cluster, jobs that should fire only once per
  cluster (aka 'singleton jobs') are handled automatically (see our 
  [clustering tutorial] for more information).
* When your application is undeployed, your jobs are automatically unscheduled.
  Note that if you use quartz-clj or Quartz directly from your application,
  you'll need  to clean up after yourself so you don't leave jobs lingering around 
  since Immutant can't automatically unschedule them for you.

## Scheduling Jobs

Scheduling a job is as simple as calling the `schedule` function from the
`immutant.jobs` namespace. Let's see it in use - if you need
an Immutant-ready application, see the [deployment tutorial] or grab the
[sample application] from that tutorial. The rest of this tutorial will 
assume you are using that sample application.

Add a job to your `immutant.clj`:

<pre class="syntax clojure">(ns immutant-demo.init
  (:use immutant-demo.core)
  (:require [immutant.web :as web]
            [immutant.jobs :as jobs)) ;; require the jobs ns
...

(jobs/schedule "my-job-name" "*/5 * * * * ?" 
                #(println "I was called!"))</pre>

Now, if we deploy and run the application (via `lein immutant deploy && lein immutant run`),
you should see the following log output:

    ...
    11:49:24,691 INFO  [org.jboss.as.server] (DeploymentScanner-threads - 2) JBAS018559: Deployed "immutant-demo.clj"
    11:49:25,008 INFO  [stdout] (JobScheduler$immutant-demo.clj_Worker-1) I was called!
    11:49:30,018 INFO  [stdout] (JobScheduler$immutant-demo.clj_Worker-2) I was called!
    11:49:35,002 INFO  [stdout] (JobScheduler$immutant-demo.clj_Worker-3) I was called!
    11:49:40,002 INFO  [stdout] (JobScheduler$immutant-demo.clj_Worker-1) I was called!
    ...
    
The `schedule` function requires three arguments:

* *name* - the name of the job.
* *spec* - the cron-style specification string (see below).
* *f* - the zero argument function that will be invoked each time the job fires.

Job scheduling is dynamic, and can occur at any time during your application's lifecycle. 
We started the job above in `immutant.clj`, but it could also be done from anywhere within 
your application code. Jobs that share the lifecycle of your application are idiomatically 
placed in `immutant.clj`.

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

## Wrapping Up

Since Immutant is still in an alpha state, none of what I said above is set in stone. If 
anything does change, We'll update this post to keep it accurate. 

If you have any feedback or questions, [get in touch]! 

[Quartz]: http://quartz-scheduler.org/
[quartz-clj]: https://github.com/mdpendergrass/quartz-clj
[Schedulers]: http://quartz-scheduler.org/api/1.8.5/org/quartz/Scheduler.html
[JobDetails]: http://quartz-scheduler.org/api/1.8.5/org/quartz/JobDetail.html
[CronTrigger]: http://quartz-scheduler.org/api/1.8.5/org/quartz/CronTrigger.html
[SimpleTrigger]: http://quartz-scheduler.org/api/1.8.5/org/quartz/SimpleTrigger.html
[clustering tutorial]: ../clustering/
[deployment tutorial]: ../deploying/
[sample application]: https://github.com/immutant/immutant-basic-web-demo
[Quartz cron specification]: http://www.quartz-scheduler.org/documentation/quartz-1.x/tutorials/TutorialLesson06
[get in touch]: /community






