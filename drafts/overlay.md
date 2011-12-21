---
title: 'Overlaying an Immutant onto a TorqueBox'
author: Jim Crossley
layout: news
tags: [ overlay, torquebox, polyglot, app-server ]
---

Recently, we've made some progress toward the promise of a polyglot
application server. With the introduction of the [Overlay] project,
it's now very easy to create a single app server capable of deploying
both Ruby and Clojure (not to mention Java, of course) applications.

For your convenience, we've set up a job on our CI server to overlay
the latest Immutant build atop the latest [TorqueBox] build whenever
either is updated. So you can be on the bleeding edge of both projects
by downloading and extracting this link:

  <http://immutant.org/builds/torquebox-immutant.zip>

For Clojure development, set `IMMUTANT_HOME` to the extracted directory
and [proceed as you normally would][deploying].

Ruby development is only slightly trickier. Set `TORQUEBOX_HOME` to
the same extracted directory and ensure that you're using the provided
jruby, i.e. put `$TORQUEBOX_HOME/jruby/bin` in the front of your
`PATH`. You should also unset `JBOSS_HOME`, `JRUBY_HOME`, `GEM_HOME`,
and `GEM_PATH`, too -- at least until you know things are working. Oh,
and I recommend using the `bin/torquebox` command to deploy your apps,
but the TorqueBox rake tasks should work fine, too.

Start the server however you're comfortable, either using the
[Leiningen] Immutant plugin, the [TorqueBox] command or even the
standard JBoss commands. It will start up all the apps you've deployed
to it, regardless of their language.

If you'd rather use your own jruby, and you've already installed the
`torquebox-server` gem, you can overlay the latest Immutant yourself
by cloning [Overlay] locally, installing [Leiningen] and running the
following:

    $ lein run $(torquebox env TORQUEBOX_HOME) immutant

All that's left is to set `IMMUTANT_HOME`:

    $ export IMMUTANT_HOME=$(torquebox env TORQUEBOX_HOME)

Now you're ready to get your polyglot on! If you have any trouble at
all, please drop by #torquebox or #immutant on freenode, and we'll get
you going.

[TorqueBox]: http://torquebox.org/
[Overlay]: http://github.com/immutant/overlay
[deploying]: http://immutant.org/news/2011/11/08/deploying-an-application/
[Leiningen]: https://github.com/technomancy/leiningen
