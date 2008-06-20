#!/bin/sh

test_description='server pre-receive stable enforcer'

. ./test-lib.sh

test_expect_success 'setup' '
	echo This is a test. >a &&
	git add a &&
	git commit -m "a" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git checkout -b stable &&
	git remote add origin ./server &&
	git push origin stable &&
	git config --add branch.stable.remote origin &&
	git config --add branch.stable.merge refs/heads/stable
'

# setup the pre-receive hook
install_server_hook 'pre-receive-stable' 'pre-receive-stable'
install_server_hook 'noop' 'noop'
install_server_hook 'pre-receive-stable-then-noop' 'pre-receive'

test_expect_success 'reject commit directly to stable' '
	echo $test_name >a &&
	git commit -a -m "$test_name going onto stable" &&
	head=$(git rev-parse HEAD) &&
	! git push 2>push.err &&
	cat push.err | grep "Moving stable to $head includes a new commit"
'

test_done

