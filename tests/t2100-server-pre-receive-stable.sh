#!/bin/sh

test_description='server pre-receive stable enforcer'

. ./test-lib.sh

test_expect_success 'setup' '
	echo This is a test. >a &&
	git add a &&
	git commit -m "a" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git checkout -b stable &&
	git remote add origin ./server &&
	git push origin stable &&
	git config --add branch.stable.remote origin &&
	git config --add branch.stable.merge refs/heads/stable
'

# setup the pre-receive hook
install_server_hook 'pre-receive-stable' 'pre-receive'

test_expect_success 'reject commit directly to stable' '
	echo $test_name >a &&
	git commit -a -m "$test_name going onto stable" &&
	head=$(git rev-parse HEAD) &&
	! git push 2>push.err &&
	cat push.err | grep "Moving stable to $head includes a new commit" &&
	git reset --hard HEAD^
'

test_expect_success 'reject aged topic branch' '
	# make one topic branch
	git checkout -b topic1 stable &&
	echo $test_name >topic1 &&
	git add topic1 &&
	git commit -m "$test_name topic1" &&
	git push origin topic1 &&

	# now make another topic
	git checkout -b topic2 stable
	echo $test_name >topic2 &&
	git add topic2 &&
	git commit -m "$test_name topic2" &&
	git push origin topic2 &&

	# merge in topic2
	git checkout stable &&
	git merge topic2 &&
	git push &&

	# merge in topic1 fails
	git merge topic1 &&
	head=$(git rev-parse HEAD) &&
	! git push 2>push.err &&
	cat push.err | grep "Moving stable to $head includes a new commit" &&
	git reset --hard ORIG_HEAD
'

test_expect_success 'accept updated aged topic branch' '
	# make one topic branch
	git checkout -b topic3 stable &&
	echo $test_name >topic3 &&
	git add topic3 &&
	git commit -m "$test_name topic3" &&
	git push origin topic3 &&

	# now make another topic
	git checkout -b topic4 stable
	echo $test_name >topic4 &&
	git add topic4 &&
	git commit -m "$test_name topic4" &&
	git push origin topic4 &&

	# merge in topic4
	git checkout stable &&
	git merge topic4 &&
	git push &&

	# update topic3 first
	git checkout topic3 &&
	git merge stable &&
	git push &&

	# Now we can update stable
	git checkout stable &&
	git merge topic3 &&
	git push
'

test_done

