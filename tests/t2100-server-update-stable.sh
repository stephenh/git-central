#!/bin/sh

test_description='server update stable enforcer'

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

test_expect_success 'initial stable commit works', '
	# do one stable-less commit
	echo $test_name >a &&
	git commit -a -m "$test_name" &&
	git push origin master &&

	git checkout -b stable &&
	git push origin stable &&
	git config --add branch.stable.remote origin &&
	git config --add branch.stable.merge refs/heads/stable
'

test_expect_success 'reject commit directly to stable' '
	echo $test_name >a &&
	git commit -a -m "$test_name going onto stable" &&
	head=$(git rev-parse HEAD) &&
	! git push 2>push.err &&
	cat push.err | grep "Moving stable must entail a merge commit" &&
	git reset --hard HEAD^
'

test_expect_success 'reject fast-forward to candidate branch' '
	# make one topic branch
	git checkout -b topic1 stable &&
	echo $test_name >topic1 &&
	git add topic1 &&
	git commit -m "$test_name topic1" &&
	git push origin topic1 &&

	git checkout stable &&
	git merge topic1 >merge.out &&
	cat merge.out | grep "Fast forward" &&
	! git push 2>push.err &&
	cat push.err | grep "Moving stable must entail a single commit" &&
	git reset --hard ORIG_HEAD
'

test_expect_success 'reject merge with wrong first-parent' '
	# make one topic branch
	git checkout -b topic2 stable &&
	echo $test_name >topic2 &&
	git add topic2 &&
	git commit -m "$test_name topic2" &&
	git push origin topic2 &&

	# move ahead stable by topic3
	git checkout -b topic3 stable &&
	echo $test_name >topic3 &&
	git add topic3 &&
	git commit -m "$test_name topic3" &&
	git push origin topic3 &&
	git checkout stable &&
	git merge --no-ff topic3 &&
	git push &&

	# back to topic2, merge in stable, and try to push it out as the new stable
	git checkout topic2 &&
	git merge stable &&
	! git push origin topic2:refs/heads/stable 2>push.err &&
	cat push.err | grep "Moving stable must have the previous stable as the first parent" &&

	# Go ahead and push topic2 itself
	git push &&

	# but merging into stable should still work fine
	git checkout stable &&
	git merge --no-ff topic2 &&
	git push
'

test_expect_success 'reject merge with changes' '
	# make one topic branch
	git checkout -b topic4 stable &&
	echo $test_name >topic4 &&
	git add topic4 &&
	git commit -m "$test_name topic4" &&
	git push origin topic4 &&

	# move ahead stable by topic5
	git checkout -b topic5 stable &&
	echo $test_name >topic5 &&
	git add topic5 &&
	git commit -m "$test_name topic5" &&
	git push origin topic5 &&
	git checkout stable &&
	git merge --no-ff topic5 &&
	git push &&

	# try merging topic4 into stable, which will get a merge commit, but
	# it should have changes involved and so get rejected
	git checkout stable &&
	git merge topic4 &&
	! git push 2>push.err &&
	cat push.err | grep "Moving stable must not result in any changes"
'

test_done

