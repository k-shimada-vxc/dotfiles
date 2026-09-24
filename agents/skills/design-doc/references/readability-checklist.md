# Readability Checklist

Use this checklist before finalizing a design document derived from a decision log.

## Mainline

- The reader can understand the change by reading only the mainline.
- The first three lines state the adopted design and why it was adopted.
- Final decisions are written as decisions, not as meeting notes.
- Superseded ideas are removed from the mainline.
- What the reviewer is being asked to decide is stated up front, and everything else is marked as already decided.
- The snapshot of the code being cited (date and branch) is noted at the top when the document cites paths, line numbers, or versions.

## Structure

- Background appears only where the reader could not judge the design without it, and links out instead of restating another document.
- Scope is explicit.
- Non-scope is explicit, stated as fact, with no general commentary about what lies outside it.
- Only terms this document coins or overloads are defined, and they are defined before they are used heavily.
- Every heading carries its own decision. No section is a stub, and no content is repeated under a second heading.
- Chapter numbers are continuous, and no sub-number sits under a parent that does not exist.
- Sections are grouped by topic, not by the order the discussion happened.
- Design rules are not repeated across many sections; one section is the source of truth and others link back to it.
- The duplication sweep was run, not assumed: take each decision and each physical name the document introduces, count where it is *explained* rather than merely mentioned or linked, and for anything explained in three or more places, keep one and replace the rest with a link. Cross-cutting items - an operational prerequisite, a blocked API, a rule that spans phases - are where this piles up.
- Each revision-history row is one or two sentences. A longer row means the decision itself never made it into the mainline.
- Examples exist when rules are numerical or easy to misread.
- Tables are used where scanning is more important than prose.
- Mermaid diagrams are used when ER, DAG, API flow, migration flow, cascade behavior, or state transitions would be clearer visually.
- Diagrams are small, labeled, and support the mainline instead of replacing important text.
- Important schema/API changes include data model, API contract, validation, indexes, deletion/cascade, permissions, migration, release, rollback, and tests as applicable.
- A summary of the main non-scope items appears near 対象範囲, not only in the last section.
- Changes that add a query path, view, index-dependent list screen, or batch operation state expected scale, which indexes apply, and which access patterns have none.
- Only 背景と課題 / 用語定義 / 代替案と採用理由 / appendices are collapsed, using the destination medium's own syntax. テスト観点 is expanded.
- Specifications appear as numbered lists, tables, or diagrams, conclusion first. Prose is left only where it carries a constraint no table row can express.
- Sibling blocks of the same kind share a shape. One is not a numbered list while the next is a paragraph.

## Evidence

- Every code reference (path, line number, function name, dependency version) was confirmed by opening the actual file, not from memory or from a similar file.
- Dependency versions were read from `go.mod` or the equivalent manifest, not from whatever version happens to sit in a local module cache.
- Any claim that something "does not exist" was made after searching for it, not from not having seen it.
- Numbers that were estimated rather than measured, and behavior that was reasoned about rather than run, are labeled as such.
- Physical names (tables, columns, files) are quoted exactly as they appear in the source, including pluralization.

## Rationale

- Alternatives a reviewer would otherwise propose appear as rows of the two-column `案` / `却下理由` table, one line each.
- No paragraph weighs merits and demerits; that comparison lives in the table.
- No rejection reason is stranded outside that table. A paragraph elsewhere that says "X も成立するが採らない" is moved into it as a row - 移行, リリース順 and 運用境界 are where these hide.
- An undecided point is one line in the mainline - what is undecided, what the document assumes meanwhile - with the argument in a collapsible block below it.
- Detailed reasons are moved into collapsible blocks.
- Historical discussion is moved into collapsible blocks.
- Nice-to-have ideas are not mixed into current scope.
- Contradictions between old notes and final decisions are resolved or isolated in a collapsible block.

## Reviewability

- Backend / Frontend responsibilities are separated when both matter.
- Impacted areas are listed.
- Test viewpoints are concrete and observable.
- Every block survived the question "without this, can the reader still understand the decision?" - nothing that fails it is left in.
- Every test viewpoint traces back to a specification that is structured, not buried in a paragraph.
- The destination document reads like a design doc, not like a transcript.
