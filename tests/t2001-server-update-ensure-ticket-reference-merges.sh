#!/bin/sh

test_description='server update trac ticket enforcer via shim'

. ./test-lib.sh

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server &&
	git config --add branch.master.remote origin &&
	git config --add branch.master.merge refs/heads/master
'

# setup the hook
install_server_hook 'update-ensure-ticket-reference' 'update'

test_expect_success 'accept merge with merge message' '
	git checkout -b topic1 master &&
	echo "$test_name" >a1 &&
	git add a1 &&
	git commit -m "$test_name topic1 re #1" &&
	git push origin topic1 &&

	git checkout -b topic2 master &&
	echo "$test_name" >a2 &&
	git add a2 &&
	git commit -m "$test_name topic2 re #2" &&
	git push origin topic2 &&

	git checkout topic1 &&
	echo "$test_name" >>a1 &&
	git commit -a -m "$test_name topic1 re #1 again" &&
	git merge topic2 &&
	git push
'

test_done

