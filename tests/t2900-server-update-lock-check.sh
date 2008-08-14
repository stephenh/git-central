#!/bin/sh

test_description='server update lock check'

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

install_update_hook 'update-lock-check.rb'

test_expect_success 'locked branch is rejected' '
	cd server &&
	git config hooks.update-lock-check.locked master &&
	cd .. &&

	echo "$test_name" >a &&
	git commit -a -m "changed" &&
	! git push 2>push.err &&
	cat push.err | grep "Branch master is locked"
'

test_expect_success 'locked branch is rejected with multiple branches set' '
	cd server &&
	git config hooks.update-lock-check.locked "foo bar master" &&
	cd .. &&

	echo "$test_name" >a &&
	git commit -a -m "changed" &&
	! git push 2>push.err &&
	cat push.err | grep "Branch master is locked"
'

test_expect_success 'preserved branch cannot be deleted' '
	cd server &&
	git config hooks.update-lock-check.locked "" &&
	git config hooks.update-lock-check.preserved master &&
	cd .. &&

	! git push origin :master 2>push.err &&
	cat push.err | grep "Branch master cannot be deleted"
'

test_done

