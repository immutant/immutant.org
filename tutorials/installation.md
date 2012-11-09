---
title: 'Installation'
sequence: 0
description: 'An in-depth look at the installation process'
date: 2012-11-09
---

This tutorial provides an in-depth look at the process for installing Immutant.
It covers setting up a development environment and installing
Immutant itself. This tutorial assumes you are on a *nix system. It also assumes you have 
[Leiningen] installed. If not, follow [these instructions] then come back here.

## Installing the lein plugin

We provide a [lein plugin] for creating your Immutant applications and 
managing their life-cycles. The last time this tutorial was updated the plugin was
at version **0.13.0**, but we recommend you check [clojars] for the latest version.

The plugin supports both Leiningen 1.x and 2.x. If you are running Leiningen 1.x, version
**1.6.2** or greater should work, but we only test with the latest version (currently **1.7.1**).
If you are using Leiningen 2.x, you need **2.0.0-preview7** or newer.

### Installing under Leinignen 1.x

For this tutorial, we'll install `lein-immutant` as a global plugin that can be used within
any project or outside of a project. The plugin provides several tasks that are useful outside
of a project directory.

To install it as a global plugin:

     $ lein plugin install lein-immutant 0.13.0
    [INFO] Unable to find resource 'lein-immutant:lein-immutant:jar:0.13.0' in repository central (http://repo1.maven.org/maven2)
    Copying 20 files to /var/folders/x0/5th62wkd2cd74dv5fn2trs6h0000gp/T/lein-a1f96bfe-33e8-42aa-893f-be22a6cf6fa7/lib
    Including lein-immutant-0.13.0.jar
    Including clj-http-0.2.7.jar
    Including commons-codec-1.5.jar
    Including commons-io-2.1.jar
    Including commons-logging-1.1.1.jar
    Including core.contracts-0.0.1.jar
    Including core.unify-0.5.3.jar
    Including data.json-0.1.1.jar
    Including deploy-tools-0.9.2.jar
    Including digest-1.4.0.jar
    Including fntest-0.3.2.jar
    Including httpclient-4.1.2.jar
    Including httpcore-4.1.2.jar
    Including httpmime-4.1.2.jar
    Including jboss-as-management-0.1.2.jar
    Including leinjacker-0.3.3.jar
    Including overlay-1.2.2.jar
    Including progress-1.0.1.jar
    Including slingshot-0.9.0.jar
    Including tools.cli-0.2.1.jar
    Including tools.nrepl-0.2.0-beta9.jar
    Created lein-immutant-0.13.0.jar

### Installing under Leiningen 2.x

Installing the plugin for Leiningen 2.x is just a matter of adding it to the
`:plugin` list in the `:user` profile of `~/.lein/profiles.clj`:

    {:user {:plugins [[lein-immutant "0.13.0"]]}}
    

## Plugin tasks

Now that you have the plugin installed, run `lein immutant` to see what tasks it provides:

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
    archive    Creates an Immutant archive from a project
    run        Starts up the Immutant specified by ~/.lein/immutant/current or $IMMUTANT_HOME, displaying its console output
    eval       Eval some code in a remote nrepl
    test       Runs tests inside an Immutant, after starting one (if necessary) and deploying the project

We'll only talk about the `install` and `run` tasks in this tutorial -
we cover the application specific management tasks in the [deployment tutorial], 
and cover the `overlay` task in the [overlay tutorial].

## Installing Immutant

Now we need to install an Immutant distribution. You have the option of either 
installing a versioned release or an [incremental build]. Our latest versioned release
is [#{latest_release.version}](#{announcement_for_version(latest_release.version)})
(released #{format_date(announcement_for_version(latest_release.version).date)}), but if
you want to stay on the cutting edge, you may want to install the latest incremental
build. We generate one after every push to [our repo] if the test suite passes.

The plugin provides an `install` command that can install a versioned release,
the latest incremental release, or any prior incremental release.

To install a versioned release, simply pass the version you want to install
as an argument to `immutant install`:

     $ lein immutant install #{latest_release.version}
    Downloading http://repository-projectodd.forge.cloudbees.com/release/org/immutant/immutant-dist/#{latest_release.version}/immutant-dist-#{latest_release.version}-bin.zip
    done!                                                                           
    Extracting /a/nice/long/tmp/path/immutant-dist-#{latest_release.version}-bin.zip
    Extracted /Users/tobias/.lein/immutant/releases/immutant-#{latest_release.version}
    Linking /Users/tobias/.lein/immutant/current to /Users/tobias/.lein/immutant/releases/immutant-#{latest_release.version}

Part of the install process links the most recently installed version to 
`~/.lein/immutant/current` so the plugin can find the Immutant install without
requiring you to set `$IMMUTANT_HOME`. If `$IMMUTANT_HOME` is set, it will
override the `current` link. 

Running it with no arguments will install the latest incremental build:

     $ lein immutant install 
     
If you want to install a specific incremental build, specify the build number
(available from our [builds page][incremental build]):

     $ lein immutant install 534
    
You can also have it install to a directory of your choosing. In this case, you must
always specify a version (if you want the latest incremental build, specify 
'latest'):

     $ lein immutant install latest /some/other/path
    
`~/.lein/immutant/current` will then be linked to that location.

The `install` command also verifies the sha1 sum of the downloaded artifact, and
will abort the installation if the sum is incorrect.

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
    09:18:03,709 INFO  [org.jboss.as] (Controller Boot Thread) JBAS015874: JBoss AS 7.1.x.incremental.107 "Arges" started in 1610ms - Started 166 of 252 services (85 services are passive or on-demand)
    
You can kill the Immutant with Ctrl-C.

## Wrapping up

If you've done all of the above, you're now ready to deploy an application. We
cover that in our [deployment tutorial]. 

Since Immutant is still in an alpha state, none of what we've
said above is set in stone. If anything does change, We'll update this tutorial
to keep it accurate. 

If you have any feedback or questions, [get in touch]! 

[Leiningen]: https://github.com/technomancy/leiningen
[these instructions]: https://github.com/technomancy/leiningen#readme
[lein plugin]: https://github.com/immutant/lein-immutant/
[clojars]: http://clojars.org/lein-immutant
[incremental build]: /builds
[our repo]: https://github.com/immutant/immutant
[latest incremental build]: http://immutant.org/builds/immutant-dist-bin.zip
[deployment tutorial]: ../deploying/
[overlay tutorial]: ../overlay/
[get in touch]: /community

