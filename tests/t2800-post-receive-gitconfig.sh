#!/bin/bash

test_description='server update git config'

. ./test-lib.sh

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone -l . --bare server.git &&
	rm -fr server.git/hooks &&
	git remote add origin ./server.git &&
	git config branch.master.remote origin &&
	git config branch.master.merge refs/heads/master &&
	git fetch
'

install_post_receive_hook 'post-receive-gitconfig'

test_expect_success 'pushing initial value works' '
	! GIT_DIR=server.git git config --list | grep foo &&

	../../scripts/create-gitconfig &&
	git checkout gitconfig &&
	echo "foo.foo=bar" > config &&
	git commit -a -m "Set foo.foo=bar."
	git push origin gitconfig

	GIT_DIR=server.git git config --list | grep foo
'

test_expect_success 'pushing locked works' '
	! test -f server.git/locked &&

	git checkout gitconfig &&
	echo "foo" > locked &&
	git add locked &&
	git commit -m "Add locked"
	git push origin gitconfig

	test -f server.git/locked
'

test_done

