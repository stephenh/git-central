#!/bin/sh

test_description='script tattoo'

. ./test-lib.sh

export PATH=$PATH:../../scripts

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server &&
	git checkout -b stable &&
	git push origin stable
'

test_expect_success 'tattoo 0' '
	git checkout -b topic1 &&
	git push origin topic1 &&
	gc-tattoo | grep topic1-0
'

test_expect_success 'tattoo 1' '
	echo "$test_name" >a &&
	git commit -a -m "make topic1-1" &&
	git push origin topic1 &&
	gc-tattoo | grep topic1-1
'

test_expect_success 'merge topic2 topic1 as tattoo 2' '
	git checkout -b topic2 stable &&
	echo "$test_name" >a.topic2 &&
	git add a.topic2
	git commit -m "make topic2" &&
	git push origin topic2 &&
	gc-tattoo | grep topic2-1

	git checkout topic1 &&
	git merge topic2 &&
	git push origin topic1 &&
	gc-tattoo | grep topic1-2
'

test_expect_success 'stable without a tag' '
	git checkout stable &&
	head=$(git rev-parse HEAD) &&
	gc-tattoo | grep "stable-$head"
'

test_expect_success 'stable with a tag' '
	git tag -m "1.0" 1.0 &&
	gc-tattoo | grep "1.0"
'

test_expect_success 'fails if not pushed' '
	git checkout topic1 &&
	echo "$test_name" >a &&
	git commit -a -m "make topic1-3" &&
	gc-tattoo | grep "topic1 has not been pushed"
'

test_expect_success 'stable fails if not pushed' '
	git checkout stable &&
	git merge --no-ff topic1 &&
	gc-tattoo | grep "stable has not been pushed"
'

test_expect_success 'use origin stable not local' '
	git checkout topic1 &&
	git push origin topic1 &&
	gc-tattoo | grep "topic1-3"
'

test_done

