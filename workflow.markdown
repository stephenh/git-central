
Overview
========

I've found this workflow works well for close-collaboration topic branches in a typical enterprise software development project.

By close-collaboration, I mean teams that are frequently sharing topic branches on a shared server and so prefer not to rebase their topic branches all the time.

Briefly:

* stable replaces master as the "special" branch that is always at the latest released version
* topic branches are created off of stable and worked on, merging in results from stable as new releases come out
* candidate branches are created as a roll up of several topic branches in anticipation for a release--qa works on the candidate branches and the candidate branch is merged into stable when released

stable
======

We dropped the master branch and started using "stable" as the branch that represented the latest release. When new a release came out and stable moved, each topic branch would `git merge origin/stable` as needed.

To keep the DAG clean, we wanted the first-parent of each commit on stable to be the previous release.

This is different than how we first managed stable's DAG, as we'd let stable be fast-forwarded to whatever qa just got done certifying. E.g. it would look like:

     A                      stable
     |\
     | * -- * --            topic1
     |          \
     |           * -- B     candidate_1.1        
     \          /
       -- * --             topic2

And when candidate_1.1 was released, we'd checkout stable, `git merge candidate_1.1` and get a fast-forward so that stable was now at commit B. Which made sense, and worked, but it meant to track the 1.0 -> 1.1 change, you'd have to dig through the topic branch mess between A and B.

So we moved to:

     A --------------- C    stable
     |\                |
     | * -- * --       |    topic1
     |          \      /
     |           * -- B     candidate_1.1        
     \          /
       -- * --             topic2

When candidate_1.1 is released, we checkout stable, `git merge --no-ff candidate_1.1` and force a new merge commit. This means commit A (1.0) is a direct first parent of commit C (1.1) and makes the DAG much nicer to follow.

Note that the [update-stable][1] hook enforces this first-parent movement of stable and the [update-ensure-follows][2] enforces topic branches merge in the new release at their earliest possible convenience (i.e. before being able to push again).

[1]: master/server/update-stable
[2]: master/server/update-ensure-follows

candidates
==========

Candidate branches are just gatherings of topic branches that have been deemed releasable by development and qa and so are ready for integration testing.

The only trick here is judicious use of `--no-ff` again as otherwise the first topic branch you merge into your new candidate branch will likely result in your candidate branch being fast-forwarded to where ever the topic branch is at.

topics
======

Topics are fairly obvious.

