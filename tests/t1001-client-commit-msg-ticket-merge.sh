#!/bin/sh

test_description='client commit-msg ticket enforcer for merges'

. ./test-lib.sh

# setup the commit-msg hook
install_client_hook 'commit-msg' 'commit-msg'

test_expect_success 'accepts merge' '
	echo "$test_name" >file &&
	git add file &&
	git commit -m "line one. re #3222." &&
	git checkout -b topic1 &&
	echo "$test_name topic1" >>file &&
	git commit -a -m "line two. re #3222." &&
	git checkout master &&
	echo "$test_name" > file2 &&
	git add file2 &&
	git commit -m "file2. re #3222." &&
	git merge topic1 &&
	git log -n 1 HEAD | grep "Merge branch"
'

test_done

