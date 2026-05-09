# Claude Code — project context






<!-- cloude-code-toolbox:mcp-skills-awareness-begin -->

### MCP & Skills awareness (Cloude Code ToolBox)

_Last synced: 2026-05-09T16:04:19.857Z._

- **Full report:** `.claude/cloude-code-toolbox-mcp-skills-awareness.md` in this workspace (auto-overwritten on each scan). Use it as ground truth for configured servers and skill folders.
- **MCP:** For **live tools** in Claude Code, enable the matching server via `/mcp`. Servers are configured in `~/.claude.json` (user) and `.mcp.json` (project).
- **When the user’s task matches a server** (e.g. Confluence work and a **Confluence** / **Atlassian** MCP is listed), **prefer that server id** and plan on tool use—not only file search.
- **Skills:** Folders below contain `SKILL.md`; attach or cite paths in chat when relevant.

#### Workspace MCP

- `d:\Users\Sander\repos\wordpress-apache\.mcp.json` _(workspace: wordpress-apache)_ — _file missing_

_No active workspace servers in mcp.json._

#### User MCP

- `C:\Users\shess\.claude.json` — _servers defined_

| Server id | Kind | Detail |
|-----------|------|--------|
| MCP_DOCKER | stdio | docker mcp gateway run --profile profile |
| context7 | http | https://mcp.context7.com/mcp |
| io.github.hashicorp/terraform-mcp-server | stdio | docker run -i --rm run --rm -i -e ${input:e} TFE_ADDRESS -e ${input:e} TFE_TOKEN -e ${input:e} ENABLE_TF_OPERATIONS hashicorp/terraform-mcp-server:0.3.3 -e TFE_ADDRESS -e TFE_TOKEN -e ENABLE_TF_OPERATIONS docker.io/hashicorp/terraform-mcp-server:0.3.3 |
| azure/aks-mcp | stdio | docker run -i --rm ghcr.io/azure/aks-mcp:latest --transport stdio |
| io.github.upstash/context7 | stdio | npx @upstash/context7-mcp@1.0.31 |

#### Project skills

_None found (or no workspace open)._

#### User skills

- **context7-mcp** — `C:\Users\shess\.claude\skills\context7-mcp` — This skill should be used when the user asks about libraries, frameworks, API references, or needs code examples. Activates for setup questions, code generation involving libraries, or mentions of specific frameworks lik

<!-- cloude-code-toolbox:mcp-skills-awareness-end -->
