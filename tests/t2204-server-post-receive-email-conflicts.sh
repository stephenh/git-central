#!/bin/sh

test_description='server post-receive email notification and how it behaves in our stable-based envrionment'

. ./test-lib.sh

export USER=author

test_expect_success 'setup' '
	echo "setup" >a &&
	echo "setup" >b &&
	echo "setup" >c &&
	git add a b c &&
	git commit -m "setup" &&
	git clone ./. server &&
	rm -fr server/.git/hooks &&
	git remote add origin ./server &&
	git config --add branch.master.remote origin &&
	git config --add branch.master.merge refs/heads/master &&
	GIT_DIR=./server/.git git config --add hooks.post-receive-email.mailinglist commits@list.com &&
	GIT_DIR=./server/.git git config --add hooks.post-receive-email.debug true &&
	GIT_DIR=. &&
	echo cbas >./server/.git/description &&

	git checkout -b stable &&
	git push origin stable
'

install_post_receive_hook 'post-receive-email'

test_expect_success 'conflict diff' '
	git checkout stable &&
	echo "line1" >a &&
	echo "line2" >>a &&
	echo "line3" >>a &&
	git commit -a -m "lines" &&
	git push origin stable &&

	git checkout -b topic1 stable &&
	echo "line1.topic1" >a &&
	echo "line2.topic1" >>a &&
	echo "line3.topic1" >>a &&
	git commit -a -m "lines changed on topic1" &&
	git push origin topic1 &&

	old_commit_hash=$(git rev-parse HEAD) &&
	old_commit_abbrev=$(git rev-parse --short HEAD) &&

	# Move stable
	git checkout stable &&
	echo "line1.stable" >a &&
	echo "line2.stable" >>a &&
	echo "line3.stable" >>a &&
	git commit -a -m "lines changed on stable" &&
	git push origin stable &&

	stable_hash=$(git rev-parse HEAD) &&

	git checkout topic1 &&
	! git merge stable &&

	echo "line1.topic" >a &&
	echo "line2.stable" >>a &&
	echo "line3.resolved" >>a &&
	git add a &&
	git commit -a -m "resolved lines for merging stable into topic1" &&
	second_stable_hash=$(git rev-parse HEAD) &&
	git push origin topic1 &&

	new_commit_hash=$(git rev-parse HEAD) &&
	new_commit_date=$(git log -n 1 --pretty=format:%cd HEAD) &&
	new_commit_abbrev=$(git rev-parse --short HEAD) &&

	interpolate ../t2204-1.txt 1.txt old_commit_hash old_commit_abbrev new_commit_hash new_commit_abbrev new_commit_date stable_hash &&
	test_cmp 1.txt server/.git/refs.heads.topic1.out
'

test_done

