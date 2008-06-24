#!/bin/sh

test_description='server pre-receive trac ticket enforcer via shim'

. ./test-lib.sh

test_expect_success 'setup' '
	echo This is a test. >a &&
	git add a &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server &&
	git config --add branch.master.remote origin &&
	git config --add branch.master.merge refs/heads/master
'

# setup the shim
install_server_hook 'noop' 'noop'
install_server_hook 'pre-receive-trac' 'pre-receive-trac'
install_server_hook 'pre-receive-trac-then-noop' 'pre-receive'

test_expect_success 'reject with bad message via shim' '
	echo $test_name >a &&
	git commit -a -m "$test_name" &&
	head=$(git rev-parse HEAD) &&
	! git push >push.out 2>push.err &&
	cat push.err | grep "Commit $head does not reference a ticket"
'

# the last test has a dirty commit message, so ammend it with a good message
test_expect_success 'accept with re via shim' '
	echo $test_name >a &&
	git commit --amend -m "$test_name re #3222" &&
	git push
'

test_expect_success 'reject second push line has bad message via shim' '
	# make a new remote branch
	git branch topic1 master &&
	git push origin topic1 &&

	# change master
	echo $test_name >a &&
	git commit -a -m "$test_name re #3222"  &&

	# change topic1 with no re
	git checkout topic1 &&
	echo "$test_name topic1" >a &&
	git commit -a -m "$test_name" &&
	head=$(git rev-parse HEAD) &&

	! git push >push.out 2>push.err &&
	cat push.err | grep "Commit $head does not reference a ticket"
'

test_expect_success 'reject first push line has bad message via shim' '
	# make a new remote branch
	git branch topic2 master &&
	git push origin topic2 &&

	# change master first with no re
	echo $test_name >a &&
	git commit -a -m "$test_name"  &&
	head=$(git rev-parse HEAD) &&

	# change topic2 with re
	git checkout topic2 &&
	echo "$test_name topic2" >a &&
	git commit -a -m "$test_name re #3222" &&

	! git push >push.out 2>push.err &&
	cat push.err | grep "Commit $head does not reference a ticket"
'

test_done

