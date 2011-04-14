#!/bin/bash

test_description='script create branch'

. ./test-lib.sh

export PATH=$PATH:../../scripts

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server &&
	git config branch.master.remote origin &&
	git config branch.master.merge refs/heads/master &&
	git fetch &&

	git checkout -b stable &&
	git push origin stable
'

test_expect_success 'push only does one branch' '
	checkout topic1 &&
	echo "$test_name" >a &&
	git commit -a -m "move topic1" &&
	git rev-parse HEAD >head.topic1 &&

	checkout topic2 &&
	echo "$test_name" >a &&
	git commit -a -m "move topic2" &&
	git rev-parse HEAD >head.topic2 &&

	push &&
	git rev-parse origin/topic2 >head.origin.topic2 &&
	git rev-parse origin/topic1 >head.origin.topic1 &&

	test_cmp head.topic2 head.origin.topic2 &&
	! test_cmp head.topic2 head.origin.topic1
'

test_done

