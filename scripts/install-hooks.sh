#!/bin/bash
# install-hooks.sh - Install pre-push hooks for all repositories
# This ensures all repos have the latest validation hooks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$BASE_DIR/templates/hooks"

echo "📦 Installing pre-push hooks for ConnectHealth projects..."
echo ""

# ============================================================
# Install fit-api hook
# ============================================================
if [ -d "$BASE_DIR/../fit-api/.git" ]; then
    echo "Installing fit-api pre-push hook..."
    cp "$TEMPLATES_DIR/pre-push-api.sh" "$BASE_DIR/../fit-api/.git/hooks/pre-push"
    chmod +x "$BASE_DIR/../fit-api/.git/hooks/pre-push"
    echo "✓ fit-api hook installed"
else
    echo "⚠ fit-api repository not found at $BASE_DIR/../fit-api"
fi

echo ""

# ============================================================
# Install fit-mobile hook
# ============================================================
if [ -d "$BASE_DIR/../fit-mobile/.git" ]; then
    echo "Installing fit-mobile pre-push hook..."
    cp "$TEMPLATES_DIR/pre-push-mobile.sh" "$BASE_DIR/../fit-mobile/.git/hooks/pre-push"
    chmod +x "$BASE_DIR/../fit-mobile/.git/hooks/pre-push"
    echo "✓ fit-mobile hook installed"
else
    echo "⚠ fit-mobile repository not found at $BASE_DIR/../fit-mobile"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Pre-push hooks installed successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Hooks will now:"
echo "  1. Block pushes if there are uncommitted changes"
echo "  2. Run all validations (tests, build, lint, etc.)"
echo "  3. Enforce coding guidelines"
echo ""
echo "To update hooks in the future, run this script again:"
echo "  ./scripts/install-hooks.sh"
echo ""
