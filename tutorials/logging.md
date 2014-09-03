---
title: 'Logging'
sequence: 6
description: 'Altering the logging configuration for your application'
date: 2014-09-03
---

By default, Immutant uses [slf4j] and [logback] for logging. Any log
messages that Immutant itself generates will be handled by logback, as
will anything your app logs via [clojure.tools.logging] or to
stderr/stdout.

If the default logging configuration doesn't meet your needs, you can
provide an alternate logback configuration, or replace logback with
some other slf4j provider.

## The default logback configuration

By default, logback is configured to log at `INFO` and below to the
console, with some of the chattier libraries we bring in configured at
`WARN` and below. The output looks like:

    23:58:53.313 INFO  [my-app.core] (main) an info message
    23:58:53.313 WARN  [my-app.core] (main) a warning message
    23:58:53.313 ERROR [my-app.core] (main) an error message
    23:58:53.450 INFO  [org.projectodd.wunderboss.web.Web] (main) Registered web context /

The [default configuration] is only applied when logback is available
and no custom config is provided.

## Overriding the default configuration

If you want a different format for your log messages, want to send
them to a file, or configure any of the other [myriad options], you
can either provide a [logback.xml] file on the classpath of your app
(in `resources/` should work), or set the `logback.configurationFile`
to the path to the file, or to the resource name if you're using
something other than `logback.xml`.

When defining a custom configuration, it may be useful to use the
[default configuration] as a starting point.

**Note**: If you're using 2.0.0-alpha1 and provide your own configuration,
you'll see warnings from logback about finding multiple `logback.xml`
files. You can ignore the warning, or update to the latest [incremental
build] to make it go away.

### Overriding the default configuration inside WildFly

In order to use a custom `logback.xml` with an application deployed to
[WildFly], you'll need to do a little more work.

First, you'll need to prevent your app from using the built-in logging
subsystem. To do that, you'll need to modify the
`jboss-deployment-structure.xml` file that gets placed in the war's
`WEB-INF/` directory. You'll need to modify the stock version - to get
it, run:

    lein immutant war

In addition to generating a war file, this also dumps a copy of the
default `jboss-deployment-structure.xml` to `target/`. Grab that and
copy it to `war-resources/WEB-INF/` in the root of your
application. Then, add the following to it:

    <exclude-subsystems>
      <subsystem name="logging" />
    </exclude-subsystems>

You'll also need to put your `logback.xml` in `war-resources/WEB-INF/lib/`.

Finally, in order for your custom resources to be included in the war
file, you'll need to add the following to your `project.clj`:

<pre class="syntax clojure">
  :immutant {:war {:resource-paths ["war-resources"]}}
</pre>

Then, regenerate your war file, and you should be good to go.

## Replacing logback

If you want to use a logging implementation other than logback, you'll
need to exclude logback and bring in your preferred implementation
along with the related slf4j bridge. For example, to use [log4j], you
can modify your `:dependencies` like so:

<pre class="syntax clojure">
  :dependencies [...
                 [org.immutant/immutant "2.x.incremental.284"
                   :exclusions [ch.qos.logback/logback-classic]]
                 [org.apache.logging.log4j/log4j-core "2.0.2"]
                 [org.apache.logging.log4j/log4j-slf4j-impl "2.0.2"]]
</pre>

For more information on using other logging implementations with
slf4j, see the [slf4j manual].

### Replacing logback inside WildFly

In order to use an alternate logging implementation inside WildFly,
you'll need to exclude the logging subsystem as we do [above] for
overriding the configuration.

## Using clojure.tools.logging

If your application uses [clojure.tools.logging], it will
automatically detect the slf4j system and just work.

[slf4j]: http://slf4j.org/
[logback]: http://logback.qos.ch/
[clojure.tools.logging]: https://github.com/clojure/tools.logging
[myriad options]: http://logback.qos.ch/manual/index.html
[logback.xml]: http://logback.qos.ch/manual/configuration.html
[default configuration]: https://github.com/projectodd/wunderboss/blob/master/modules/core/src/main/resources/logback-default.xml
[incremental build]: /builds/2x/
[WildFly]: http://wildfly.org/
[log4j]: http://logging.apache.org/log4j/2.x/
[slf4j manual]: http://www.slf4j.org/manual.html#swapping
[above]: #Overriding_the_default_configuration_inside_WildFly
