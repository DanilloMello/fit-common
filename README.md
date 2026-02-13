# ConnectHealth Documentation

## Structure

```
fit-docs/
├── docs/                 # Shared across all apps
│   ├── DOMAIN_SPEC.md        # Entities, enums, business rules
│   ├── API_REGISTRY.md       # All API endpoints (updated by providers)
│   ├── CODING_GUIDELINES.md  # Code standards and best practices
│   ├── VALIDATION_SETUP.md   # Pre-push & PR validation guide
│   ├── PRD.md                # Requirements
│   └── SPRINT_PLAN.md        # Roadmap
│
├── fit-api/            # Backend-specific
│   ├── ARCHITECTURE.md    # Java/Spring patterns
│   └── DATABASE.md        # PostgreSQL schema
│
├── fit-mobile/            # Frontend-specific
│   ├── ARCHITECTURE.md    # NX/React Native patterns
│   └── SCREENS.md         # Screen specifications
│
├── skills/                # AI Agent Skills
│   ├── orchestrator/      # Entry point - routes to app skills
│   ├── fit-api/        # Backend specialist
│   └── fit-mobile/        # Frontend specialist
│
├── scripts/
│   └── (removed - now using symlinks)
│
└── mcp/                   # MCP Server for AI tools
    └── src/index.ts
```

## How It Works

### For AI Agents

1. Load `orchestrator` skill first
2. Orchestrator routes to `fit-api-skill` or `fit-mobile-skill`
3. App skills have only relevant context

### API Integration

1. **fit-api** implements endpoints
2. **fit-api** updates `docs/API_REGISTRY.md`
3. **fit-mobile** reads `API_REGISTRY.md` to consume

### Syncing

**Using symlinks** - docs are always up-to-date automatically!

```bash
# One-time setup (already done)
cd fit-api/.claude && ln -s ../../fit-common/docs docs
cd fit-mobile/.claude && ln -s ../../fit-common/docs docs
```

Changes to `fit-common/docs/` are instantly visible in both apps.

### Code Quality & Validation

**Pre-push hooks** automatically validate code before every push:
- **fit-api**: Tests, build, format, SonarLint, API Registry sync
- **fit-mobile**: Tests, lint, type check, build, guidelines

**PR validation** runs on GitHub Actions for comprehensive CI/CD checks.

See [VALIDATION_SETUP.md](./docs/VALIDATION_SETUP.md) for complete guide.

## Quick Start

```bash
# Clone this repo as docs/
git clone <this-repo> fit-common

# Setup MCP
cd fit-docs/mcp
npm install && npm run build

# Configure Claude Code (.claude/mcp.json in each app repo)
{
  "servers": {
    "connecthealth": {
      "command": "node",
      "args": ["/path/to/fit-docs/mcp/dist/index.js"],
      "env": { "DOCS_PATH": "/path/to/fit-common" }
    }
  }
}
```
