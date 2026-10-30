# Notion output

- Use the Notion MCP tools to create a new page and return the URL of the new page.
- Use Notion callout blocks for key concepts or definitions, important edge cases, etc.
- Represent the quiz with toggle blocks: each option is a toggle, and its body says whether
  it is correct and why. For example:
  ```markdown
  1. Question
     ▶ Option 1
      ❌ Explanation for why it was incorrect
     ▶ Option 2
      ❌ Explanation for why it was incorrect
     ▶ Option 3
      ✅ Explanation for why it was correct
     ▶ Option 4
       ❌ Explanation for why it was incorrect
  2. Question
     ...
  ```
