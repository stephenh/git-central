#!/bin/bash

test_description='script checkout'

. ./test-lib.sh

export PATH=$PATH:../../scripts

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone -l . --bare server.git &&
	rm -fr server.git/hooks &&
	git remote add origin ./server.git
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
	git clone server.git person2 &&
	cd person2 &&
	git checkout -b topic2 origin/stable &&
	echo "$test_name on server" >a &&
	git commit -a -m "Made topic2 on server" &&
	git push origin topic2
	cd .. &&

	! git branch | grep topic2 &&
	checkout topic2 &&
	git branch | grep topic2 &&
	git branch -r | grep origin/topic2 &&
	git config --list | grep "branch.topic2.merge=refs/heads/topic2" &&

	echo "$test_name on client" >a &&
	git commit -a -m "Move topic2 on client" &&
	git push origin topic2
'

test_expect_success 'checkout an existing local branch' '
	checkout topic1
'

test_expect_success 'checkout a revision does not create a new branch' '
	echo "$test_name" >a &&
	git commit -a -m "$test_name" &&

	prior=$(git rev-parse HEAD^) &&
	checkout $prior &&
	git branch | grep "no branch"
'

test_done

