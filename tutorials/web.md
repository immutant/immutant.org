---
title: Web
sequence: 1.5
description: "Deploying web apps built with popular Clojure libraries"
date: 2014-02-03
---

There are a number of popular Clojure web frameworks and libraries.
Most are based on [Ring] and most provide a [Leiningen] application
template that includes [lein-ring] configuration, i.e. a `:ring` key
in your `project.clj` file that contains a map of options.

Immutant can deploy these applications natively, without any
additional configuration required.

## Compojure

[Compojure] is a small routing library for Ring apps upon which many
other Clojure web frameworks are based, though it's quite useful on
its own. Normally, you create a new compojure app like so:

    $ lein new compojure compy
    $ cd compy
    $ lein ring server

This results in a basic "hello world" app available at
<http://localhost:3000/>. As you edit and save your project files,
changes are automatically reflected when you refresh your browser.

The Immutant experience is similar: just use the [lein-immutant]
plugin instead of [lein-ring]:

    $ lein new compojure compy
    $ cd compy
    $ lein immutant server

The `server` subtask was introduced in version 1.2.0 of
[lein-immutant]. It conveniently encapsulates the `install` (if
necessary), `deploy` and `run` subtasks of the same plugin. The
concept of application *deployment* is fundamental to Immutant. A
single Immutant process may have multiple apps deployed to it, and
each is distinguished by a context path matching its project name, by
default: <http://localhost:8080/compy>. If you prefer to mount your
app at the root context, add this to your project.clj:

    :immutant {:context-path "/"}
    
See the [deployment] tutorial for more details.

Once deployed, changes to your project's source files are reflected
whenever you reload your browser. Further, an nREPL service is
provided for each deployed app, enabling a much richer development
experience. The port it's bound to is logged and written to a
well-known file in your project directory that most Clojure editors
should recognize.

You could kill the server at this point by typing Ctrl-c, but leave it
up instead (you'll see why below), and open a new shell to explore a
couple other frameworks.

## Other Ring-based Frameworks

[Luminus] is a micro-framework based on a set of lightweight
libraries including compojure, among others. 

    $ cd ..
    $ lein new luminus lumpy

And [Caribou] is yet another Ring-based framework that will deploy on
Immutant right out of the box:

    $ cd ..
    $ lein new caribou carrie
    $ cd carrie
    $ lein caribou migrate resources/config/development.clj

At this point you have a choice to make: if you didn't kill the
Immutant running *compy* above, you can deploy *carrie* to the same
instance:

    $ lein immutant deploy

Check the output in your *compy* shell to see *carrie* being deployed.

Or if you did kill the *compy* server, you can run the `server` task
again, but note that now both *compy* and *carrie* will be deployed,
each with their own nREPL service and isolated classpath. You can use
the `list` subtask to list your deployed apps, and the `undeploy` task
to remove them.

    $ lein immutant list
    $ lein immutant undeploy compy
    $ lein immutant server

Note that we're running Immutant from our *carrie* project directory.
This is due to Caribou relying on some relative paths, e.g. `app/`, in
its configuration. This is fine for development, but should be changed
to an absolute path before deploying to a production Immutant.

Finally, note that Caribou sets the `[:immutant :context-path]` to `/`
in its project.clj, so to test it, you'll need to visit
<http://localhost:8080/>

## Pedestal

Another exciting Clojure web framework is [Pedestal], but it's not
based on Ring. So instead of a handler, its entry-point is a special
servlet comprised of a stack of "interceptors". Creating a Pedestal
service app is straightforward:

    $ lein new pedestal-service peddy

But before we deploy it, we need a way to make its servlet known to
Immutant when deployed. One simple way is to add an `immutant.init`
namespace to our app. Write the following to
`peddy/src/immutant/init.clj`:

    (ns immutant.init
      (:require [immutant.web             :as web]
                [io.pedestal.service.http :as http]
                [peddy.service            :as app]))
    (web/start-servlet "/" (::http/servlet (http/create-servlet app/service)))

Now we can deploy the app:

    $ lein immutant deploy peddy

And visit it at <http://localhost:8080/peddy>

## Interactive Development

Regardless of which Clojure web framework you choose, there is much
nerd joy to be had evolving your app at a REPL. Each app you deploy
will have its own nREPL service when deployed with the `:dev` profile
active (the default). And you can interact with all the Immutant
services easily while your app is deployed and running, even writing
and running tests that rely on those services, obviating the need for
any tedious mocking frameworks or the annoying packaging and
deployment steps typically required by Java app servers.

Please leave your comments or questions below if we can further
clarify running any of the above applications (or any others!) on
Immutant.

[deployment]: ../deploying/
[lein-ring]: https://github.com/weavejester/lein-ring
[lein-immutant]: https://github.com/immutant/lein-immutant
[Ring]: https://github.com/ring-clojure/ring
[Leiningen]: https://github.com/technomancy/leiningen
[Compojure]: https://github.com/weavejester/compojure
[Luminus]: http://www.luminusweb.net/
[Pedestal]: http://pedestal.io/
[Caribou]: http://let-caribou.in/
