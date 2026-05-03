# Cloude Code ToolBox — MCP & Skills awareness

_Generated: 2026-05-03T04:52:13.523Z_

## How to use this report

- **Saved copy:** This file is **`.claude/cloude-code-toolbox-mcp-skills-awareness.md`** — refreshed whenever the toolbox runs an MCP & Skills scan (including on workspace open when auto-scan is enabled). It is meant for **Claude Code workspace context** together with `CLAUDE.md` (which gets a shorter replaceable summary when auto-merge is on).
- **MCP:** Lists **configured** servers from VS Code `mcp.json`. **Claude Code** uses `~/.claude/settings.json` and `/mcp` in the panel for its own MCP list — align or port configs as needed.
- **Skills:** **On-disk** folders with `SKILL.md`. Claude Code does not auto-load them; attach `SKILL.md` or paths in chat when useful.
- **Task routing:** When the user’s request matches a server’s purpose (e.g. Confluence → Confluence/Atlassian MCP), prefer that **server id** from the tables below.

---

## MCP — workspace

Workspace `mcp.json` _(folder: wordpress-apache)_

- **d:\Users\Sander\repos\wordpress-apache\.vscode\mcp.json** — _File missing_

_No active workspace servers in mcp.json._

## MCP — user profile

- **C:\Users\shess\AppData\Roaming\Code\User\mcp.json** — _File exists — servers defined_

| Server id | Kind | Detail |
|-----------|------|--------|
| io.github.hashicorp/terraform-mcp-server | stdio | docker run -i --rm run --rm -i -e ${input:e} TFE_ADDRESS -e ${input:e} TFE_TOKEN -e ${input:e} ENABLE_TF_OPERATIONS hashicorp/terraform-mcp-server:0.3.3 -e TFE_ADDRESS -e TFE_TOKEN -e ENABLE_TF_OPERATIONS docker.io/hashicorp/terraform-mcp-server:0.3.3 |
| azure/aks-mcp | stdio | docker run -i --rm ghcr.io/azure/aks-mcp:latest --transport stdio |
| io.github.upstash/context7 | stdio | npx @upstash/context7-mcp@1.0.31 |

## Skills (local `SKILL.md` folders)

### Project-scoped

_None found (or no workspace open)._

### User-scoped

- **context7-mcp** — `C:\Users\shess\.claude\skills\context7-mcp`
  - This skill should be used when the user asks about libraries, frameworks, API references, or needs code examples. Activates for setup questions, code generation involving libraries, or mentions of specific frameworks lik

---

## Suggested next steps

- **MCP:** Command Palette → `MCP: List Servers` (or this extension’s hub **MCP** tab). In Claude Code, use `/mcp` to connect servers for the Claude session.
- **Edit config:** `MCP: Open Workspace Folder MCP Configuration` / `MCP: Open User Configuration`.
- **Refresh this report:** run **Intelligence — scan MCP & Skills awareness** again after changing `mcp.json` or adding skills.

_Report from Cloude Code ToolBox extension._
