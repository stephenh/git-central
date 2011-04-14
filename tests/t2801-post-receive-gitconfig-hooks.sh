#!/bin/bash

test_description='server update git config'

. ./test-lib.sh

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone -l . --bare server.git &&
	rm -fr server.git/hooks &&
	git remote add origin ./server.git
'

install_post_receive_hook 'post-receive-gitconfig'

test_expect_success 'adding hook' '
	ls server.git/hooks | grep post-receive &&
	../../scripts/create-gitconfig &&
	git checkout gitconfig &&

	mkdir hooks &&
	cd hooks &&
	echo "#!/bin/bash" > post-receive &&
	echo "../../../server/post-receive-gitconfig" >> post-receive &&
	echo "echo barbar" >> post-receive &&
	echo "#!/bin/bash" > update  &&
	echo "echo foofoo" >> update &&
	git add post-receive &&
	git add update &&
	git commit -m "added post-receive and update" &&
	git push origin gitconfig &&
	cd .. &&

	cat server.git/hooks/post-receive | grep barbar &&
	cat server.git/hooks/update | grep foofoo
'

test_expect_success 'changing hook' '
	echo "#!/bin/bash" > hooks/update  &&
	echo "echo lala" >> hooks/update &&
	git commit -a -m "changed update" &&
	git push origin gitconfig &&

	cat server.git/hooks/post-receive | grep barbar &&
	! cat server.git/hooks/update | grep barbar &&
	cat server.git/hooks/update | grep lala
'

test_expect_success 'removing hook does not work' '
	git rm hooks/update &&
	git commit -m "removed update" &&
	git push origin gitconfig &&

	ls server.git/hooks | grep post-receive
	ls server.git/hooks | grep update
'

test_done

