# Agent rules for this repository

These rules are for coding agents that work on this repository itself. They are not part of the flow's
templates.

## Git
- Never run git commands that change state: no commit, branch, checkout, stash, add, reset, merge, rebase, tag or
  push. The maintainer does all of that.
- Read-only git is fine: status, diff, log, show.
- Leave your changes as uncommitted edits in the working tree, and list the changed files when you finish.
- Skill or workflow steps that say to commit (a design doc, a plan, a task) are skipped here. Leave the files in
  place instead.
