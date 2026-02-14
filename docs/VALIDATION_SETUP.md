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

## Pre-Push Hook

### What It Does

The pre-push hook runs **automatically** before every `git push`, blocking the push if validations fail.

### Location

- **Template**: `fit-common/templates/hooks/pre-push.sh`
- **Installed at**: `{app}/.git/hooks/pre-push`

### How to Use

**Normal workflow** (hook runs automatically):
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

#### Common (All Repos)

0. **Uncommitted Changes Check**
   - Checks: `git status --porcelain`
   - Ensures: All changes are committed before pushing
   - **Blocks push if uncommitted changes exist**

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

6. **SonarLint Validation** (if configured)
   - Runs: `./gradlew sonarqube`

#### fit-mobile (React Native/Expo)

1. **TypeScript Type Check**
   - Runs: `tsc --noEmit`

2. **Lint Check**
   - Runs: `nx run-many --target=lint --all`
   - Fix: Add `--fix` flag

3. **Test Execution**
   - Runs: `nx run-many --target=test --all`

4. **Build Check**
   - Runs: `nx run-many --target=build --all`

5. **Guidelines Validation**
   - Checks for: `console.log`, `debugger`, `any` type, TODO/FIXME

6. **API Registry Compliance**
   - If API clients changed, prompts to verify `API_REGISTRY.md` compliance

7. **Dependency Check**
   - If `package.json` changed, `package-lock.json` should be updated

---

## PR Validation (GitHub Actions)

PR validation runs **automatically** on GitHub when:
- A pull request is opened/updated
- Code is pushed to `main` or `develop` branches

### Location

- **fit-api**: `.github/workflows/pr-validation.yml`
- **fit-mobile**: `.github/workflows/pr-validation.yml`

### fit-api CI/CD Pipeline

1. **Setup**: Checkout, Java 21, PostgreSQL 15
2. **Validation**: Format, build, tests, API Registry sync, guidelines
3. **Reporting**: Test results, coverage, Codecov
4. **Optional**: SonarQube analysis

### fit-mobile CI/CD Pipeline

1. **Setup**: Checkout, Node.js 20, dependencies
2. **Validation**: TypeScript, ESLint, tests, build, guidelines
3. **Reporting**: Test results, coverage, Codecov
4. **Security**: npm audit

---

## Setup Instructions

### Team Setup

When a new developer joins:

1. **Clone repos as siblings**
   ```bash
   git clone https://github.com/DanilloMello/fit-api.git
   git clone https://github.com/DanilloMello/fit-mobile.git
   git clone https://github.com/DanilloMello/fit-common.git
   ```

2. **Install pre-push hook**
   ```bash
   cd fit-common
   ./scripts/install-hooks.sh
   ```

3. **Verify setup**
   ```bash
   ls -la fit-api/.git/hooks/pre-push     # Should exist and be executable
   ls -la fit-mobile/.git/hooks/pre-push   # Should exist and be executable
   ```

### GitHub Actions Setup

1. Ensure workflow files exist in each app repo
2. Optional: Configure `SONAR_TOKEN`, `CODECOV_TOKEN` in GitHub Secrets
3. Create a test PR to verify workflows run

---

## Common Scenarios

### Scenario 1: Uncommitted changes detected

```
✗ Uncommitted changes detected
```

**Solution:** `git add . && git commit -m "your message"` then push again.

### Scenario 2: Tests fail

**Solution:** Run tests locally, fix, commit, push again.

### Scenario 3: Code format fails

**Solution:**
- fit-api: `./gradlew spotlessApply`
- fit-mobile: `npx nx run-many --target=lint --all --fix`

### Scenario 4: API Registry not updated

**Solution:** Update `API_REGISTRY.md` in fit-common repo if you added/changed endpoints.

---

## Maintenance

### Updating the Hook

1. Edit `fit-common/templates/hooks/pre-push.sh`
2. Commit and push to fit-common
3. Re-run `./scripts/install-hooks.sh` to distribute to apps

### Updating CI/CD Workflows

Edit `.github/workflows/pr-validation.yml` in the target app repo.

---

## Troubleshooting

### Hook doesn't run
```bash
ls -la .git/hooks/pre-push    # Check existence
chmod +x .git/hooks/pre-push   # Make executable
```

### Hook fails immediately
```bash
bash -n .git/hooks/pre-push    # Check syntax
bash -x .git/hooks/pre-push    # Debug mode
```

---

## Best Practices

1. Never skip hooks without good reason
2. Run validations locally before pushing
3. Keep hooks fast (< 2 minutes)
4. Fix issues, don't bypass
5. Update hooks when guidelines change

---

## Related Documentation

- [CODING_GUIDELINES.md](./CODING_GUIDELINES.md) - Code standards enforced by hooks
- [API_REGISTRY.md](./API_REGISTRY.md) - API contract sync validation
- [DOMAIN_SPEC.md](./DOMAIN_SPEC.md) - Domain model reference

---

**Last Updated:** 2026-02-14
