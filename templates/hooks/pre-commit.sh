#!/bin/bash
# pre-commit hook - Warn if fit-common is outdated

# Check if .claude/common exists
if [ ! -d ".claude/common" ]; then
    exit 0
fi

# Check if fit-common is behind remote
cd .claude/common

# Fetch latest (quietly)
git fetch origin main 2>/dev/null

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main 2>/dev/null || echo "$LOCAL")

if [ "$LOCAL" != "$REMOTE" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️  WARNING: fit-common documentation is OUTDATED"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Your local fit-common is behind the remote repository."
    echo "You may be working with stale documentation."
    echo ""
    echo "To update:"
    echo "  git submodule update --remote .claude/common"
    echo "  git add .claude/common"
    echo "  git commit --amend --no-edit"
    echo ""
    echo "Continue anyway? (y/N)"
    read -r response

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Commit cancelled. Please update fit-common first."
        exit 1
    fi
fi

cd ../..
exit 0
