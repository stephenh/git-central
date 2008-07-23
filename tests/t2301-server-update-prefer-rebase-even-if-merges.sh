#!/bin/sh

test_description='server update prefer rebase (with incoming merges)'

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
	git fetch &&

	# Specifically, setup a stable that we will merge and check for rebase
	git checkout -b stable master &&
	echo "setup.stable" >a &&
	git commit -a -m "stable" &&
	git push origin stable
'

install_server_hook 'update-prefer-rebase' 'update'

test_expect_success 'merging in stable does not fool the script' '
	# start our branch, and share it
	git checkout -b topic1 stable &&
	git config --add branch.topic1.remote origin &&
	git config --add branch.topic1.merge refs/heads/topic1 &&
	echo "topic1" >a.topic1 &&
	git add a.topic1 &&
	git commit -m "topic1" &&
	git push origin topic1 &&

	# now, separately, move ahead stable, and share it
	git checkout stable
	echo "setup.stable.moved" >a &&
	git commit -a -m "stable moved" &&
	git push origin stable &&

	# have another client commit (in this case, it is the server, but close enough) move topic1
	cd server &&
	git checkout topic1 &&
	echo "$test_name" >a.client2 &&
	git add a.client2 &&
	git commit -m "topic1 changed by client2" &&
	cd .. &&

	# now locally try and merge in stable (even though we are out of date)
	git checkout topic1 &&
	git merge stable &&

	# We are shutdown for being a rewind
	! git push 2>push.err &&
	cat push.err | grep "[rejected]        topic1 -> topic1 (non-fast forward)"

	# Make a new merge commit
	git pull &&
	! git push 2>push.err &&
	cat push.err | grep "It looks like you should rebase instead of merging"
'

test_done

