#!/bin/sh

test_description='server update stable enforcer still works with prefer rebased'

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
install_update_hook 'update-stable' 'update-prefer-rebase'

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

test_expect_success 'accept merge' '
	# make one topic branch
	git checkout -b topic1 stable &&
	echo $test_name >topic1 &&
	git add topic1 &&
	git commit -m "$test_name topic1" &&
	git push origin topic1 &&

	# try merging topic1 into stable, which will get a merge commit, but
	# it should have changes involved and so get rejected
	git checkout stable &&
	git merge --no-ff topic1 &&
	git push
'

test_done

