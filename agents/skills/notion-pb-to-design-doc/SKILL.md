---
name: notion-pb-to-design-doc
description: Turn a Notion product backlog page into a readable design document page in the team's ticket style. Use when Codex needs to read PB or requirements discussion pages in Notion, extract the final decisions, align the tone and headings to an existing design ticket, and write or rewrite the destination Notion page with summaries, tables, examples, scope, and test viewpoints.
---

# Notion PB To Design Doc

Convert a Notion PB page into a design document that is easy to review.
Treat the PB as a decision log, not as the final document structure.

## Quick Start

1. Fetch the source PB page.
2. Fetch the destination design page.
3. If the user gave a reference ticket, fetch that too and mirror its tone and section order.
4. Extract only the final decisions first. Later meeting notes override earlier notes.
5. Identify unresolved design decisions before writing. If core schema/API/validation choices are still open, discuss them with the user first and do not update Notion yet.
6. Use `references/section-template.md` for structure and visual aids, then write the destination page.
7. Re-fetch the destination page and run `references/readability-checklist.md` before finishing.

## Instruction Ownership

- `SKILL.md`: workflow, decision gates, and safe Notion update rules.
- `references/section-template.md`: section order, expected content by section, tables, Mermaid guidance, and reusable patterns.
- `references/readability-checklist.md`: final review checklist only.

## Workflow

### 0. If Notion MCP is not connected

1. Add the Notion MCP:
   - `codex mcp add notion --url https://mcp.notion.com/mcp`
2. Enable remote MCP client:
   - Set `[features].rmcp_client = true` in `config.toml` or run `codex --enable rmcp_client`
3. Log in with OAuth:
   - `codex mcp login notion`

If setup is required, stop there and tell the user to retry after restarting Codex.

### 1. Read the three inputs

- Source PB page: the raw requirements and meeting history.
- Destination page: the page to overwrite or update as the final design doc.
- Reference design ticket: optional, but preferred when the team already has a writing style.

When reading the PB:

- Prioritize the latest meeting notes over earlier drafts.
- Distinguish clearly between:
  - final decisions
  - open questions
  - rejected or outdated options
  - background examples
- Treat "probably", "TBD", conflicting comments, unresolved review comments, and user wording like "未定" or "相談" as open decisions until confirmed.

If a statement was superseded later, do not keep it in the mainline.

Before updating Notion, report the core decisions and open questions in chat when:

- the destination page is mostly blank and the agent is constructing the design from multiple source pages
- the design changes schema, public API, validation rules, deletion/cascade behavior, permissions, or migration strategy
- the source pages disagree, or the FE design implies BE API behavior that is not explicitly decided

Only write the destination page after the user confirms the disputed decisions or explicitly asks for a draft despite the open questions.

### 2. Structure and write the draft

Read `references/section-template.md` before drafting. Follow its section order unless the reference ticket strongly suggests another shape.

### 3. Separate mainline and rationale

The mainline should contain only:

- scope
- current decision
- rule
- interface contract
- impact
- tests
- non-scope

Move these into toggles unless they are essential to understand the decision:

- why option A beat option B
- historical discussion flow
- outdated assumptions
- "nice to have" items that are not included now
- discrepancy notes between old callouts and later meeting outcomes

Use labels such as:

- `背景の詳細`
- `判断理由`
- `補足`

### 4. Update the destination page safely

- Preserve the page title and properties unless the user asked to change them.
- If the destination is clearly a dedicated design page, replacing the full body is usually cleaner than incremental edits.
- Re-fetch the destination page before replacing content so you understand whether there are child pages or blocks that must be preserved.
- If child pages or databases exist, do not delete them silently.
- When the page is empty or nearly empty, still avoid treating the first draft as final if important decisions are unresolved. Share a concise draft outline first, then update after confirmation.

### 5. Final review

Read `references/readability-checklist.md` and use it as the source of truth for final review. Fix the page before finishing when the checklist exposes structure, readability, or reviewability issues.

## Writing Rules

- Write in concise Japanese.
- Match the section order and tone of the reference ticket when one is provided.
- Use decisive statements rather than meeting-note phrasing.
- Prefer `X とする` / `Y は削除する` / `Z を追加する`.
- Keep the document review-oriented, not transcript-oriented.

## References

- `references/section-template.md`
- `references/readability-checklist.md`
