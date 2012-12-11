---
title: 'Immutant, Poorsmatic, OpenShift and PostgreSQL'
author: Jim Crossley
layout: news
tags: [ openshift, tutorial, postgresql, poorsmatic ]
---

Today we'll get a Clojure application running in Immutant on
[OpenShift], persisting its data to a [PostgreSQL] database. We'll use
[Poorsmatic], the app I built in my recent talk at Clojure/Conj 2012.

Poorsmatic, a "poor man's [Prismatic]", is an awful content discovery
service, but a pretty good example of many of Immutant's features,
including topics, queues, XA transactions, HA services, and a few
other things. In my talk I used [Datomic] as my database, but here
we'll try a more SQL-y approach, using [Lobos] for migrations, the
[Korma] DSL, and OpenShift's PostgreSQL cartridge for persistence.

## Create an app on OpenShift

To [get started] on OpenShift you'll need an account, the command line
tools installed, and a domain setup. Below you'll see references to
*$namespace* -- this corresponds to your domain name.

Let's create an app. Call it poorsmatic.

    $ rhc app create -a poorsmatic -t jbossas-7

We're specifying the `jbossas-7` OpenShift cartridge. That will create
a sample Java application in the `poorsmatic/` directory. But we don't
want that. Instead, we'll use the [Immutant Quickstart] to add the
Immutant modules to AS7 and replace the Java app with a Clojure app:

    cd poorsmatic
    rm -rf pom.xml src
    git remote add quickstart -m master git://github.com/immutant/openshift-quickstart.git
    git pull -s recursive -X theirs quickstart master
    git add -A .
    git commit -m "Add Immutant modules and setup Clojure project"

At this point, we could `git push`, and after a couple of minutes hit
http://poorsmatic-$namespace.rhcloud.com to see a static welcome page.
But we've all seen those before so let's configure our database and
add the Poorsmatic source files before pushing.

# Add the PostgreSQL database

To add a PostgreSQL database to our app, we add a cartridge:

    $ rhc cartridge add postgresql-8.4 -a poorsmatic

And boom, we have a database. We have to tweak it just a bit, though.
So we're going to log into our app using the ssh URI from the output
of the `app create` command (available via `rhc app show -a
poorsmatic` or from the *My Applications* tab of the web UI). Here's
the URI it gave me:

    $ ssh a4117d5ebac04c5f8114f7a96eba2737@poorsmatic-jimi.rhcloud.com

Once logged in, we need to modify PostgreSQL's default configuration
to enable distributed transactions, which Poorsmatic uses. We're going
to set `max_prepared_transactions` to 10 and then restart the database:

    $ perl -p -i -e 's/#(max_prepared_transactions).*/\1 = 10/' postgresql-8.4/data/postgresql.conf
    $ pg_ctl restart -D $PWD/postgresql-8.4/data -m fast

If you forget to do this, you'll see errors referencing
`max_prepared_transactions` in the logs.

# Add the Poorsmatic source to your app

We'll use git to pull in the Poorsmatic source. You can use the same
technique to get your own apps deployed to OpenShift:

    $ git pull -s recursive -X theirs git://github.com/jcrossley3/poorsmatic.git korma-lobos
    $ git commit -m "Pulled in Poorsmatic"

Note that we specified the `korma-lobos` branch.

# Point the app to the database

You'll see profiles in `project.clj` that determine which database
both lobos and korma use. We'll add one for our OpenShift database,
too:

<pre class="syntax clojure">:profiles {...

       :openshift {:immutant {:init poorsmatic.core/start}
                   :db-spec {:name "java:jboss/datasources/PostgreSQLDS"
                             :subprotocol "postgresql"}}}
</pre>

And then we'll enable the `:openshift` profile in
`deployments/your-clojure-application.clj`:

<pre class="syntax clojure">{
 :root (System/getenv "OPENSHIFT_REPO_DIR")
 :context-path "/"
 :swank-port 24005
 :nrepl-port 27888

 :lein-profiles [:openshift]
}</pre>

Note that we have both nREPL and Swank endpoints configured, too. But
don't worry, they aren't externally accessible. They can only be
accessed via an ssh tunnel secured with your private key.

# Add your Twitter credentials

Finally, because Poorsmatic accesses Twitter's streaming API, you must
create an account at [http://dev.twitter.com] and add a file called
`resources/twitter-creds` that contains your OAuth credentials:

<pre class="syntax clojure">
["app-key" "app-secret" "user-token" "user-token-secret"]
}</pre>

# Push!

Now we can commit our changes and push:

    $ git add -A .
    $ git commit -m "Database config and twitter creds"
    $ git push

And now we can wait. The first push will take a few minutes. You
should login to your app and run:

    $ tail_all

Eventually, you should see a log message saying `Deployed
"your-clojure-application.clj"`, at which point you can go to
http://poorsmatic-$namespace.rhcloud.com, enter *bieber* and then
watch your `server.log`. Reload the page to see the URL's and the
counts. 

# The REPL

Run the following:

    $ rhc port-forward -a poorsmatic

If it works -- it may not, depending on your OS -- you can then connect
your nREPL client to `localhost:27888`. If it doesn't work, try this:

    $ ssh -L 27888:127.11.205.129:27888 a4117d5ebac04c5f8114f7a96eba2737@poorsmatic-jimi.rhcloud.com

But replace `127.11.205.129` with whatever `rhc port-forward` told you
(or log on to your app and `echo $OPENSHIFT_INTERNAL_IP`) and use your
own ssh URI.

# Tune in next time...

Immutant's clustering capabilities yield its coolest features, e.g.
load-balanced message distribution, highly-available services and
scheduled jobs, etc. But clustering is a pain to configure when
multicast is disabled. OpenShift aims to simplify that, but it's
[not quite there yet][883944]. In a future post, I hope to demonstrate
those clustering features by creating a *scaled* application on
OpenShift, letting it deal with all the murky cluster configuration
for you.

Stay tuned!


[get started]: https://openshift.redhat.com/community/get-started 
[Immutant Quickstart]: https://github.com/immutant/openshift-quickstart
[Lobos]: https://github.com/budu/lobos
[Korma]: http://sqlkorma.com/
[Poorsmatic]: https://github.com/jcrossley3/poorsmatic
[Prismatic]: http://getprismatic.com
[Datomic]: http://www.datomic.com/
[PostgreSQL]: http://www.postgresql.org/
[OpenShift]: http://openshift.com/
[883944]: https://bugzilla.redhat.com/show_bug.cgi?id=883944
