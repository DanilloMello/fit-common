#!/bin/bash
# post-merge hook - Auto-update fit-common after git pull

echo ""
echo "📥 Updating fit-common documentation..."

if git submodule update --remote .claude/common --merge 2>/dev/null; then
    echo "✅ fit-common updated to latest version"
else
    echo "⚠️  Could not update fit-common (may not exist yet)"
fi

echo ""
