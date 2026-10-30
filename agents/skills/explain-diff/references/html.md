# HTML output

- **Use `render.py` from the skill directory instead of hand-writing HTML.**
  Repeated invocations tend to regenerate near-identical CSS/JS boilerplate every time,
  which wastes tokens and drifts in quality — it is factored out once. Write a small
  JSON content spec (title, subtitle, slug, sections with raw HTML bodies, quiz questions
  with correct/incorrect options) and run:
  ```
  python3 <skill-directory>/render.py <spec.json>
  ```
  This handles all CSS, JavaScript, page scaffolding, table of contents, quiz-option
  randomization, and the date-prefixed filename automatically — only write the
  content spec, not the full HTML page. Run
  `python3 <skill-directory>/render.py --help` for the exact JSON schema if you haven't
  used it recently. Do not copy the renderer elsewhere.
- Section `html` fields in the spec are raw HTML you write directly — use `<pre>` for
  code blocks (already `white-space: pre-wrap` styled by the renderer), `.diagram`/
  `.flow`/`.box`/`.box.fail` divs for flow diagrams, `.callout` for key definitions/
  edge cases, and plain `<table>` for comparison tables. The exact class names available
  are defined in the `CSS` constant in `render.py`.
- The quiz is interactive: when the reader clicks an option, the page tells them whether
  they were correct. The renderer builds this from the spec's `quiz` field and shows the
  same short feedback for every option, so put the reasoning into the sections, not the options.
- Don't use ASCII diagrams — use the renderer's HTML diagram classes instead.
- The renderer prints the output path. Give that path to the user.
