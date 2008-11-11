#!/bin/sh

test_description='server update trac ticket enforcer via shim'

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
install_update_hook 'update-ensure-ticket-reference'

test_expect_success 'reject new branch with bad message' '
	git checkout -b topic1 master &&
	echo $test_name >a &&
	git commit -a -m "$test_name" &&
	head=$(git rev-parse HEAD)
	! git push origin topic1 >push.out 2>push.err &&
	cat push.err | grep "Commit $head does not reference a ticket"
'

# the last test has a dirty commit message, so ammend it with a good message
test_expect_success 'accept new branch with re' '
	git checkout -b topic2 master &&
	echo $test_name >a &&
	git commit --amend -m "$test_name re #3222" &&
	git push origin topic2
'

test_expect_success 'reject new branch with bad message in second of three' '
	git checkout -b topic3 master &&
	echo "$test_name first" >a &&
	git commit -a -m "$test_name first re #3222" &&

	# the bad one
	echo "$test_name second" >a &&
	git commit -a -m "$test_name second" &&
	head=$(git rev-parse HEAD) &&

	echo "$test_name third" >a &&
	git commit -a -m "$test_name third re #3222" &&

	! git push origin topic3 >push.out 2>push.err &&
	cat push.err | grep "Commit $head does not reference a ticket"
'

test_expect_success 'accept new branch with re in all of three' '
	git checkout -b topic4 master &&
	echo "$test_name first" >a &&
	git commit -a -m "$test_name first re #3222" &&

	# the bad one
	echo "$test_name second" >a &&
	git commit -a -m "$test_name second re #3222" &&
	head=$(git rev-parse HEAD) &&

	echo "$test_name third" >a &&
	git commit -a -m "$test_name third re #3222" &&

	git push origin topic4
'

test_expect_success 'accept branch that has been excused' '
	git checkout -b topic5 master &&
	echo "$test_name first" >a &&
	git commit -a -m "$test_name first with no re" &&

	! git push origin topic5

	cd server
	git config hooks.update-ensure-ticket-reference.excused topic5
	cd ..

	git push origin topic5
'

test_done

