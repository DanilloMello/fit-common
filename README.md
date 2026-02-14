# ConnectHealth Documentation

## Structure

```
fit-common/
├── docs/                 # Shared across all apps
│   ├── DOMAIN_SPEC.md        # Entities, enums, business rules
│   ├── API_REGISTRY.md       # All API endpoints (updated by providers)
│   ├── CODING_GUIDELINES.md  # Code standards and best practices
│   ├── VALIDATION_SETUP.md   # Pre-push & PR validation guide
│   ├── PRD.md                # Requirements
│   └── SPRINT_PLAN.md        # Roadmap
│
├── skills/                # AI Agent Skills
│   └── project-orchestrator-doc/  # Entry point - routes to app skills
│
├── scripts/
│   └── install-hooks.sh       # Install pre-push hook for sibling repos
│
├── templates/hooks/
│   └── pre-push.sh            # Code quality validation hook
│
└── mcp/                   # MCP Configuration Templates
    ├── fit-api.mcp.json       # MCP config for fit-api
    ├── fit-mobile.mcp.json    # MCP config for fit-mobile
    └── README.md              # MCP setup guide
```

## How It Works

### For AI Agents (via MCP)

Each app (fit-api, fit-mobile) has its own MCP servers configured in `.claude/mcp.json`, with one server per folder type:

| MCP Server | Exposes |
|------------|---------|
| `{app}-docs` | `fit-common/docs/` — shared documentation |
| `{app}-skills` | `{app}/.claude/skills/` — app-specific patterns |
| `{app}-scripts` | `fit-common/scripts/` — automation scripts |
| `{app}-hooks` | `fit-common/templates/hooks/` — git hook templates |

MCP config templates live in `fit-common/mcp/` and are copied to each app's `.claude/mcp.json`.

### API Integration

1. **fit-api** implements endpoints
2. **fit-api** updates `docs/API_REGISTRY.md`
3. **fit-mobile** reads `API_REGISTRY.md` via MCP to consume

### Code Quality

**Pre-push hook** validates code quality before every `git push`:
- **fit-api**: Tests, build, format, guidelines, API Registry sync
- **fit-mobile**: TypeScript, ESLint, tests, build, guidelines

**PR validation** runs on GitHub Actions for CI/CD checks.

See [VALIDATION_SETUP.md](./docs/VALIDATION_SETUP.md) for details.

## Quick Start

### Clone all repos as siblings

```bash
git clone https://github.com/DanilloMello/fit-api.git
git clone https://github.com/DanilloMello/fit-mobile.git
git clone https://github.com/DanilloMello/fit-common.git
```

Expected layout:

```
projetos/
├── fit-api/
├── fit-mobile/
└── fit-common/
```

### Install pre-push hook

```bash
cd fit-common
./scripts/install-hooks.sh
```

### Setup MCP (already done in each app)

Each app has a `.claude/mcp.json` that references fit-common via relative paths. No manual setup needed — Claude Code picks it up automatically.

To update MCP configs after fit-common changes:
```bash
cp fit-common/mcp/fit-api.mcp.json fit-api/.claude/mcp.json
cp fit-common/mcp/fit-mobile.mcp.json fit-mobile/.claude/mcp.json
```

### Working with documentation

Edit docs directly in fit-common, commit, and push:

```bash
cd fit-common
vim docs/API_REGISTRY.md
git add docs/API_REGISTRY.md
git commit -m "docs: update API registry"
git push
```

MCP servers in each app read directly from fit-common — no sync step needed.
