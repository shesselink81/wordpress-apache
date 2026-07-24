# Claude Code — project context


























<!-- cloude-code-toolbox:mcp-skills-awareness-begin -->

### MCP & Skills awareness (Cloude Code ToolBox)

_Last synced: 2026-07-24T20:31:41.116Z._

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
| azure/aks-mcp | stdio | docker run -i --rm -v C:/Users/shess/.azure:/root/.azure ghcr.io/azure/aks-mcp:latest --transport stdio |
| context7 | http | https://mcp.context7.com/mcp |
| io.github.upstash/context7 | stdio | npx @upstash/context7-mcp@1.0.31 |
| MCP_DOCKER | stdio | docker mcp gateway run --profile ai_coding |

_Off (Toolbox stash):_ 

- **io.github.hashicorp/terraform-mcp-server** (stdio)

#### Project skills

_None found (or no workspace open)._

#### User skills

_None found._

<!-- cloude-code-toolbox:mcp-skills-awareness-end -->
