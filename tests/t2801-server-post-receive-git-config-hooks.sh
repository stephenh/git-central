#!/bin/sh

test_description='server update git config'

. ./test-lib.sh

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server
'

install_post_receive_hook 'post-receive-git-config'

test_expect_success 'adding hook' '
	ls server/.git/hooks | grep post-receive &&
	../../scripts/make-gitconfig-branch &&
	git checkout gitconfig &&

	mkdir hooks &&
	cd hooks &&
	echo "#!/bin/sh" > post-receive &&
	echo "../../../../server/post-receive-git-config" >> post-receive &&
	echo "echo barbar" >> post-receive &&
	echo "#!/bin/sh" > update  &&
	echo "echo foofoo" >> update &&
	git add post-receive &&
	git add update &&
	git commit -m "added post-receive and update" &&
	git push origin gitconfig &&
	cd .. &&

	cat server/.git/hooks/post-receive | grep barbar &&
	cat server/.git/hooks/update | grep foofoo
'

test_expect_success 'changing hook' '
	echo "#!/bin/sh" > hooks/update  &&
	echo "echo lala" >> hooks/update &&
	git commit -a -m "changed update" &&
	git push origin gitconfig &&

	cat server/.git/hooks/post-receive | grep barbar &&
	! cat server/.git/hooks/update | grep barbar &&
	cat server/.git/hooks/update | grep lala
'

test_expect_success 'removing hook does not work' '
	git rm hooks/update &&
	git commit -m "removed update" &&
	git push origin gitconfig &&

	ls server/.git/hooks | grep post-receive
	ls server/.git/hooks | grep update
'

test_done

