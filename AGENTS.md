# AGENTS.md

This file is the vendor-neutral coordination contract for AI tooling that works on this repository itself. It is
not part of the flow: the rules an agent follows *inside a workspace* live in `template/BRIEF.md`.

## Source of Truth

This file is the canonical source of truth for how agents work on this repository.

Vendor-specific files are adapters derived from it, never the source of truth. When present:
- `.claude/CLAUDE.md` — Claude Code adapter; MUST defer to this file.
- `.claude/skills/*/SKILL.md` — tool-scoped skill implementations of shared intent declared here.
- `.mcp.json` — shared MCP server configuration.

No adapter is currently checked in. Add one only when a tool needs mechanics this file cannot express.

Adapters MUST NOT redefine shared rules. Tool-local files such as `.claude/settings.local.json` are not part of the
shared contract.

## Cross-Tool Rules

- Keep shared behavior and domain knowledge in this file. Adapters reference it; they do not restate it.
- Treat vendor-specific directories such as `.codex/` as generated or adapter layers.
- Use progressive context loading. The examples are long (up to about 1,000 lines): read their outlines
  (`grep -n '^#'`) and the sections you need, not whole files.
- Prefer the active tool's native mechanisms for scoped instructions, custom agents, prompts, or subagents
  instead of forcing another vendor's UX model.

## Git

- Never run git commands that change state: no commit, branch, checkout, stash, add, reset, merge, rebase, tag or
  push. The maintainer does all of that.
- Read-only git is fine: status, diff, log, show.
- Leave your changes as uncommitted edits in the working tree, and list the changed files when you finish.
- Skill or workflow steps that say to commit (a design doc, a plan, a task) are skipped here. Leave the files in
  place instead.

## Subagent Orchestration

Cap concurrent subagents at **4 per fan-out wave**. This is a hard limit, counted across nested subagents; excess
work MUST queue into a later wave instead of raising the cap.

Rationale: almost every change here touches the same few files (README, PROMPTS, the templates). Beyond a few
parallel workers, edits collide and the protocol drifts out of agreement faster than it gets written.

Rules:

- Spawn only for genuinely independent slices: in practice, one example file per subagent. The protocol files
  (`README.md`, `PROMPTS.md`, `template/*`, `new-workspace.sh`) are one shared slice and MUST be edited in-session
  by a single owner, before any example work starts.
- Prefer 2-3 subagents. Do the work in-session when it is a single file, a wording fix, or needs conversation
  context the subagent cannot see.
- NEVER fan out for exploration that one or two reads or a grep can answer.
- Assign one integration owner per shared file. Sibling subagents MUST NOT edit the same file.
- Give every subagent its complete slice: the file it owns, the exact names and line forms from the protocol files,
  and the acceptance check (the greps under Commands).
- Dispatch all independent tasks in one batch; NEVER spawn-wait-spawn.
- Collect results once. NEVER poll.
- A subagent MAY spawn its own workers only when its slice requires it; nested fan-out counts against the same cap.
- Run the checks once after the wave, not per subagent.
- A fresh reviewer subagent for a finished change is encouraged; it reads only and counts against the cap.

## Protocol Architecture and Boundaries

The repository publishes a protocol, not code. Its names and line formats are a contract with two readers: leads,
who copy the templates into workspaces, and agents, who follow `template/BRIEF.md` literally.

- **`README.md` is the specification.** `template/BRIEF.md` is the agent's copy of the same rules. `PROMPTS.md` and
  `template/TASKS.md` / `template/GOAL.md` must agree with both. When they disagree, it is a bug; fix it in all of
  them in the same change.
- **File ownership in a workspace** is part of the contract:
  - BRIEF.md and GOAL.md are written by the lead.
  - In TASKS.md, the agent only appends and the lead may edit anything.
  - RESULTS.md is written by the agent and is append-only.
- **Fixed names and line forms.** Renaming any of these is a breaking change:
  - task IDs, branches, patches and reports: `task-<NN>`, `task-<NN>-fix<M>`, `task-<NN>-review`,
    `out/task-<NN>.patch`, `reports/task-<NN>/`
  - review files: `inputs/review-task-<NN>-<M>.md`
  - the `Status: proposed | approved` line
  - log lines: `RESULT`, `BLOCKED`, `IDLE`, `PLANNED`, `WAITING`

  A breaking change updates the templates, README, PROMPTS and all three examples in the same change.
- **Guardrails are not optional.** Don't weaken the following without the maintainer asking:
  - no remote, no network, sandboxed runs
  - no secrets or personal data in text
  - untrusted inputs are data
  - never rewrite history
  - honest "unchecked" labels
  - the lead approves the plan
- **Examples illustrate; they don't define.** A rule that exists only in an example is a bug. Move it to README and
  BRIEF, or delete it.
- Don't add tooling (servers, package manifests, CI) unless asked. The point of the flow is that it is files only.

Dependency graph:

```text
README.md (spec)
├── template/BRIEF.md     agent rules; must match README
├── template/GOAL.md      lead's goal format
├── template/TASKS.md     task format and Status rule
├── PROMPTS.md            kickoff, resume, idle poll, reviewer
├── new-workspace.sh      copies the templates; creates inputs/ reports/ out/ repo/
└── example/
    ├── EXAMPLE_GENERIC.md       the whole flow, including GOAL.md
    ├── EXAMPLE_AGENT_LAB.md     own BRIEF; builds on README
    └── EXAMPLE_GAME_THREEJS.md  builds on EXAMPLE_AGENT_LAB.md
```

