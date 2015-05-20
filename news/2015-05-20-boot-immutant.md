---
title: An Immutant Plugin For Boot
author: Toby Crawley
layout: news
tags: [ boot, wildfly ]
---

[Boot] is an interesting new build tool for Clojure from [Alan Dipert]
and [Micha Niskin] \(if you're not familiar with it, Alan & Micha gave
a great [intro at Clojure/West]).

To support the (possibly empty) set of Immutant 2.x users that use
Boot *and* [deploy to WildFly], we've ported the functionality of our
[lein-immutant] plugin to Boot, and have released the cleverly-named
[boot-immutant].

boot-immutant provides two tasks: `immutant-war` and `immutant-test`,
which are analogous to the `immutant war` and `immutant test` tasks
from lein-immutant, respectively.

We consider the current release ([0.3.0]) beta quality. If you're in
the exclusive set would find this plugin useful, give it a try and let
us know if you run in to any issues, either through the
[usual channels] or by filing an [issue].

[Boot]: http://boot-clj.com/
[Alan Dipert]: https://github.com/alandipert
[Micha Niskin]: https://github.com/micha
[intro at Clojure/West]: https://www.youtube.com/watch?v=TcnzB2tB-8Q
[deploy to WildFly]: http://immutant.org/documentation/current/apidoc/guide-wildfly.html
[lein-immutant]: https://github.com/immutant/lein-immutant/
[boot-immutant]: https://github.com/immutant/boot-immutant/
[0.3.0]: https://clojars.org/boot-immutant/versions/0.3.0
[usual channels]: http://immutant.org/community/
[issue]: https://github.com/immutant/boot-immutant/
