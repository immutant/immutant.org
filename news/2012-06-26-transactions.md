---
title: 'Introducing Distributed XA Transaction Support'
author: Jim Crossley
layout: news
tags: [ transactions, xa ]
---

[bear]: http://www.youtube.com/watch?v=v6cY0zz-958
[xa]: http://en.wikipedia.org/wiki/X/Open_XA
[2pc]: http://en.wikipedia.org/wiki/Two-phase_commit_protocol
[manual]: http://immutant.org/builds/LATEST/html-docs/transactions.html
[attributes]: http://docs.oracle.com/javaee/6/tutorial/doc/bncij.html
[community]: http://immutant.org/community/

We're as happy as [a bear in a koi pond][bear] to announce support for
Distributed (XA) Transactions in Immutant.

Messaging and Caching resources in Immutant are now automatically
transactional and XA capable. And we make it easy for you to define
DataSources for your XA compliant SQL databases so that you can then
define transactions incorporating all three types of resources in your
Clojure applications.

## Some Background

[X/Open XA][xa] is a standard specification for allowing multiple,
independent resources to participate in a single, distributed
transaction using a [two-phase commit (2PC)][2pc] protocol.

Say your application stores data in more than one place, perhaps an
Oracle database and a Postgres database. When a function in your
application writes data to those two databases, XA can ensure that it
doesn't leave your data in an inconsistent state when the Oracle
database fails. ;-)

To accomplish this, the commit and rollback methods are invoked not on
any single resource like a JDBC or JMS connection but on a
TransactionManager instead. Its job is to coordinate the commit or
rollback of each resource involved in a particular transaction.

## Creating an XA DataSource

To include your database in a distributed transaction, you need to
create an XA DataSource for it. Do this using the
`immutant.xa/datasource` function. It will expect the appropriate JDBC
driver for your database to be available in the classpath, so you'll
need to add one of the following to your Leiningen `project.clj`:

<pre class="syntax clojure">  (defproject foo "1.0.0-SNAPSHOT"
    :dependencies [[com.h2database/h2 "1.3.160"]              ; H2
                   [org.clojars.gukjoon/ojdbc "1.4"]          ; Oracle
                   [org.clojars.kjw/mysql-connector "5.1.11"] ; MySQL
                   [postgresql "9.0-801.jdbc4"]               ; Postgres
                   [net.sourceforge.jtds/jtds "1.2.4"]        ; MS SQL Server
                   [java.jdbc "0.2.2"]])
</pre>

The comments on the right indicate the database types we currently
support, and the versions above have been successfully tested in
Immutant.

With the driver available, all that's left is to create the
DataSource. Here are some examples from our integration tests:

<pre class="syntax clojure">  (defonce h2 (xa/datasource "h2" {:adapter "h2" :database "mem:foo"}))
  (defonce oracle (xa/datasource "oracle" {:adapter "oracle"
                                            :host "oracle.cpct4icp7nye.us-east-1.rds.amazonaws.com"
                                            :username "myuser"
                                            :password "mypassword"
                                            :database "mydb"}))
  (defonce mysql (xa/datasource "mysql" {:adapter "mysql"
                                          :host "mysql.cpct4icp7nye.us-east-1.rds.amazonaws.com"
                                          :username "myuser"
                                          :password "mypassword"
                                          :database "mydb"}))
  (defonce postgres (xa/datasource "postgres" {:adapter "postgresql"
                                                :username "myuser"
                                                :password "mypassword"
                                                :database "mydb"}))
  (defonce mssql (xa/datasource "mssql" {:adapter "mssql"
                                          :host "mssql.cpct4icp7nye.us-east-1.rds.amazonaws.com"
                                          :username "myuser"
                                          :password "mypassword"
                                          :database "mydb"}))
</pre>

To use one of those in a `clojure.java.jdbc` connection spec, you
should associate it with the `:datasource` key, like so:

<pre class="syntax clojure">  (jdbc/with-connection {:datasource oracle}
    (jdbc/create-table :things [:name "varchar(50)"]))
</pre>

This should of course work with any Clojure SQL library built on
`clojure.java.jdbc`, e.g. Korma, ClojureQL, Lobos, etc.

See the [manual] for more details.

## Defining an XA Transaction

Let's start with an example:

<pre class="syntax clojure">  (ns xa.example
    (:require [immutant.xa :as xa]
              [immutant.cache :as cache]
              [immutant.messaging :as msg]
              [clojure.java.jdbc :as sql]))
  
  (defn do-three-things []
    (xa/transaction
     (sql/with-connection {:datasource my-ds}
       (sql/insert-records :things {:name "foo"}))
     (cache/put my-cache :a 1)
     (msg/publish "/queue/test" "success!")))
</pre>

The `do-three-things` function will insert a record into a SQL
database, write an entry to a cache and publish a message to a queue,
all within a single transaction. When it completes, either all of
those things will have happened or none will, depending on whether an
exception is tossed from the body passed to `xa/transaction`.

So the `xa/transaction` macro starts a transaction, executes its body,
and then commits the transaction unless an exception is caught, in
which case the transaction is rolled back.

## Transaction Scope

I lied a little. The `xa/transaction` macro is really just an alias
for the `required` macro in the `immutant.xa.transaction` namespace,
which is one of six macros matching the
[transaction attributes for JEE Container-Managed Persistence][attributes]:
`required`, `requires-new`, `not-supported`, `supports`, `mandatory`,
and `never`. According to that spec, `required` is the default, so we
alias it in the main `immutant.xa` namespace.

These macros allow you to control the scope of your transactions when
your functions call each other. For example,

<pre class="syntax clojure">  (ns xa.example ...)
  (defn foo []
    (xa/transaction
     (do-three-things)))
</pre>

Here, we have one function, `foo`, defining a transaction that calls another
function, `do-three-things`, that seemingly defines another
transaction. Or does it? In fact, the `required` macro won't start a
new transaction if there's already one associated with the current
thread. It'll simply include its body in the transaction started by
the caller. If we really wanted a new transaction, we'd call
`requires-new` inside `do-three-things`.

Here's another example:

<pre class="syntax clojure">  (ns xa.example
    (:require [immutant.xa.transaction :as tx]))
  
  (tx/required
   (one)
   (tx/not-supported
    (two))
   (tx/requires-new
    (three))
   (throw (Exception.)))
</pre>

Here we have a function, `one`, running within a transaction that is
suspended prior to calling the function `two`, that runs completely
outside of any transaction, after which a second transaction is
started before calling the function, `three`.

We then toss an exception (we could've also called
`tx/set-rollback-only`) that causes everything we did in `one` to
rollback. The exception does not affect what we did in `two` or
`three`, however.

Incidentally, any exception tossed in `two` or `three` would also
rollback the actions of `one` since all the macros re-throw whatever
they catch.

## Conclusion

XA is not for every application. It's mostly used when you have
multiple JDBC backends or you need to synchronize your JDBC and JMS
(HornetQ messaging) calls. Transactional data-grids (Infinispan
caching) are also often handy, so we feel good about making all of
these resources automatically transactional in Immutant, not to
mention providing clean Clojure interfaces for them.

Look for a new 0.2.0 release of Immutant in the coming weeks, and feel
free to [find us in the normal channels][community] if you have any
questions.
