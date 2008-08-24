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
	gc-checkout topic1 &&
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
	gc-pull &&
	git cat-file commit $(git rev-parse HEAD) | grep parent | wc -l | grep 1
'

#test_expect_success 'pull does a rebase but does not fuck up merges' '
#	# Change "a" itself so we will eventually conflict
#	gc-checkout topic2 &&
#	echo "$test_name on topic2" >a &&
#	git commit -a -m "move topic2" &&
#
#	# Change a.topic2 as well for another commit to continue rebasing after fixing the conflict
#	echo "$test_name on topic2" >a.topic2 &&
#	git add a.topic2 &&
#	git commit -m "move a.topic2" &&
#
#	# Move stable
#	git checkout stable &&
#	echo "$test_name on stable" >a &&
#	git commit -a -m "move stable" &&
#	git push origin stable &&
#
#	# Move topic2 on the server, then merge stable
#	cd server &&
#	git checkout stable &&
#	echo "$test_name on stable server" >a.stable.server &&
#	git add a.stable.server &&
#	git commit -m "move stable server" &&
#	git checkout topic2 &&
#	echo "$test_name" >a.topic2.server &&
#	git add a.topic2.server &&
#	git commit -m "move topic2 on the server" &&
#	git merge stable &&
#	cd .. &&
#
#	# Merge stable locally too--should conflict
#	git checkout topic2 &&
#	git merge origin/stable
#
#	# Now pull and see what happens
#	# gc-pull
#'

test_done

