#!/bin/sh

test_description='commit-msg ticket hook'

. ./test-lib.sh


# setup the commit-msg hook
install_client_hook 'commit-msg' 'commit-msg'

test_expect_success 'rejects with bad message' '
	echo "$test_name" > file &&
	git add file &&
	! git commit -m "first"
'

test_expect_success 'rejects with re:' '
	echo "$test_name" > file &&
	git add file &&
	! git commit -m "first re: #3200"
'

test_expect_success 'rejects with re no space' '
	echo "$test_name" > file &&
	git add file &&
	! git commit -m "first re#3200"
'

test_expect_success 'accepts with re' '
	echo "$test_name" > file &&
	git add file &&
	git commit -m "first re #3200"
'

test_expect_success 'accepts with RE' '
	echo "$test_name" > file &&
	git add file &&
	git commit -m "first RE #3200"
'

test_expect_success 'accepts with refs' '
	echo "$test_name" > file &&
	git add file &&
	git commit -m "first refs #3200"
'

test_expect_success 'accepts with qa' '
	echo "$test_name" > file &&
	git add file &&
	git commit -m "first qa #3200"
'

test_done

