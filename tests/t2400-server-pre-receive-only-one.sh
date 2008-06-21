#!/bin/sh

test_description='server pre-receive only one branch/push'

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

install_server_hook 'pre-receive-only-one' 'pre-receive'

test_expect_success 'pushing just topic is okay' '
	git checkout -b topic &&
	echo "$test_name" >a &&
	git commit -a -m "$test_name on topic" &&
	git push origin topic
'

test_expect_success 'pushing just master is okay' '
	git checkout master &&
	echo "$test_name" >a &&
	git commit -a -m "$test_name on master" &&
	git push
'

test_expect_success 'pushing both master and topic fails' '
	echo "$test_name" >a &&
	git commit -a -m "$test_name on master" &&

	git checkout topic &&
	echo "$test_name" >a &&
	git commit -a -m "$test_name on topic" &&

	! git push 2>push.err &&
	cat push.err | grep "Only push one branch at a time"
'


test_done

