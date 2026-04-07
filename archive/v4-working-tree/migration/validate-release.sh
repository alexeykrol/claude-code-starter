#!/bin/bash

# validate-release.sh
# Pre-release validation script for Claude Code Starter framework
# Checks version consistency across all framework files

set -e

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Pre-Release Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

# Function to report error
error() {
  echo -e "${RED}❌ $1${NC}"
  ERRORS=$((ERRORS + 1))
}

# Function to report success
success() {
  echo -e "${GREEN}✅ $1${NC}"
}

# Function to report warning
warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

# 1. Extract expected version from CLAUDE.md
echo "Step 1: Extracting version from CLAUDE.md..."
if [ ! -f "CLAUDE.md" ]; then
  error "CLAUDE.md not found"
  exit 1
fi

EXPECTED_VERSION=$(grep "Framework: Claude Code Starter v" CLAUDE.md | tail -1 | sed 's/.*v\([0-9.]*\).*/\1/')

if [ -z "$EXPECTED_VERSION" ]; then
  error "Could not extract version from CLAUDE.md"
  exit 1
fi

success "Expected version: v$EXPECTED_VERSION"
echo ""

# 2. Check active framework markers in CLAUDE.md
echo "Step 2: Checking active framework version markers in CLAUDE.md..."
# Validate only active markers, not historical references.
CLAUDE_VERSIONS=$(grep "Framework: Claude Code Starter v" CLAUDE.md | grep -o "v[0-9]\+\.[0-9]\+\.[0-9]\+" | sort -u)

INCONSISTENT=false
while IFS= read -r version; do
  version_num=$(echo "$version" | sed 's/v//')
  if [ "$version_num" != "$EXPECTED_VERSION" ]; then
    error "Found inconsistent version in CLAUDE.md: $version (expected: v$EXPECTED_VERSION)"
    INCONSISTENT=true
  fi
done <<< "$CLAUDE_VERSIONS"

if [ "$INCONSISTENT" = false ]; then
  success "All version references in CLAUDE.md are consistent"
fi
echo ""

# 3. Check cold-start-silent.md protocol
echo "Step 3: Checking .claude/protocols/cold-start-silent.md..."
if [ ! -f ".claude/protocols/cold-start-silent.md" ]; then
  warning ".claude/protocols/cold-start-silent.md not found (optional)"
else
  COLD_START_VERSION=$(grep "^\*\*Version:\*\*" .claude/protocols/cold-start-silent.md | head -1 | sed 's/.*Version:\*\* \([0-9.]*\).*/\1/')

  if [ -z "$COLD_START_VERSION" ]; then
    warning "Could not extract version from cold-start-silent.md"
  elif [ "$COLD_START_VERSION" != "$EXPECTED_VERSION" ]; then
    error "cold-start-silent.md version mismatch: $COLD_START_VERSION (expected: $EXPECTED_VERSION)"
  else
    success "cold-start-silent.md version matches: v$COLD_START_VERSION"
  fi
fi
echo ""

# 4. Check completion-silent.md protocol
echo "Step 4: Checking .claude/protocols/completion-silent.md..."
if [ ! -f ".claude/protocols/completion-silent.md" ]; then
  warning ".claude/protocols/completion-silent.md not found (optional)"
else
  COMPLETION_VERSION=$(grep "^\*\*Version:\*\*" .claude/protocols/completion-silent.md | head -1 | sed 's/.*Version:\*\* \([0-9.]*\).*/\1/')

  if [ -z "$COMPLETION_VERSION" ]; then
    warning "Could not extract version from completion-silent.md"
  elif [ "$COMPLETION_VERSION" != "$EXPECTED_VERSION" ]; then
    error "completion-silent.md version mismatch: $COMPLETION_VERSION (expected: $EXPECTED_VERSION)"
  else
    success "completion-silent.md version matches: v$COMPLETION_VERSION"
  fi
fi
echo ""

# 5. Check CHANGELOG.md
echo "Step 5: Checking CHANGELOG.md..."
if [ ! -f "CHANGELOG.md" ]; then
  warning "CHANGELOG.md not found"
