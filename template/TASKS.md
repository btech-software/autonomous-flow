# Tasks (task queue)

<!--
Header: ## task-<NN> (<order>; <lead|agent>, <date time>; <source>): <one-line goal>
  order:  now | next | after task-<MM> | next window | do these BEFORE task-<MM>
  source: GOAL.md | follow-up <N> | #<issue>
Status line, directly under the header: Status: proposed | approved
  The agent works only approved tasks. A task with no Status line counts as approved,
  so tasks the lead writes by hand need none.
Body: inputs to read, base branch and new branch, exact checks / acceptance criteria,
deliverables (out/task-<NN>.patch, reports/task-<NN>/REPORT.md|REVIEW.md|MEMO.md), then "RESULT line."
Review follow-ups: ## task-<NN>-fix1 (...): the independent review's changes, citing inputs/review-task-<NN>-<M>.md.

Who writes here:
- The agent appends the tasks it proposes from GOAL.md. It never edits or deletes an existing entry.
- The lead may edit anything: reword a proposal, delete it, reorder it, add tasks, flip proposed to approved.
The agent picks the first approved task with no RESULT or BLOCKED line in RESULTS.md.

Example of a task the lead writes by hand (no Status line, so it counts as approved). Copy it below this comment;
left here, the agent ignores it:

## task-01 (now; lead, <date> UTC; #<issue>): <goal>
inputs/task-01/ has <issue / PR / data>. On a branch task-01 from main: <what to change>. Check: <acceptance
criteria the agent can run on this host>. Add a test that fails without the change and passes with it. Deliver
out/task-01.patch, reports/task-01/REPORT.md; RESULT line.
-->
