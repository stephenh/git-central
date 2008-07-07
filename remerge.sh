#!/bin/sh

git rev-list --first-parent "stable..HEAD" | while read commit ; do
	number_of_parents=$(git rev-list -n 1 --parents $commit | sed 's/ /\n/g' | grep -v $commit | wc -l)
	if [[ $number_of_parents > 1 ]] ; then
		# For each parent
		git rev-list --no-walk --parents $commit | sed 's/ /\n/g' | grep -v $commit | while read parent ; do
			echo "merge=$commit parent=$parent"
			# Does this parent have any children besides us?
			#
			# List the parents of all branch commits (after stable/parent), find
			# those that include our parent, get their sha1, remove our merge
			git rev-list --parents --branches ^stable "^$parent" | grep $parent | gawk '{print $1}' | grep -v $commit | while read child ; do
				echo "child $child"
				git rev-list "$child" "^$commit"
			done
			# Find any commits in the parent (and another branch) but not us--that means we need it
			# number_missing=$(git rev-list "$parent" --branches "^HEAD" | wc -l)
			# if [[ $number_missing > 0 ]] ; then
			# 	git rev-list "$parent" --branches "^HEAD" | xargs git name-rev
			# fi
		done
	fi
done

