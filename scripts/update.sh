#!/bin/bash
# CalcX Advanced Update Script
# Automatically updates CalcX Advanced to the latest version from GitHub

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Repository information
REPO_URL="https://github.com/genesisgzdev/calcx-advanced.git"
INSTALL_DIR="$HOME/.calcx-advanced"
VERSION_FILE="VERSION"

echo -e "${BLUE}========================================${RESET}"
echo -e "${BLUE}  CalcX Advanced Update Utility${RESET}"
echo -e "${BLUE}========================================${RESET}\n"

# Check if git is installed
if ! command -v git >/dev/null 2>&1; then
    echo -e "${RED}✗ Error: git is not installed${RESET}"
    echo "Please install git and try again"
    exit 1
fi

# Detect installation directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}Current installation:${RESET} $PROJECT_ROOT"

# Check if we're in a git repository
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo -e "${YELLOW}⚠ Warning: Not a git repository${RESET}"
    echo "This installation was not cloned from git."
    echo "Please reinstall using:"
    echo "  git clone $REPO_URL"
    exit 1
fi

# Get current version
if [ -f "$PROJECT_ROOT/$VERSION_FILE" ]; then
    CURRENT_VERSION=$(cat "$PROJECT_ROOT/$VERSION_FILE")
    echo -e "${BLUE}Current version:${RESET} $CURRENT_VERSION"
else
    echo -e "${YELLOW}⚠ Warning: Version file not found${RESET}"
    CURRENT_VERSION="unknown"
fi

# Save current branch
CURRENT_BRANCH=$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
echo -e "${BLUE}Current branch:${RESET} $CURRENT_BRANCH"

# Check for uncommitted changes
if ! git -C "$PROJECT_ROOT" diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "${YELLOW}⚠ Warning: You have uncommitted changes${RESET}"
    read -p "Do you want to stash your changes? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git -C "$PROJECT_ROOT" stash save "Auto-stash before update $(date +%Y-%m-%d_%H:%M:%S)"
        echo -e "${GREEN}✓ Changes stashed${RESET}"
        STASHED=true
    else
        echo -e "${RED}✗ Update cancelled${RESET}"
        exit 1
    fi
fi

# Fetch latest changes
echo -e "\n${BLUE}Fetching updates from repository...${RESET}"
if git -C "$PROJECT_ROOT" fetch origin; then
    echo -e "${GREEN}✓ Fetch successful${RESET}"
else
    echo -e "${RED}✗ Failed to fetch updates${RESET}"
    exit 1
fi

# Check if updates are available
LOCAL_HASH=$(git -C "$PROJECT_ROOT" rev-parse HEAD)
REMOTE_HASH=$(git -C "$PROJECT_ROOT" rev-parse origin/$CURRENT_BRANCH)

if [ "$LOCAL_HASH" = "$REMOTE_HASH" ]; then
    echo -e "\n${GREEN}✓ Already up to date!${RESET}"
    echo "No updates available."

    # Restore stash if we stashed
    if [ "$STASHED" = true ]; then
        git -C "$PROJECT_ROOT" stash pop
        echo -e "${GREEN}✓ Stashed changes restored${RESET}"
    fi
    exit 0
fi

# Show what will be updated
echo -e "\n${YELLOW}Updates available:${RESET}"
git -C "$PROJECT_ROOT" log --oneline HEAD..origin/$CURRENT_BRANCH | head -5

# Confirm update
echo ""
read -p "Do you want to update? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Update cancelled${RESET}"

    # Restore stash if we stashed
    if [ "$STASHED" = true ]; then
        git -C "$PROJECT_ROOT" stash pop
        echo -e "${GREEN}✓ Stashed changes restored${RESET}"
    fi
    exit 0
fi

# Perform update
echo -e "\n${BLUE}Updating CalcX Advanced...${RESET}"
if git -C "$PROJECT_ROOT" pull origin "$CURRENT_BRANCH"; then
    echo -e "${GREEN}✓ Update successful${RESET}"
else
    echo -e "${RED}✗ Update failed${RESET}"
    exit 1
fi

# Get new version
if [ -f "$PROJECT_ROOT/$VERSION_FILE" ]; then
    NEW_VERSION=$(cat "$PROJECT_ROOT/$VERSION_FILE")
    echo -e "${GREEN}Updated to version:${RESET} $NEW_VERSION"
fi

# Restore stash if we stashed
if [ "$STASHED" = true ]; then
    echo -e "\n${BLUE}Restoring your changes...${RESET}"
    if git -C "$PROJECT_ROOT" stash pop; then
        echo -e "${GREEN}✓ Stashed changes restored${RESET}"
    else
        echo -e "${YELLOW}⚠ Warning: Could not auto-restore changes${RESET}"
        echo "Your changes are still in the stash. Use 'git stash pop' to restore them manually."
    fi
fi

# Make scripts executable
echo -e "\n${BLUE}Setting permissions...${RESET}"
chmod +x "$PROJECT_ROOT/calcx.sh" 2>/dev/null || true
chmod +x "$PROJECT_ROOT"/src/*.sh 2>/dev/null || true
chmod +x "$PROJECT_ROOT"/lib/*.sh 2>/dev/null || true
chmod +x "$PROJECT_ROOT"/scripts/*.sh 2>/dev/null || true
echo -e "${GREEN}✓ Permissions updated${RESET}"

# Check dependencies
echo -e "\n${BLUE}Checking dependencies...${RESET}"
DEPS_OK=true

if ! command -v bc >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ bc not found (recommended for calculations)${RESET}"
    DEPS_OK=false
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ python3 not found (required for advanced features)${RESET}"
    DEPS_OK=false
fi

if ! command -v zenity >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ zenity not found (required for GUI mode)${RESET}"
    DEPS_OK=false
fi

if [ "$DEPS_OK" = true ]; then
    echo -e "${GREEN}✓ All dependencies satisfied${RESET}"
else
    echo -e "\n${YELLOW}Some dependencies are missing.${RESET}"
    echo "Run './scripts/install.sh' to install missing dependencies."
fi

# Summary
echo -e "\n${GREEN}========================================${RESET}"
echo -e "${GREEN}  Update Complete!${RESET}"
echo -e "${GREEN}========================================${RESET}"

if [ "$CURRENT_VERSION" != "unknown" ] && [ -n "$NEW_VERSION" ] && [ "$CURRENT_VERSION" != "$NEW_VERSION" ]; then
    echo -e "Updated from ${YELLOW}$CURRENT_VERSION${RESET} to ${GREEN}$NEW_VERSION${RESET}"
fi

echo -e "\nYou can now run CalcX Advanced with:"
echo -e "  ${BLUE}calcx${RESET}  (if installed globally)"
echo -e "  ${BLUE}./calcx.sh${RESET}  (from installation directory)"

exit 0
