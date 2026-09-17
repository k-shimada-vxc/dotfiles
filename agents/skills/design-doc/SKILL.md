---
name: design-doc
description: Turn a decision log into a readable design document in the team's ticket style. Use when the agent needs to read requirements or discussion history - a Notion PB page, local requirement notes and meeting memos, or decisions made in this conversation - extract the final decisions, align the tone and headings to an existing design ticket, and write or rewrite the destination document with summaries, tables, examples, scope, and test viewpoints.
---

# Design Doc

Convert a decision log into a design document that is easy to review.
Treat the source as a decision log, not as the final document structure.

The section order, the mainline/rationale split, and the review checklist are the same for every medium.
Only how the destination is read and written differs.

## Quick Start

1. Identify the three inputs and the destination medium (§1).
2. Read `references/output-targets.md` for the destination medium in use.
3. Fetch the source, the destination, and the reference design ticket when one was given.
4. Extract only the final decisions first. Later notes override earlier notes.
5. Identify unresolved design decisions before writing. If core schema/API/validation choices are still open, discuss them with the user first and do not write the destination yet.
6. Use `references/section-template.md` for structure and visual aids, then write the destination.
7. Re-read the destination and run `references/readability-checklist.md` before finishing.

## Instruction Ownership

- `SKILL.md`: workflow, decision gates, and the mainline/rationale split.
- `references/output-targets.md`: how to read and write each destination medium, including collapsible-block syntax and safe replacement rules.
- `references/section-template.md`: section order, expected content by section, tables, Mermaid guidance, and reusable patterns.
- `references/readability-checklist.md`: final review checklist only.

## Workflow

### 1. Identify the inputs and the destination medium

Three inputs:

- **Source decision log** - the raw requirements and discussion history. Any of:
  - a page in a documentation tool, such as a Notion PB or requirements page
  - local Markdown or text files: requirement memos, meeting notes, an older design doc
  - this conversation itself, when the decisions were made here
  - several of the above combined
- **Destination** - the document to write or rewrite as the final design doc.
- **Reference design ticket** - optional, but preferred when the team already has a writing style.

Decide the destination medium before drafting, because it fixes the collapsible-block and diagram syntax.
If the user did not say where the document goes, ask. Do not silently pick one.
Reasonable defaults to propose: the same tool as the source when the source is a page; a file in the repository when the source is local files or this conversation.

### 2. Read the sources

- Prioritize the latest notes over earlier drafts.
- Distinguish clearly between:
  - final decisions
  - open questions
  - rejected or outdated options
  - background examples
- Treat "probably", "TBD", conflicting comments, unresolved review comments, and user wording like `未定` or `相談` as open decisions until confirmed.

If a statement was superseded later, do not keep it in the mainline.

Report the core decisions and open questions in chat before writing the destination when:

- the destination is empty or mostly blank and the agent is constructing the design from multiple sources
- the design changes schema, public API, validation rules, deletion/cascade behavior, permissions, or migration strategy
- the sources disagree, or the FE design implies BE API behavior that is not explicitly decided

Only write the destination after the user confirms the disputed decisions or explicitly asks for a draft despite the open questions.

### 3. Structure and write the draft

Read `references/section-template.md` before drafting. Follow its section order unless the reference ticket strongly suggests another shape.

### 4. Separate mainline and rationale

The mainline should contain only:

- scope
- current decision
- rule
- interface contract
- impact
- tests
- non-scope

Move these into collapsible blocks unless they are essential to understand the decision:

- why option A beat option B
- historical discussion flow
- outdated assumptions
- "nice to have" items that are not included now
- discrepancy notes between old callouts and later meeting outcomes

Use labels such as:

- `背景の詳細`
- `判断理由`
- `補足`

This decides *what* is collapsed. *How* a collapsible block is written is medium-specific; see `references/output-targets.md`.

### 5. Write the destination safely

Read the destination-medium section of `references/output-targets.md` and follow it. Regardless of medium:

- Preserve the existing title and metadata unless the user asked to change them.
- Re-read the destination before replacing content, so you know what would be lost.
- When the destination is a dedicated design document, replacing the full body is usually cleaner than incremental edits.
- Never delete nested content - child pages, databases, attachments, sibling sections - silently.
- When the destination is empty or nearly empty, still avoid treating the first draft as final if important decisions are unresolved. Share a concise draft outline first, then write after confirmation.

### 6. Final review

Read `references/readability-checklist.md` and use it as the source of truth for final review. Fix the document before finishing when the checklist exposes structure, readability, or reviewability issues.

## Writing Rules

- Write in concise Japanese.
- Match the section order and tone of the reference ticket when one is provided.
- Use decisive statements rather than meeting-note phrasing.
- Prefer `X とする` / `Y は削除する` / `Z を追加する`.
- Keep the document review-oriented, not transcript-oriented.

## References

- `references/output-targets.md`
- `references/section-template.md`
- `references/readability-checklist.md`
