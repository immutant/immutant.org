---
title: Releasing a Release
layout: default
---

[release-repo]: http://github.com/immutant/immutant-release

# Preparation

Code is released from the `master` branch of [immutant/immutant-release][release-repo].

Set up this repository as an additional remote for your workspace:

    git remote add release git@github.com:immutant/immutant-release.git

Ensure that the tag you are attempting to release does not exist in the release repository,
or maven will fail part way through the build

    git push release :0.1.0

Ensure that the `master` branch has the contents you wish to release.  Using the `-f`
flag to force is allowed in this case, since the **immutant-release** repository is not
a public-facing human-cloneable repository.

    git push release master:master -f

# Pre-flight build

Using the [build system](http://projectodd.ci.cloudbees.com/), select the 
**immutant-release** job.  This job may be easily found under the 
**Release** tab in CI.

<img src="/images/releasing/ci.png" />

Enter in the version to release, followed by the **next** version after the release, and
select the **release-staging** profile.  The **release-staging** profile can build against
other projects also built to the **release-staging** repository.  This is useful when
performing a chain of releasing involving **polyglot** and **immutant**
to ensure they all work together before publishing any to public repositories.

<img src="/images/releasing/start-preflight.png" />

After each pre-flight build, you will need to reset the release repository:

    git push release :0.1.0
    git push release master:master -f
    
When you are happy with the pre-flight build (in other words, it completes successfully), 
you're ready to run the real build.

# Perform the Builds

Using the [build system](http://projectodd.ci.cloudbees.com/), again select the 
**immutant-release** job, selecting the **release** profile this time.

<img src="/images/releasing/start-build.png" />

# Verify the maven artifacts

Verify that the artifacts you expect have been uploaded and deployed to

[http://repository-projectodd.forge.cloudbees.com/release](http://repository-projectodd.forge.cloudbees.com/release)

# Push the clojar projects to clojars.org

1. Download the clojars projects as a zip to a machine that has ruby and lein installed. {url coming soon?}
2. Unzip and run the `bin/push-to-clojars.rb` script.

# Push changes from the release repository to the official repository

## Fetch the release commits locally:

    git fetch release

## Rebase in the release commits:

    git rebase release/master

## Push to the official repository

    git push origin master

## Push the tag to the official repository

    git push origin 0.1.0

# Release the project in JIRA

<img src="/images/releasing/jira-release.png" style="width: 100%"/>

# Announce it

## Post it on `immutant.org`

## Notify `immutant-users@`

## Notify `the-core`

## Notify `clojure@`

## Tweet it.

## Set the /topic in `#immutant` IRC channel using ChanServ (if you can).
