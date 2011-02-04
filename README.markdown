
Overview
========

Tweaks for using git in a corporate/close-team environment.

Scripts
=======

* [checkout][12]: does the right thing for creating/tracking a new or existing remote branch
* [push][13]: pushes only the current branch to origin
* [pull][14]: pulls changes down but with `rebase-i-p` to avoid same-branch merges and commit replays

[12]: blob/master/scripts/checkout
[13]: blob/master/scripts/push
[14]: blob/master/scripts/pull

Server-side Hooks
=================

See the individual scripts for documentation, but an overview:

* [post-receive-commitnumbers][1]: makes Subversion-like monotonically increasing commit numbers for every commit
* [post-receive-email][2]: contrib email script with customizations for stuff like combined diffs
* [post-receive-gitconfig][3]: auto-updates the git config+hooks on the server when updated in the repo
* [post-receive-hudson][4]: auto-creates new jobs in Hudson when branches in git are created
* [post-receive-trac][5]: updates trac tickets with messages referencing the commits
* [update-allow-tags-branches][6]: contrib/example branch/tag enforcement script with customizations
* [update-ensure-follows][7]: allows nomination of special branches (e.g. stable) that everyone must have merged
* [update-ensure-ticket-reference][8]: enforces ticket references in commit messages (e.g. for trac)
* [update-lock-check][9]: enforces locked/preserved branches
* [update-stable][10]: enforces proper movement of stable

[1]: blob/master/server/post-receive-commitnumbers
[2]: blob/master/server/post-receive-email
[3]: blob/master/server/post-receive-gitconfig
[4]: blob/master/server/post-receive-hudson
[5]: blob/master/server/post-receive-trac
[6]: blob/master/server/update-allow-tags-branches
[7]: blob/master/server/update-ensure-follows
[8]: blob/master/server/update-ensure-ticket-reference
[9]: blob/master/server/update-lost-check
[10]: blob/master/server/update-stable

Client-side Hooks
=================

* [commit-msg-trac][11]: enforces ticket references in commit messages

[11]: blob/master/client/commit-msg-trac

Bootstrapping Scripts
=====================

* [create-gitconfig][15]: creates a new DAG for managing repository-specific configuration (works with [post-receive-gitconfig][3])
* [create-stable][16]: creates a new DAG for the first release to merge in to (works with [update-stable][10])

[15]: blob/master/scripts/create-gitconfig
[16]: blob/master/scripts/create-stable

Install Server-side Hooks
=========================

* Download/clone the `gc` repo to something like `/srv/git/gc`
* Edit `your_repo.git/hooks/post-receive` and `your_repo.git/hooks/update` to call the `gc` hooks as appropriate
  * [post-receive.sample][17] and [update.sample][18] are good templates to use for calling multiple hooks

[17]: blob/master/server/post-receive.sample
[18]: blob/master/server/update.sample

Todo
====

* Install approach for scripts
* Install for client hooks

