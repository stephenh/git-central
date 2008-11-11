#!/bin/sh

test_description='server update tags in branch check'

. ./test-lib.sh

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server
'

install_update_hook 'update-ensure-tag-in-branch'

test_expect_success 'push only tag fails' '
	echo "$test_name" >a &&
	git commit -a -m "$test_name moved master" &&
	git tag -a -m "tagged move as r1" r1 &&
	! git push --tags 2>push.err &&
	cat push.err | grep "The tag r1 is not included in any branch." &&

	# But now it works if we push the commit first
	git push &&
	git push --tags
'

test_expect_success 'push works if done at the same time' '
	echo "$test_name" >a &&
	git commit -a -m "$test_name moved master" &&
	git tag -a -m "tagged move as r2" r2 &&
	git push origin master r2
'

test_expect_success 'moving branch back and deleting tag works' '
	git reset --hard HEAD^ &&
	git push --force origin master:master :r2
'

test_done

