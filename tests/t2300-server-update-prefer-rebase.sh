#!/bin/sh

test_description='server update prefer rebase'

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

install_update_hook 'update-prefer-rebase'

test_expect_success 'all local changes do not need a merge' '
	# server is on "setup"

	# make an outstanding change for us--but do not push
	echo "$test_name" >a.client1 &&
	git add a.client1 &&
	git commit -m "$test_name on client1" &&

	# have another client commit (in this case, it is the server, but close enough)
	cd server &&
	echo "$test_name" >a.client2 &&
	git add a.client2 &&
	git commit -m "$test_name on client2" &&

	# go back to our client and it will merge in our changes
	cd .. &&
	git pull &&
	merge=$(git rev-parse HEAD) &&

	! git push 2>push.err &&
	cat push.err | grep "It looks like you should rebase instead of merging $merge" &&
	git reset --hard origin/master
'

test_expect_success 'all local changes do not need a merge even with more commits after' '
	# server is on "setup"

	# make an outstanding change for us--but do not push
	echo "$test_name" >a.client1 &&
	git add a.client1 &&
	git commit -m "$test_name on client1" &&

	# have another client commit (in this case, it is the server, but close enough)
	cd server &&
	echo "$test_name" >a.client2 &&
	git add a.client2 &&
	git commit -m "$test_name on client2" &&

	# go back to our client and it will merge in our changes
	cd .. &&
	git pull &&
	merge=$(git rev-parse HEAD) &&

	# To complicate things, have them add another change
	echo "$test_name again" >a.client1 &&
	git commit -a -m "$test_name on client1 again" &&

	! git push 2>push.err &&
	cat push.err | grep "It looks like you should rebase instead of merging $merge" &&
	git reset --hard origin/master
'

test_expect_success 'already shared topic changes do warrant a merge' '
	# server is on "setup"

	# make a change on topic for us and share it
	git checkout -b topic master &&
	echo "$test_name" >a.client1 &&
	git add a.client1 &&
	git commit -m "$test_name on client1 and topic" &&
	git push origin topic &&

	# make an outstanding change that we will have to merge later
	echo "$test_name again" >>a.client1 &&
	git commit -a -m "$test_name on client1 and topic again" &&

	# have another client commit to master (in this case, it is the server, but close enough)
	cd server &&
	echo "$test_name" >a.client2 &&
	git add a.client2 &&
	git commit -m "$test_name on client2" &&

	# go back to our client and it will merge in our changes
	cd .. &&
	git checkout master &&
	git pull &&
	git merge topic &&

	git push
'

test_expect_success 'simple commit' '
	# go back to topic and make a simple commit/push as a sanity check
	git checkout topic &&
	echo "$test_name" >>a.client1 &&
	git commit -a -m "$test_name on client1 and topic" &&
	git push
'

test_done

