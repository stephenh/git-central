#!/bin/sh

test_description='server update candidate enforcer'

. ./test-lib.sh

test_expect_success 'setup' '
	echo setup >a &&
	git add a &&
	git commit -m "a" &&
	git clone ./. server &&
	git remote add origin ./server &&
	rm -fr server/.git/hooks
'

# setup the update hook
install_update_hook 'update-stable'

test_expect_success 'initial stable commit works' '
	# do one stable-less commit
	echo $test_name >a &&
	git commit -a -m "$test_name" &&
	git push origin master &&

	git checkout -b stable &&
	git push origin stable &&
	git config --add branch.stable.remote origin &&
	git config --add branch.stable.merge refs/heads/stable
'

test_expect_success 'create topic1 and topic2' '
	git checkout -b topic1 stable &&
	echo "$test_name topic1" >a.topic1 &&
	git add a.topic1 &&
	git commit -m "start topic1" &&

	git checkout -b topic2 stable &&
	echo "$test_name topic2" >a.topic2 &&
	git add a.topic2 &&
	git commit -m "start topic2" &&

	git push origin topic2 topic1
'

test_expect_success 'create candidate1' '
	git checkout -b candidate1 stable &&
	git merge topic1 topic2 &&
	git push origin candidate1
'

test_expect_success 'topic1 cannot be changed' '
	git checkout topic1 &&
	echo "$test_name" >a.topic1 &&
	git commit -a -m "$test_name" &&
	! git push origin topic1 2>push.err &&
	cat push.err | grep "topic1 has been merged into candidate1"
'

test_expect_success 'candidate1 can be changed' '
	git checkout candidate1 &&
	echo "$test_name" >a.topic1 &&
	git commit -a -m "$test_name" &&
	git push origin candidate1
'

test_expect_success 'merge candidate into stable' '
	git checkout stable &&
	git merge candidate1 --no-ff &&
	git push origin stable
'

test_expect_success 'candidate cannot be changed' '
	git checkout candidate1 &&
	echo "$test_name" >a.topic1 &&
	git commit -a -m "$test_name" &&
	! git push origin candidate1 2>push.err &&
	cat push.err | grep "candidate1 has been merged into stable"
	! cat push.err | grep "candidate1 has been merged into candidate1"
'

test_expect_success 'topic1 cannot be changed' '
	# It is already changed but error message should chagne
	git checkout topic1 &&
	! git push origin topic1 2>push.err &&
	cat push.err | grep "topic1 has been merged into stable" &&
	git reset --hard HEAD^
'

test_expect_success 'topic3 can initially be created on stable and then moved' '
	git checkout -b topic3 stable &&
	git push origin topic3 &&

	echo "$test_name" >a.topic3 &&
	git add a.topic3 &&
	git commit -m "$test_name" &&
	git push origin topic3
'

test_done

