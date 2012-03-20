---
title: 'Slides From My Clojure/West Presentation'
author: Jim Crossley
layout: news
tags: [ presentations, event ]
---

This past weekend I gave an "Introducing Immutant" talk at
[Clojure/West](http://clojurewest.org) in San Jose, CA. And except for
one tiny slide, it seemed to go fairly well.

I was a little nervous to see both
[Rich](http://twitter.com/richhickey) and
[Stu](http://twitter.com/stuarthalloway) in attendance. And that was
*before* they gently chided me for slide #63, in which I demonstrate
the use of core Clojure functions to alter Immutant caches. They were
justifiably concerned that doing so would be confusing, to say the
least.

In the talk, I explained that the `core.cache` library, upon which the
Immutant cache is built, requires `IPersistentMap`
implementations. But after reviewing the code later, I realized I was
wrong. I got this wrong impression by attempting to make the Immutant
caches successfully pass the `core.cache` test suite. That was very
close to being a good idea.

The `core.cache` test suite ensures that its caches can `assoc` and
`dissoc` expected results, which works great for local,
efficiently-copied persistent collections. Not so much for
distributed, inefficiently-copied collections. So I implemented them
by mutating instead of copying, just to make the tests pass...

...and completely violated
[The Principle Of Least Surprise](http://en.wikipedia.org/wiki/Principle_of_least_astonishment). I
was focusing more on the polymorphic aspect of the core functions than
their implied immutability.

The
[fix was easy](https://github.com/immutant/immutant/commit/fabe041d995c5b02dbeaafa87bc161b5b79bd883),
of course: just remove the core interface implementations that mutate
stuff along with the `assoc/dissoc` tests. We can still use the
read-only core functions (`get`, `seq`, `find`, etc.) and we still
have the mutation functions in their own `immutant.cache/Mutable`
namespace. In effect, an Immutant cache now responds to the core
Clojure functions exactly like a `java.util.HashMap` would.

Slide decks for open-source projects often quickly become obsolete. In
this deck, #63 already is.

The slides are also available on
[github along with all the others](https://github.com/strangeloop/clojurewest2012-slides)
from Clojure/West.

<div style="width:425px" id="__ss_12072036"><iframe src="http://www.slideshare.net/slideshow/embed_code/12072036" width="425" height="355" frameborder="0" marginwidth="0" marginheight="0" scrolling="no"></iframe></div>
