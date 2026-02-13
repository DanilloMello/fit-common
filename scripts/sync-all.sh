#!/bin/bash
# sync-all.sh - DEPRECATED: Syncing is now handled by symlinks
# This script is kept for reference only
#
# See README.md for the new symlink-based approach

echo "DEPRECATED: This script is no longer needed."
echo "Docs are now symlinked: fit-api/.claude/docs -> fit-common/docs"
echo "Changes to fit-common/docs/ are instantly visible in both apps."
exit 0

# --- OLD IMPLEMENTATION (ARCHIVED) ---
set -e
BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Syncing ConnectHealth docs to repos..."

# Sync to fit-api
if [ -d "$BASE/../fit-api" ]; then
    mkdir -p "$BASE/../fit-api/docs"
    cp -r "$BASE/common"/* "$BASE/../fit-api/docs/"
    cp "$BASE/fit-api"/*.md "$BASE/../fit-api/docs/"
    cp "$BASE/skills/fit-api/SKILL.md" "$BASE/../fit-api/docs/SKILL.md"
    echo "fit-api synced"
fi

# Sync to fit-mobile
if [ -d "$BASE/../fit-mobile" ]; then
    mkdir -p "$BASE/../fit-mobile/docs"
    cp -r "$BASE/common"/* "$BASE/../fit-mobile/docs/"
    cp "$BASE/fit-mobile"/*.md "$BASE/../fit-mobile/docs/"
    cp "$BASE/skills/fit-mobile/SKILL.md" "$BASE/../fit-mobile/docs/SKILL.md"
    echo "fit-mobile synced"
fi

echo "Done!"
