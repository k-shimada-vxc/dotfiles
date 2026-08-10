# Readability Checklist

Use this checklist before finalizing a PB-derived design document.

## Mainline

- The reader can understand the change by reading only the mainline.
- The first screenful explains what changes.
- Final decisions are written as decisions, not as meeting notes.
- Superseded ideas are removed from the mainline.
- What the reviewer is being asked to decide is stated up front, and everything else is marked as already decided.
- The snapshot of the code being cited (date and branch) is noted at the top when the document cites paths, line numbers, or versions.

## Structure

- The document starts with background/problem, not only a list of decisions.
- Scope is explicit.
- Non-scope is explicit.
- Terms are defined before they are used heavily.
- Chapter numbers are continuous.
- Sections are grouped by topic, not by the order the discussion happened.
- Design rules are not repeated across many sections; one section is the source of truth and others link back to it.
- Examples exist when rules are numerical or easy to misread.
- Tables are used where scanning is more important than prose.
- Mermaid diagrams are used when ER, DAG, API flow, migration flow, cascade behavior, or state transitions would be clearer visually.
- Diagrams are small, labeled, and support the mainline instead of replacing important text.
- Important schema/API changes include data model, API contract, validation, indexes, deletion/cascade, permissions, migration, release, rollback, and tests as applicable.
- A summary of the main non-scope items appears near 対象範囲, not only in the last section.
- Changes that add a query path, view, index-dependent list screen, or batch operation state expected scale, which indexes apply, and which access patterns have none.
- Only 背景と課題 / 用語定義 / 代替案と採用理由 / appendices are collapsed. テスト観点 is expanded.
- Specifications appear as numbered lists, tables, or diagrams, conclusion first. Prose is reserved for rationale.
- Sibling blocks of the same kind share a shape. One is not a numbered list while the next is a paragraph.

## Evidence

- Every code reference (path, line number, function name, dependency version) was confirmed by opening the actual file, not from memory or from a similar file.
- Dependency versions were read from `go.mod` or the equivalent manifest, not from whatever version happens to sit in a local module cache.
- Any claim that something "does not exist" was made after searching for it, not from not having seen it.
- Numbers that were estimated rather than measured, and behavior that was reasoned about rather than run, are labeled as such.
- Physical names (tables, columns, files) are quoted exactly as they appear in the source, including pluralization.

## Rationale

- Important rejected alternatives are summarized when they explain why the chosen design is reasonable.
- Detailed reasons are moved into toggles.
- Historical discussion is moved into toggles.
- Nice-to-have ideas are not mixed into current scope.
- Contradictions between old notes and final decisions are resolved or isolated in a toggle.

## Reviewability

- Backend / Frontend responsibilities are separated when both matter.
- Impacted areas are listed.
- Test viewpoints are concrete and observable.
- Every test viewpoint traces back to a specification that is structured, not buried in a paragraph.
- The destination page reads like a design doc, not like a transcript.
