#!/bin/bash

# update-version.sh
# Updates framework version across all files
# Usage: bash migration/update-version.sh <new-version>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if version argument provided
if [ -z "$1" ]; then
  echo -e "${RED}Error: Version argument required${NC}"
  echo ""
  echo "Usage: bash migration/update-version.sh <version>"
  echo "Example: bash migration/update-version.sh 2.5.1"
  echo ""
  exit 1
fi

NEW_VERSION="$1"

# Validate version format (x.y.z)
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo -e "${RED}Error: Invalid version format${NC}"
  echo "Expected format: x.y.z (e.g., 2.5.1)"
  echo "Got: $NEW_VERSION"
  exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}📝 Updating Framework Version${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "New version: v$NEW_VERSION"
echo ""

# Detect OS for sed compatibility
if [[ "$OSTYPE" == "darwin"* ]]; then
  SED_INPLACE="sed -i ''"
else
  SED_INPLACE="sed -i"
fi

# Function to update version in file
update_file() {
  local file="$1"
  local description="$2"

  if [ ! -f "$file" ]; then
    echo -e "${YELLOW}⚠️  Skipping $description (file not found)${NC}"
    return
  fi

  # Extract current version
  OLD_VERSION=$(grep -o "v[0-9]\+\.[0-9]\+\.[0-9]\+" "$file" | head -1 | sed 's/v//')

  if [ -z "$OLD_VERSION" ]; then
    echo -e "${YELLOW}⚠️  Could not extract version from $description${NC}"
    return
  fi

  # Update version
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/v$OLD_VERSION/v$NEW_VERSION/g" "$file"
    sed -i '' "s/\"$OLD_VERSION\"/\"$NEW_VERSION\"/g" "$file"
  else
    sed -i "s/v$OLD_VERSION/v$NEW_VERSION/g" "$file"
    sed -i "s/\"$OLD_VERSION\"/\"$NEW_VERSION\"/g" "$file"
  fi

  echo -e "${GREEN}✅ Updated $description${NC} (v$OLD_VERSION → v$NEW_VERSION)"
}

# Update all files
update_file "CLAUDE.md" "CLAUDE.md"
update_file ".claude/protocols/cold-start.md" "Cold Start Protocol"
update_file ".claude/protocols/completion.md" "Completion Protocol"
update_file "migration/build-distribution.sh" "Build Distribution Script"
update_file "package.json" "package.json"

# Update migration templates
if [ -f "migration/CLAUDE.production.md" ]; then
  update_file "migration/CLAUDE.production.md" "Production CLAUDE.md template"
fi

if [ -f "migration/CLAUDE.template.md" ]; then
  update_file "migration/CLAUDE.template.md" "CLAUDE.md template"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Version update complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Updated to: v$NEW_VERSION"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Validate release: bash migration/validate-release.sh"
echo "  3. Update CHANGELOG.md manually"
echo "  4. Commit changes: git commit -am 'chore: Bump version to v$NEW_VERSION'"
echo "  5. Create release: bash migration/create-release.sh"
echo ""
