
#!/bin/sh

test_description='server pre-receive ticket enforcer via shim'

. ./test-lib.sh

test_expect_success 'setup' '
	echo "setup" >a &&
	git add a &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server &&
	git config --add branch.master.remote origin &&
	git config --add branch.master.merge refs/heads/master
'

# setup the hook
install_server_hook 'pre-receive-ticket' 'pre-receive'

test_expect_success 'reject new branch with bad message' '
	git checkout -b topic1
	echo $test_name >a &&
	git commit -a -m "$test_name" &&
	head=$(git rev-parse HEAD)
	git push origin topic1 >push.out 2>push.err
	cat push.err | grep "Commit $head does not reference a ticket"
'

# the last test has a dirty commit message, so ammend it with a good message
test_expect_success 'accept new branch with re' '
	echo $test_name >a &&
	git commit --amend -m "$test_name re #3222" &&
	git push origin topic1
'

test_done

