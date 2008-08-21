#!/bin/sh

test_description='server post-receive email notification and how it behaves in our stable-based envrionment'

. ./test-lib.sh

export USER=author

test_expect_success 'setup' '
	echo "setup" >a &&
	echo "setup" >b &&
	echo "setup" >c &&
	git add a b c &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server &&
	git config --add branch.master.remote origin &&
	git config --add branch.master.merge refs/heads/master &&
	GIT_DIR=./server/.git git config --add hooks.post-receive-email.mailinglist commits@list.com &&
	GIT_DIR=./server/.git git config --add hooks.post-receive-email.debug true &&
	GIT_DIR=. &&
	echo cbas >./server/.git/description &&

	git checkout -b stable &&
	git push origin stable
'

install_post_receive_hook 'post-receive-email'

test_expect_success 'merge in stable' '
	git checkout -b topic1 stable &&
	echo "move" >a.topic1 &&
	git add a.topic1 &&
	git commit -a -m "move topic1" &&
	git push origin topic1 &&
	old_commit_hash=$(git rev-parse HEAD) &&

	# Move stable
	git checkout stable &&
	echo "$test_name 1" >a &&
	echo "$test_name 1" >b &&
	echo "$test_name 1" >c &&
	git commit -a -m "move stable 1" &&
	first_stable_hash=$(git rev-parse HEAD) &&

	echo "$test_name 2" >a &&
	echo "$test_name 2" >b &&
	echo "$test_name 2" >c &&
	git commit -a -m "move stable 2" &&
	second_stable_hash=$(git rev-parse HEAD) &&
	git push origin stable &&

	# Merge stable
	git checkout topic1 &&
	git merge stable &&
	git push &&

	new_commit_hash=$(git rev-parse HEAD) &&
	new_commit_date=$(git log -n 1 --pretty=format:%cd HEAD) &&

	interpolate ../t2203-1.txt 1.txt old_commit_hash new_commit_hash new_commit_date first_stable_hash second_stable_hash &&
	test_cmp 1.txt server/.git/refs.heads.topic1.out
'

test_expect_success 'merge in stable with conflict' '
	git checkout topic1 &&
	echo "$test_name on topic1" >a &&
	git commit -a -m "move topic1" &&
	git push origin topic1 &&
	old_commit_hash=$(git rev-parse HEAD) &&

	# Move stable
	git checkout stable &&
	echo "$test_name 1" >a &&
	echo "$test_name 1" >b &&
	echo "$test_name 1" >c &&
	git commit -a -m "move stable 1" &&
	first_stable_hash=$(git rev-parse HEAD) &&

	echo "$test_name 2" >a &&
	echo "$test_name 2" >b &&
	echo "$test_name 2" >c &&
	git commit -a -m "move stable 2" &&
	second_stable_hash=$(git rev-parse HEAD) &&
	git push origin stable &&

	# Merge stable
	git checkout topic1 &&
	! git merge stable &&
	echo "$test_name 2 merged topic1" >a &&
	git add a &&
	git commit -F .git/MERGE_MSG
	git push &&

	new_commit_hash=$(git rev-parse HEAD) &&
	new_commit_date=$(git log -n 1 --pretty=format:%cd HEAD) &&

	interpolate ../t2203-2.txt 2.txt old_commit_hash new_commit_hash new_commit_date first_stable_hash second_stable_hash &&
	test_cmp 2.txt server/.git/refs.heads.topic1.out
'

test_done

