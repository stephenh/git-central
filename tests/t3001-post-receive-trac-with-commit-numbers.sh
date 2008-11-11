#!/bin/sh

test_description='server post receive trac with commit numbers'

. ./test-lib.sh

export PYTHON=echo
export TRAC_ENV=/foo/trac

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server
'

install_post_receive_hook 'post-receive-assign-commit-numbers' 'post-receive-trac'

test_expect_success 'new branch' '
	git checkout -b topic1 master &&
	echo "$test_name" >a &&
	git commit -a -m "changed on topic1" &&
	new_commit_hash=$(git rev-parse HEAD) &&
	git push origin topic1 2>push.err &&
	cat push.err | grep "/foo/trac topic1 $new_commit_hash r/1 $new_commit_hash"
'

test_expect_success 'new branch with already existing does not double tap' '
	git checkout -b topic2 topic1 &&
	existing_commit_hash=$(git rev-parse HEAD) &&
	git push origin topic2 2>push.err &&
	! cat push.err | grep "/foo/trac topic2"
'

test_expect_success 'update branch' '
	# Already on topic2
	echo "$test_name" >a &&
	git commit -a -m "changed on topic2" &&
	new_commit_hash=$(git rev-parse HEAD) &&
	git push origin topic2 2>push.err &&
	cat push.err | grep "/foo/trac topic2 $new_commit_hash r/2 $new_commit_hash"
'

test_expect_success 'update branch to an already published commit does not double tap' '
	# Make topic1 catch up to topic2, which will be a fast forward that does need re-tapped
	git checkout topic2 &&
	topic2_hash=$(git rev-parse HEAD) &&

	git checkout topic1 &&
	git merge topic2 &&
	topic1_hash=$(git rev-parse HEAD) &&

	git push 2>push.err &&

	! cat push.err | grep "/foo/trac topic2"
	! cat push.err | grep "/foo/trac topic1"
'

test_expect_success 'update branch with abbreviation' '
	git checkout topic2
	git tag -m "release1" release1 &&
	git push --tags &&

	echo "$test_name" >a &&
	git commit -a -m "changed on topic2" &&
	new_commit_describe=$(git describe HEAD) &&
	new_commit_hash=$(git rev-parse HEAD) &&
	git push origin topic2 2>push.err &&
	cat push.err | grep "/foo/trac topic2 $new_commit_describe r/3 $new_commit_hash"
'

test_expect_success 'update branch with abbreviation and two commits' '
	echo "$test_name 1" >a &&
	git commit -a -m "changed on topic2 1" &&
	first_commit_describe=$(git describe HEAD) &&
	first_commit_hash=$(git rev-parse HEAD) &&

	echo "$test_name 2" >a &&
	git commit -a -m "changed on topic2 2" &&
	second_commit_describe=$(git describe HEAD) &&
	second_commit_hash=$(git rev-parse HEAD) &&

	git push origin topic2 2>push.err &&
	cat push.err | grep "/foo/trac topic2 $first_commit_describe r/4 $first_commit_hash" &&
	cat push.err | grep "/foo/trac topic2 $second_commit_describe r/5 $second_commit_hash"
'

test_done

