---
title: lein-immutant Plugin 1.0.0.beta1 Released
author: The Immutant Team
layout: news
tags: [ lein, lein-immutant, installation ]
---

As we [approach a 1.0.0 of Immutant](../announcing-1-0-0-beta1/), we've also been focusing on
getting our
[Leiningen plugin](https://github.com/immutant/lein-immutant/) ready
for a 1.0.0 release as well.

Today, we're as pleased as a
[punch bug player](http://en.wikipedia.org/wiki/Punch_buggy) to
announce the first 1.0.0 beta release of the plugin: **1.0.0.beta1**. 

For 1.0.0.beta1, we've made quite a few changes to the plugin, some of
which are not backwards compatible. We'll talk about all of the
changes, starting with the breaking ones.

## The base install dir location and structure

When we wrote the initial version of the plugin, we used
`.lein/immutant` as base directory for storing Immutant installs and
other files. But as the plugin has grown, we've realized that's not
the best place for storing those files, since they aren't Leiningen
specific. Therefore, we've moved the base directory to `~/.immutant`.

In addition, we've reorganized layout of `~/.immutant/releases` to be
a bit cleaner.

### What happens then when I upgrade to 1.0.0.beta1 of the plugin?

Since the new plugin will be looking in `~/.immutant`, it won't see
the prior installs in `~/.lein/immutant`. We recommend you remove
`~/.lein/immutant` and re-install any versions of Immutant that you
need.

If you would rather keep your existing base directory, you have two
options:

* The plugin now supports overriding the base directory, either by
  setting an environment variable (`$LEIN_IMMUTANT_BASE_DIR`) or by
  adding `:lein-immutant {:base-dir "/path"}` to your user profile in
  `.lein/profiles.clj` or to your `project.clj`. Setting the base
  directory in `project.clj` will override the setting in
  `.lein/profiles.clj`. Using the environment variable will override
  both. 
* You can copy `~/.lein/immutant` to `~/.immutant`. However, the
  `current` link is absolute, and will have to be manually corrected.

If you do keep your old base directory, you will be unable to use
`lein immutant install` to switch the `current` version between
versions that were installed by an older plugin. If that's a feature
that you use, we strongly urge you to let the plugin create and manage
the new base directory.

## The plugin now installs the latest release by default

Pre-1.0.0.beta1, the plugin installed the latest incremental build
when you executed `lein immutant install`. As we approach 1.0.0 of
Immutant, we've changed the plugin to install the latest stable
release instead.

So, to install the latest stable release:

    lein immutant install
    
If you want to install the latest incremental build:

    lein immutant install :latest
    
You can still specify any stable release version or incremental build
number to get an exact version.

## Listing installed versions

A couple of releases ago, we added the `lein immutant list` command
that lists currently deployed applications. In 1.0.0.beta1, this
command has been extended with a `--installs` flag (or `-i`) to list
all of the installed Immutant versions instead of deployments:

    $ lein immutant list --installs
    The following versions of Immutant are installed to /home/tobias/.immutant
    (* is currently active via /home/tobias/.immutant/current):

       0.10.0                         (type: full)
       0.10.0                         (type: slim)
       0.6.0                          (type: full)
       0.9.0                          (type: slim)
       0.9.0                          (type: full)
     * 1.0.0.beta1                    (type: slim)
       1.x.incremental.879            (type: slim)
       1.x.incremental.882            (type: slim)
       
You'll also now see this list after every `lein immutant install` invocation.

## Get it

If you're already using `lein-immutant` you probably already know how
to do this, but just in case - to install it, add it to the `:plugins`
list in your `:user` profile in `~/.lein/profiles.clj`:

    {:user {:plugins [[lein-immutant "1.0.0.beta1"]]}}

## Get in touch

We realize this release has quite a few changes, and we may not have
all of the kinks worked out. If you have any questions, issues, or
other feedback, you can always find us on
[#immutant on freenode](/community/) or you can file an issue on
[lein-immutant](https://github.com/immutant/lein-immutant/issues).

