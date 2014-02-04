---
title: lein-immutant Plugin 1.2.0 Released
author: The Immutant Team
layout: news
tags: [ lein, lein-immutant, installation ]
sequence: 1
---

We just released version [1.2.0](https://clojars.org/lein-immutant) of
our Leiningen plugin. This release contains the following changes:

* You can now pass `--log-level` to the `immutant run` task to adjust
  the logging level for the console and `server.log` output. This only works
  with [Immutant 1.1.0] or newer.
* The `immutant run` task also now takes `--offset` and `--node-name`
  options as shortcuts for using a
  [port offset](/tutorials/clustering/) and for setting the node name
  when [in a cluster](/tutorials/clustering/).
* There is now an `immutant server` task that is analogous to `ring
  server`. It will install Immutant (if not already installed), deploy
  the current application, run Immutant, and open the first web
  handler registered by the app in a browser (this latter step
  requires [Immutant 1.1.0]).
* Tasks that require Immutant to be installed (`deploy`, `run`,
  `server`, `test`) will now automatically install the latest
  versioned release if no Immutant is available.
* A few minor fixes around the overlay task, including preserving
  proper executable permissions on scripts in the overlaid install.

For the full list of changes, see [the milestone](https://github.com/immutant/lein-immutant/issues?milestone=13&state=closed).

## Get it

If you're already using `lein-immutant` you probably already know how
to do this, but just in case - to install it, add it to the `:plugins`
list in your `:user` profile in `~/.lein/profiles.clj`:

    {:user {:plugins [[lein-immutant "1.2.0"]]}}

## Get in touch

If you have any questions, issues, or other feedback, you can always
find us on [#immutant on freenode](/community/) or you can file an
issue on
[lein-immutant](https://github.com/immutant/lein-immutant/issues).

[Immutant 1.1.0]: ../announcing-1-1-0/
