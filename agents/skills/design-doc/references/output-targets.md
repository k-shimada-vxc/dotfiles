# Output Targets

How to read and write the destination for each medium. Read only the section for the medium in use.

SKILL.md §4 decides *what* goes into a collapsible block. This file decides *how* it is written.

| medium | collapsible block | diagram | table |
| --- | --- | --- | --- |
| Notion page | toggle block | Mermaid code block | Notion table or Markdown table |
| Markdown file | `<details><summary>ラベル</summary>` | ` ```mermaid ` fence | Markdown table |
| chat reply | not available - use a `判断理由:` labeled paragraph instead | ` ```mermaid ` fence | Markdown table |

## Notion page

### If the Notion MCP is not connected

- Claude Code: `claude mcp add --transport http notion https://mcp.notion.com/mcp`, then log in with OAuth from `/mcp`.
- Codex: `codex mcp add notion --url https://mcp.notion.com/mcp`, set `[features].rmcp_client = true` in `config.toml` (or run `codex --enable rmcp_client`), then `codex mcp login notion`.

If setup is required, stop there and tell the user to retry after restarting the agent.

### Writing the page

- Preserve the page title and properties unless the user asked to change them.
- Re-fetch the page before replacing content so you know whether child pages, databases, or comments exist.
- If child pages or databases exist, do not delete them silently. Name them and ask.
- Replacing the whole body is usually cleaner than incremental block edits on a dedicated design page.
- Keep Mermaid diagrams small enough to review inside a Notion code block without scrolling.

## Markdown file

- Confirm the destination path with the user before the first write. Do not invent a location.
- If the file exists, read it first and preserve front matter and any sections outside the design doc.
- Use `<details><summary>ラベル</summary>` with a blank line before the body, otherwise the Markdown inside will not render.
- The section template numbers top-level sections as `# 1. ...`. When the file needs its own title, make the title `#` and shift the numbered sections to `##`; keep the numbering itself intact.
- Write Mermaid in ` ```mermaid ` fences.
- If the file is under Git, show the diff after writing. Do not commit unless the user asks.

## Chat reply

Use this only for a draft outline or a design small enough not to need a document.

- Collapsible blocks do not exist. Keep rationale in the mainline as a short `判断理由:` labeled paragraph, and cut anything that would have been collapsed as `補足`.
- Keep the section order from the section template, but merge sections aggressively so the whole reply stays scannable.
- Say explicitly that this is a draft and ask where the final document should live.
