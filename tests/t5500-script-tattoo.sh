#!/bin/sh

test_description='script tattoo'

. ./test-lib.sh

export PATH=$PATH:../../scripts

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server &&
	git checkout -b stable &&
	git push origin stable
'

# tattoo makes assumptions based on the update stable hook sanity checks
install_update_hook 'update-stable'
install_post_receive_hook 'post-receive-assign-commit-numbers'

test_expect_success 'tattoo of unpublished commit fails' '
	gc-tattoo | grep "No commit number tag found"
'

test_done

test_expect_success 'tattoo 1' '
	git checkout -b topic1 &&
	echo "$test_name" >a.topic1 &&
	git add a.topic1 &&
	git commit -a -m "move topic1-1" &&
	git push origin topic1 &&
	gc-tattoo | grep topic1-1
'

test_expect_success 'tattoo 2' '
	echo "$test_name" >a &&
	git commit -a -m "make topic1-2" &&
	git push origin topic1 &&
	gc-tattoo | grep topic1-2
'

test_expect_success 'merge topic2 into topic1 as tattoo 3' '
	git checkout -b topic2 stable &&
	echo "$test_name" >a.topic2 &&
	git add a.topic2 &&
	git commit -m "make topic2-1" &&
	git push origin topic2 &&
	gc-tattoo | grep topic2-1 &&

	git checkout topic1 &&
	git merge topic2 &&
	git push origin topic1 &&
	gc-tattoo | grep topic1-3 &&

	git checkout topic2 &&
	gc-tattoo | grep topic2-1
'

test_expect_success 'fails if not pushed' '
	git checkout topic1 &&
	echo "$test_name" >a &&
	git commit -a -m "make topic1-4" &&
	head=$(git rev-parse HEAD) &&
	gc-tattoo | grep "$head has not been pushed" &&
	git push origin topic1 &&
	gc-tattoo | grep topic1-4
'

test_expect_success 'stable fails if not pushed' '
	git checkout stable &&
	git merge --no-ff topic1 &&
	head=$(git rev-parse HEAD) &&
	gc-tattoo | grep "$head has not been pushed" &&
	git push &&
	gc-tattoo | grep "stable-$head"
'

test_expect_success 'stable without a tag' '
	git checkout stable &&
	head=$(git rev-parse HEAD) &&
	gc-tattoo | grep "stable-$head"
'

test_expect_success 'stable with a tag' '
	git tag -m "1.0" 1.0 &&
	gc-tattoo | grep "1.0"
'

test_expect_success 'use origin stable not local' '
	git checkout origin/stable &&
	git branch -d stable &&
	git checkout topic2 &&
	gc-tattoo | grep "topic2-1"
'

test_done

