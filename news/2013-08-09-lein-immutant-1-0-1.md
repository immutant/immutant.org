---
title: lein-immutant Plugin 1.0.1 Released
author: The Immutant Team
layout: news
tags: [ lein, lein-immutant, installation ]
---

We just released version [1.0.1](https://clojars.org/lein-immutant) of
our Leiningen plugin. This is a patch release, with the following
changes:

* Archive creation no longer uses `lib/` as a staging area for
  dependencies - this prevents stale dependencies from being picked up
  in development after creating an archive.
* Archives are no longer created in the current directory, but under
  `project-root/target/` instead. The exact location will depend on
  the profiles that are active. The archive command will output the
  full path to the archive.
* The url used by the `install` and `overlay` tasks to download
  Immutant has been changed to use a
  [CDN](https://aws.amazon.com/cloudfront/). This should provide
  shorter download times, and allows us to track download counts to
  get a feel for usage.

## Get it

If you're already using `lein-immutant` you probably already know how
to do this, but just in case - to install it, add it to the `:plugins`
list in your `:user` profile in `~/.lein/profiles.clj`:

    {:user {:plugins [[lein-immutant "1.0.1"]]}}

## Get in touch

If you have any questions, issues, or other feedback, you can always
find us on [#immutant on freenode](/community/) or you can file an
issue on
[lein-immutant](https://github.com/immutant/lein-immutant/issues).

