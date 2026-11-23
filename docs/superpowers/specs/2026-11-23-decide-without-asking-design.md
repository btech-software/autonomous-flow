# Decide without asking

## Intent
An unattended run must not stop to ask the lead a question inside the session. The lead reads the files, not the
session. A question asked there waits until someone happens to look. In one real unattended run, a single question
held the agent for 23.5 hours, and another one for 7.7 hours. Model time across those runs was under 10 hours.

The flow already says the agent works "without asking for confirmation" (README) and plans tasks that are
"workable without asking" (BRIEF). It does not say what to do when a choice comes up in the middle of a task, or
when a skill or command the agent runs tells it to ask or to wait for an answer. Only an example's troubleshooting
table mentions the failure (EXAMPLE_AGENT_LAB.md, "Agent stops to ask questions"). A rule that exists only in an
example is a bug (AGENTS.md).

## Goals
- The agent never asks in the session and never waits there for an answer.
- A choice the task leaves open gets made, and the lead can see it and overrule it in review.
- A choice the agent cannot make safely reaches the lead through a file, and the agent moves on.

## Non-goals
- No new log line, file type or Status value. BLOCKED already carries "why".
- No change to planning approval: proposed tasks still wait for the lead in TASKS.md.

## Anti-goals
- The agent reads "don't ask" as permission to work proposed tasks or to skip the lead's approval.
- The agent picks a destructive or guardrail-breaking option because it was "the quickest decision".
- Decisions made silently, with nothing in the report.

## Approaches
- **A. One rule in BRIEF and README: decide the smallest reversible option, write it under `## Decisions` in the
  task's report, BLOCKED when no option is safe (picked).** It uses the existing report and BLOCKED line. It costs
  one bullet in each copy of the rules.
- B. A new `ASKED` log line plus a question file in inputs/. It is more machinery, and it adds a line form to the
  fixed contract.
- C. Only a kickoff-prompt sentence. A fresh session started with the resume prompt would not see it, and BRIEF is
  what the agent follows literally.

## Design
- README.md, "### 3. The agent does the work": one bullet, **Decisions without asking**, the spec of the rule.
- template/BRIEF.md, "## Rules": the agent's copy of the same rule, as one bullet after the BLOCKED/IDLE bullet.
- PROMPTS.md, Kickoff: one sentence pointing at the rule.
- example/EXAMPLE_AGENT_LAB.md: the same bullet in its own BRIEF's Rules. The other examples need no edit:
  EXAMPLE_GENERIC abbreviates its BRIEF, and EXAMPLE_GAME_THREEJS reuses the Agent-Lab rules unchanged.
- Guardrails and the task's text always win over "smallest and easiest to undo".

## Left to the builder
Line wrapping at about 115 columns, and the exact position of the README bullet within section 3.
