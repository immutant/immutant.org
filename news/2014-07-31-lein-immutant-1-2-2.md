---
title: lein-immutant Plugin 1.2.2 Released
author: The Immutant Team
layout: news
tags: [ lein, lein-immutant, installation ]
---

We just released version [1.2.2](https://clojars.org/lein-immutant) of
our Leiningen plugin. This release contains the following changes:

* Active profiles are now honored for the `immutant test` task.
* The `immutant run` and `immutant server` tasks no longer give
  spurious profile warnings under lein 2.4.2.

For the full list of changes, see
[the milestone](https://github.com/immutant/lein-immutant/issues?q=milestone%3A1.2.2+is%3Aclosed).

## Get it

If you're already using `lein-immutant` you probably already know how
to do this, but just in case - to install it, add it to the `:plugins`
list in your `:user` profile in `~/.lein/profiles.clj`:

    {:user {:plugins [[lein-immutant "1.2.2"]]}}

## Get in touch

If you have any questions, issues, or other feedback, you can always
find us on [#immutant on freenode](/community/) or you can file an
issue on
[lein-immutant](https://github.com/immutant/lein-immutant/issues).
