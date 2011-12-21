---
title: "Getting Started: Installing Immutant"
author: Toby Crawley
layout: news
tags: [ installation, lein, tutorial, getting-started ]
---

<div class="notice big">
  This article is out of date - see our <a href="/news/2011/12/21/installing-redux/">new tutorial</a> for
  the latest instructions for installing Immutant.
</div>

Greetings! This article is the first in a [series of tutorials on getting started][getting-started]
with Immutant. This entry covers setting up a development environment and installing
Immutant. This tutorial assumes you are on a *nix system. It also assumes you have 
[Leiningen] installed. If not, follow [these instructions], then come back here.

## Installing the lein plugin

We provide a [lein plugin] for creating your Immutant applications and 
managing their life-cycles. As of this post, the latest version of the plugin 
is 0.2.0. Check [clojars] for the current version.

Let's install it as a global plugin:

    ~ $ lein plugin install lein-immutant 0.2.0
    Copying 3 files to /a/nice/long/tmp/path/lib
    Including lein-immutant-0.2.0.jar
    Including clojure-1.2.0.jar
    Including commons-exec-1.1.jar
    Including fleet-0.9.5.jar
    Created lein-immutant-0.2.0.jar

Now, run `lein immutant` to see what tasks the plugin provides:

    ~ $ lein immutant
    Manage the deployment lifecycle of an Immutant application.

    Subtasks available:
    new        Create a new project skeleton initialized for immutant.
    init       Adds a sample immutant.clj configuration file to an existing project
    deploy     Deploys the current project to the Immutant specified by $IMMUTANT_HOME
    undeploy   Undeploys the current project from the Immutant specified by $IMMUTANT_HOME
    run        Starts up the Immutant specified by $IMMUTANT_HOME, displaying its console output

We'll only talk about the `run` task today, and save the rest for the next tutorial.

## Installing Immutant

Now we need to install an Immutant distribution. We've yet to make any official
releases, but our [CI] server is setup to publish an [incremental build] every time
we push to the [git repo]. The latest incremental build is always available at
<http://immutant.org/builds/immutant-dist-bin.zip>. 

At this point, I'd love to tell you to install Immutant via:

    lein immutant install # coming soon!
    
But that currently won't work. Until we actually implement that, you'll have to download
and setup Immutant manually. Go ahead and download our [latest incremental build].

Once you have the zip file downloaded, unzip it somewhere handy. For this 
walk-through, I'm going to put it in `~/immutant/`. When unzipped, the distribution
will have the build number in the directory name. It's handy to have a consistent
path to the distribution, allowing us to download other incremental builds in the
future with minimal fuss. To do that, link the distribution to `current`. Here is
my shell session doing just that:

    ~ $ mkdir immutant
    ~ $ cd immutant
    ~/immutant $ unzip -q ../downloads/immutant-dist-bin.zip
    ~/immutant $ ln -s immutant-1.x.incremental.15 current
    ~/immutant $ ls
    current                     immutant-1.x.incremental.15
    ~/immutant $ ls -l
    total 8
    lrwxr-xr-x  1 tobias  staff   27 Nov  7 22:41 current -> immutant-1.x.incremental.15
    drwxrwxr-x  3 tobias  staff  102 Nov  7 13:20 immutant-1.x.incremental.15

Now we'll set a environment variable pointing to the distribution:

    export IMMUTANT_HOME=~/immutant/current
    
This will tell the lein plugin where to find Immutant. Once we implement `lein immutant install`,
this requirement will go away.

## Running Immutant

To verify that Immutant is properly installed, let's fire it up. To do so, 
use the `lein immutant run` command. This is a convenient way to start the Immutant's 
JBoss server, and will run in the foreground displaying the console log. 
You'll see lots of log messages that you can ignore - the
one to look for should be the last message, and will tell you the Immutant was properly
started:

    ~/immutant $ lein immutant run
    Starting Immutant via /Users/tobias/immutant/current/jboss/bin/standalone.sh
    ...
    (a plethora of log messages deleted)
    ...
    22:46:31,663 INFO  [org.jboss.as] (Controller Boot Thread) JBoss AS 7.x.incremental.182 "Ahoy!" started in 2990ms - Started 136 of 200 services (61 services are passive or on-demand)
    
You can kill the Immutant with Ctrl-C.

## Wrapping up

If you've done all of the above, you're now ready to deploy an application. We'll
cover that in our [next tutorial]. 

Since Immutant is still in a pre-alpha state, none of what I
said above is set in stone. If anything does change, I'll edit this post
to keep it accurate. 

If you have any feedback or questions, [get in touch]! 

[getting-started]: /news/tags/getting-started/
[Leiningen]: https://github.com/technomancy/leiningen
[these instructions]: https://github.com/technomancy/leiningen#readme
[lein plugin]: https://github.com/immutant/lein-immutant/
[clojars]: http://clojars.org/lein-immutant
[CI]: https://projectodd.ci.cloudbees.com/view/Immutant/
[incremental build]: /builds
[git repo]: https://github.com/immutant/immutant
[latest incremental build]: http://immutant.org/builds/immutant-dist-bin.zip
[next tutorial]: /news/2011/11/08/deploying-an-application/
[get in touch]: /community






