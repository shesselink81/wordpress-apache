# Cloude Code ToolBox — MCP & Skills awareness

_Generated: 2026-08-01T18:36:05.724Z_

## How to use this report

- **Saved copy:** This file is **`.claude/cloude-code-toolbox-mcp-skills-awareness.md`** — refreshed whenever the toolbox runs an MCP & Skills scan (including on workspace open when auto-scan is enabled). It is meant for **Claude Code workspace context** together with `CLAUDE.md` (which gets a shorter replaceable summary when auto-merge is on).
- **MCP:** Lists **configured** servers from Claude Code config (`~/.claude.json` for user scope, `.mcp.json` for project scope). Use `/mcp` in the Claude Code panel to connect servers for your session.
- **Skills:** **On-disk** folders with `SKILL.md`. Claude Code does not auto-load them; attach `SKILL.md` or paths in chat when useful.
- **Task routing:** When the user’s request matches a server’s purpose (e.g. Confluence → Confluence/Atlassian MCP), prefer that **server id** from the tables below.

---

## MCP — workspace

Workspace `mcp.json` _(folder: wordpress-apache)_

- **d:\Users\Sander\repos\wordpress-apache\.mcp.json** — _File missing_

_No active workspace servers in mcp.json._

## MCP — user profile

- **C:\Users\shess\.claude.json** — _File exists — servers defined_

| Server id | Kind | Detail |
|-----------|------|--------|
| azure/aks-mcp | stdio | docker run -i --rm -v C:/Users/shess/.azure:/root/.azure ghcr.io/azure/aks-mcp:latest --transport stdio |
| context7 | http | https://mcp.context7.com/mcp |
| io.github.upstash/context7 | stdio | npx @upstash/context7-mcp@1.0.31 |
| MCP_DOCKER | stdio | docker mcp gateway run --profile ai_coding |

_User servers **off** (Toolbox stash):_

| Server id | Kind | Detail |
|-----------|------|--------|
| io.github.hashicorp/terraform-mcp-server | stdio | docker run -i --rm run --rm -i -e ${input:e} TFE_ADDRESS -e ${input:e} TFE_TOKEN -e ${input:e} ENABLE_TF_OPERATIONS hashicorp/terraform-mcp-server:0.3.3 -e TFE_ADDRESS -e TFE_TOKEN -e ENABLE_TF_OPERATIONS docker.io/hashicorp/terraform-mcp-server:0.3.3 |

## Skills (local `SKILL.md` folders)

### Project-scoped

_None found (or no workspace open)._

### User-scoped

_None found._

---

## Suggested next steps

- **MCP:** Use this extension’s hub **MCP** tab, or `claude mcp list` in the terminal. In Claude Code, use `/mcp` to connect servers for the session.
- **Edit config:** Open `~/.claude.json` (user MCP) or `<workspace>/.mcp.json` (project MCP) via the extension commands.
- **Refresh this report:** run **Intelligence — scan MCP & Skills awareness** again after changing MCP config or adding skills.

_Report from Cloude Code ToolBox extension._