else
  # CHANGELOG.md uses format "## [X.Y.Z]" without "v" prefix
  if grep -q "## \[$EXPECTED_VERSION\]" CHANGELOG.md; then
    success "CHANGELOG.md contains entry for v$EXPECTED_VERSION"
  else
    error "CHANGELOG.md missing entry for v$EXPECTED_VERSION"
  fi
fi
echo ""

# 6. Check package.json (if exists)
echo "Step 6: Checking package.json..."
if [ ! -f "package.json" ]; then
  warning "package.json not found (optional)"
else
  PACKAGE_VERSION=$(grep '"version"' package.json | head -1 | sed 's/.*"version": "\(.*\)".*/\1/')

  if [ -z "$PACKAGE_VERSION" ]; then
    warning "Could not extract version from package.json"
  elif [ "$PACKAGE_VERSION" != "$EXPECTED_VERSION" ]; then
    error "package.json version mismatch: $PACKAGE_VERSION (expected: $EXPECTED_VERSION)"
  else
    success "package.json version matches: v$PACKAGE_VERSION"
  fi
fi
echo ""

# 7. Check git tag
echo "Step 7: Checking git tags..."
CURRENT_TAG=$(git describe --tags --exact-match 2>/dev/null || echo "")

if [ -z "$CURRENT_TAG" ]; then
  warning "No git tag on current commit (expected: v$EXPECTED_VERSION)"
  warning "Create tag with: git tag v$EXPECTED_VERSION"
else
  TAG_VERSION=$(echo "$CURRENT_TAG" | sed 's/v//')
  if [ "$TAG_VERSION" != "$EXPECTED_VERSION" ]; then
    error "Git tag mismatch: $CURRENT_TAG (expected: v$EXPECTED_VERSION)"
  else
    success "Git tag matches: $CURRENT_TAG"
  fi
fi
echo ""

# 8. Check distribution files exist
echo "Step 8: Checking distribution files..."
MISSING_FILES=0

if [ ! -f "CLAUDE.md" ]; then
  error "Distribution file missing: CLAUDE.md"
  MISSING_FILES=$((MISSING_FILES + 1))
fi

if [ ! -f "AGENTS.md" ]; then
  error "Distribution file missing: AGENTS.md"
  MISSING_FILES=$((MISSING_FILES + 1))
fi

if [ ! -d ".codex" ]; then
  error "Distribution directory missing: .codex/"
  MISSING_FILES=$((MISSING_FILES + 1))
fi

if [ ! -f ".codex/commands/start.sh" ]; then
  error "Codex command missing: .codex/commands/start.sh"
  MISSING_FILES=$((MISSING_FILES + 1))
fi

if [ ! -f ".codex/commands/finish.sh" ]; then
  error "Codex command missing: .codex/commands/finish.sh"
  MISSING_FILES=$((MISSING_FILES + 1))
fi

if [ ! -f ".codex/commands/migration-router.sh" ]; then
  error "Codex command missing: .codex/commands/migration-router.sh"
  MISSING_FILES=$((MISSING_FILES + 1))
fi

if [ ! -f "security/initial-scan.sh" ]; then
  warning "Security script missing: security/initial-scan.sh"
fi

if [ ! -f "security/cleanup-dialogs.sh" ]; then
  warning "Security script missing: security/cleanup-dialogs.sh"
fi

if [ $MISSING_FILES -eq 0 ]; then
  success "All critical distribution files present"
fi
echo ""

# Final report
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ All validation checks passed for v$EXPECTED_VERSION${NC}"
  echo ""
  echo "Ready to release!"
  echo ""
  echo "Next steps:"
  echo "  1. Run: bash migration/build-distribution.sh"
  echo "  2. Create release: gh release create v$EXPECTED_VERSION ..."
  echo ""
  exit 0
else
  echo -e "${RED}❌ Validation failed with $ERRORS error(s)${NC}"
  echo ""
  echo "Please fix the errors above before releasing."
  echo ""
  exit 1
fi
