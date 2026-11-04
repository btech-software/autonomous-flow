# Prompts

The prompts are short because the files carry the state. Replace task IDs and branches as needed.

## Kickoff (first session)

> Read BRIEF.md, TASKS.md and RESULTS.md in this folder, then work the first task with no RESULT or BLOCKED line,
> under BRIEF.md. Continue through the queue without stopping.

## Resume (fresh session after a crash or a full context)

Say what is done, what comes next, and that existing work is the agent's own:

> Fresh session (the last one could not continue). Read BRIEF.md, TASKS.md and RESULTS.md. K1 to K4 are done.
> Continue K5 (branch k5 from main; any work already on that branch or in the working tree is yours from the
> last session, so keep it), then K6, straight through.

If the previous session died from an oversized context:

> Your previous session ran out of room. Read only the tails of TASKS.md and RESULTS.md, keep every read small,
> and do the first unfinished task.

## Idle poll

Use this when the queue is empty and the agent should keep watching for new tasks. In Claude Code:

> /loop 10m Read the tail of TASKS.md and RESULTS.md. If a task has no RESULT or BLOCKED line, work it under
> BRIEF.md; otherwise append `IDLE <UTC time>` to RESULTS.md.

## Reviewer (separate session, no shared context)

> You are an independent reviewer. Read BRIEF.md and task KN in TASKS.md. Apply out/kN.patch on <base> in a
> scratch branch, run the host checks, and judge it only against the task. Write inputs/review-D<NNN>.md with
> LAND, CHANGES or HOLD, then each ask as a numbered item with file:line. Do not fix anything yourself, and do
> not write to RESULTS.md.

After the review, the lead appends a follow-up task to TASKS.md:

```
## KNb (now; lead, <date> UTC): the review's changes to KN
inputs/review-D<NNN>.md asks: 1) ... 2) ... Same branch kN, one new commit. Re-export out/kN.patch; RESULT line
saying how each ask was met.
```
