---
name: project-orchestrator-doc
description: Entry point for ConnectHealth development. Routes to app-specific skills based on context.
---

# ConnectHealth Project Orchestrator

> **AI Agent**: Start here. Determine context, then load the appropriate skill.

---

## 1. Multi-Repo Layout

```
projetos/
├── fit-common/              # Shared docs & MCP config templates
│   ├── docs/                # Shared documentation
│   ├── skills/              # Common skills (this orchestrator)
│   ├── scripts/             # Automation scripts
│   ├── templates/hooks/     # Git hook templates
│   └── mcp/                 # MCP config templates for each app
│
├── fit-api/                 # Backend repo (github.com/DanilloMello/fit-api)
│   ├── CLAUDE.md            # Entry point guide
│   └── .claude/
│       ├── mcp.json         # MCP servers → fit-common folders
│       └── skills/fit-api/  # API-specific skill
│
└── fit-mobile/              # Frontend repo (github.com/DanilloMello/fit-mobile)
    ├── CLAUDE.md            # Entry point guide
    └── .claude/
        ├── mcp.json         # MCP servers → fit-common folders
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
2. Use `fit-api-docs` MCP → `DOMAIN_SPEC.md` - Entities, enums, business rules
3. Use `fit-api-docs` MCP → `API_REGISTRY.md` - API endpoints to implement
4. Use `fit-api-docs` MCP → `CODING_GUIDELINES.md` - Coding standards
5. `.claude/skills/fit-api/SKILL.md` - Java/Spring patterns & file locations

### Frontend (fit-mobile)

When working in fit-mobile, read in this order:

1. `fit-mobile/CLAUDE.md` - Project overview and architecture
2. Use `fit-mobile-docs` MCP → `DOMAIN_SPEC.md` - Entities, enums, business rules
3. Use `fit-mobile-docs` MCP → `API_REGISTRY.md` - API endpoints to consume
4. Use `fit-mobile-docs` MCP → `CODING_GUIDELINES.md` - Coding standards
5. `.claude/skills/fit-mobile/SKILL.md` - React Native/NX patterns & file locations

---

## 4. Common Resources (fit-common/docs/)

Access these via the `{app}-docs` MCP server:

| File | Purpose |
|------|---------|
| `DOMAIN_SPEC.md` | Entities, enums, value objects, business rules |
| `API_REGISTRY.md` | Complete API specification (fit-api provides, fit-mobile consumes) |
| `PRD.md` | Product requirements and features |
| `SPRINT_PLAN.md` | Development roadmap |
| `CODING_GUIDELINES.md` | Code standards for both Java and TypeScript |
| `VALIDATION_SETUP.md` | Pre-push hooks and CI/CD validation |

---

## 5. App-Specific Resources

### fit-api

Located in `.claude/skills/fit-api/`:
- `SKILL.md` - Java/Spring patterns, file locations, checklists

### fit-mobile

Located in `.claude/skills/fit-mobile/`:
- `SKILL.md` - React Native/NX patterns, file locations, checklists

---

## 6. Key Workflows

### Adding New API Endpoints (fit-api)

1. Implement endpoint in `fit-api/`
2. **Update `API_REGISTRY.md`** in fit-common repo
3. Commit and push to fit-common
4. fit-mobile can now consume the new endpoint via MCP

### Consuming API from Mobile (fit-mobile)

1. **Always check `API_REGISTRY.md` via `fit-mobile-docs` MCP first**
2. Never guess endpoint URLs or contracts
3. Implement API client following the exact specification

### Updating Common Documentation

1. Edit files in `fit-common/docs/`
2. Commit and push to fit-common
3. MCP servers in each app read directly — no sync needed

---

## 7. Validation

Pre-push hook auto-detects project type and runs validations:

**Java/Spring (fit-api):**
- Code format (Spotless), Build, Tests, API Registry sync, Guidelines

**TypeScript/React Native (fit-mobile):**
- TypeScript, ESLint, Tests, Build, Guidelines, API Registry compliance

See `VALIDATION_SETUP.md` via MCP for details.

---

## 8. Quick Reference

### When starting work:
1. Read `CLAUDE.md` in the app repo
2. Use `{app}-docs` MCP to read `DOMAIN_SPEC.md`
3. Use `{app}-docs` MCP to read `API_REGISTRY.md`
4. Read `.claude/skills/{app}/SKILL.md` for code patterns

### When adding features:
- **Backend:** Update `API_REGISTRY.md` in fit-common when adding endpoints
- **Frontend:** Always check `API_REGISTRY.md` via MCP before implementing
- **Both:** Follow patterns in respective SKILL.md files

---

**Last Updated:** 2026-02-14
