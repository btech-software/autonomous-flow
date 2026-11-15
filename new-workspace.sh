#!/usr/bin/env bash
# Usage: new-workspace.sh <workspace-dir> <source-repo-path-or-url> [base-branch]
set -euo pipefail
ws=$1 src=$2 base=${3:-main}
here=$(cd "$(dirname "$0")" && pwd)

[ -e "$ws" ] && { echo "refusing: $ws exists" >&2; exit 1; }
mkdir -p "$ws"/{inputs,reports,out}
cp "$here"/template/BRIEF.md "$here"/template/TASKS.md "$ws"/
: > "$ws"/RESULTS.md

git clone --quiet --branch "$base" "$src" "$ws"/repo
git -C "$ws"/repo remote remove origin   # agent cannot push or fetch

# The agent commits "as the configured author" (BRIEF.md), so one must resolve in repo/.
if ! git -C "$ws"/repo config user.name >/dev/null || ! git -C "$ws"/repo config user.email >/dev/null; then
  echo "warning: no git author resolves in $ws/repo; set one before starting the agent:" >&2
  echo "  git -C $ws/repo config user.name '<name>' && git -C $ws/repo config user.email '<email>'" >&2
fi
echo "workspace ready: $ws (repo/ on $base, no remote). Edit BRIEF.md and TASKS.md, then start the agent there."
