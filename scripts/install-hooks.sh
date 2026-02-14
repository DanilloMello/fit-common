#!/bin/bash
# install-hooks.sh - Install git hooks and configure submodule behavior
# Can be run from fit-common OR from app repos (via submodule)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$BASE_DIR/templates/hooks"

echo "📦 Installing git hooks and configuration for ConnectHealth..."
echo ""

# Function to install hooks for a repository
install_hooks() {
    local repo_path=$1
    local repo_type=$2

    echo "Installing hooks for $repo_type at $repo_path"

    # Configure git to always recurse submodules
    echo "  ⚙️  Configuring git submodule auto-update..."
    git -C "$repo_path" config submodule.recurse true
    git -C "$repo_path" config submodule.update merge

    # Install pre-commit hook (outdated warning)
    echo "  📝 Installing pre-commit hook (outdated check)..."
    cp "$TEMPLATES_DIR/pre-commit.sh" "$repo_path/.git/hooks/pre-commit"
    chmod +x "$repo_path/.git/hooks/pre-commit"

    # Install post-merge hook (auto-update after pull)
    echo "  🔄 Installing post-merge hook (auto-update after pull)..."
    cp "$TEMPLATES_DIR/post-merge.sh" "$repo_path/.git/hooks/post-merge"
    chmod +x "$repo_path/.git/hooks/post-merge"

    # Install post-checkout hook (update when switching branches)
    echo "  🔀 Installing post-checkout hook (update on checkout)..."
    cp "$TEMPLATES_DIR/post-checkout.sh" "$repo_path/.git/hooks/post-checkout"
    chmod +x "$repo_path/.git/hooks/post-checkout"

    # Install pre-push hook (validation - unified auto-detecting hook)
    echo "  ✅ Installing pre-push hook (auto-detecting validation)..."
    cp "$TEMPLATES_DIR/pre-push.sh" "$repo_path/.git/hooks/pre-push"
    chmod +x "$repo_path/.git/hooks/pre-push"

    echo "  ✓ Hooks installed for $repo_type"
}

# Detect if we're in a submodule or standalone fit-common
if [ -f "$BASE_DIR/../../.git" ] || [ -d "$BASE_DIR/../../.git" ]; then
    # We're in a submodule (.claude/common/)
    REPO_ROOT="$(cd "$BASE_DIR/../.." && pwd)"
    APP_NAME=$(basename "$REPO_ROOT")

    echo "🔍 Detected submodule installation in $APP_NAME"
    echo ""

    if [[ "$APP_NAME" == "fit-api"* ]] || [ -f "$REPO_ROOT/gradlew" ]; then
        install_hooks "$REPO_ROOT" "fit-api"
    elif [[ "$APP_NAME" == "fit-mobile"* ]] || [ -f "$REPO_ROOT/package.json" ]; then
        install_hooks "$REPO_ROOT" "fit-mobile"
    else
        echo "⚠ Could not detect repository type"
        exit 1
    fi
else
    # Standalone fit-common, try to find sibling repos
    echo "🔍 Standalone fit-common installation"
    echo ""

    if [ -d "$BASE_DIR/../fit-api/.git" ]; then
        install_hooks "$BASE_DIR/../fit-api" "fit-api"
    else
        echo "⚠ fit-api repository not found at $BASE_DIR/../fit-api"
    fi

    echo ""

    if [ -d "$BASE_DIR/../fit-mobile/.git" ]; then
        install_hooks "$BASE_DIR/../fit-mobile" "fit-mobile"
    else
        echo "⚠ fit-mobile repository not found at $BASE_DIR/../fit-mobile"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Git hooks and configuration installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Automated workflow enabled:"
echo "  ✓ git clone → always fetches latest fit-common"
echo "  ✓ git pull → auto-updates fit-common (post-merge hook)"
echo "  ✓ git checkout → updates fit-common when switching branches (post-checkout hook)"
echo "  ✓ git commit → warns if fit-common outdated (pre-commit hook)"
echo "  ✓ git push → validates code quality (pre-push hook)"
echo "  ✓ submodule.recurse = true → all git commands update submodules"
echo ""
