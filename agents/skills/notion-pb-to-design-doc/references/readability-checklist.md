# Readability Checklist

Use this checklist before finalizing a PB-derived design document.

## Mainline

- The reader can understand the change by reading only the mainline.
- The first screenful explains what changes.
- Final decisions are written as decisions, not as meeting notes.
- Superseded ideas are removed from the mainline.

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
- The destination page reads like a design doc, not like a transcript.
