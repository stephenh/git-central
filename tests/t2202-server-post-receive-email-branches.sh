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

test_expect_success 'create branch with existing commits does not replay them' '
	git checkout -b topic2 topic &&
	existing_commit_hash=$(git rev-parse HEAD) &&
	existing_commit_date=$(git log -n 1 --pretty=format:%cd HEAD) &&

	git push origin topic2 &&

	interpolate ../t2202-3.txt 3.txt existing_commit_hash existing_commit_date &&
	test_cmp 3.txt server/.git/refs.heads.topic2.out
'

test_expect_success 'update branch with existing commits does not replay them' '
	# Put a commit on topic2, then fast foward topic to it
	git checkout topic2 &&
	echo "$test_name" >a &&
	git commit -a -m "$test_name on topic" &&
	git push &&

	git checkout topic &&
	old_commit_hash=$(git rev-parse HEAD) &&
	git merge topic2 &&
	existing_commit_hash=$(git rev-parse HEAD) &&
	git push &&

	interpolate ../t2202-4.txt 4.txt old_commit_hash existing_commit_hash &&
	test_cmp 4.txt server/.git/refs.heads.topic.out
'

test_expect_success 'rewind branch' '
	git checkout topic &&
	old_commit_hash=$(git rev-parse HEAD) &&

	git reset --hard HEAD^ &&
	git push --force &&
	new_commit_hash=$(git rev-parse HEAD) &&

	interpolate ../t2202-5.txt 5.txt old_commit_hash new_commit_hash &&
	test_cmp 5.txt server/.git/refs.heads.topic.out
'

test_expect_success 'rewind and continue branch' '
	git checkout topic &&
	old_commit_hash=$(git rev-parse HEAD) &&

	git reset --hard HEAD^ &&
	echo "$test_name" >a &&
	git commit -a -m "$test_name on topic" &&
	new_commit_hash=$(git rev-parse HEAD) &&
	new_commit_date=$(git log -n 1 --pretty=format:%cd HEAD) &&

	git push --force &&
	interpolate ../t2202-6.txt 6.txt old_commit_hash new_commit_hash new_commit_date &&
	test_cmp 6.txt server/.git/refs.heads.topic.out
'

test_expect_success 'delete branch' '
	old_commit_hash=$(git rev-parse HEAD) &&
	git push origin :refs/heads/topic &&

	interpolate ../t2202-2.txt 2.txt old_commit_hash &&
	test_cmp 2.txt server/.git/refs.heads.topic.out
'

test_done

