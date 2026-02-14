#!/bin/bash
# post-checkout hook - Update fit-common when switching branches

# Check if .claude/common exists
if [ ! -d ".claude/common" ]; then
    exit 0
fi

echo ""
echo "🔄 Checking fit-common documentation status..."

cd .claude/common

# Fetch latest
git fetch origin main 2>/dev/null

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main 2>/dev/null || echo "$LOCAL")

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "⚠️  fit-common is outdated. Updating to latest version..."
    git merge origin/main --ff-only 2>/dev/null || {
        echo "❌ Could not auto-update fit-common (conflicts or diverged)"
        echo "Please manually update:"
        echo "  cd .claude/common && git pull origin main"
        cd ../..
        exit 0
    }
    echo "✅ fit-common updated to latest version"
else
    echo "✅ fit-common is up-to-date"
fi

cd ../..
echo ""
exit 0
