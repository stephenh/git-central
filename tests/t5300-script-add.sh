#!/bin/sh

test_description='script add'

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

test_expect_success 'add picks up new files' '
	echo "$test_name" >a.new &&
	add &&
	git commit -m "add"
'

test_expect_success 'add picks up changed files' '
	echo "$test_name" >a.new &&
	add &&
	git commit -m "change"
'

test_expect_success 'add picks up removed files' '
	rm a.new &&
	add &&
	git commit -m "remove"
'

test_done

