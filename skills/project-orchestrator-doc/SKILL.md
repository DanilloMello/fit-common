---
name: project-orchestrator-doc
description: Entry point for ConnectHealth development. Routes to app-specific skills based on context.
---

# ConnectHealth Project Orchestrator

> **AI Agent**: Start here. Determine context, then load the appropriate skill.

---

## 1. Multi-Repo Layout with Submodules

```
projetos/
├── fit-common/              # Common docs & resources (git submodule in each app)
│   ├── docs/                # Shared documentation
│   ├── skills/              # Common skills
│   ├── mcp/                 # MCP server
│   ├── scripts/             # Installation scripts
│   └── templates/hooks/     # Git hook templates
│
├── fit-api/                 # Backend repo (github.com/DanilloMello/fit-api)
│   ├── CLAUDE.md            # Entry point guide
│   └── .claude/
│       ├── common/          # → Git submodule to fit-common
│       └── skills/fit-api/  # API-specific skill
│
└── fit-mobile/              # Frontend repo (github.com/DanilloMello/fit-mobile)
    ├── CLAUDE.md            # Entry point guide
    └── .claude/
        ├── common/          # → Git submodule to fit-common
        └── skills/fit-mobile/  # Mobile-specific skill
```

---

## 2. Routing by Context

| Working on... | Repo | First Read | Then Load Skill |
|---------------|------|-----------|----------------|
| Java/Spring/Database | `fit-api/` | `CLAUDE.md` | `.claude/skills/fit-api/SKILL.md` |
| React Native/Expo/UI | `fit-mobile/` | `CLAUDE.md` | `.claude/skills/fit-mobile/SKILL.md` |
| Common docs/schemas | `fit-common/` | `README.md` | Read `docs/` directly |

---

## 3. Documentation Loading Order

### Backend (fit-api)

When working in fit-api, read in this order:

1. `fit-api/CLAUDE.md` - Project overview and architecture
2. `.claude/common/docs/DOMAIN_SPEC.md` - Entities, enums, business rules
3. `.claude/common/docs/API_REGISTRY.md` - API endpoints to implement
4. `.claude/common/docs/CODING_GUIDELINES.md` - Coding standards
5. `.claude/skills/fit-api/SKILL.md` - Java/Spring patterns & file locations
6. `ARCHITECTURE.md` - Module structure (if exists in root)
7. `DATABASE.md` - PostgreSQL schema (if exists in root)

### Frontend (fit-mobile)

When working in fit-mobile, read in this order:

1. `fit-mobile/CLAUDE.md` - Project overview and architecture
2. `.claude/common/docs/DOMAIN_SPEC.md` - Entities, enums, business rules
3. `.claude/common/docs/API_REGISTRY.md` - API endpoints to consume
4. `.claude/common/docs/CODING_GUIDELINES.md` - Coding standards
5. `.claude/skills/fit-mobile/SKILL.md` - React Native/NX patterns & file locations
6. `ARCHITECTURE.md` - Module structure (if exists in root)
7. `SCREENS.md` - Screen specifications (if exists in root)

---

## 4. Common Resources (fit-common)

All apps access these via `.claude/common/docs/`:

| File | Purpose |
|------|---------|
| `DOMAIN_SPEC.md` | Entities, enums, value objects, business rules |
| `API_REGISTRY.md` | Complete API specification (fit-api provides, fit-mobile consumes) |
| `PRD.md` | Product requirements and features |
| `SPRINT_PLAN.md` | Development roadmap |
| `CODING_GUIDELINES.md` | Code standards for both Java and TypeScript |
| `VALIDATION_SETUP.md` | Pre-push hooks and CI/CD validation |
| `SUBMODULE_GUIDE.md` | How to work with git submodules |

---

## 5. App-Specific Resources

### fit-api

Located in `.claude/skills/fit-api/`:
- `SKILL.md` - Java/Spring patterns, file locations, checklists

Optional in root (if created):
- `ARCHITECTURE.md` - Detailed module structure
- `DATABASE.md` - Schema and migration guides

### fit-mobile

Located in `.claude/skills/fit-mobile/`:
- `SKILL.md` - React Native/NX patterns, file locations, checklists

Optional in root (if created):
- `ARCHITECTURE.md` - Detailed module structure
- `SCREENS.md` - Screen specifications

---

## 6. Key Workflows

### Adding New API Endpoints (fit-api)

1. Implement endpoint in `fit-api/`
2. **Update `.claude/common/docs/API_REGISTRY.md`** in fit-common
3. Commit and push to fit-common repository
4. Update submodule reference in fit-api
5. fit-mobile can now consume the new endpoint

### Consuming API from Mobile (fit-mobile)

1. **Always check `.claude/common/docs/API_REGISTRY.md` first**
2. Never guess endpoint URLs or contracts
3. Implement API client following the exact specification
4. If endpoint doesn't exist, request it from fit-api team

### Updating Common Documentation

All common docs live in fit-common repository:

1. Navigate to `fit-common/` (or via submodule at `.claude/common/`)
2. Edit files in `docs/`
3. Commit and push to fit-common repository
4. Update submodule reference in app repos:
   ```bash
   cd fit-api  # or fit-mobile
   git submodule update --remote .claude/common
   git add .claude/common
   git commit -m "chore: update fit-common to latest"
   git push
   ```

---

## 7. Submodule Workflow

**Initial setup** (already done):
```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/DanilloMello/fit-api.git

# Install git hooks
cd fit-api
./.claude/common/scripts/install-hooks.sh
```

**Daily workflow** (automated by hooks):
```bash
git pull        # Automatically updates submodule (post-merge hook)
git commit      # Warns if submodule outdated (pre-commit hook)
git push        # Validates code quality (pre-push hook)
```

See `.claude/common/docs/SUBMODULE_GUIDE.md` for complete guide.

---

## 8. Validation & Hooks

Pre-push hook automatically detects project type and runs appropriate validations:

**Java/Spring (fit-api):**
- Code format (Spotless)
- Build validation
- Tests
- API Registry sync check
- Coding guidelines (no System.out.println, @Transactional on Use Cases only)

**TypeScript/React Native (fit-mobile):**
- TypeScript type check
- ESLint
- Tests
- Build check
- Coding guidelines (no console.log, debugger, prefer typed over 'any')
- API Registry compliance
- Dependency lock file sync

See `.claude/common/docs/VALIDATION_SETUP.md` for details.

---

## 9. MCP Server Integration

The MCP server provides tool access to documentation:

**Location:** `fit-common/mcp/`

**Configuration:** Add to `.claude/mcp.json`:
```json
{
  "servers": {
    "connecthealth": {
      "command": "node",
      "args": ["./.claude/common/mcp/dist/index.js"],
      "env": {
        "DOCS_PATH": "./.claude/common"
      }
    }
  }
}
```

---

## 10. Quick Reference

### When starting work:
1. Read `CLAUDE.md` in the app repo (fit-api or fit-mobile)
2. Read `.claude/common/docs/DOMAIN_SPEC.md` for entities
3. Read `.claude/common/docs/API_REGISTRY.md` for API contract
4. Read `.claude/skills/{app}/SKILL.md` for code patterns

### When adding features:
- **Backend:** Update API_REGISTRY.md when adding endpoints
- **Frontend:** Always check API_REGISTRY.md before implementing
- **Both:** Follow patterns in respective SKILL.md files

### When in doubt:
- Check `CODING_GUIDELINES.md` for standards
- Check `VALIDATION_SETUP.md` for quality gates
- Check `SUBMODULE_GUIDE.md` for git workflow

---

**Last Updated:** 2026-02-14
