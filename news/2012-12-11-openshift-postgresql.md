---
title: 'OpenShift, PostgreSQL and Poorsmatic'
author: Jim Crossley
layout: news
tags: [ openshift, tutorial, postgresql, poorsmatic ]
---

Today we'll get a Clojure application running in Immutant on
[OpenShift], persisting its data to a [PostgreSQL] database. We'll use
[Poorsmatic], the app I built in [my recent talk] at Clojure/Conj 2012.

[Poorsmatic], a "poor man's [Prismatic]", is a truly awful content
discovery service that merely returns URL's from Twitter that contain
at least one occurrence of the search term used to find the tweets
containing the URL's in the first place.

Got that? Don't worry. It doesn't matter.

Because Poorsmatic was contrived to be a pretty good example of many
of Immutant's features, including topics, queues, XA transactions, HA
services, and a few other things. In my talk I used [Datomic] as my
database, but here we'll try a different approach, using [Lobos] for
database migrations, the [Korma] DSL, and OpenShift's PostgreSQL
cartridge for persistence.

## Create an app on OpenShift

To [get started] on OpenShift you'll need an account, the command line
tools installed, and a domain setup. Below you'll see references to
*$namespace* -- this corresponds to your domain name.

Once you've setup your domain, create an app. Call it poorsmatic.

    $ rhc app create -a poorsmatic -t jbossas-7

We're specifying the `jbossas-7` OpenShift cartridge. That will create
a sample Java application in the `poorsmatic/` directory. But we don't
want that. Instead, we'll use the [Immutant Quickstart] to add the
Immutant modules to AS7 and replace the Java app with a Clojure app:

    cd poorsmatic
    rm -rf pom.xml src
    git remote add quickstart -m master git://github.com/openshift-quickstart/immutant-quickstart.git
    git pull --no-commit -s recursive -X theirs quickstart master
    git add -A .
    git commit -m "Add Immutant modules and setup Clojure project"

At this point, we could `git push`, and after a couple of minutes hit
<http://poorsmatic-$namespace.rhcloud.com> to see a static welcome
page. Instead, we'll configure our database and add the Poorsmatic
source files before pushing.

# Add the PostgreSQL cartridge

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
    $ exit

If you forget to do this, you'll see errors referencing
`max_prepared_transactions` in the logs.

# Add the Poorsmatic source to your app

We'll use git to pull in the Poorsmatic source code. You can use the
same technique to get your own apps deployed to OpenShift:

    $ git pull -s recursive -X theirs git://github.com/jcrossley3/poorsmatic.git korma-lobos

Note that we specified the `korma-lobos` branch.

# Configure the app to use PostgreSQL

You'll see Leiningen profiles in `project.clj` that determine which
database both the lobos and korma libraries will use. One of these
profiles, `:openshift`, refers to the name of the PostgreSQL
datasource configured in your `.openshift/config/standalone.xml`
provided by the quickstart.

We'll activate the `:openshift` profile in
`deployments/your-clojure-application.clj`:

<pre class="syntax clojure">{
 :root (System/getenv "OPENSHIFT_REPO_DIR")
 :context-path "/"
 :swank-port 24005
 :nrepl-port 27888

 :lein-profiles [:openshift]
}</pre>

# Add your Twitter credentials

Finally, because Poorsmatic accesses Twitter's streaming API, you must
create an account at <http://dev.twitter.com> and add a file called
`resources/twitter-creds` that contains your OAuth credentials in a
simple Clojure vector:

<pre class="syntax clojure">["app-key" "app-secret" "user-token" "user-token-secret"]</pre>

You may be concerned about storing sensitive information with your
app, but remember that OpenShift secures your git repo with ssh
public/private key pairs and only those people whose public keys
you've associated with your app have access to it.

# Push!

Now we can commit our changes and push:

    $ git add -A .
    $ git commit -m "Database config and twitter creds"
    $ git push

And now we wait. The first push will take a few minutes. Immutant will
be installed and started, your app deployed, the app's dependencies
fetched, the database schema installed, etc. You should login to your
app and view the logs while your app boots:

    $ ssh a4117d5ebac04c5f8114f7a96eba2737@poorsmatic-jimi.rhcloud.com
    $ tail_all

Eventually, you should see a log message saying `Deployed
"your-clojure-application.clj"`, at which point you can go to
<http://poorsmatic-$namespace.rhcloud.com>, enter *bieber* and then
watch your `server.log` fill up with more meaningless drivel than you
ever dreamed possible.

[And you may even see some bieber tweets.](http://instantrimshot.com/index.php?sound=rimshot&play=true) ;-)

Reload the web page to see the scraped URL's and their counts.

# The REPL

You may have noticed the [nREPL] and [Swank] ports configured in the
deployment descriptor above. They are not externally accessible. They
can only be accessed via an ssh tunnel secured with your private key.

Run the following:

    $ rhc port-forward -a poorsmatic

Depending on your OS, this may not work. If it doesn't, try the `-L`
option:

    $ ssh -L 27888:127.11.205.129:27888 a4117d5ebac04c5f8114f7a96eba2737@poorsmatic-jimi.rhcloud.com

But replace `127.11.205.129` with whatever `rhc port-forward` told you
(or ssh to your instance and `echo $OPENSHIFT_INTERNAL_IP`). And
obviously, you should use the ssh URI associated with your own app.

Once the tunnel is established, you can then connect to the remote
REPL at `127.0.0.1:27888` using whatever REPL client you prefer.

# Tune in next time...

Immutant's clustering capabilities yield some of its coolest features,
e.g. load-balanced message distribution, highly-available services and
scheduled jobs, etc. But clustering is a pain to configure when
multicast is disabled. OpenShift aims to simplify that, but it's
[not quite there yet][883944]. In a future post, I hope to demonstrate
those clustering features by creating a *scaled* OpenShift
application, letting it deal with all the murky cluster configuration
for you.

Stay tuned!

[get started]: https://openshift.redhat.com/community/get-started 
[Immutant Quickstart]: https://github.com/openshift-quickstart/immutant-quickstart
[Lobos]: https://github.com/budu/lobos
[Korma]: http://sqlkorma.com/
[Poorsmatic]: https://github.com/jcrossley3/poorsmatic
[Prismatic]: http://getprismatic.com
[Datomic]: http://www.datomic.com/
[PostgreSQL]: http://www.postgresql.org/
[OpenShift]: http://openshift.com/
[883944]: https://bugzilla.redhat.com/show_bug.cgi?id=883944
[nREPL]: https://github.com/clojure/tools.nrepl
[Swank]: https://github.com/technomancy/swank-clojure
[my recent talk]: http://www.youtube.com/watch?v=P9tfxdcpkCc
