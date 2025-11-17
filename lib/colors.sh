#!/bin/bash
# Color definitions for CalcX Advanced

RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
BOLD_CYAN='\033[1;36m'
BOLD_GREEN='\033[1;32m'
BOLD_RED='\033[1;31m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'

print_success() { echo -e "${BOLD_GREEN}✓${RESET} $1"; }
print_error() { echo -e "${BOLD_RED}✗${RESET} $1"; }
print_warning() { echo -e "${BOLD_YELLOW}⚠${RESET} $1"; }
print_info() { echo -e "${BOLD_BLUE}ℹ${RESET} $1"; }

export -f print_success print_error print_warning print_info
