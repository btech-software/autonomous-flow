# Tasks (K-series)

<!--
Header: ## K<N> (<order>; lead, <date time>; #<issue>): <one-line goal>
  order: now | next | after K<M> | next window | do these BEFORE K<M>
Body: inputs to read, base branch and new branch, exact checks / acceptance criteria,
deliverables (out/k<N>.patch, reports/K<N>/REPORT.md|REVIEW.md|MEMO.md), then "RESULT line."
Review follow-ups: ## K<N>b (...): the independent review's changes, citing inputs/review-D<NNN>.md.
Append only; the agent finds the first task with no RESULT/BLOCKED line in RESULTS.md.
-->

## K1 (now; lead, <date> UTC; #<issue>): <goal>
inputs/K1/ has <issue / PR / data>. On a branch k1 from main: <what to change>. Check: <acceptance criteria the
agent can run on this host>. Add a test that fails without the change and passes with it. Deliver out/k1.patch,
reports/K1/REPORT.md; RESULT line.
