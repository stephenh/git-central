#!/bin/sh

test_description='server update ensure merged'

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
	git checkout -b stable &&
	git push origin stable
'

install_server_hook 'update-ensure-merged' 'update'

test_expect_success 'pushing just topic is okay' '
	git checkout -b topic &&
	echo "$test_name" >a &&
	git commit -a -m "$test_name on topic" &&
	git push origin topic
'

test_expect_success 'if topic moves on, tagging candidate requires a merge' '
	git checkout -b candidate stable &&
	git merge topic --no-ff &&
	git push &&

	git checkout topic &&
	echo "$test_name on topic" >a &&
	git commit -a -m "$test_name on topic" &&
	git push &&

	git checkout candidate &&
	git tag -a -m "Tagging candidate" deployment-1 &&
	! git push --tags 2>push.err &&
	cat push.err | grep "Rejecting refs/tags/deployment-1 because you need to merge" &&
	cat push.err | grep "topic" &&

	git merge topic &&
	git tag -d deployment-1 &&
	git tag -a -m "Tagging candidate" deployment-1 &&
	git push --tags
'

test_expect_success 'if stable moves on, tagging candidate requires a merge' '
	git checkout stable &&
	echo "$test_name on stable" >a.stable &&
	git add a.stable &&
	git commit -a -m "$test_name on stable" &&
	git push &&

	git checkout candidate &&
	git tag -a -m "Tagging candidate" deployment-2 &&
	! git push --tags 2>push.err &&
	cat push.err | grep "Rejecting refs/tags/deployment-2 because you need to merge" &&
	cat push.err | grep "stable" &&

	git merge stable &&
	git tag -d deployment-2 &&
	git tag -a -m "Tagging candidate" deployment-2 &&
	git push --tags
'

test_expect_success 'when creating a candidate, it must be a merge' '
	git checkout -b topic2 stable &&
	echo "$test_name on topic2" >a &&
	git commit -a -m "$test_name on topic2" &&
	git push origin topic2 &&

	git checkout -b candidate2 stable &&
	git merge topic2 &&
	! git push origin candidate2 2>push.err &&
	cat push.err | grep "Candidate branches must be only merges" &&

	git reset --hard HEAD^ &&
	git merge --no-ff topic2 &&
	git push origin candidate2
'

test_done

