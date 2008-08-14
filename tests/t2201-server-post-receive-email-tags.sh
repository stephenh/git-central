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

test_expect_success 'create tag' '
	git tag -a -m 1.0 1.0 &&
	git push --tags &&
	new_commit_hash=$(git rev-parse HEAD) &&
	tag_hash=$(git rev-parse 1.0) &&
	eval $(git for-each-ref --shell "--format=tag_date=%(taggerdate)" refs/tags/1.0) &&

	interpolate ../t2201-1.txt 1.txt new_commit_hash tag_hash tag_date &&
	test_cmp 1.txt server/.git/refs.tags.1.0.out
'

test_expect_success 'commit on tag branch' '
	old_commit_hash=$(git rev-parse HEAD) &&
	echo "$test_name" >a &&
	git commit -a -m "$test_name" &&
	prior_commit_hash=$(git rev-parse HEAD) &&
	prior_commit_date=$(git log -n 1 --pretty=format:%cd HEAD) &&

	echo "$test_name 2" >a &&
	git commit -a -m "$test_name 2" &&
	new_commit_hash=$(git rev-parse HEAD) &&
	new_commit_date=$(git log -n 1 --pretty=format:%cd HEAD) &&

	git push &&
	new_commit_abbrev=$(git rev-list -n 1 --pretty=format:%h HEAD | grep -v commit) &&
	interpolate ../t2201-2.txt 2.txt old_commit_hash new_commit_hash new_commit_date new_commit_abbrev prior_commit_hash prior_commit_date &&
	test_cmp 2.txt server/.git/refs.heads.master.out
'

test_expect_success 'retag branch' '
	git tag -a -m 2.0 2.0 &&
	git push --tags &&
	new_commit_hash=$(git rev-parse HEAD) &&
	tag_hash=$(git rev-parse 2.0) &&
	eval $(git for-each-ref --shell "--format=tag_date=%(taggerdate)" refs/tags/2.0) &&

	interpolate ../t2201-3.txt 3.txt new_commit_hash tag_hash tag_date &&
	test_cmp 3.txt server/.git/refs.tags.2.0.out
'

test_done

