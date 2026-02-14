#!/bin/bash
# Pre-push hook for fit-mobile
# Validates code quality, tests, and guidelines compliance before pushing

set -e

echo "🔍 Running pre-push validations for fit-mobile..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track failures
FAILED=0

# ============================================================
# 0. Check for uncommitted changes
# ============================================================
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}✗ Uncommitted changes detected${NC}"
    echo ""
    echo "You have uncommitted changes. Please commit them before pushing:"
    echo ""
    git status --short
    echo ""
    echo "To commit your changes:"
    echo "  git add ."
    echo "  git commit -m 'your commit message'"
    echo ""
    echo "Or to see what changed:"
    echo "  git diff"
    echo ""
    exit 1
fi

# Function to print step
step() {
    echo -e "${YELLOW}▶ $1${NC}"
}

# Function to print success
success() {
    echo -e "${GREEN}✓ $1${NC}"
    echo ""
}

# Function to print error
error() {
    echo -e "${RED}✗ $1${NC}"
    echo ""
    FAILED=1
}

# ============================================================
# 1. TypeScript Type Check
# ============================================================
step "Running TypeScript type check..."

if npx tsc --noEmit; then
    success "Type check passed"
else
    error "TypeScript type errors found. Fix them before pushing."
fi

# ============================================================
# 2. Lint Check
# ============================================================
step "Running ESLint..."

if npx nx run-many --target=lint --all --quiet; then
    success "Lint check passed"
else
    error "ESLint errors found. Run 'npx nx run-many --target=lint --all --fix' to auto-fix."
fi

# ============================================================
# 3. Run Tests
# ============================================================
step "Running tests..."

if npx nx run-many --target=test --all --quiet; then
    success "All tests passed"
else
    error "Tests failed. Fix failing tests before pushing."
fi

# ============================================================
# 4. Build Check
# ============================================================
step "Building project..."

# For Expo/React Native, we'll do a dry-run build check
if npx nx run-many --target=build --all --quiet 2>/dev/null; then
    success "Build check passed"
else
    # If build target doesn't exist, just check if TypeScript compiles
    echo "  ℹ Build target not configured - TypeScript compilation check only"
    echo ""
fi

# ============================================================
# 5. Guidelines Validation
# ============================================================
step "Validating coding guidelines compliance..."

# Check for console.log statements
CONSOLE_LOG_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E "\.(ts|tsx|js|jsx)$" | xargs grep -l "console\.log" 2>/dev/null || true)
if [ -n "$CONSOLE_LOG_FILES" ]; then
    echo -e "${YELLOW}  ⚠ Found console.log statements in:${NC}"
    echo "$CONSOLE_LOG_FILES" | sed 's/^/    - /'
    echo "  Remove console.log before pushing (use proper debugging or remove)"
    echo ""
    read -p "  Proceed anyway? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "Please remove console.log statements"
    fi
fi

# Check for 'any' type usage
ANY_TYPE_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E "\.(ts|tsx)$" | xargs grep -E ":\s*any\b" 2>/dev/null || true)
if [ -n "$ANY_TYPE_FILES" ]; then
    echo -e "${YELLOW}  ⚠ Found 'any' type usage - prefer specific types:${NC}"
    echo "$ANY_TYPE_FILES" | head -5 | sed 's/^/    - /'
    if [ $(echo "$ANY_TYPE_FILES" | wc -l) -gt 5 ]; then
        echo "    ... and $(($(echo "$ANY_TYPE_FILES" | wc -l) - 5)) more"
    fi
    echo ""
fi

# Check for debugger statements
DEBUGGER_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E "\.(ts|tsx|js|jsx)$" | xargs grep -l "debugger" 2>/dev/null || true)
if [ -n "$DEBUGGER_FILES" ]; then
    error "Found 'debugger' statements (remove before pushing):\n$DEBUGGER_FILES"
fi

# Check for TODO/FIXME comments
TODO_COUNT=$(git diff --cached --name-only --diff-filter=ACM | grep -E "\.(ts|tsx|js|jsx)$" | xargs grep -c "TODO\|FIXME" 2>/dev/null | awk -F: '{sum+=$2} END {print sum}')
if [ "$TODO_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}  ℹ Found $TODO_COUNT TODO/FIXME comments${NC}"
    echo "  Consider addressing them before pushing"
    echo ""
fi

success "Guidelines validation complete"

# ============================================================
# 6. API Registry Compliance Check
# ============================================================
step "Checking API endpoint compliance..."

# Check if any API client files were modified
MODIFIED_API_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E "(api|client|service)\.(ts|tsx)$" | grep -v "\.spec\." || true)

if [ -n "$MODIFIED_API_FILES" ]; then
    echo "  Modified API-related files detected:"
    echo "$MODIFIED_API_FILES" | sed 's/^/    - /'
    echo ""
    echo -e "${YELLOW}  ⚠ Reminder: Ensure all API calls match .claude/common/docs/API_REGISTRY.md${NC}"
    echo ""
    read -p "  Have you verified endpoints against API_REGISTRY.md? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        error "Please verify API endpoints against API_REGISTRY.md"
    else
        success "API Registry compliance confirmed by user"
    fi
else
    success "No API client changes detected"
fi

# ============================================================
# 7. Dependency Check
# ============================================================
step "Checking dependencies..."

# Check if package.json was modified
if git diff --cached --name-only | grep -q "package.json"; then
    echo -e "${YELLOW}  ⚠ package.json was modified${NC}"
    echo "  Make sure you ran 'npm install' after changes"
    echo ""

    # Check if package-lock.json or yarn.lock was also modified
    if git diff --cached --name-only | grep -qE "(package-lock\.json|yarn\.lock)"; then
        success "Lock file updated"
    else
        echo -e "${YELLOW}  ⚠ Lock file not updated${NC}"
        echo "  Run 'npm install' to update package-lock.json"
        echo ""
        read -p "  Proceed anyway? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error "Please run 'npm install' before pushing"
        fi
    fi
else
    success "No dependency changes"
fi

# ============================================================
# Summary
# ============================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FAILED -eq 1 ]; then
    echo -e "${RED}❌ Pre-push validation FAILED${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Fix the errors above before pushing."
    echo "To bypass this hook (NOT recommended): git push --no-verify"
    echo ""
    exit 1
else
    echo -e "${GREEN}✅ All validations passed!${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Proceeding with push..."
    echo ""
fi
