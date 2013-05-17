---
title: 'Installation'
sequence: 0
description: 'An in-depth look at the installation process'
date: 2013-02-26
---

This tutorial provides an in-depth look at the process for installing Immutant.
It covers setting up a development environment and installing
Immutant itself. This tutorial assumes you are on a *nix system. It also assumes you have 
[Leiningen] installed. If not, follow [these instructions] then come back here.

## Installing the lein plugin

We provide a [lein plugin] for creating your Immutant applications and
managing their life-cycles. The last time this tutorial was updated
the plugin was at version **#{site.latest_plugin_version}**, but we
recommend you check [clojars] for the latest version.

The plugin only supports both Leiningen 2.0.0 and higher. 

### Installing under Leiningen

Installing the plugin for Leiningen is just a matter of adding it to the
`:plugin` list in the `:user` profile of `~/.lein/profiles.clj`:

    {:user {:plugins [[lein-immutant "#{site.latest_plugin_version}"]]}}
    

## Plugin tasks

Now that you have the plugin installed, run `lein immutant` to see what tasks it provides:

    $ lein immutant
    undeploy   Undeploys a project from the current Immutant
    new        Creates a new project skeleton initialized for Immutant
    archive    Creates an Immutant archive from a project
    deploy     Deploys a project to the current Immutant
    run        Starts up the current Immutant, displaying its console output
    env        Displays paths to the Immutant that the plugin is currently using
    overlay    Overlays a feature set onto the current Immutant
    init       Adds a sample immutant.init namespace to the current project
    test       Runs a project's tests inside the current Immutant
    version    Prints version info for the current Immutant
    install    Downloads and installs an Immutant version

    Run `lein help immutant $SUBTASK` for subtask details.

We'll only talk about the `install` and `run` tasks in this tutorial -
we cover the application specific management tasks in the [deployment tutorial], 
and cover the `overlay` task in the [overlay tutorial].

## Installing Immutant

Now we need to install an Immutant distribution. You have the option of either 
installing a versioned release or an [incremental build]. Our latest versioned release
is [#{latest_release.version}](#{announcement_for_version(latest_release.version).url})
(released #{format_date(announcement_for_version(latest_release.version).date)}), but if
you want to stay on the cutting edge, you may want to install the latest incremental
build. We generate one after every push to [our repo] if the test suite passes.

The plugin provides an `install` subtask that can install a versioned release,
the latest incremental release, or any prior incremental release.

To install a versioned release, simply pass the version you want to install
as an argument to `immutant install`:

     $ lein immutant install #{latest_release.version}
    Downloading http://repository-projectodd.forge.cloudbees.com/release/org/immutant/immutant-dist/#{latest_release.version}/immutant-dist-#{latest_release.version}-slim.zip
    done!                                                                           
    Extracting /a/nice/long/tmp/path/immutant-dist-#{latest_release.version}-slim.zip
    Extracted /Users/tobias/.lein/immutant/releases/slim/immutant-#{latest_release.version}
    Linking /Users/tobias/.lein/immutant/current to /Users/tobias/.lein/immutant/releases/immutant-#{latest_release.version}

The install subtask will install a *slim* distribution by default, but
will install the *full* distribution if passed the `--full`
option. For more details on the difference between *slim* and *full*,
see the [install](/install) page.

Part of the install process links the most recently installed version to 
`~/.lein/immutant/current` so the plugin can find the Immutant install without
requiring you to set `$IMMUTANT_HOME`. If `$IMMUTANT_HOME` is set, it will
override the `current` link. 

Running it with no arguments will install the latest incremental build:

     $ lein immutant install 
     
If you want to install a specific incremental build, specify the build number
(available from our [builds page][incremental build]):

     $ lein immutant install 705
    
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
[latest incremental build]: http://immutant.org/builds/immutant-dist-slim.zip
[deployment tutorial]: ../deploying/
[overlay tutorial]: ../overlay/
[get in touch]: /community

