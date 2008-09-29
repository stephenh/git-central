#!/bin/sh

test_description='server assign commit numbers'

. ./test-lib.sh

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server &&
	git config --add branch.master.remote origin &&
	git config --add branch.master.merge refs/heads/master &&
	git fetch
'

install_post_receive_hook 'post-receive-assign-commit-numbers'

test_expect_success 'assign one new commit' '
	git checkout master &&
	echo "$test_name" >a &&
	git commit -a -m "changed a" &&
	git push origin master &&
	git fetch &&

	test "$(git rev-parse HEAD)" = "$(git rev-parse r/0)"
	test "$(git describe --tags)" = "r/0"
'

test_expect_success 'assign two new commits' '
	echo "$test_name first" >a &&
	git commit -a -m "changed a first" &&
	echo "$test_name second" >a &&
	git commit -a -m "changed a second" &&
	git push origin master &&
	git fetch &&

	test "$(git rev-parse HEAD)" = "$(git rev-parse r/2)"
	test "$(git describe --tags)" = "r/2"

	test "$(git rev-parse HEAD^)" = "$(git rev-parse r/1)"
	test "$(git describe --tags HEAD^)" = "r/1"
'

test_expect_success 'pushing commits to a new branch does not reassign' '
	git checkout -b topica &&
	echo "$test_name" &&
	git push origin topica &&
	git fetch &&

	! git rev-parse r/3
'

test_done

