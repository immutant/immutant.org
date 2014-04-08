---
title: lein-immutant Plugin 1.2.1 Released
author: The Immutant Team
layout: news
tags: [ lein, lein-immutant, installation ]
sequence: 1
---

We just released version [1.2.1](https://clojars.org/lein-immutant) of
our Leiningen plugin. This release contains the following changes:

* Archives that include their dependencies now have deploy-time
  dependency resolution disabled by default.
* Archives that include their dependencies now also include any plugin
  dependencies as well, though they will only be recognized by
  [Immutant 1.1.1] or newer.
* The `archive` subtask now takes a `--version` flag, which will cause
  the project version to be appended to the artifact name.
* The `archive`, `deploy`, `server`, and `test` subtasks now trigger
  execution of any `:prep-tasks` (which are, by default, `javac` and
  `compile`).

For the full list of changes, see [the milestone](https://github.com/immutant/lein-immutant/issues?milestone=15&state=closed).

## Get it

If you're already using `lein-immutant` you probably already know how
to do this, but just in case - to install it, add it to the `:plugins`
list in your `:user` profile in `~/.lein/profiles.clj`:

    {:user {:plugins [[lein-immutant "1.2.1"]]}}

## Get in touch

If you have any questions, issues, or other feedback, you can always
find us on [#immutant on freenode](/community/) or you can file an
issue on
[lein-immutant](https://github.com/immutant/lein-immutant/issues).

[Immutant 1.1.1]: ../announcing-1-1-1/
