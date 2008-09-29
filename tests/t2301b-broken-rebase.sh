#!/bin/sh

test_description='rebase interactive does not rebase'

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

	git checkout -b stable master &&
	echo "setup.stable" >a &&
	git commit -a -m "stable" &&
	git push origin stable
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
	# B: start our topic2 branch, and share it
	git checkout -b topic2 origin/stable &&
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
	echo "commit D continuing topic2" >a.client2 &&
	git add a.client2 &&
	git commit -m "commit D by client2" &&

	# E: the same other client merges the moved stable
	git merge stable &&

	# F: the same other client moves topic2 again
	echo "commit F" >a.client2 &&
	git commit -a -m "commit F by client2" &&
	F_hash=$(git rev-parse HEAD) &&
	cd .. &&

	# g: now locally merge in the moved stable (even though our topic2 is out of date)
	git checkout topic2 &&
	git merge stable &&
	g_hash=$(git rev-parse HEAD) &&

	# h: advance local topic2
	echo "commit H" >a.topic2 &&
	git commit -a -m "commit H continues local fork" &&
	h_hash=$(git rev-parse HEAD) &&

	# i: make a new merge commit
	git pull --no-rebase &&
	i_hash=$(git rev-parse HEAD) &&

	# Watch merge rejected as something that should get rebased
	# ! git push origin topic2
	test "$i_hash $h_hash $F_hash" = "$(git rev-list --parents --no-walk HEAD)"

	# Now fix it the merge by rebasing it
	git reset --hard ORIG_HEAD &&
	GIT_EDITOR=: git rebase -i -p origin/topic2 &&
	h2_hash=$(git rev-parse HEAD) &&

	# Should be:
	# test "$h2_hash $F_hash" = "$(git rev-list --parents --no-walk HEAD)"
	# But is just:
	test "$h_hash $g_hash" = "$(git rev-list --parents --no-walk HEAD)"
	# Where did $F_hash go?
'

test_done

