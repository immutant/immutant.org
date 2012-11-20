---
title: Overlay
description: 'Mix TorqueBox and Immutant to run Ruby and Clojure apps together'
sequence: 6
date: 2012-09-25
---

The [Overlay] project makes it very easy to create a single JBoss app
server capable of deploying both Ruby and Clojure (and Java, of
course) applications.

## Laying TorqueBox over Immutant

The same [Leiningen Immutant plugin][plugin] that you use to install
Immutant may be used to overlay the latest [TorqueBox] as well:

    $ lein immutant overlay torquebox

And voila, your Immutant is suddenly also a TorqueBox! Now we need to
set up your environment for TorqueBox development.

    $ export TORQUEBOX_HOME=$HOME/.lein/immutant/current
    $ export PATH=$TORQUEBOX_HOME/jruby/bin:$PATH

The TorqueBox distribution provides its own JRuby with the TorqueBox
gems pre-installed. You can now use the `torquebox` command to deploy
your Ruby applications to your Immutant!

## Laying Immutant over TorqueBox

If you'd rather use your own JRuby, and you've already installed the
`torquebox-server` gem, you can overlay the latest Immutant by cloning
the [Overlay] project locally, installing [Leiningen] (version 2) and
running the following:

    $ lein overlay $(torquebox env TORQUEBOX_HOME) immutant

All that's left is to set `IMMUTANT_HOME` and [proceed as you normally would][deploying]:

    $ export IMMUTANT_HOME=$(torquebox env TORQUEBOX_HOME)

The [Overlay] project is capable of overlaying features from any JBoss
AS7 distribution onto another one.

## Convenient Combo-Pack

For your convenience, we've set up a job on our CI server to overlay
the latest Immutant build atop the latest [TorqueBox] build whenever
either is updated. So you can be on the bleeding edge of both projects
by downloading and extracting this link:

  <http://immutant.org/builds/torquebox-immutant.zip>

Set both `TORQUEBOX_HOME` and `IMMUTANT_HOME` to the extracted
directory, and...

## Get Your Polyglot On!

Your overlaid server may be started however you're comfortable: either
using the [Leiningen] Immutant plugin, the [TorqueBox] command or even
the standard JBoss commands. It will start up all the apps you've
deployed to it, regardless of their language.

[TorqueBox]: http://torquebox.org/
[Overlay]: http://github.com/immutant/overlay
[deploying]: ../deploying/
[Leiningen]: http://leiningen.org/
[plugin]: ../installation/
