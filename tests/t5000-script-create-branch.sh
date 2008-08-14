#!/bin/sh

test_description='script create branch'

. ./test-lib.sh

export PATH=$PATH:../../scripts

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server &&
	git config --add branch.master.remote origin &&
	git config --add branch.master.merge refs/heads/master &&
	git fetch

	git checkout -b stable
	git push origin stable
'

test_expect_success 'create branch clones stable' '
	create-branch topic1
	git branch | grep topic1
	git branch -r | grep origin/topic1
	git config --list | grep "branch.topic1.merge=refs/heads/topic1"
'

test_done

