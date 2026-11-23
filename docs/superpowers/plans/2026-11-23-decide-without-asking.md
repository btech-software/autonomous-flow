# Decide Without Asking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** An unattended agent never asks or waits in the session; it decides the smallest reversible option and
writes it down, or logs BLOCKED with the question and moves on.

**Architecture:** One protocol rule, stated in the spec (README.md) and copied into the agent's rules
(template/BRIEF.md), the kickoff prompt (PROMPTS.md) and the one example with its own full Rules section
(example/EXAMPLE_AGENT_LAB.md). No new log line, file type or Status value.

**Tech Stack:** Markdown files and the existing Bash script `new-workspace.sh`. No build or test suite: verification
is greps and the workspace smoke run from AGENTS.md.

**Spec:** `docs/superpowers/specs/2026-11-23-decide-without-asking-design.md`

## Global Constraints

- Branch `decide-without-asking`, worktree `../autonomous-flow-decide-without-asking`. Leave every change
  uncommitted; the maintainer commits (AGENTS.md, Git). Skip the commit steps of any skill.
- Do not touch the uncommitted work on `main` in `../autonomous-flow`.
- Line forms stay fixed: `RESULT`, `BLOCKED`, `IDLE`, `PLANNED`, `WAITING`, `Status: proposed | approved`.
- Wrap prose at about 115 columns. LF, UTF-8, final newline. Do not reformat untouched text.
- No real machine names, paths, people or tokens in any file.
- Guardrails and the task's text always win over "smallest and easiest to undo".

## Review Focus

1. A skill or command the agent runs says "ask the user" or "wait for approval". The agent skips that step, decides,
   and records it. It does not stall. Pinned by the walkthrough in Task 1, Step 6 (scenario a).
2. A `Status: proposed` task. "Never wait" must not make the agent work it. It still logs WAITING and works other
   approved tasks. Pinned by Task 1, Step 6 (scenario b).
3. The quickest option breaks a guardrail (rewrites history, needs network or an install). The guardrail wins and
   the agent logs BLOCKED. Pinned by Task 1, Step 6 (scenario c).
4. A choice comes up while planning, before any report exists. The agent writes the assumption into the task text
   it appends, and does not ask. Pinned by Task 1, Step 6 (scenario d).
5. A fresh session started with the resume prompt, which never mentions the rule. The rule must reach it through
   BRIEF.md alone. Pinned by Task 1, Step 5 (smoke run) and Step 6 (scenario e).

---

### Task 1: The rule in the protocol files (README, BRIEF, PROMPTS)

AGENTS.md makes these one shared slice with a single owner, edited before any example work.

**Files:**
- Modify: `README.md` (section "### 3. The agent does the work", new bullet after **Host-only verification**)
- Modify: `template/BRIEF.md` (section "## Rules", new bullet directly after the `IDLE` / `BLOCKED` bullet, lines 39-40)
- Modify: `PROMPTS.md` (section "## Kickoff (first session)", one sentence appended inside the quote)

**Interfaces:**
- Produces: the exact BRIEF bullet text below. Task 2 copies it verbatim.

- [ ] **Step 1: Run the check and confirm it fails**

Run, from the worktree root:
```bash
grep -c 'Decisions without asking' README.md; grep -c 'Never ask the lead anything in this session' template/BRIEF.md; grep -c 'Never stop to ask me' PROMPTS.md
```
Expected: `0`, `0`, `0`.

- [ ] **Step 2: Add the README bullet (the spec)**

Exact text, as one bullet in section 3:
```markdown
- **Decisions without asking:** the lead reads the files, not the session. The agent never asks a question in
  the session and never waits there for an answer, even when a skill or command it runs says to. Approval of
  proposed tasks still happens in TASKS.md. When a task leaves a choice open, the agent takes the option that is
  smallest and easiest to undo, within the task's text and the guardrails. It lists each such choice and its
  alternatives under `## Decisions` in the task's report. A choice it can't make safely becomes a `BLOCKED` line
  that states the question, and the agent moves on.
```

- [ ] **Step 3: Add the BRIEF bullet (the agent's copy)**

Exact text, directly after the bullet that starts `- When none is left, append`:
```markdown
- Never ask the lead anything in this session, and never wait there for an answer: the lead reads only these
  files. Skip any skill or command step that asks or waits. Proposed tasks still wait for approval in TASKS.md.
  When a task leaves a choice open, take the option that is smallest and easiest to undo within the task and these
  rules, and list it with the alternatives under `## Decisions` in the task's report. If no option is safe without
  the lead, append BLOCKED with the question and go on to the next task.
