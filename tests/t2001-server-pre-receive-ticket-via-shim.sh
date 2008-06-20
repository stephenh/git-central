
#!/bin/sh

test_description='server pre-receive ticket enforcer via shim'

. ./test-lib.sh

test_expect_success 'setup' '
	echo This is a test. >a &&
	git add a &&
	git commit -m "a" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server &&
	git config --add branch.master.remote origin &&
	git config --add branch.master.merge refs/heads/master
'

# setup the shim
install_server_hook 'pre-receive' 'pre-receive'
install_server_hook 'pre-receive-ticket' 'pre-receive-ticket'

test_expect_success 'reject with bad message via shim' '
	echo $test_name >a &&
	git commit -a -m "$test_name" &&
	head=$(git rev-parse HEAD)
	git push >push.out 2>push.err
	cat push.err | grep "Commit $head does not reference a ticket"
'

# the last test has a dirty commit message, so ammend it with a good message
test_expect_success 'accept with re via shim' '
	echo $test_name >a &&
	git commit --amend -m "$test_name re #3222" &&
	git push
'

test_done

