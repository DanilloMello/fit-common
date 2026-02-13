---
name: connecthealth-project-orchestrator-doc
description: Entry point for ConnectHealth development. Routes to app-specific skills based on context.
---

# ConnectHealth Project Orchestrator

> **AI Agent**: Start here. Determine context, then load the appropriate skill.

---

## 1. Multi-Repo Layout

```
projetos/
├── fit-docs/    # This repo - docs & skills (source of truth)
├── fit-api/               # Backend repo (github.com/DanilloMello/fit-api)
│   └── CLAUDE.md          # Points back to docs
└── fit-mobile/            # Frontend repo (github.com/DanilloMello/fit-mobile)
    └── CLAUDE.md          # Points back to docs
```

---

## 2. Routing

| Working on... | Repo | Load Skill |
|---------------|------|------------|
| Java/Spring/Database | `../fit-api/` | **fit-api-skill** |
| React Native/Expo/UI | `../fit-mobile/` | **fit-mobile-skill** |
| Domain/API contracts | this repo | Read `docs/` docs |

---

## 3. Loading Order

### Backend (fit-api)
```
1. docs/DOMAIN_SPEC.md      # Entities, enums
2. docs/API_REGISTRY.md     # API to implement
3. skills/fit-api/SKILL.md    # Patterns
4. fit-api/ARCHITECTURE.md    # Module structure
5. fit-api/DATABASE.md        # Schema
```

### Frontend (fit-mobile)
```
1. docs/DOMAIN_SPEC.md      # Entities, enums
2. docs/API_REGISTRY.md     # API to consume
3. skills/fit-mobile/SKILL.md # Patterns
4. fit-mobile/ARCHITECTURE.md # Module structure
5. fit-mobile/SCREENS.md      # Screen specs
```

---

## 4. Common Resources

| File | Content |
|------|---------|
| `docs/DOMAIN_SPEC.md` | Entities, enums, rules |
| `docs/API_REGISTRY.md` | All API endpoints |
| `docs/PRD.md` | Requirements |
| `docs/SPRINT_PLAN.md` | Roadmap |

---

## 5. App Resources

### fit-api
- `fit-api/ARCHITECTURE.md` - Java/Spring patterns
- `fit-api/DATABASE.md` - PostgreSQL schema

### fit-mobile
- `fit-mobile/ARCHITECTURE.md` - NX/React Native patterns
- `fit-mobile/SCREENS.md` - Screen specs

---

## 6. API Registry Rule

**IMPORTANT**: When fit-api adds new endpoints:
1. Implement endpoint in `../fit-api/`
2. **Update `docs/API_REGISTRY.md`** in this repo
3. fit-mobile can then consume from `../fit-mobile/`

---

## 7. Docs Repo Structure

```
fit-docs/
├── docs/                       # Shared domain docs
│   ├── DOMAIN_SPEC.md
│   ├── API_REGISTRY.md
│   ├── PRD.md
│   └── SPRINT_PLAN.md
├── fit-api/                      # Backend-specific docs
│   ├── ARCHITECTURE.md
│   └── DATABASE.md
├── fit-mobile/                   # Frontend-specific docs
│   ├── ARCHITECTURE.md
│   └── SCREENS.md
├── skills/                       # AI Skills
│   ├── project-orchestrator-doc/
│   ├── fit-api/
│   └── fit-mobile/
├── scripts/
│   └── (removed - now using symlinks)
└── mcp/                          # MCP server for tool access
```
