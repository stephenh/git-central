#!/bin/sh

test_description='script checkout'

. ./test-lib.sh

export PATH=$PATH:../../scripts

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server
	git checkout -b stable &&
	git push origin stable
'

test_expect_success 'checkout a new branch clones stable' '
	checkout topic1 &&
	git branch | grep topic1 &&
	git branch -r | grep origin/topic1 &&
	git config --list | grep "branch.topic1.merge=refs/heads/topic1"
'

test_expect_success 'checkout an existing remote branch' '
	cd server &&
	git checkout -b topic2 stable &&
	echo "$test_name" >a &&
	git commit -a -m "Made topic2 on server" &&
	cd .. &&

	checkout topic2
	git branch | grep topic2
	git branch -r | grep origin/topic2
	git config --list | grep "branch.topic2.merge=refs/heads/topic2"
'

test_expect_success 'checkout an existing local branch' '
	checkout topic1
'

test_done

