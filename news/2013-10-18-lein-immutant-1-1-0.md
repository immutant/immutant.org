---
title: lein-immutant Plugin 1.1.0 Released
author: The Immutant Team
layout: news
tags: [ lein, lein-immutant, installation ]
sequence: 1
---

We just released version [1.1.0](https://clojars.org/lein-immutant) of
our Leiningen plugin. This release contains the following changes:

* The `immutant archive` subtask now includes dependencies by
  default. To exclude them, pass `--exclude-dependencies` or `-e` to
  the task.

* The `immutant test` subtask now runs tests in an Immutant container
  that uses a different set of network ports than the defaults, and
  writes its logs to `target/isolated-immutant/log/`. This allows you
  to keep your development Immutant up while running your tests,
  without the development and test deployments of your application
  interfering with each other.

* The `immutant new` and `immutant init` subtasks have been removed,
  since they provided little value, and cluttered an already large
  subtask list.

* The `immutant overlay` subtask now copies the current Immutant
  install before applying the overlay, allowing you to roll back to
  the prior version.
  
* The `immutant install` task can now install a runnable Immutant
  without requiring the `unzip` binary to be installed on non-Windows
  systems.

## Get it

If you're already using `lein-immutant` you probably already know how
to do this, but just in case - to install it, add it to the `:plugins`
list in your `:user` profile in `~/.lein/profiles.clj`:

    {:user {:plugins [[lein-immutant "1.1.0"]]}}

## Get in touch

If you have any questions, issues, or other feedback, you can always
find us on [#immutant on freenode](/community/) or you can file an
issue on
[lein-immutant](https://github.com/immutant/lein-immutant/issues).

