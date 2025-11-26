#!/usr/bin/env bash
# Common functions and variables for R2R scripts

set -euo pipefail

# Load environment variables from .claude/config/.env
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${CLAUDE_DIR}/config/.env"

if [ -f "$ENV_FILE" ]; then
    export $(cat "$ENV_FILE" | grep -v '^#' | xargs)
fi

R2R_BASE_URL="${R2R_BASE_URL:-https://api.136-119-36-216.nip.io}"
API_KEY="${API_KEY:-}"

if [ -z "$API_KEY" ]; then
    echo "Error: API_KEY not set in .env file" >&2
    exit 1
fi

# Default settings
export DEFAULT_LIMIT=3
export DEFAULT_MAX_TOKENS=4000
export DEFAULT_MODE="research"
export DEFAULT_SEARCH_STRATEGY="vanilla"  # vanilla, rag_fusion, hyde

# Colors for output
export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export YELLOW='\033[1;33m'
export RED='\033[0;31m'
export NC='\033[0m' # No Color

# Helper functions for output (only actively used functions)
print_error() {
    echo -e "${RED}✗ $1${NC}" >&2
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}
