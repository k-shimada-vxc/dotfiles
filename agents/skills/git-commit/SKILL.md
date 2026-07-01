---
name: git-commit
description: Split repository changes into appropriate intentional commits and create Japanese conventional commit messages. Use when the user asks to commit changes, organize commits, split work by purpose, or commit staged/unstaged changes; inspect the full git state, avoid unrelated files, stage only the intended paths or hunks, commit one intent at a time, and do not push.
---

# Git Commit

Create clean local commits from the current repository state.

## Core Workflow

1. Inspect all current changes:
   - `git status --short`
   - `git diff --stat`
   - `git diff --cached --stat`
   - Read focused diffs for changed files before deciding commit groups.
2. Identify commit groups by intent, not by file count. Use one commit per intent.
3. Do not require every intermediate commit to build by itself. Prefer a readable history over broadening a commit just to make each commit independently buildable.
4. Ensure the final worktree state is reasonable before finishing. Run relevant formatters/tests when the committed changes warrant them, or report why they were not run.
5. Stage only files or hunks for the current group. Use `git add <path>` for cleanly separated files and `git add -p` when one file contains multiple intents.
6. Commit the current index with a Japanese conventional commit message.
7. Repeat until all intended changes are committed.
8. Report created commits from `git log --oneline` and mention any remaining untracked or unstaged files.

## Grouping Rules

- Keep one intention per commit.
- Separate unrelated work even when it touches adjacent files.
- Separate generated files from source edits when the generator boundary is clear.
- Keep mechanical formatting separate from behavioral changes when both are substantial.
- Keep test-only changes separate when they are not inseparable from the implementation.
- Do not include user or environment files unless the user explicitly asked for them.
- If the correct split is ambiguous, propose the groups and ask before staging.

## Buildability Policy

- Commit-unit buildability is not required.
- Do not merge distinct intentions solely because an earlier commit would not compile or pass tests alone.
- The final state after all planned commits should be verified according to repository expectations.
- If final verification fails, stop and report the failure instead of creating more commits blindly.

## Commit Message Policy

- Use Japanese conventional commit subjects: `<type>: <短い要約>`.
- Subject is required.
- Body is optional.
- For simple changes, subject-only is allowed.

### Prefix Guide

- `feat`: New behavior, feature additions, or user-visible capability changes.
- `fix`: Bug fixes and behavior corrections.
- `refactor`: Internal restructuring without behavior changes.
- `test`: Test-only updates.
- `docs`: Documentation-only updates.
- `chore`: Maintenance work, build/config/tooling, or repository housekeeping.

### Body Guidelines

- `feat` / `fix`: body recommended when impact or cause is not obvious.
- `refactor`: body recommended for non-trivial restructuring.
- `chore` / `docs` / `test`: subject-only is usually enough.
- Use concise Japanese labels only when useful, such as `背景:`, `変更内容:`, `意図:`, `影響:`, `テスト:`.
- Keep each body label to one line.

## Safe Staging Rules

- Never discard working tree changes.
- Never run `git reset --hard`, `git checkout --`, or destructive cleanup.
- Do not amend, rebase, squash, or push unless the user explicitly asks.
- If existing staged changes do not match the next commit group, explain the mismatch and adjust the index without discarding file contents.
- If a file has mixed intents and hunk staging is not reliable, ask the user how to split it.

## Helper Script

Use `scripts/commit_index.sh` to commit the current index after staging the intended group.

1. Resolve the script relative to this `SKILL.md`, not relative to the repository being committed.
2. Verify the script exists before using it.
3. If the environment uses approval-gated sandboxing and committing needs `.git/index.lock`, request the runtime's elevated/approved execution path before running the helper.
4. If the helper is missing, fall back to plain `git commit -m ...` and explicitly mention the fallback.
