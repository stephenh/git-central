#!/bin/sh

test_description='server update ensure follows'

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

install_update_hook 'update-ensure-follows'

test_expect_success 'pushing stable works' '
	git checkout -b stable &&
	git push origin stable
'

test_expect_success 'branch with unmoved stable is okay' '
	cd server &&
	git config hooks.update-ensure-follows.branches stable &&
	cd .. &&

	git checkout -b topic1 &&
	echo "$test_name" >a.topic1 &&
	git add a.topic1 &&
	git commit -m "Add on topic1." &&
	git push origin topic1
'

test_expect_success 'branch with moved stable requires merge' '
	git checkout stable &&
	echo "$test_name" >a &&
	git commit -a -m "Change on stable" &&
	git push origin stable &&

	git checkout topic1 &&
	echo "$test_name" >a.topic1 &&
	git commit -a -m "Change on topic1." &&
	! git push origin topic1 2>push.err &&
	cat push.err | grep "You need to merge stable into topic1" &&

	git merge stable &&
	git push origin topic1
'

test_expect_success 'branch with moved stable as second branch requires merge' '
	cd server &&
	git config hooks.update-ensure-follows.branches "foo stable" &&
	cd .. &&

	git checkout stable &&
	echo "$test_name" >a &&
	git commit -a -m "Change on stable" &&
	git push origin stable &&

	git checkout topic1 &&
	echo "$test_name" >a.topic1 &&
	git commit -a -m "Change on topic1." &&
	! git push origin topic1 2>push.err &&
	cat push.err | grep "You need to merge stable into topic1" &&

	git merge stable &&
	git push origin topic1
'

test_expect_success 'tag with moved stable is okay' '
	git checkout stable &&
	echo "$test_name" >a &&
	git commit -a -m "Change on stable" &&
	git push origin stable &&

	git checkout topic1 &&
	git tag topic1-tag1
	git push --tags
'

test_expect_success 'branch deletion with moved stable is okay' '
	git checkout stable &&
	echo "$test_name" >a &&
	git commit -a -m "Change on stable" &&

	git push origin :topic1
'

test_expect_success 'excused branch with moved stable is okay' '
	git checkout -b topic2 stable &&
	echo "$test_name" >a.topic2 &&
	git add a.topic2 &&
	git commit -m "Change on topic2" &&
	git push origin topic2 &&

	git checkout stable &&
	echo "$test_name" >a &&
	git commit -a -m "Change on stable" &&
	git push origin stable &&

	git checkout topic2 &&
	echo "$test_name foo" >a.topic2 &&
	git commit -a -m "Change on topic2 again" &&
	! git push origin topic2 &&

	cd server &&
	git config hooks.update-ensure-follows.excused topic2 &&
	cd .. &&

	git push origin topic2
'

test_done

