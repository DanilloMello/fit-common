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

**Using Git Submodules** - docs are version-controlled and work cross-platform!

fit-common is embedded as a git submodule in each application repository:
- **fit-api**: `.claude/common/` → git submodule
- **fit-mobile**: `.claude/common/` → git submodule

**Automated updates:**
- `git pull` → post-merge hook auto-updates fit-common
- `git checkout` → post-checkout hook auto-updates fit-common
- `git commit` → pre-commit hook warns if fit-common outdated

Changes to fit-common are synchronized via git version control.

### Code Quality & Validation

**Automated git hooks** ensure code quality and fresh documentation:

**Pre-commit hook:**
- Warns if fit-common documentation is outdated
- Gives option to cancel and update first

**Post-merge hook:**
- Auto-updates fit-common after `git pull`

**Post-checkout hook:**
- Auto-updates fit-common when switching branches

**Pre-push hook:**
- **Uncommitted changes check** - Blocks push if changes not committed
- **fit-api**: Tests, build, format, SonarLint, API Registry sync
- **fit-mobile**: Tests, lint, type check, build, guidelines

**Git config:**
- `submodule.recurse = true` - All git commands automatically update submodules
- `submodule.update = merge` - Use merge strategy for updates

**Install hooks:** `./.claude/common/scripts/install-hooks.sh` (run from fit-api or fit-mobile)

**PR validation** runs on GitHub Actions for comprehensive CI/CD checks.

See [VALIDATION_SETUP.md](./docs/VALIDATION_SETUP.md) for complete guide.

## Quick Start

**Option 1: Clone app repository (fit-api or fit-mobile) - RECOMMENDED**

```bash
# Clone with submodules automatically
git clone --recurse-submodules https://github.com/DanilloMello/fit-api.git
cd fit-api

# Ensure fit-common is on latest version
git submodule update --remote .claude/common

# Install hooks (includes git config)
./.claude/common/scripts/install-hooks.sh

# Docs are now available at .claude/common/docs/
```

**Option 2: Clone fit-common standalone (for documentation development)**

```bash
git clone https://github.com/DanilloMello/fit-common.git
cd fit-common
```

**If you already cloned without submodules:**

```bash
cd fit-api  # or fit-mobile
git submodule init
git submodule update --remote .claude/common
./.claude/common/scripts/install-hooks.sh
```

**Setup MCP Server (optional):**

```bash
# Build MCP server
cd .claude/common/mcp
npm install && npm run build

# Configure Claude Code (.claude/mcp.json)
{
  "servers": {
    "connecthealth": {
      "command": "node",
      "args": ["./.claude/common/mcp/dist/index.js"],
      "env": { "DOCS_PATH": "./.claude/common" }
    }
  }
}
```

See [SUBMODULE_GUIDE.md](./docs/SUBMODULE_GUIDE.md) for detailed workflow.
