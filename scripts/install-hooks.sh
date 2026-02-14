#!/bin/bash
# install-hooks.sh - Install pre-push validation hook for ConnectHealth apps
# Run from fit-common repo. Detects sibling fit-api/fit-mobile directories.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="$BASE_DIR/templates/hooks"

echo "Installing pre-push hook for ConnectHealth..."
echo ""

install_hook() {
    local repo_path=$1
    local repo_name=$2

    if [ ! -d "$repo_path/.git" ]; then
        echo "  Skipping $repo_name - not a git repo at $repo_path"
        return
    fi

    echo "  Installing pre-push hook for $repo_name..."
    cp "$TEMPLATES_DIR/pre-push.sh" "$repo_path/.git/hooks/pre-push"
    chmod +x "$repo_path/.git/hooks/pre-push"
    echo "  Done: $repo_name"
}

# Install for sibling repos
if [ -d "$BASE_DIR/../fit-api/.git" ]; then
    install_hook "$BASE_DIR/../fit-api" "fit-api"
else
    echo "  fit-api not found at $BASE_DIR/../fit-api"
fi

echo ""

if [ -d "$BASE_DIR/../fit-mobile/.git" ]; then
    install_hook "$BASE_DIR/../fit-mobile" "fit-mobile"
else
    echo "  fit-mobile not found at $BASE_DIR/../fit-mobile"
fi

echo ""
echo "Done. Pre-push hook validates: tests, build, lint, guidelines."
echo ""
