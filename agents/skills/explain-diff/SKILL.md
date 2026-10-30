---
name: explain-diff
description: Use when the user asks for a rich explanation of a code change, diff, branch, or PR. Produces a self-contained HTML page by default, or a Notion page when the user asks for Notion.
---

# Explain Diff

Please make me a rich, interactive explanation of the specified code change.

It should have these sections:

- Background: Explain the existing system relevant to this change. (You should broadly explore surrounding code for this.) We don't know how much the reader already knows, so include a deep background for beginners (note that it can be skipped if the reader is already familiar), and then a more narrow background directly relevant to the change.
- Intuition: Explain the core intuition for the code change. The focus here is to explain the essence, not the full details. Use concrete examples with toy data. Use figures and diagrams liberally.
- Code: Do a high-level walkthrough of the changes to the code. Group/order the changes in an understandable way.
- Quiz: Come up with five questions that test the reader's knowledge of this PR. This should be medium difficulty, difficult enough that you actually need to understand the substance of the PR to answer them, but not gotchas. The goal is to help the reader make sure that they've actually understood. Each question is multiple choice, and the reader can check their answer; how feedback is shown depends on the output format.

Writing:

- Please write with the clarity and flow of Martin Kleppmann, making it engaging and
  written in classic style. Transitions between sections should be smooth.
- Some tips on diagrams. Ideally, pick a small number of diagram families that can be
  reused throughout the explanation to explain various cases. Make sure to include example data. Some useful kinds:
  - A very simplified version of the UI the user sees in the app, to explain UI changes.
  - A system diagram showing data flow or communication between components, with
    example data included.
- Use callouts for key concepts or definitions, important edge cases, etc.

Output:

- Produce an HTML page unless the user asks for Notion. HTML stays on the local machine,
  while a Notion page is sent to an external workspace, so only publish there on request.
- Before writing, read the reference for the chosen output. It covers how to build the
  page, how to render diagrams and the quiz, and what to return to the user.
  - HTML: `references/html.md`
  - Notion: `references/notion.md`
- Resolve `references/` and `render.py` from the directory containing this `SKILL.md`.
