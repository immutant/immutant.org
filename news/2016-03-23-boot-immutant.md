---
title: An Immutant Plugin For Boot Redux
author: Toby Crawley
layout: news
tags: [ boot, wildfly ]
---

Last year, we [released] a [Boot] plugin for building Immutant WAR
archives for deploying to the [WildFly] application server. This
initial version was basically a port of the [lein-immutant] plugin
and didn't really behave as a proper Boot plugin should (mainly by
writing outside of and ignoring files in the fileset).

This made it difficult to use the plugin for anything other than a
vanilla project, so we rewrote the plugin to be a better Boot citizen.

The new plugin provides two tasks: `boot.immutant/gird` and
`boot.immutant/test-in-container`. The `gird` task adds the files
needed to activate an Immutant application in WildFly to the fileset,
allowing you to use standard Boot tasks to assemble the other contents
and actually create the war:

<pre class="syntax clojure">(require '[boot.immutant :refer :all])

(deftask build-war []
  (comp
    (uber :as-jars true)
    (aot :all true)
    (gird :init-fn 'my-app.core/init)
    (war)
    (target)))
</pre>

For more details on the `gird` task, see the [deployment guide].

The `test-in-container` task will take an Immutant WAR, spin up a
WildFly container, deploy the WAR, run your tests, and shut it
down. To build on the above example:

<pre class="syntax clojure">(deftask run-tests []
  (comp
    (build-dev-war)
    (test-in-container)))
</pre>

For more details on the `test-in-container` task, see the
[testing guide].

If you're a Boot + Immutant + WildFly user, please see the [README]
for installation instructions, give it a try and let us know if you
run in to any issues, either through the [usual channels] or by filing
an [issue].

[released]: /news/2015/05/20/boot-immutant/
[Boot]: http://boot-clj.com/
[WildFly]: http://immutant.org/documentation/current/apidoc/guide-wildfly.html
[lein-immutant]: https://github.com/immutant/lein-immutant/
[boot-immutant]: https://github.com/immutant/boot-immutant/
[deployment guide]: https://github.com/immutant/boot-immutant/blob/master/resources/deployment-guide.md
[testing guide]: https://github.com/immutant/boot-immutant/blob/master/resources/testing-guide.md
[README]: https://github.com/immutant/boot-immutant#installation
[usual channels]: http://immutant.org/community/
[issue]: https://github.com/immutant/boot-immutant/
