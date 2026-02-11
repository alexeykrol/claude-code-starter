#!/bin/bash

# create-release.sh
# Automated release script for Claude Code Starter framework
# Usage: bash migration/create-release.sh [--skip-validation]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}🚀 Claude Code Starter Framework Release${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Parse arguments
SKIP_VALIDATION=false
if [ "$1" = "--skip-validation" ]; then
  SKIP_VALIDATION=true
  echo -e "${YELLOW}⚠️  Skipping validation (--skip-validation flag)${NC}"
  echo ""
fi

# Step 1: Extract version from CLAUDE.md
echo -e "${BLUE}Step 1:${NC} Extracting version from CLAUDE.md..."
if [ ! -f "CLAUDE.md" ]; then
  echo -e "${RED}Error: CLAUDE.md not found${NC}"
  exit 1
fi

VERSION=$(grep "Framework: Claude Code Starter v" CLAUDE.md | tail -1 | sed 's/.*v\([0-9.]*\).*/\1/')

if [ -z "$VERSION" ]; then
  echo -e "${RED}Error: Could not extract version from CLAUDE.md${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Version: v$VERSION${NC}"
echo ""

# Step 2: Validate release
if [ "$SKIP_VALIDATION" = false ]; then
  echo -e "${BLUE}Step 2:${NC} Validating release..."
  if ! bash migration/validate-release.sh; then
    echo ""
    echo -e "${RED}Validation failed. Please fix errors before releasing.${NC}"
    exit 1
  fi
  echo ""
else
  echo -e "${YELLOW}Step 2: Skipped (validation)${NC}"
  echo ""
fi

# Step 3: Check for uncommitted changes
echo -e "${BLUE}Step 3:${NC} Checking git status..."
if ! git diff --quiet || ! git diff --staged --quiet; then
  echo -e "${YELLOW}⚠️  Warning: You have uncommitted changes${NC}"
  echo ""
  git status --short
  echo ""
  read -p "Continue with release? (y/N) " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Release cancelled."
    exit 1
  fi
else
  echo -e "${GREEN}✅ Working tree clean${NC}"
fi
echo ""

# Step 4: Check if tag already exists
echo -e "${BLUE}Step 4:${NC} Checking if tag v$VERSION exists..."
if git rev-parse "v$VERSION" >/dev/null 2>&1; then
  echo -e "${YELLOW}⚠️  Tag v$VERSION already exists${NC}"
  echo ""
  read -p "Delete existing tag and re-release? (y/N) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting local tag..."
    git tag -d "v$VERSION"

    echo "Deleting remote tag..."
    git push origin ":refs/tags/v$VERSION" 2>/dev/null || true

    echo "Deleting GitHub release..."
    gh release delete "v$VERSION" -y 2>/dev/null || true

    echo -e "${GREEN}✅ Existing tag and release deleted${NC}"
  else
    echo "Release cancelled."
    exit 1
  fi
else
  echo -e "${GREEN}✅ Tag does not exist yet${NC}"
fi
echo ""

# Step 5: Build distribution
echo -e "${BLUE}Step 5:${NC} Building distribution..."
bash migration/build-distribution.sh

if [ ! -f "dist-release/init-project.sh" ]; then
  echo -e "${RED}Error: Distribution build failed${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Distribution built successfully${NC}"
echo ""

# Step 6: Copy entry files to distribution
echo -e "${BLUE}Step 6:${NC} Copying entry files to distribution..."
cp CLAUDE.md dist-release/CLAUDE.md
cp AGENTS.md dist-release/AGENTS.md
echo -e "${GREEN}✅ CLAUDE.md and AGENTS.md copied${NC}"
echo ""

# Step 7: Verify distribution artifacts
echo -e "${BLUE}Step 7:${NC} Verifying distribution artifacts..."
REQUIRED_FILES=(
  "dist-release/init-project.sh"
  "dist-release/framework.tar.gz"
  "dist-release/framework-commands.tar.gz"
  "dist-release/quick-update.sh"
  "dist-release/CLAUDE.md"
  "dist-release/AGENTS.md"
)

MISSING=false
for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo -e "${RED}❌ Missing: $file${NC}"
    MISSING=true
  else
    echo -e "${GREEN}✅ Found: $file${NC}"
  fi
done

if [ "$MISSING" = true ]; then
  echo ""
  echo -e "${RED}Error: Missing required distribution files${NC}"
  exit 1
fi
echo ""

# Step 8: Create git tag
echo -e "${BLUE}Step 8:${NC} Creating git tag v$VERSION..."
git tag -a "v$VERSION" -m "Release v$VERSION"
echo -e "${GREEN}✅ Tag created${NC}"
echo ""

# Step 9: Push tag to remote
echo -e "${BLUE}Step 9:${NC} Pushing tag to remote..."
git push origin "v$VERSION"
echo -e "${GREEN}✅ Tag pushed${NC}"
echo ""

# Step 10: Create GitHub release
echo -e "${BLUE}Step 10:${NC} Creating GitHub release..."

# Check if CHANGELOG has release notes
if grep -q "## \[$VERSION\]" CHANGELOG.md; then
  # Extract release notes from CHANGELOG
  RELEASE_NOTES=$(awk "/## \[$VERSION\]/,/## \[[0-9]/" CHANGELOG.md | sed '1d;$d')
  echo "$RELEASE_NOTES" > /tmp/release-notes-$VERSION.md
  NOTES_FILE="/tmp/release-notes-$VERSION.md"
else
  # Use default release notes
  echo "Release v$VERSION" > /tmp/release-notes-$VERSION.md
  NOTES_FILE="/tmp/release-notes-$VERSION.md"
fi

# Create release with artifacts
gh release create "v$VERSION" \
  --title "Claude Code Starter v$VERSION" \
  --notes-file "$NOTES_FILE" \
  dist-release/init-project.sh \
  dist-release/framework.tar.gz \
  dist-release/framework-commands.tar.gz \
  dist-release/quick-update.sh \
  dist-release/CLAUDE.md \
  dist-release/AGENTS.md

echo -e "${GREEN}✅ GitHub release created${NC}"
echo ""

# Cleanup
rm -f /tmp/release-notes-$VERSION.md

# Final summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Release v$VERSION completed successfully!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Release URL: https://github.com/alexeykrol/claude-code-starter/releases/tag/v$VERSION"
echo ""
echo "Distribution artifacts:"
echo "  • init-project.sh"
echo "  • framework.tar.gz"
echo "  • framework-commands.tar.gz"
echo "  • quick-update.sh"
echo "  • CLAUDE.md"
echo "  • AGENTS.md"
echo ""
echo "Next steps:"
echo "  1. Verify release on GitHub"
echo "  2. Test installation on host project"
echo "  3. Announce release (if applicable)"
echo ""
