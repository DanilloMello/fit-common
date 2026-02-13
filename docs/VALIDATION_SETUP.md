# Validation Setup Guide

## Overview

ConnectHealth projects enforce code quality through automated validations at two critical points:

1. **Pre-Push Hooks** - Local validation before pushing to remote
2. **PR Validation** - CI/CD validation on pull requests

This ensures that only high-quality, tested code reaches the main branch.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Developer Workflow                                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  1. Write code                                                │
│  2. Commit changes                                            │
│  3. Push to remote ──► PRE-PUSH HOOK (local validation)     │
│     │                   ├─ Tests                             │
│     │                   ├─ Build                             │
│     │                   ├─ Lint/Format                       │
│     │                   ├─ Guidelines check                  │
│     │                   └─ Quality checks                    │
│     │                                                         │
│     └─► If pass ──► Remote repository                       │
│                                                               │
│  4. Create PR ──────► PR VALIDATION (CI/CD)                 │
│                       ├─ All pre-push checks                │
│                       ├─ Test coverage report                │
│                       ├─ Security audit                      │
│                       ├─ API Registry sync check             │
│                       └─ Automated code review               │
│                                                               │
│  5. Review & Merge                                           │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Pre-Push Hooks

### What They Do

Pre-push hooks run **automatically** before every `git push`, blocking the push if validations fail. This catches issues early, before they reach the remote repository.

### Location

- **fit-api**: `.git/hooks/pre-push`
- **fit-mobile**: `.git/hooks/pre-push`

### How to Use

**Normal workflow** (hooks run automatically):
```bash
git add .
git commit -m "feat: add new feature"
git push origin feature/my-branch
# ▶ Pre-push hook runs automatically here
```

**Bypass hook** (NOT recommended, use only in emergencies):
```bash
git push --no-verify
```

### What Gets Validated

#### fit-api (Java/Spring Boot)

1. **Code Format Check**
   - Runs: `./gradlew spotlessCheck`
   - Ensures: Google Java Format compliance
   - Fix: `./gradlew spotlessApply`

2. **Build Validation**
   - Runs: `./gradlew build -x test`
   - Ensures: Project compiles without errors

3. **Test Execution**
   - Runs: `./gradlew test`
   - Ensures: All tests pass

4. **API Registry Sync Check**
   - Checks: If controllers changed, `API_REGISTRY.md` should be updated
   - Ensures: Backend and frontend stay in sync

5. **Guidelines Validation**
   - Checks for:
     - `System.out.println` (use SLF4J instead)
     - `@Transactional` on repositories (should be on Use Cases only)
     - Large commented code blocks
   - Ensures: Code follows best practices

6. **SonarLint Validation** (if configured)
   - Runs: `./gradlew sonarqube`
   - Ensures: No critical/blocker issues

#### fit-mobile (React Native/Expo)

1. **TypeScript Type Check**
   - Runs: `tsc --noEmit`
   - Ensures: No type errors

2. **Lint Check**
   - Runs: `nx run-many --target=lint --all`
   - Ensures: ESLint rules followed
   - Fix: Add `--fix` flag

3. **Test Execution**
   - Runs: `nx run-many --target=test --all`
   - Ensures: All tests pass

4. **Build Check**
   - Runs: `nx run-many --target=build --all`
   - Ensures: Project builds successfully

5. **Guidelines Validation**
   - Checks for:
     - `console.log` statements (remove or use proper debugging)
     - `debugger` statements (must remove)
     - `any` type usage (prefer specific types)
     - TODO/FIXME comments (informational)
   - Ensures: Code follows best practices

6. **API Registry Compliance**
   - Checks: If API clients changed, prompts to verify `API_REGISTRY.md` compliance
   - Ensures: Frontend uses correct backend endpoints

7. **Dependency Check**
   - Checks: If `package.json` changed, `package-lock.json` should be updated
   - Ensures: Dependencies are properly locked

---

## PR Validation (GitHub Actions)

### What They Do

