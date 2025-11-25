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

# Global flags
JSON_OUTPUT=false
VERBOSE=false
EXTENDED_THINKING=false

# Parse flags
parse_flags() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --json) JSON_OUTPUT=true; shift ;;
            --verbose) VERBOSE=true; shift ;;
            --thinking) EXTENDED_THINKING=true; shift ;;
            *) break ;;
        esac
    done
}