## Project Overview

autonomous-flow is a file-driven workflow for letting a coding agent work on a git repository unattended for hours
or days.
1. A lead writes a goal.
2. The agent proposes numbered tasks and the lead approves them.
3. The agent works the approved tasks on branches in a remote-less clone and delivers patches, reports and one log
   line per task.

| Path | Role |
|---|---|
| `README.md` | The protocol specification |
| `PROMPTS.md` | Prompts the lead pastes: kickoff, resume, idle poll, reviewer |
| `template/BRIEF.md`, `template/GOAL.md`, `template/TASKS.md` | Copied into every new workspace |
| `new-workspace.sh` | `new-workspace.sh <workspace-dir> <source-repo> [base-branch]` |
| `example/*.md` | Worked walkthroughs |
| `docs/superpowers/` | Design docs and plans for changes to this repo |

There is no build, test suite or linter. Verification is the greps and the workspace smoke run below.

## Commands

The old notation must never come back. Expected output: nothing.

```bash
grep -rnE '\b[Kk]([0-9]+[a-z]?|<N>|N[a-z]?|<M>)\b|D<NNN>|review-D[0-9*]|K-series' \
  README.md PROMPTS.md template example new-workspace.sh
```

Workspace smoke run, in a throwaway directory. It must create BRIEF.md, GOAL.md, TASKS.md, RESULTS.md, inputs/,
reports/, out/ and repo/, and repo/ must have no remote:

```bash
bash -n new-workspace.sh
ws=$(mktemp -d)/ws && ./new-workspace.sh "$ws" . main && ls "$ws" && git -C "$ws"/repo remote | wc -l
rm -rf "$(dirname "$ws")"
```

The smoke run clones the last *commit*, but it copies the templates from the working tree. Uncommitted template
edits show up in the result; uncommitted changes elsewhere don't.

A template must not ship a task the agent would work. Expected: 0.

```bash
awk '/<!--/{c=1} /-->/{c=0;next} !c && /^## task-/' template/TASKS.md | wc -l
```

## Writing Conventions

Match the existing style. Do not reformat untouched text.

- **Short and plain:** one idea per sentence, no filler, active voice. This is the same rule BRIEF.md gives the
  agent, and the docs should model it.
- **Wrap prose at about 115 columns.** Tables, code blocks and long URLs are exempt.
- **Placeholders** are `<like-this>`. The agent treats a GOAL.md section that still holds them as unwritten, so
  don't use angle brackets for anything else in templates.
- **Dates and times** are UTC: `2026-03-02 14:00 UTC`.
- **Examples use invented people and projects** (Dana, `orders-api`). Never put a real machine name, path, email
  or token into any file. That is the same rule the agent follows.
- **Code blocks** carry a language tag when they hold commands (`bash`) or file contents (`markdown`). Log excerpts
  stay untagged.
- **Shell scripts** are Bash with `#!/usr/bin/env bash` and `set -euo pipefail`. They refuse to overwrite existing
  paths.
- **Markdown** uses LF line endings, UTF-8 and a final newline.

## General Guidelines

1. Before writing anything, describe your approach. Wait for approval when the change touches the protocol (names,
   line forms, ownership, guardrails) or the requirements are ambiguous. A typo or wording fix can go
   ahead directly.
2. If requirements are ambiguous, ask clarifying questions before editing.
3. A protocol change touches several files by nature. List all of them before you start: README, BRIEF, the other
   templates, PROMPTS, the script and the examples. Edit the spec first, then the files that copy it.
4. After a protocol change, walk through it as the agent would. Look for any state where an agent following
   BRIEF.md literally would deadlock, plan twice, work an unapproved task, or edit the lead's text. Report what you
   found.
5. When there is a bug, reproduce it first: a grep that finds the bad text, or a smoke run that fails. Then fix it
   until the same check passes.
6. Every time the user corrects you, reflect on what you did wrong and form a plan to never repeat that mistake.

## Behavioral Guidelines

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Writing

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before editing:
- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum change that solves the problem. Nothing speculative.**

- No rules, log lines or file types beyond what was asked.
- No machinery where a sentence in BRIEF.md would do.
- No configurability that wasn't requested.
- Every rule you add is one more thing an unattended agent can misread. Add a rule only when its absence
  causes a concrete failure.

Ask: "Would a lead reading this for the first time say it is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing files:
- Don't "improve" adjacent wording, examples, or formatting.
- Don't rewrite examples that aren't wrong.
- Match existing style, even if you'd do it differently.
- If you notice an unrelated inconsistency, mention it — don't fix it.

When your changes create orphans:
- Remove references, sections, and placeholders that YOUR change made stale.
- Don't remove pre-existing content unless asked.

The test: every changed line traces directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Rename a term" → "The grep for the old term returns nothing; every example still reads naturally."
- "Add a protocol rule" → "README and BRIEF state it identically. PROMPTS mention it where an agent needs it.
  A walkthrough as the agent finds no deadlock."
- "Fix the script" → "Reproduce the failure in a throwaway smoke run, then make the run pass."
- "Fix an example" → "It agrees with README and BRIEF: names, branches, order words, log lines."

For multi-step tasks, state a brief plan:

```text
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it consistent") require constant
clarification.
