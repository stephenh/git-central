#!/bin/sh

test_description='server update git config'

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
	git fetch
'

install_post_receive_hook 'post-receive-git-config'

test_expect_success 'pushing initial value works' '
	cd server &&
	! git config --list | grep foo &&
	cd .. &&

	../../scripts/make-gitconfig-branch.sh &&
	git checkout gitconfig &&
	echo "foo.foo=bar" > config &&
	git commit -a -m "Set foo.foo=bar."
	git push origin gitconfig

	cd server &&
	git config --list | grep foo &&
	cd ..
'

test_done

