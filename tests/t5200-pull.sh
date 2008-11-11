#!/bin/sh

test_description='script pull'

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

test_expect_success 'pull does a rebase' '
	checkout topic1 &&
	echo "$test_name" >a.topic1 &&
	git add a.topic1 &&
	git commit -m "move topic1" &&

	# Move topic1 on the server
	cd server &&
	git checkout topic1 &&
	echo "$test_name" >a &&
	git commit -a -m "move topic1 on the server" &&
	cd .. &&

	# Only one parent
	pull &&
	test 1 = $(git cat-file commit $(git rev-parse HEAD) | grep parent | wc -l)
'

test_expect_success 'pull does a rebase but does not fuck up merges' '
	checkout topic2 &&
	echo "$test_name on topic2" >a.topic2 &&
	git add a.topic2 &&
	git commit -a -m "create topic2" &&
	git push origin topic2 &&

	# Move stable
	git checkout stable &&
	echo "$test_name on stable" >a &&
	git commit -a -m "move stable that will not be replayed" &&
	git push origin stable &&

	# And merge stable into topic2
	git checkout topic2 &&
	git merge stable &&

	# Move topic2 on the server
	cd server &&
	git checkout topic2 &&
	echo "$test_name" >a.topic2.server &&
	git add a.topic2.server &&
	git commit -m "move topic2 on the server" &&
	cd .. &&

	# Merge stable locally too--should conflict
	git checkout topic2 &&
	pull &&
	test 1 = $(git rev-list --all --pretty=oneline | grep "replayed" | wc -l) &&
	push
'

test_expect_success 'pull moves when we have no local changes' '
	git checkout topic2 &&

	# Move topic2 on the server
	cd server &&
	git checkout topic2 &&
	echo "$test_name" > a.topic2.server &&
	git commit -a -m "move topic2 on the server" &&
	cd .. &&

	pull &&
	test $(git rev-parse HEAD) = $(git rev-parse origin/topic2)
'

test_done

