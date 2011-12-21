---
title: "Getting Started: Installing Immutant v2"
author: Toby Crawley
layout: news
sequence: 1
tags: [ installation, lein, tutorial, getting-started ]
---

Greetings! This article covers the new, improved method for installing Immutant, and
replaces the [first] in the [getting started series of tutorials][getting-started]
with Immutant. This entry covers setting up a development environment and installing
Immutant. This tutorial assumes you are on a *nix system. It also assumes you have 
[Leiningen] installed. If not, follow [these instructions], then come back here.

## Installing the lein plugin

We provide a [lein plugin] for creating your Immutant applications and 
managing their life-cycles. As of this post, the latest version of the plugin 
is 0.3.1. Check [clojars] for the current version.

Let's install it as a global plugin:

     $ lein plugin install lein-immutant 0.3.1
    Copying 3 files to /a/nice/long/tmp/path/lib
    Including lein-immutant-0.3.1.jar
    Including clojure-1.2.0.jar
    Including clojure-contrib-1.2.0.jar
    Including data.json-0.1.1.jar
    Including fleet-0.9.5.jar
    Including overlay-1.0.1.jar
    Including progress-1.0.1.jar
    Created lein-immutant-0.3.0.jar

Now, run `lein immutant` to see what tasks the plugin provides:

     $ lein immutant
    Manage the deployment lifecycle of an Immutant application.

    Subtasks available:
    install    Downloads and installs Immutant
    overlay    Overlays features onto ~/.lein/immutant/current or $IMMUTANT_HOME
    env        Displays paths to the Immutant that the plugin can find
    new        Creates a new project skeleton initialized for Immutant
    init       Adds a sample immutant.clj configuration file to an existing project
    deploy     Deploys the current project to the Immutant specified by ~/.lein/immutant/current or $IMMUTANT_HOME
    undeploy   Undeploys the current project from the Immutant specified by ~/.lein/immutant/current or $IMMUTANT_HOME
    run        Starts up the Immutant specified by ~/.lein/immutant/current or $IMMUTANT_HOME, displaying its console output

We'll only talk about the `install`, and `run` tasks in this article -
we covered the application specific management tasks in our [second tutorial].

## Installing Immutant

Now we need to install an Immutant distribution. We've yet to make any official
releases, but our [CI] server is setup to publish an [incremental build] every time
we push to the [git repo]. The latest incremental build is always available at
<http://immutant.org/builds/immutant-dist-bin.zip>. The [previous version][first] of 
this tutorial walked you through downloading and installing the latest incremental
manually, but with the new `install` task, that's no longer necessary - the
`install` task will download and install the latest incremental build for you. 
Let's see that in action:

     $ lein immutant install
    Downloading http://repository-projectodd.forge.cloudbees.com/incremental/immutant/LATEST/immutant-dist-bin.zip
    done!                                                                           
    Extracting /a/nice/long/tmp/path/lib/immutant-dist-bin.zip
    Extracted /Users/tobias/.lein/immutant/releases/immutant-1.x.incremental.51
    Linking /Users/tobias/.lein/immutant/current to /Users/tobias/.lein/immutant/releases/immutant-1.x.incremental.51
    
Part of the install process links the most recently installed version to 
`~/.lein/immutant/current` so the plugin can find the Immutant install without
requiring you to set `$IMMUTANT_HOME`. If `$IMMUTANT_HOME` is set, it will
override the `current` link. 

If you want to install a specific incremental build, specify the build number
(available from our [builds page][incremental build]) as an argument to lein:

     $ lein immutant install 50
    
You can also have it install to a directory of your choosing (if you want the latest
build, specify 'latest' as the version):

     $ lein immutant install latest /some/other/path
    
`~/.lein/immutant/current` will be linked to that location.

## Running Immutant

To verify that Immutant is properly installed, let's fire it up. To do so, 
use the `lein immutant run` command. This is a convenient way to start the Immutant's 
JBoss server, and will run in the foreground displaying the console log. 
You'll see lots of log messages that you can ignore - the
one to look for should be the last message, and will tell you the Immutant was properly
started:

     $ lein immutant run
    Starting Immutant via /Users/tobias/.lein/immutant/current/jboss/bin/standalone.sh
    ...
    (a plethora of log messages deleted)
    ...
    09:18:03,709 INFO  [org.jboss.as] (Controller Boot Thread) JBoss AS 7.1.0.Beta1 "Tesla" started in 2143ms - Started 149 of 211 services (61 services are passive or on-demand)
    
You can kill the Immutant with Ctrl-C.

## Wrapping up

If you've done all of the above, you're now ready to deploy an application. We
covered that in our [second tutorial]. 

Since Immutant is still in a pre-alpha state, none of what I
said above is set in stone. If anything does change, We'll update this post
to keep it accurate. 

If you have any feedback or questions, [get in touch]! 

[first]: /news/2011/11/08/installing/
[getting-started]: /news/tags/getting-started/
[Leiningen]: https://github.com/technomancy/leiningen
[these instructions]: https://github.com/technomancy/leiningen#readme
[lein plugin]: https://github.com/immutant/lein-immutant/
[clojars]: http://clojars.org/lein-immutant
[CI]: https://projectodd.ci.cloudbees.com/view/Immutant/
[incremental build]: /builds
[git repo]: https://github.com/immutant/immutant
[latest incremental build]: http://immutant.org/builds/immutant-dist-bin.zip
[second tutorial]: /news/2011/11/08/deploying-an-application/
[get in touch]: /community






