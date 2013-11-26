---
title: 'Installation'
sequence: 0
description: 'An in-depth look at the installation process'
date: 2013-10-10
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

The plugin only supports Leiningen 2.0.0 and higher. 

### Installing under Leiningen

Installing the plugin for Leiningen is just a matter of adding it to the
`:plugin` list in the `:user` profile of `~/.lein/profiles.clj`:

    {:user {:plugins [[lein-immutant "#{site.latest_plugin_version}"]]}}
    

## Plugin tasks

The plugin provides several subtasks, but this tutorial will only
focus on `install` and `run`. To list all of them, simply run `lein
immutant`:

    $ lein immutant

## Installing Immutant

Now we need to install an Immutant distribution. You have the option of either 
installing a versioned release or an [incremental build]. Our latest versioned release
is [#{latest_release.version}](#{announcement_for_version(latest_release.version).url})
(released #{format_date(announcement_for_version(latest_release.version).date)}), but if
you want to stay on the cutting edge, you may want to install the latest incremental
build. We generate one after every push to [our repo] if our
comprehensive test suite passes.

The plugin provides an `install` subtask that can install a versioned release,
the latest incremental release, or any prior incremental release.

To install the latest versioned release, call `immutant install` with no arguments:

    $ lein immutant install
    Downloading http://repository-projectodd.forge.cloudbees.com/release/org/immutant/immutant-dist/#{latest_release.version}/immutant-dist-#{latest_release.version}-slim.zip
    done!                                                                           
    Extracting /a/nice/long/tmp/path/immutant-dist-#{latest_release.version}-slim.zip
    Extracted /Users/tobias/.immutant/releases/slim/immutant-#{latest_release.version}-slim
    Linking /Users/tobias/.immutant/current to /Users/tobias/.immutant/releases/immutant-#{latest_release.version}-slim

The `install` subtask will install a *slim* distribution by default, but
will install the *full* distribution if passed the `--full`
option. For more details on the difference between *slim* and *full*,
see the [install](/install) page.

Part of the install process links the most recently installed version to 
`~/.immutant/current` so the plugin can find the Immutant install without
requiring you to set `$IMMUTANT_HOME`. If `$IMMUTANT_HOME` is set, it will
override the `current` link. 

Passing the special word `LATEST` will install the latest incremental
build:

    $ lein immutant install LATEST
     
If you want to install a specific version (either an incremental build
or a release), specify the build number (available from our
[builds page][incremental build]) for an incremental build:

    $ lein immutant install 705
     
or a version for a release:

    $ lein immutant install #{latest_release.version}

You can list your installations, and see the current one, with the
`list` subtask:

    $ lein immutant list -i

The `install` command also verifies the sha1 sum of the downloaded
artifact, and will abort the installation if the sum is incorrect.

You can override the plugin base directory (`~/.immutant`) by setting
`$LEIN_IMMUTANT_BASE_DIR` or by adding `:lein-immutant {:base-dir
"/path"}` to your user profile in `.lein/profiles.clj` or to your
`project.clj`. Setting the base directory in `project.clj` will
override the setting in `.lein/profiles.clj`. Using the environment
variable will override both.

## Running Immutant

To verify that Immutant is properly installed, let's fire it up. To do
so, use the `lein immutant run` command. This is a convenient way to
start the Immutant's JBoss server, and will run in the foreground
displaying the console log. You'll see lots of log messages that you
can ignore - the one to look for should be the last message, and will
tell you the Immutant was properly started:

    $ lein immutant run
    Starting Immutant via /Users/tobias/.immutant/current/jboss/bin/standalone.sh
    ...
    (a plethora of log messages deleted)
    ...
    09:18:03,709 INFO  [org.jboss.as] (Controller Boot Thread) JBAS015874: JBoss AS 7.1.x.incremental.107 "Arges" started in 1610ms - Started 166 of 252 services (85 services are passive or on-demand)
    
You can kill the Immutant with Ctrl-C.

## Wrapping up

If you've done all of the above, you're now ready to deploy an application. We
cover that in our [deployment tutorial]. 

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

