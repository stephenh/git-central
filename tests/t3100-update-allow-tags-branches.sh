#!/bin/bash

test_description='server update allow tags and branches'

. ./test-lib.sh

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone -l . --bare server.git &&
	rm -fr server.git/hooks &&
	git remote add origin ./server.git
'

install_update_hook 'update-allow-tags-branches'

test_expect_success 'push only tag fails' '
	echo "$test_name" >a &&
	git commit -a -m "$test_name moved master" &&
	git tag -a -m "tagged move as r1" r1 &&
	! git push --tags 2>push.err &&
	cat push.err | grep "The tag r1 is not included in any branch" &&

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
	GIT_DIR=./server.git git config hooks.update-allow-tags-branches.deletetag true
	git reset --hard HEAD^ &&
	git push --force origin master:master :r2
'

test_done

