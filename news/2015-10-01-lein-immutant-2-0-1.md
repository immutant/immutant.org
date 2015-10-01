---
title: New versions of Leiningen and Boot plugins
author: The Immutant Team
layout: news
tags: [ lein, lein-immutant, boot, boot-immutant, installation ]
---

This announcement only pertains to those who deploy their applications
to [WildFly] or [EAP].

We just released version [2.0.1] and of [lein-immutant] and version
[0.4.0] of [boot-immutant]. Both releases fix an [issue] where "dev"
wars were no longer deployable if they used [Immutant 2.1.

`lein-immutant` and `boot-immutant` are plugins, for [Leiningen] and
[Boot] respectively, that are required for your application to run on
[WildFly] or [EAP]. Specifically, they provide tasks for packaging
your app as a WAR file and testing it "inside" the container.
             
If you have any questions, issues, or other feedback, you can always
find us on [#immutant on freenode or or mailing list](/community/) or
you can file an issue on the appropriate project.

[2.0.1]: https://clojars.org/lein-immutant
[lein-immutant]: https://github.com/immutant/lein-immutant/
[0.4.0]: https://clojars.org/boot-immutant
[boot-immutant]: https://github.com/immutant/boot-immutant/
[issue]: https://github.com/immutant/lein-immutant/issues/111
[Immutant 2.1.0]: ../announcing-2-1-0/
[WildFly]: /documentation/2.1.0/apidoc/guide-wildfly.html
[EAP]: /documentation/2.1.0/apidoc/guide-EAP.html
[Leiningen]: http://leiningen.org/
[Boot]: http://boot-clj.com/
