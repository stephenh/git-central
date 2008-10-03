#!/bin/sh

test_description='client checkout auto-set branch rebase=true'

. ./test-lib.sh

test_expect_success 'setup' '
	echo "setup" >file &&
	git add file &&
	git commit -m "setup" &&
	git clone . ./server &&
	git remote add origin ./server &&
	git config branch.master.remote origin &&
	git config branch.master.merge refs/heads/master
'

# setup the post-checkout hook
install_post_checkout_hook 'post-checkout-rebase'

test_expect_success 'sets rebase on new topic branch' '
	! git config --list | grep branch.master.rebase &&
	git checkout -b topic master &&
	git config --list | grep branch.topic.rebase=true
'

test_expect_success 'checking out remote branch does nothing' '
	git push origin topic:topic2 &&
	git fetch &&
	git checkout origin/topic2 &&
	! git config --list | grep "branch..rebase"
'

test_expect_success 'cloning stable sets up the correct merge' '
	git push origin topic:stable &&
	git fetch &&
	git checkout -b topic3 origin/stable &&
	test "refs/heads/topic3" = "$(git config branch.topic3.merge)"
'

test_done

