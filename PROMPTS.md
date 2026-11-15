# Prompts

The prompts are short because the files carry the state. Replace task IDs and branches as needed.

## Kickoff (first session)

> Read BRIEF.md, GOAL.md, TASKS.md and RESULTS.md in this folder. Plan any GOAL.md section that has no PLANNED
> line, under BRIEF.md. Then work the first approved task with no RESULT or BLOCKED line, and continue through the
> queue without stopping. While tasks wait for my approval, poll as when idle.

## Resume (fresh session after a crash or a full context)

Say what is done, what comes next, and that existing work is the agent's own:

> Fresh session (the last one could not continue). Read BRIEF.md, GOAL.md, TASKS.md and RESULTS.md. task-01 to
> task-04 are done. Continue task-05 (branch task-05 from main; any work already on that branch or in the working
> tree is yours from the last session, so keep it), then task-06, straight through.

If the previous session died from an oversized context:

> Your previous session ran out of room. Read only the tails of GOAL.md, TASKS.md and RESULTS.md (find PLANNED
> lines and task headers with grep, as BRIEF.md says), keep every read small, and do the first unfinished
> approved task.

## Idle poll

Use this when the queue is empty, or every remaining task is waiting for approval, and the agent should keep
watching. In Claude Code:

> /loop 10m Read the tails of GOAL.md, TASKS.md and RESULTS.md. If a GOAL.md section has no PLANNED line (check
> with grep over the whole of RESULTS.md), plan it under BRIEF.md. If an approved task has no RESULT or BLOCKED line, work it under BRIEF.md. Otherwise append
> `IDLE <UTC time>` to RESULTS.md.

## Reviewer (separate session, no shared context)

> You are an independent reviewer. Read BRIEF.md and task-<NN> in TASKS.md. Apply out/task-<NN>.patch on <base> in
> a scratch branch, run the host checks, and judge it only against the task. Write inputs/review-task-<NN>-<M>.md
> (M: 1 for the first review of this task, 2 for the next) with LAND, CHANGES or HOLD, then each ask as a numbered
> item with file:line. Do not fix anything yourself, and do not write to RESULTS.md.

After the review, the lead appends a fix task to TASKS.md:

```
## task-<NN>-fix1 (now; lead, <date> UTC): the review's changes to task-<NN>
inputs/review-task-<NN>-1.md asks: 1) ... 2) ... Same branch task-<NN>, one new commit. Re-export
out/task-<NN>.patch; RESULT line saying how each ask was met.
```
