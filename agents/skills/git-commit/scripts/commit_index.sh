#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 '<type: summary>' ['body line 1' ...]" >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a Git repository." >&2
  exit 1
fi

if git diff --cached --quiet; then
  echo "No staged changes to commit." >&2
  exit 2
fi

subject="$1"
shift

cmd=(git commit -m "$subject")
for body in "$@"; do
  cmd+=(-m "$body")
done

"${cmd[@]}"
git log -1 --oneline
