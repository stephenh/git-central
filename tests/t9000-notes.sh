#!/bin/sh

test_description='sanity check of commands listed in GitNotes'

. ./test-lib.sh

test_expect_success 'setup' '
	echo setup >a &&
	git add a &&
	git commit -m "a" &&
	git clone ./. server &&
	git remote add origin ./server &&
	rm -fr server/.git/hooks

	git checkout -b stable &&
	git push origin stable &&
	git config --add branch.stable.remote origin &&
	git config --add branch.stable.merge refs/heads/stable
'

test_expect_success 'make a new local/remote branch' '
	git fetch &&
	git checkout -b hotfix2 origin/stable &&
	git push origin hotfix2 &&

	# Initially we are still setup to pull from stable
	git config --list | grep branch.hotfix2.merge=refs/heads/stable &&
	git config --replace-all branch.hotfix2.merge refs/heads/hotfix2 &&

	# But we want to pull from the new hotfix2 instead
	git config --list | grep branch.hotfix2.merge=refs/heads/hotfix2
'

test_expect_success 'make a new local branch' '
	# Remove the old hotfix2 local branch
	git checkout origin/hotfix2 &&
	git branch -d hotfix2 &&

	# Now back to the real commands
	git fetch &&
	git checkout -b hotfix2 origin/hotfix2
'

test_done

