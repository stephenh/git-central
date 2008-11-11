#!/bin/sh

# Create an empty file object
empty_file_hash=$(git hash-object -w --stdin <<FOO
FOO)

# Make a root directory tree with the config file in it
config_tree_hash=$(git mktree <<FOO
100644 blob $empty_file_hash	config
FOO)

# Commit the root directory tree
commit_hash=$(git commit-tree $config_tree_hash <<FOO
Initial commit on config branch.
FOO)

# Push the commit out to the gitconfig branch
git update-ref refs/heads/gitconfig "$commit_hash" 0000000000000000000000000000000000000000

