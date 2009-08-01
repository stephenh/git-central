
Svn
===

 * pro: Monotic rev numbers (though commitnumbers is better as they don't change with the whole repo)
 * pro: Cherry picking doesn't duplicate the commit
 * pro: Good/faster trac integration
 * pro: Inherently flattened branches (requires branch.name.rebase+pending preservemerges--or `pull`)
 * con: allows anti-social change hoarding of one large commit
 * con: lots of .svn meta folders (slows down Eclipse)
 * con: looses data in rename+merge scenario
 * con: allows pushing from an out-of-date working copy as long as specific files don't conflict

Git
===

 * pro: index (easier to break up commits, see only conflicts during merging)
 * pro: stash (or local WIP on multiple branches without separate working copies)
 * pro: local commits
 * pro: combined diffs in gitk and commit emails
 * pro: "git diff" in conflicted merges only shows conflicts, not what merged cleanly
 * pro: safe merging (working copy is not munged, always have ORIG_HEAD or reflog)
 * pro: pre-filled-in merge commit messages (e.g. with what conflicted)
 * pro: DAG visualization (gitk)
 * pro: just one .git meta folder
 * con: requires flags/prefer-rebase script to maintain flattened branches
 * con: allows anti-social change hoarding of many small commits
 * con: no good tattoo (fixed with commitnumbers)
 * con: trac integration is slow

