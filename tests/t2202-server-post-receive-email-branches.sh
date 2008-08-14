#!/bin/sh

test_description='server post-receive email notification'

. ./test-lib.sh

export USER=author

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server &&
	git config --add branch.master.remote origin &&
	git config --add branch.master.merge refs/heads/master &&
	GIT_DIR=./server/.git git config --add hooks.post-receive-email.mailinglist commits@list.com &&
	GIT_DIR=./server/.git git config --add hooks.post-receive-email.debug true &&
	GIT_DIR=.
	echo cbas >./server/.git/description
'

install_post_receive_hook 'post-receive-email'

test_expect_success 'create branch' '
	git checkout -b topic master &&
	echo "$test_name" >a &&
	git commit -a -m "$test_name on topic" &&
	prior_commit_hash=$(git rev-parse HEAD) &&
	prior_commit_date=$(git log -n 1 --pretty=format:%cd HEAD) &&

	echo "$test_name 2" >a &&
	git commit -a -m "$test_name on topic 2 " &&
	new_commit_hash=$(git rev-parse HEAD) &&
	new_commit_date=$(git log -n 1 --pretty=format:%cd HEAD) &&

	git push origin topic &&

	interpolate ../t2202-1.txt 1.txt new_commit_hash new_commit_date prior_commit_hash prior_commit_date &&
	test_cmp 1.txt server/.git/refs.heads.topic.out
'

test_expect_success 'delete branch' '
	old_commit_hash=$(git rev-parse HEAD) &&
	git push origin :refs/heads/topic &&

	interpolate ../t2202-2.txt 2.txt old_commit_hash &&
	test_cmp 2.txt server/.git/refs.heads.topic.out
'

test_done

