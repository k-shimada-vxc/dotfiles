# Section Template

Use this as the default structure for design documents derived from a decision log.

## Standard Order

1. `# 1. 背景と課題`
2. `# 2. 対象範囲`
3. `# 3. 用語定義`
4. `# 4. 基本方針`
5. `# 5. 代替案と採用理由`
6. `# 6. 詳細設計`
7. `# 7. API / 権限 / 運用境界`
8. `# 8. 移行・リリース・ロールバック`
9. `# 9. 影響範囲`
10. `# 10. テスト観点`
11. `# 11. 非スコープ・残論点`

Open the document with the conclusion - the adopted design and why - in three lines or fewer, as a lead paragraph above `# 1.` with no heading of its own. A `# 0.` summary section is redundant once that lead exists; add one only when the change is large enough that three lines cannot carry it.

Add `# 0.1 このレビューで判断してほしいこと` whenever decisions still need someone else's call. Put it directly after the lead so reviewers see it before the details.

This order is a menu, not a quota. Write a section only when it carries content that changes how the reader judges the design. Omit the rest outright - do not leave a stub heading - and renumber so the chapter numbers stay continuous. For schema/API changes, keep the surviving sections in this relative order so readers meet the problem and the terms before field-level details.

## Collapse Policy

Which sections may be collapsed is a separate decision from what goes inside a collapsible block (see SKILL.md §4).
How a collapsible block is written depends on the destination medium; see `output-targets.md`.

- May be collapsed: `1. 背景と課題`, `3. 用語定義`, `5. 代替案と採用理由`, appendices.
- Keep expanded: everything else. `10. テスト観点` in particular, even though older tickets collapse it.

## Prose vs Structure

Default to structure. Prose survives only where it carries a constraint the reader cannot reconstruct from the design itself, and even then in the fewest sentences that make it understandable.

- **Specification** — something an implementer turns into a checklist, or a reviewer marks pass/fail line by line → numbered list or table, conclusion first.
- **Rationale** — why this option, what was rejected, what constraint forced it → a row in the `5. 代替案と採用理由` table. Keep it as prose only when a table row cannot express the constraint, and place it after the conclusion.

Comparing options in prose is not thoroughness. A paragraph weighing merits and demerits belongs in the table as a one-line rejection reason.

Signs a paragraph needs splitting:

- It carries more than two independently verifiable statements.
- A sibling block at the same level is already a list. If 登録 is numbered and 更新 is a paragraph, they are the same kind of thing and should look alike.

To find buried specifications, cross-check `10. テスト観点` against the rest of the document. For each viewpoint, find the specification it came from; if that lives in a paragraph rather than a list, table, or diagram, structure it. Specifications leak into 運用境界 and 移行 as well as 詳細設計.

## Code References

When the document cites file paths, line numbers, function names, or dependency versions, put a one-line note at the very top:

> 本書のコード参照は YYYY-MM-DD 時点の `<branch>` のもの。実装着手時にズレている可能性がある。

## Recommended Content

### 0.1 このレビューで判断してほしいこと

- List only the items that cannot be settled by the document alone.
- State explicitly that everything else is already decided.
- Table columns: 判断事項 / 本書の想定 / 詳細セクション.

### 1. 背景と課題

Write this section only when the reader cannot judge the design without it. Skip it when the background is self-evident or already written somewhere else; link to that page instead of restating it.

- What problem exists now
- Why the change is needed
- What the first release is expected to achieve
- If the first release only prepares a foundation, say that clearly
- The current model or workflow, only to the extent the problem needs it

### 2. 対象範囲

- What this ticket covers
- What kinds of changes are included
- End with a one or two line summary of the main non-scope items, then point to `11. 非スコープ・残論点` for the full list

### 3. 用語定義

Define only the terms this document coins or overloads. A term the team already uses, or one defined in a document you can link, does not belong here. If nothing is left, drop the section.

- Define new tables, flags, APIs, states, and domain terms before using them heavily.
- Include transitional states when they matter, such as orphaned or partially registered data.
- Keep this section short; field-level details belong in 詳細設計.

### 4. 基本方針

- Flat bullet list of final policies
- No long history
- Reference later sections for detailed rules instead of repeating the same rule.

### 5. 代替案と採用理由

A two-column table: `案` / `却下理由`. Nothing else.

- One row per alternative that a reviewer would otherwise propose. Alternatives nobody would raise are noise.
- One line per rejection reason, in the minimum wording that makes it understandable. No merit-and-demerit prose.
- The adopted option is already stated in the lead; this table only says why the others are not it.
- Keep rejected options out of the main decision path after this section.

### 6. 詳細設計

- Data model and field definitions
- Validation rules and error timing
- Indexes and constraints
- Deletion/cascade behavior
- Processing flow
- Mermaid diagrams when relationships or flows are easier to review visually:
  - ER-style diagram for table relationships
  - flowchart for processing, migration, or deletion/cascade flow
  - state diagram for lifecycle or transitional states
  - graph for DAG/order dependencies
- Apply the split described in `Prose vs Structure`
- Put rationale in collapsible blocks
- Close with a 性能・規模 subsection when the change adds a query path, a view, an index-dependent list screen, or a batch operation:
  - Expected row counts and how the number was derived
  - Which indexes the new query path uses, and which access patterns have none
  - How it will be verified, and whether that verification has happened yet

### 7. API / 権限 / 運用境界

- Public or internal API contracts
- Generic CRUD versus dedicated API responsibilities
- User roles, admin-only operations, and external integration responsibilities
- How invalid or transitional states are detected operationally

### 8. 移行・リリース・ロールバック

- Existing data migration
- Temporary nullable fields or phased rollout steps
- Release order
- Rollback or recovery plan
- What cleanup is manual versus automated

### 9. 影響範囲

- Modules, screens, APIs, models, jobs, tables

### 10. テスト観点

- Unit
- Integration
- Use concrete observable behavior
- Include migration, validation, permission, deletion, and rollback viewpoints when relevant

### 11. 非スコープ・残論点

- Explicitly state what is not included now
- Include nice-to-have items only if they were discussed and intentionally excluded
- Separate "not doing" from "not decided yet".

## Useful Patterns

### Field change table

Recommended columns:

- table or area
- new field name / old field name
- physical name
- type
- formula or behavior

### Warning rule table

Recommended columns:

- target
- condition
- timing
- handling

### Collapsible block labels

- `背景の詳細`
- `判断理由`
- `補足`

### Revision history appendix

Add a collapsed `付録. 改訂履歴` section once the document has been reviewed and revised at least once, so reviewers who read an earlier version can see what moved.

Recommended columns:

- date
- what changed, in one or two sentences

### Mermaid diagram patterns

Use Mermaid only when the diagram clarifies a relationship, dependency, or workflow better than prose or a table. Keep diagrams small enough to review in the destination without scrolling.

Good candidates:

- Entity relationships for new/changed tables
- DAG or ordering dependencies
- API sequence or transaction boundaries
- Migration/release flow
- Deletion/cascade decision flow
- State transitions such as temporary, invalid, or orphan states
