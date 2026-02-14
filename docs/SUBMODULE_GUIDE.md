# Git Submodules Guide for ConnectHealth

## What Are Submodules?

Git submodules allow one repository to contain another repository as a subdirectory. In ConnectHealth, `fit-common` is embedded as a submodule in both `fit-api` and `fit-mobile`.

## Structure

```
fit-api/                    # or fit-mobile/
└── .claude/
    └── common/             # ← Git submodule pointing to fit-common
        ├── docs/           # Shared documentation
        ├── skills/         # AI skills
        ├── scripts/        # Helper scripts
        ├── templates/      # Templates (hooks, etc.)
        └── mcp/            # MCP server
```

## Common Operations

### Clone Repository with Submodules

```bash
# New clone - includes submodules automatically
git clone --recurse-submodules https://github.com/DanilloMello/fit-api.git

# Ensure latest version
cd fit-api
git submodule update --remote .claude/common

# Install hooks
./.claude/common/scripts/install-hooks.sh

# Already cloned without submodules? Initialize them:
git submodule init
git submodule update
```

### Update Submodule to Latest Version

```bash
# Pull latest changes from fit-common
git submodule update --remote .claude/common

# Commit the update
git add .claude/common
git commit -m "chore: update fit-common to latest version"
git push
```

### Modify Shared Documentation

**Scenario:** You need to update `API_REGISTRY.md`

```bash
# Navigate into the submodule
cd .claude/common

# Make your changes
vim docs/API_REGISTRY.md

# Commit to fit-common repository
git add docs/API_REGISTRY.md
git commit -m "docs: add new endpoint for user profile"
git push origin master

# Return to parent repository
cd ../..

# Update submodule reference in fit-api/fit-mobile
git add .claude/common
git commit -m "chore: update fit-common submodule with API changes"
git push
```

### Check Submodule Status

```bash
# See which commit the submodule is on
git submodule status

# Output: [commit-hash] .claude/common (heads/master)

# Check if submodule is up-to-date
cd .claude/common
git fetch
git status
cd ../..
```

### Reset Submodule to Committed Version

```bash
# If you made uncommitted changes in the submodule and want to reset:
git submodule update --force .claude/common
```

## Automated Workflow

Once you run `./.claude/common/scripts/install-hooks.sh`, the following happens automatically:

### On `git clone`
- Submodules are cloned with `--recurse-submodules`
- fit-common documentation is immediately available

### On `git pull`
- **post-merge hook** automatically updates `.claude/common/` to latest
- No manual intervention needed

### On `git checkout` (switching branches)
- **post-checkout hook** checks if fit-common is outdated
- Automatically updates to latest version
- Warns if conflicts prevent auto-update

### On `git commit`
- **pre-commit hook** checks if fit-common is behind remote
- Warns you: "⚠️ WARNING: fit-common documentation is OUTDATED"
- Gives option to cancel and update first

### On `git push`
- **pre-push hook** validates code quality
- Runs tests, build, linting, etc.

## Workflow for Teams

### Developer 1: Updates Documentation

```bash
# In fit-api repository
cd .claude/common
vim docs/DOMAIN_SPEC.md
git add docs/DOMAIN_SPEC.md
git commit -m "docs: update entity definitions"
git push origin master
cd ../..
git add .claude/common
git commit -m "chore: update fit-common"
git push
```

### Developer 2: Gets Updates

```bash
# In fit-mobile repository
git pull origin master
# post-merge hook automatically updates .claude/common ✅

# Or manually:
git submodule update --remote .claude/common
```

## Troubleshooting

### "Submodule is not initialized"

```bash
git submodule init
git submodule update
```

### "Detached HEAD in submodule"

This is normal! Submodules track specific commits, not branches.

To work on the submodule:
```bash
cd .claude/common
git checkout master
git pull
# Make changes...
```

### "Modified content" when running git status

```bash
# If you see:
# modified:   .claude/common (modified content)

# Option 1: Commit the changes in the submodule
cd .claude/common
git add .
git commit -m "docs: update"
git push
cd ../..

# Option 2: Discard changes in the submodule
git submodule update --force .claude/common
```

### "Submodule commit not found"

```bash
# The parent repo references a commit that doesn't exist in fit-common
# Update to latest:
git submodule update --remote .claude/common
git add .claude/common
git commit -m "chore: update fit-common to latest"
```

### Pre-commit hook says fit-common is outdated

```bash
# Update fit-common to latest:
git submodule update --remote .claude/common

# Add to current commit:
git add .claude/common
git commit --amend --no-edit
```

## Best Practices

1. **Always commit submodule changes first**
   - Commit to `.claude/common` (fit-common)
   - Then commit the submodule reference in fit-api/fit-mobile

2. **Pull with submodules** (git config handles this automatically)
   ```bash
   git pull
   # post-merge hook updates submodules automatically
   ```

3. **Update submodules regularly**
   ```bash
   git submodule update --remote
   ```

4. **Check submodule status before committing**
   ```bash
   git status
   git submodule status
   ```

5. **Don't make uncommitted changes in submodules**
   - Either commit to fit-common and push
   - Or discard the changes

## Git Config

The automated hooks configure these settings:

```bash
# Automatically recurse into submodules for all git commands
git config submodule.recurse true

# Use merge strategy when updating submodules
git config submodule.update merge
```

You can verify these with:
```bash
git config --get submodule.recurse   # Should output: true
git config --get submodule.update    # Should output: merge
```

## MCP Server Configuration

Update your `.claude/mcp.json` (or global MCP config):

```json
{
  "servers": {
    "connecthealth": {
      "command": "node",
      "args": ["C:/Users/YourUser/projetos/fit-api/.claude/common/mcp/dist/index.js"],
      "env": {
        "DOCS_PATH": "C:/Users/YourUser/projetos/fit-api/.claude/common"
      }
    }
  }
}
```

Or use relative path (if supported):
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

## References

- [Git Submodules Official Docs](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [GitHub Submodules Guide](https://github.blog/2016-02-01-working-with-submodules/)
- [ConnectHealth VALIDATION_SETUP.md](./VALIDATION_SETUP.md)

---

**Last Updated:** 2026-02-14
