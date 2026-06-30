# Section Template

Use this as the default structure for PB-derived design tickets.

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

Add `# 0. このPBで何が変わるか` only when a short summary materially improves readability.

For small tickets, merge nearby sections rather than keeping empty headings. For schema/API changes, keep this order so readers see the problem and terms before field-level details.

## Recommended Content

### 1. 背景と課題

- Current model or workflow
- What problem exists now
- Why the change is needed
- What the first release is expected to achieve
- If the first release only prepares a foundation, say that clearly

### 2. 対象範囲

- What this ticket covers
- What kinds of changes are included
- Short note pointing to non-scope instead of listing every exclusion here

### 3. 用語定義

- Define new tables, flags, APIs, states, and domain terms before using them heavily.
- Include transitional states when they matter, such as orphaned or partially registered data.
- Keep this section short; field-level details belong in 詳細設計.

### 4. 基本方針

- Flat bullet list of final policies
- No long history
- Reference later sections for detailed rules instead of repeating the same rule.

### 5. 代替案と採用理由

- Summarize important alternatives and why they were rejected.
- Include tradeoffs that reviewers are likely to ask about.
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
- Put rationale in toggles

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

### Toggle labels

- `背景の詳細`
- `判断理由`
- `補足`

### Mermaid diagram patterns

Use Mermaid only when the diagram clarifies a relationship, dependency, or workflow better than prose or a table. Keep diagrams small enough to review in Notion.

Good candidates:

- Entity relationships for new/changed tables
- DAG or ordering dependencies
- API sequence or transaction boundaries
- Migration/release flow
- Deletion/cascade decision flow
- State transitions such as temporary, invalid, or orphan states