PR validation runs **automatically** on GitHub when:
- A pull request is opened/updated
- Code is pushed to `main` or `develop` branches

### Location

- **fit-api**: `.github/workflows/pr-validation.yml`
- **fit-mobile**: `.github/workflows/pr-validation.yml`

### Workflow Steps

#### fit-api CI/CD Pipeline

1. **Setup**
   - Checkout code
   - Setup Java 21
   - Setup PostgreSQL 15 for tests

2. **Validation**
   - Code format check (Spotless)
   - Build project
   - Run all tests
   - Check API Registry sync
   - Check for System.out.println
   - Check for @Transactional on repositories

3. **Reporting**
   - Publish test results
   - Generate coverage report
   - Upload to Codecov (if configured)

4. **Optional**
   - SonarQube analysis (if token configured)

#### fit-mobile CI/CD Pipeline

1. **Setup**
   - Checkout code
   - Setup Node.js 20
   - Install dependencies

2. **Validation**
   - TypeScript type check
   - ESLint check
   - Run all tests
   - Build check
   - Check for console.log
   - Check for debugger statements
   - Check for 'any' type usage
   - Check package-lock.json sync

3. **Reporting**
   - Publish test results
   - Generate coverage report
   - Upload to Codecov (if configured)

4. **Security**
   - Run npm audit for vulnerabilities

---

## Setup Instructions

### Initial Setup (Already Done)

The pre-push hooks are already installed. If you need to reinstall:

#### fit-api
```bash
cd fit-api
chmod +x .git/hooks/pre-push
```

#### fit-mobile
```bash
cd fit-mobile
chmod +x .git/hooks/pre-push
```

### Team Setup

When a new developer joins:

1. **Clone repositories**
   ```bash
   git clone <fit-api-repo>
   git clone <fit-mobile-repo>
   git clone <fit-common-repo>
   ```

2. **Hooks are automatically active** (included in `.git/hooks/`)

3. **Verify hook setup**
   ```bash
   # fit-api
   cd fit-api
   ls -la .git/hooks/pre-push  # Should exist and be executable

   # fit-mobile
   cd fit-mobile
   ls -la .git/hooks/pre-push  # Should exist and be executable
   ```

4. **Test hooks**
   ```bash
   # Make a dummy commit and try to push
   git commit --allow-empty -m "test: verify pre-push hook"
   git push origin HEAD
   # Hook should run and validate
   ```

### GitHub Actions Setup

1. **Ensure workflow files exist** (already created)
   - `fit-api/.github/workflows/pr-validation.yml`
   - `fit-mobile/.github/workflows/pr-validation.yml`

2. **Optional: Configure secrets** (for advanced features)
   - Go to GitHub repo → Settings → Secrets and variables → Actions
   - Add:
     - `SONAR_TOKEN` - For SonarQube analysis
     - `SONAR_HOST_URL` - SonarQube server URL
     - `CODECOV_TOKEN` - For Codecov integration

3. **Verify workflow runs**
   - Create a test PR
   - Check "Actions" tab in GitHub
   - Workflow should run automatically

---

## Common Scenarios

### Scenario 1: Pre-push hook fails on tests

```bash
❌ Tests failed. Fix failing tests before pushing.
```

**Solution:**
1. Run tests locally: `./gradlew test` (fit-api) or `nx test` (fit-mobile)
2. Identify failing tests
3. Fix the tests or the code
4. Commit the fix
5. Push again

### Scenario 2: Code format check fails

```bash
❌ Code format check failed. Run './gradlew spotlessApply' to fix formatting.
```

**Solution:**
```bash
# fit-api
./gradlew spotlessApply
git add .
git commit --amend --no-edit
git push

# fit-mobile (auto-fix with ESLint)
npx nx run-many --target=lint --all --fix
git add .
git commit --amend --no-edit
git push
```

### Scenario 3: API Registry not updated

```bash
⚠️ Controller files modified but API_REGISTRY.md not updated
```

