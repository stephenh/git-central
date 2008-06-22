#!/bin/sh

test_description='client checkout auto-set branch rebase=true'

. ./test-lib.sh

test_expect_success 'setup' '
	echo "setup" >file &&
	git add file &&
	git commit -m "setup"
'

# setup the post-checkout hook
install_client_hook 'post-checkout-rebase' 'post-checkout'

test_expect_success 'sets rebase on new topic branch' '
	! git config --list | grep branch.master.rebase &&
	git checkout -b topic master &&
	git config --list | grep branch.topic.rebase=true
'

test_done

