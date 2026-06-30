---
name: gh-address-comments
description: Address actionable GitHub PR review threads or issue comments for the current branch using the GitHub CLI. Use when the user asks to inspect, fix, reply to, or resolve PR comments; verify gh authentication, fetch thread-level context, ask which comments to address unless the scope is explicit, then implement fixes, test, reply, and resolve confirmed threads.
---

# PR Comment Handler

Find the open PR for the current branch and address comments with `gh`.

## Preconditions

- Ensure `gh` is installed and authenticated with repo access. Run `gh auth status`; if it fails, ask the user to run `gh auth login`.
- Networked `gh` commands may require the active agent runtime's approval flow. In Codex, rerun blocked `gh` commands with escalated sandbox permissions. In Claude Code, follow the permission prompt.
- Use the bundled `scripts/fetch_comments.py` from this skill directory. Do not search the working repository for another copy first.

## 1) Inspect comments needing attention

- Run the skill-local `scripts/fetch_comments.py` from the target repository and capture output to a temporary JSON file for filtering.
- Group inline comments by review thread (`PRRT_*`) and prioritize unresolved threads.
- Include top-level PR conversation comments when they contain actionable requests.

## 2) Ask the user for clarification

- Number the actionable unresolved threads/comments and summarize the required fixes briefly.
- Ask which numbered comments to address unless the user explicitly said to handle all actionable comments.

## 3) If user chooses comments

- Apply fixes for the selected comments.
- Run focused tests before replying on GitHub. If a test cannot be run, explain why before posting or resolving.

## 4) Reply and resolve threads

- Prefer replying at thread level, then resolve the same thread when the fix is confirmed.
- Reply template command:
```bash
gh api graphql \
  -f query='mutation($threadId:ID!,$body:String!){addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$threadId,body:$body}){comment{id url}}}' \
  -f threadId='PRRT_xxx' \
  -f body='対応内容'
```
- Resolve template command:
```bash
gh api graphql \
  -f query='mutation($threadId:ID!){resolveReviewThread(input:{threadId:$threadId}){thread{id isResolved}}}' \
  -f threadId='PRRT_xxx'
```

## 5) Verify no unresolved target threads remain

- Re-run the skill-local `scripts/fetch_comments.py` and confirm target threads are resolved.
- Share a short summary: fixed threads, remaining threads, and test command results.

## Notes

- If gh hits auth/rate issues mid-run, prompt the user to re-authenticate with `gh auth login`, then retry.
- If only comment ID (`PRRC_*`) is known, use GraphQL query to get the parent thread ID first, then reply/resolve at thread level.
