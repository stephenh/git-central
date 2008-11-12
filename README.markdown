
Overview
========

Tweaks for using git in a corporate/close-team environment.

Scripts
=======

* [checkout][12]: does the right thing for creating/tracking a new or existing remote branch
* [push][13]: pushes only the current branch to origin
* [pull][14]: pulls changes down but with `rebase-i-p` to avoid same-branch merges and commit replays

[12]: master/scripts/checkout
[13]: master/scripts/push
[14]: master/scripts/pull

Server-side Hooks
=================

See the individual scripts for documentation, but an overview:

* [post-receive-assign-commitnumbers][1]: makes Subversion-like monotonically increasing commit numbers for every commit
* [post-receive-email][2]: contrib email script with customizations for stuff like combined diffs
* [post-receive-gitconfig][3]: auto-updates the git config+hooks on the server when updated in the repo
* [post-receive-hudson][4]: auto-creates new jobs in Hudson when branches in git are created
* [post-receive-trac][5]: updates trac tickets with messages referencing the commits
* [update-allow-tags-branches][6]: contrib/example branch/tag enforcement script with customizations
* [update-ensure-follows][7]: allows nomination of special branches (e.g. stable) that everyone must have merged
* [update-ensure-ticket-reference][8]: enforces ticket references in commit messages (e.g. for trac)
* [update-lock-check][9]: enforces locked/preserved branches
* [update-stable][10]: enforces proper movement of stable

[1]: master/server/post-receive-assign-commitnumbers
[2]: master/server/post-receive-email
[3]: master/server/post-receive-gitconfig
[4]: master/server/post-receive-hudson
[5]: master/server/post-receive-trac
[6]: master/server/update-allow-tags-branches
[7]: master/server/update-ensure-follows
[8]: master/server/update-ensure-ticket-reference
[9]: master/server/update-lost-check
[10]: master/server/update-stable

Client-side Hooks
=================

* [commit-msg-trac][11]: enforces ticket references in commit messages

[11]: master/client/commit-msg-trac

Bootstrapping Scripts
=====================

* [create-gitconfig][15]: creates a new DAG for managing repository-specific configuration
* [create-stable][16]: creates a new DAG for the first release to merge in to

[15]: master/scripts/create-gitconfig
[16]: master/scripts/create-stable



