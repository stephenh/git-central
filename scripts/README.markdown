
gc-add
======

`gc-add <path>...`

* If no arguments, adds all new, adds all changed, removes all removed
* If arguments, passes through to `git add`

gc-checkout
===========

`gc-checkout <branch>`

* If `branch` already exists locally, check it out
* If `branch` already exists remotely, check it out
* If `branch` is new, create it locally and remotely

gc-commit
=========

`gc-commit`

* Passes through to `git commit`

gc-diff
=======

`gc-diff`

* Passes through to `git diff`

gc-pull
=======

`gc-pull`

* Passes through to `git pull` but with `--rebase` flag

gc-push
=======

`gc-push`

* Pushes only the current branch to `origin`

gc-remerge
==========

* Work in progress, not done

gc-rm
=====

`gc-rm`

* Passes through to `git rm`

gc-status
=========

`gc-status`

* Passes through to `git status`


