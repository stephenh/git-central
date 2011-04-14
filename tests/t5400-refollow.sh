#!/bin/bash

test_description='script refollow'

. ./test-lib.sh

export PATH=$PATH:../../scripts

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone -l . --bare server.git &&
	rm -fr server.git/hooks &&
	git remote add origin ./server.git &&
	git checkout -b stable &&
	git push origin stable
'

test_expect_success 'setup gitconfig' '
	create-gitconfig &&
	git checkout gitconfig &&
	echo "hooks.update-ensure-follows.branches=stable" >>config &&
	echo "hooks.update-ensure-follows.excused=master gitconfig" >>config &&
	git commit -a -m "enable update-ensure-follows" &&
	git push origin gitconfig
'

test_expect_success 'make topic1 then move stable' '
	git checkout -b topic1 stable &&
	echo "$test_name" >a.topic1 &&
	git add a.topic1 &&
	git commit -m "$test_name on topic1" &&
	git push origin topic1 &&

	git checkout stable &&
	echo "$test_name" >a &&
	git commit -a -m "$test_name on stable" &&
	git push
'

test_expect_success 'refollow fails with dirty index' '
	echo "$test_name" >a &&
	git add a &&
	! refollow 2>refollow.err &&
	cat refollow.err | grep "refusing to refollow--your index is not clean" &&
	! git reset a
'

test_expect_success 'refollow topic1 onto stable' '
	echo "$test_name" >a &&
	git commit -a -m "move stable" &&
	git push origin stable &&
	refollow >refollow.out &&
	cat refollow.out | grep "Merging stable into topic1...succeeded"

	git checkout topic1 &&
	git pull origin topic1 &&
	cat a | grep "$test_name"
'

test_expect_success 'refollow does not double tap' '
	# Still on topic1
	head=$(git rev-parse HEAD) &&
	refollow &&
	git pull origin topic1 &&
	git rev-parse HEAD | grep $head
'

test_expect_success 'refollow respects excused' '
	git checkout gitconfig &&
	head=$(git rev-parse HEAD) &&

	git checkout stable &&
	echo "$test_name" >a &&
	git commit -a -m "move stable" &&
	git push origin stable &&

	refollow &&

	git checkout gitconfig &&
	git pull origin gitconfig &&
	git rev-parse HEAD | grep $head
'

test_expect_success 'refollow continues on conflict' '
	git checkout -b topic2 stable &&
	echo "$test_name" >a &&
	git commit -a -m "create topic2" &&
	git push origin topic2 &&

	git checkout stable &&
	echo "$test_name" >a &&
	git commit -a -m "move stable" &&
	git push origin stable &&

	refollow > refollow.out &&
	cat refollow.out | grep "Merging stable into topic1...succeeded"
	cat refollow.out | grep "Merging stable into topic2...failed merge"
'

test_done

