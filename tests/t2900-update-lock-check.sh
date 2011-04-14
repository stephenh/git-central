#!/bin/bash

test_description='server update lock check'

. ./test-lib.sh

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone -l . --bare server.git &&
	rm -fr server.git/hooks &&
	git remote add origin ./server.git &&
	git config branch.master.remote origin &&
	git config branch.master.merge refs/heads/master &&
	git fetch
'

install_update_hook 'update-lock-check'

test_expect_success 'locked branch is rejected' '
	echo master >> server.git/locked &&

	echo "$test_name" >a &&
	git commit -a -m "changed" &&
	! git push 2>push.err &&
	cat push.err | grep "Branch master is locked"
'

test_expect_success 'locked branch is rejected with multiple branches set' '
	echo foo >> server.git/locked &&
	echo bar >> server.git/locked &&

	echo "$test_name" >a &&
	git commit -a -m "changed" &&
	! git push 2>push.err &&
	cat push.err | grep "Branch master is locked"
'

test_expect_success 'preserved branch cannot be deleted' '
	echo > server.git/locked &&
	git push origin master:master2 &&
	echo master2 > server.git/preserved &&

	! git push origin :master2 2>push.err &&
	cat push.err | grep "Branch master2 cannot be deleted"
'

test_done

