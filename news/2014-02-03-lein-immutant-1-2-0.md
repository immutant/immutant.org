---
title: lein-immutant Plugin 1.2.0 Released
author: The Immutant Team
layout: news
tags: [ lein, lein-immutant, installation ]
sequence: 1
---

We just released version [1.2.0](https://clojars.org/lein-immutant) of
our Leiningen plugin. This release contains the following changes:

Features:

* `--log-level` when used with 1.1.0
* `--offset` and `--node-name`
* auto-install
* server


Fixes:

* overlay file perms
* better install management when not using a managed dir?

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

