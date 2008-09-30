#!/bin/sh

test_description='server update prefer underscores in branch names'

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
	git checkout -b stable &&
	git push origin stable
'

install_update_hook 'update-prefer-underscores'

test_expect_success 'pushing topic_topic works' '
	git checkout -b topic_topic &&
	echo "$test_name" >a &&
	git commit -a -m "$test_name on topic_topic" &&
	git push origin topic_topic
'

test_expect_success 'pushing topicTopic fails' '
	git checkout -b topicTopic &&
	echo "$test_name" >a &&
	git commit -a -m "$test_name on topicTopic" &&
	! git push origin topicTopic 2>push.err &&
	cat push.err | grep "Please use underscored branch names"
'

test_done

