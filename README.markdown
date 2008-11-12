
Overview
========

Tweaks for using git in a corporate/close-team environment.

Server-side Hooks
=================

See the individual scripts for documentation, but an overview:

* post-receive-assign-commitnumbers: makes Subversion-like monotonically increasing commit numbers for every commit
* post-receive-email: contrib email script with customizations for stuff like combined diffs
* post-receive-git-config: auto-updates the git config+hooks on the server when updated in the repo
* post-receive-hudson: auto-creates new jobs in Hudson when branches in git are created
* post-receive-trac: updates trac tickets with messages referencing the commits
* update-allow-tags-branches: contrib/example branch/tag enforcement script with customizations
* update-ensure-follows: allows nomination of special branches (e.g. stable) that everyone must have merged
* update-ensure-ticket-reference: enforces ticket references in commit messages (e.g. for trac)
* update-lock-check: enforces locked/preserved branches
* update-stable: enforces proper movement of stable

Client-side Hooks
=================

* commit-msg-trac: enforces ticket references in commit messages

Scripts
=======

* checkout: `checkout <branch>` does the right thing for creating/tracking a new or existing remote branch
* push: pushes only the current branch to origin
* pull: pulls changes down but with rebase-i-p (instead of merge) to avoid same-branch merges and commit replays

