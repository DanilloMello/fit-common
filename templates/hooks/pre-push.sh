#!/bin/bash
# Universal pre-push hook for ConnectHealth projects
# Auto-detects project type (Java/Spring or TypeScript/React Native)
# Validates code quality, tests, and guidelines compliance before pushing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track failures
FAILED=0

# ============================================================
# Auto-detect project type
# ============================================================
if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    PROJECT_TYPE="api"
    echo "🔍 Running pre-push validations for fit-api..."
elif [ -f "package.json" ]; then
    PROJECT_TYPE="mobile"
    echo "🔍 Running pre-push validations for fit-mobile..."
else
    echo -e "${RED}❌ Could not detect project type${NC}"
    echo "This hook requires either build.gradle (Java) or package.json (Node.js)"
    exit 1
fi
echo ""

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

# ============================================================
# Project-specific validations
# ============================================================

if [ "$PROJECT_TYPE" == "api" ]; then
    # ============================================================
    # JAVA/SPRING VALIDATIONS
    # ============================================================

    # 1. Code Format Check
    step "Checking code format..."
    if grep -q "spotless" build.gradle 2>/dev/null; then
        if ./gradlew spotlessCheck --quiet; then
            success "Code format is valid"
        else
            error "Code format check failed. Run './gradlew spotlessApply' to fix formatting."
        fi
    else
        echo "  ⚠ Spotless not configured - skipping format check"
        echo ""
    fi

    # 2. Build Validation
    step "Building project..."
    if ./gradlew build -x test --quiet; then
        success "Build successful"
    else
        error "Build failed. Fix compilation errors before pushing."
    fi

    # 3. Run Tests
    step "Running tests..."
    if ./gradlew test --quiet; then
        success "All tests passed"
    else
        error "Tests failed. Fix failing tests before pushing."
    fi

    # 4. API Registry Sync Check
    step "Checking API Registry synchronization..."
    MODIFIED_CONTROLLERS=$(git diff --cached --name-only --diff-filter=ACM | grep -E "Controller\.java$" || true)
    if [ -n "$MODIFIED_CONTROLLERS" ]; then
        if git diff --cached --name-only | grep -q "API_REGISTRY.md"; then
            success "API Registry appears to be updated"
        else
            echo -e "${YELLOW}  ⚠ Controller files modified but API_REGISTRY.md not updated${NC}"
            echo "  Modified controllers:"
            echo "$MODIFIED_CONTROLLERS" | sed 's/^/    - /'
            echo ""
            echo "  Please verify:"
            echo "    1. If you added/changed endpoints, update API_REGISTRY.md in fit-common repo"
            echo "    2. If no API changes, you can proceed"
            echo ""
            read -p "  Did you update API_REGISTRY.md or are there no API changes? (y/n): " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                error "Please update API_REGISTRY.md before pushing"
            else
                success "API Registry check confirmed by user"
            fi
        fi
    else
        success "No controller changes detected"
    fi

    # 5. Guidelines Validation
    step "Validating coding guidelines compliance..."

    # Check for System.out.println
    SYSOUT_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep "\.java$" | xargs grep -l "System\.out\.println" 2>/dev/null || true)
    if [ -n "$SYSOUT_FILES" ]; then
        echo -e "${YELLOW}  ⚠ Found System.out.println in:${NC}"
        echo "$SYSOUT_FILES" | sed 's/^/    - /'
        echo "  Use SLF4J logger instead"
        echo ""
        read -p "  Proceed anyway? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error "Please remove System.out.println statements"
        fi
    fi

    # Check for @Transactional on repositories
    TRANSACTIONAL_REPOS=$(git diff --cached --name-only --diff-filter=ACM | grep "Repository\.java$" | xargs grep -l "@Transactional" 2>/dev/null || true)
    if [ -n "$TRANSACTIONAL_REPOS" ]; then
        error "Found @Transactional on repositories (should be on Use Cases only):\n$TRANSACTIONAL_REPOS"
    fi

    success "Guidelines validation complete"

    # 6. SonarLint Validation (if configured)
    step "Checking SonarLint..."
    if grep -q "sonarqube" build.gradle 2>/dev/null || grep -q "sonar" build.gradle 2>/dev/null; then
        if ./gradlew sonarqube -x test --quiet 2>/dev/null; then
            success "SonarLint validation passed"
        else
            echo -e "${YELLOW}  ⚠ SonarLint check could not be completed${NC}"
            echo "  Make sure to check SonarLint in your IDE before pushing"
            echo ""
        fi
    else
        echo "  ℹ SonarQube plugin not configured - check SonarLint in IDE manually"
        echo ""
    fi

elif [ "$PROJECT_TYPE" == "mobile" ]; then
    # ============================================================
    # TYPESCRIPT/REACT NATIVE VALIDATIONS
    # ============================================================

    # 1. TypeScript Type Check
    step "Running TypeScript type check..."
    if npx tsc --noEmit; then
        success "Type check passed"
    else
        error "TypeScript type errors found. Fix them before pushing."
    fi

    # 2. Lint Check
    step "Running ESLint..."
    if npx nx run-many --target=lint --all --quiet; then
        success "Lint check passed"
    else
        error "ESLint errors found. Run 'npx nx run-many --target=lint --all --fix' to auto-fix."
    fi

    # 3. Run Tests
    step "Running tests..."
    if npx nx run-many --target=test --all --quiet; then
        success "All tests passed"
    else
        error "Tests failed. Fix failing tests before pushing."
    fi

    # 4. Build Check
    step "Building project..."
    if npx nx run-many --target=build --all --quiet 2>/dev/null; then
        success "Build check passed"
    else
        echo "  ℹ Build target not configured - TypeScript compilation check only"
        echo ""
    fi

    # 5. Guidelines Validation
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

    # 6. API Registry Compliance Check
    step "Checking API endpoint compliance..."
    MODIFIED_API_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E "(api|client|service)\.(ts|tsx)$" | grep -v "\.spec\." || true)
    if [ -n "$MODIFIED_API_FILES" ]; then
        echo "  Modified API-related files detected:"
        echo "$MODIFIED_API_FILES" | sed 's/^/    - /'
        echo ""
        echo -e "${YELLOW}  ⚠ Reminder: Ensure all API calls match API_REGISTRY.md in fit-common repo${NC}"
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

    # 7. Dependency Check
    step "Checking dependencies..."
    if git diff --cached --name-only | grep -q "package.json"; then
        echo -e "${YELLOW}  ⚠ package.json was modified${NC}"
        echo "  Make sure you ran 'npm install' after changes"
        echo ""

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