```

- [ ] **Step 4: Append the kickoff sentence in PROMPTS.md**

At the end of the Kickoff quote, after "poll as when idle.", add on the quote's last line or a new `>` line:
`Never stop to ask me in this session; decide or log BLOCKED as BRIEF.md says.`

- [ ] **Step 5: Run the checks and confirm they pass**

```bash
grep -c 'Decisions without asking' README.md; grep -c 'Never ask the lead anything in this session' template/BRIEF.md; grep -c 'Never stop to ask me' PROMPTS.md
grep -rnE '\b[Kk]([0-9]+[a-z]?|<N>|N[a-z]?|<M>)\b|D<NNN>|review-D[0-9*]|K-series' README.md PROMPTS.md template example new-workspace.sh
awk '/<!--/{c=1} /-->/{c=0;next} !c && /^## task-/' template/TASKS.md | wc -l
git diff -U0 | grep '^+' | grep -v '^+++' | awk 'length > 116' | wc -l
bash -n new-workspace.sh
ws=$(mktemp -d)/ws && ./new-workspace.sh "$ws" . decide-without-asking && grep -c 'Never ask the lead anything' "$ws"/BRIEF.md && git -C "$ws"/repo remote | wc -l; rm -rf "$(dirname "$ws")"
```
Expected: `1`, `1`, `1`; no output from the old-notation grep; `0`; `0`; no syntax error; the smoke run prints
`workspace ready`, then `1` (the template is copied from the working tree), then `0` remotes.

- [ ] **Step 6: Walk through it as the agent (AGENTS.md guideline 4)**

Read template/BRIEF.md literally for each scenario and write one line per scenario in the hand-off note: the line
of BRIEF.md that decides it, and the resulting action. Each must end without a question in the session, without
working a proposed task and without a deadlock:
- (a) A skill step says "ask the user which option, then wait". Expected: skip, decide, `## Decisions` entry.
- (b) Only `Status: proposed` tasks remain. Expected: WAITING, then poll as when idle, per Planning.
- (c) The quickest fix needs `git push --force` or a package install. Expected: BLOCKED with the question.
- (d) While planning, the goal is ambiguous about scope. Expected: the assumption is written into the appended
  task text, under the existing "workable without asking".
- (e) A session started with the Resume prompt only. Expected: BRIEF.md alone gives the rule.

Report any scenario that fails, and stop. Do not add rules to fix it without the maintainer.

- [ ] **Step 7: Leave the files uncommitted** and list them: README.md, template/BRIEF.md, PROMPTS.md.

---

### Task 2: The rule in EXAMPLE_AGENT_LAB.md's own brief

**Files:**
- Modify: `example/EXAMPLE_AGENT_LAB.md` (its `## Rules`, new bullet directly after the bullet that starts
  `- When none is left, append`, lines 212-213)

**Interfaces:**
- Consumes: the BRIEF bullet from Task 1, Step 3, verbatim.

The other examples need no edit. EXAMPLE_GENERIC.md abbreviates its brief. EXAMPLE_GAME_THREEJS.md says
"(the Rules section from the Agent-Lab brief, unchanged)". The troubleshooting row "Agent stops to ask questions"
stays as it is: it illustrates the rule and is still true.

- [ ] **Step 1: Run the check and confirm it fails**

```bash
grep -c 'Never ask the lead anything in this session' example/EXAMPLE_AGENT_LAB.md
```
Expected: `0`.

- [ ] **Step 2: Insert the Task 1 bullet verbatim**

- [ ] **Step 3: Run the checks and confirm they pass**

```bash
b() { awk '/^- Never ask the lead anything/{p=1;print;next} p&&/^(- |$|#)/{p=0} p' "$1"; }
diff <(b template/BRIEF.md) <(b example/EXAMPLE_AGENT_LAB.md) && echo identical
grep -rnE '\b[Kk]([0-9]+[a-z]?|<N>|N[a-z]?|<M>)\b|D<NNN>|review-D[0-9*]|K-series' README.md PROMPTS.md template example new-workspace.sh
git diff -U0 | grep '^+' | grep -v '^+++' | awk 'length > 116' | wc -l
```
Expected: `identical`; no output from the old-notation grep; `0`.

- [ ] **Step 4: Leave the file uncommitted** and list all changed files on the branch: README.md, template/BRIEF.md,
  PROMPTS.md, example/EXAMPLE_AGENT_LAB.md, plus the spec and this plan under docs/superpowers/.

## Merge note for the maintainer

`main` has uncommitted edits in template/BRIEF.md (line 38, the `#<issue>` sentence) and in
example/EXAMPLE_AGENT_LAB.md (around lines 412, 553 and 562). This branch adds lines right after BRIEF.md line 40
and EXAMPLE_AGENT_LAB.md line 213. They do not overlap. Expect a clean merge or a trivial adjacent-line resolution
in BRIEF.md.