**Solution:**
1. Check if you added/modified API endpoints
2. If yes:
   ```bash
   # Update the registry
   vi .claude/docs/API_REGISTRY.md
   # Add your new endpoints following the existing format
   git add .claude/docs/API_REGISTRY.md
   git commit --amend --no-edit
   git push
   ```
3. If no API changes, confirm when prompted

### Scenario 4: Need to push urgently (broken hook)

```bash
# ONLY in emergencies - bypasses all checks
git push --no-verify

# Better: Fix the issue and push properly
```

**⚠️ Warning:** Bypassing hooks should be rare. Always fix issues instead.

### Scenario 5: CI/CD fails but local hook passed

**Possible causes:**
- Environment differences (Node/Java version)
- Missing dependencies
- Database setup issues

**Solution:**
1. Check GitHub Actions logs
2. Reproduce the issue locally with same versions
3. Fix and push again

---

## Maintenance

### Updating Hooks

If hooks need to be updated:

1. **Edit hook file directly**
   ```bash
   vi fit-api/.git/hooks/pre-push
   # Make changes
   chmod +x fit-api/.git/hooks/pre-push
   ```

2. **Distribute to team**
   - Hooks are in `.git/` which is not tracked by git
   - Share updated hook via:
     - Slack/email
     - Store template in `fit-common/templates/hooks/`
     - Team members copy manually

### Updating CI/CD Workflows

1. **Edit workflow file**
   ```bash
   vi fit-api/.github/workflows/pr-validation.yml
   # Make changes
   ```

2. **Commit and push**
   ```bash
   git add .github/workflows/pr-validation.yml
   git commit -m "ci: update PR validation workflow"
   git push
   ```

3. **Workflows are auto-updated** for all team members

---

## Troubleshooting

### Hook doesn't run

```bash
# Check if hook file exists
ls -la .git/hooks/pre-push

# Check if it's executable
stat .git/hooks/pre-push

# Make it executable
chmod +x .git/hooks/pre-push
```

### Hook runs but fails immediately

```bash
# Check for syntax errors
bash -n .git/hooks/pre-push

# Run with debug mode
bash -x .git/hooks/pre-push
```

### GitHub Actions workflow doesn't trigger

- Check `.github/workflows/pr-validation.yml` exists
- Ensure `on: pull_request` matches your branch name
- Check GitHub repo → Settings → Actions → "Allow all actions"

### Gradle/NPM commands not found in hook

```bash
# Ensure you're in the project root
pwd

# Check if gradle wrapper exists
ls -la gradlew  # fit-api

# Check if node_modules exists
ls -la node_modules  # fit-mobile
```

---

## Best Practices

1. **Never skip hooks without good reason** - They catch issues early
2. **Run validations locally before pushing** - Faster feedback loop
3. **Keep hooks fast** - Should complete in < 2 minutes
4. **Fix issues, don't bypass** - Technical debt accumulates
5. **Update hooks when guidelines change** - Keep them in sync
6. **Monitor CI/CD costs** - Use caching and parallelization
7. **Review hook output** - Understand what failed and why

---

## Related Documentation

- [CODING_GUIDELINES.md](./CODING_GUIDELINES.md) - Code standards enforced by hooks
- [API_REGISTRY.md](./API_REGISTRY.md) - API contract sync validation
- [DOMAIN_SPEC.md](./DOMAIN_SPEC.md) - Domain model reference
- [fit-api/CLAUDE.md](../../fit-api/CLAUDE.md) - Backend development guide
- [fit-mobile/CLAUDE.md](../../fit-mobile/CLAUDE.md) - Frontend development guide

---

## Summary

| Component | Purpose | Runs When | Bypass |
|-----------|---------|-----------|--------|
| Pre-push hook (local) | Fast validation before remote push | Every `git push` | `--no-verify` |
| PR validation (CI/CD) | Comprehensive validation on PR | PR open/update, push to main/develop | Cannot bypass |

**Both layers ensure code quality** - local hooks catch issues fast, CI/CD provides authoritative validation.

---

**Last Updated:** 2026-02-13
**Maintained By:** ConnectHealth Team
