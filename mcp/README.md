# MCP Configuration Templates

This folder contains the **source of truth** for MCP server configurations used by each ConnectHealth application.

## How It Works

Each app (fit-api, fit-mobile) has its own `.claude/mcp.json` that defines filesystem MCP servers. These configs are derived from the templates here.

## Available Configs

| Template | Target App | Copy To |
|----------|-----------|---------|
| `fit-api.mcp.json` | fit-api | `fit-api/.claude/mcp.json` |
| `fit-mobile.mcp.json` | fit-mobile | `fit-mobile/.claude/mcp.json` |

## MCP Servers Per App

Each app gets 4 MCP servers, one per folder type:

| Server Suffix | Exposes | Source Path |
|---------------|---------|-------------|
| `*-docs` | Shared documentation | `fit-common/docs/` |
| `*-skills` | App-specific skills | `{app}/.claude/skills/` |
| `*-scripts` | Automation scripts | `fit-common/scripts/` |
| `*-hooks` | Git hook templates | `fit-common/templates/hooks/` |

## When to Update

Update these templates when:
- A new doc is added/removed in `fit-common/docs/`
- A new script is added/removed in `fit-common/scripts/`
- A new hook is added/removed in `fit-common/templates/hooks/`
- A new folder category needs its own MCP server

After updating a template, copy the changes to the target app's `.claude/mcp.json`.

## Setup

To set up MCP for an app, copy the appropriate template:

```bash
# For fit-api
cp fit-common/mcp/fit-api.mcp.json fit-api/.claude/mcp.json

# For fit-mobile
cp fit-common/mcp/fit-mobile.mcp.json fit-mobile/.claude/mcp.json
```

All paths use relative references (`../fit-common/`) and assume repos are cloned as siblings under the same parent directory.
