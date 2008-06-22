#!/bin/sh

rm .git/hooks/*

cat >.git/hooks/commit-msg <<'FOO'
#!/bin/sh

grep -i '\(\(re\|refs\|qa\) #[0-9]\+\)\|\(no ticket\)' "$1" > /dev/null

if [ $? -ne 0 ]
then
	echo "Please reference a ticket"
	exit 1
fi
FOO

cat >.git/hooks/post-checkout <<'FOO'
#!/bin/bash

# The hook is given three parameters: the ref of the previous HEAD, the ref of
# the new HEAD (which may or may not have changed), and a flag indicating
# whether the checkout was a branch checkout (changing branches, flag=1) or a
# file checkout (retrieving a file from the index, flag=0).

branch=$(git symbolic-ref HEAD)
branch=${branch/refs\/heads\//}

git config --list | grep "branch.${branch}.rebase" > /dev/null
if [ $? -ne 0 ] ; then
	git config --add "branch.${branch}.rebase" true
fi
FOO

