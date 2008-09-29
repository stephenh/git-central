#!/bin/sh

test_description='server update prefer rebase (with incoming merges)'

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
	git fetch &&

	# Specifically, setup a stable that we will merge and check for rebase
	git checkout -b stable master &&
	echo "setup.stable" >a &&
	git commit -a -m "stable" &&
	git push origin stable
'

install_update_hook 'update-prefer-rebase'

#
# A -- B         <-- origin/stable
#  \   |
#   C -- D       <-- origin/topic1
#    \ |  \
#      e - f     <-- topic1
#
# Nope: should rebase e ontop of D
#
test_expect_success 'merging in stable does not fool the script' '
	# start our branch, and share it
	git checkout -b topic1 stable &&
	git config --add branch.topic1.remote origin &&
	git config --add branch.topic1.merge refs/heads/topic1 &&
	echo "topic1" >a.topic1 &&
	git add a.topic1 &&
	git commit -m "topic1" &&
	git push origin topic1 &&

	# now, separately, move ahead stable, and share it
	git checkout stable
	echo "setup.stable.moved" >a &&
	git commit -a -m "stable moved" &&
	git push origin stable &&

	# have another client commit (in this case, it is the server, but close enough) move topic1
	cd server &&
	git checkout topic1 &&
	echo "$test_name" >a.client2 &&
	git add a.client2 &&
	git commit -m "topic1 changed by client2" &&
	cd .. &&

	# now locally try and merge in stable (even though topic1 is out of date)
	git checkout topic1 &&
	git merge stable &&

	# We are shutdown for being a rewind
	! git push 2>push.err &&
	cat push.err | grep "[rejected]        topic1 -> topic1 (non-fast forward)"

	# Make a new merge commit
	git pull &&
	! git push 2>push.err &&
	cat push.err | grep "It looks like you should rebase instead of merging" &&

	# Now fix it
	git reset --hard ORIG_HEAD &&
	GIT_EDITOR=: git rebase -i -p origin/topic1 &&
	git push &&
	git branch -r --contains stable | grep origin/topic
'

#
# A --C------            <-- origin/stable
#  \  |      \
#   B -- D -- E -- F     <-- origin/topic2
#    \|             \
#     g -- h ------- i   <-- topic2
#
# Trying to push F..i
#
# merge-base(F, h) has two options: B and C
#
test_expect_success 'merging in stable with tricky double baserev does not fool the script' '
	# B: start our branch, and share it
	git checkout -b topic2 stable &&
	git config --add branch.topic2.remote origin &&
	git config --add branch.topic2.merge refs/heads/topic2 &&
	echo "commit B" >a.topic2 &&
	git add a.topic2 &&
	git commit -m "commit B created topic2" &&
	git push origin topic2 &&

	# C: now, separately, move ahead stable, and share it
	git checkout stable
	echo "commit C" >a &&
	git commit -a -m "commit C moved stable" &&
	git push origin stable &&

	# D: have another client commit (in this case, it is the server, but close enough) moves topic2
	cd server &&
	git checkout topic2 &&
	# We might have cruft from the previous test
	git reset --hard &&
	echo "commit D continuing topic2" >a.client2 &&
	git add a.client2 &&
	git commit -m "commit D by client2" &&

	# E: another client merges stable
	git merge stable &&

	# F: another client moves topic2 again
	echo "commit F" >a.client2 &&
	git commit -a -m "commit F by client2" &&
	cd .. &&

	# g: now locally try and merge in stable (even though topic2 is out of date)
	git checkout topic2 &&
	git merge stable &&

	# h: advance local topic2
	echo "commit H" >a.topic2 &&
	git commit -a -m "commit H continues local fork" &&

	# i: make a new merge commit
	git pull &&
	! git push origin topic2 2>push.err &&
	cat push.err | grep "It looks like you should rebase instead of merging"

	# Now fix it
	# git reset --hard ORIG_HEAD &&
	# GIT_EDITOR=: git rebase -i -p origin/topic2 &&
	# git push &&
	# git branch -r --contains stable | grep origin/topic2
'

test_done

