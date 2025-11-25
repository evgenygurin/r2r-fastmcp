#!/usr/bin/env bash
# R2R RAG Command
# RAG query with generation

source "$(dirname "$0")/../lib/common.sh"

r2r_rag() {
    local query="$1"
    local max_tokens="${2:-$DEFAULT_MAX_TOKENS}"
    local json_output="${3:-false}"

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/retrieval/rag" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -d "{\"query\":\"${query}\",\"search_settings\":{\"use_hybrid_search\":true,\"search_strategy\":\"${DEFAULT_SEARCH_STRATEGY}\"},\"rag_generation_config\":{\"max_tokens\":${max_tokens}}}")

    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
    else
        echo "$response" | jq -r '.results.generated_answer'
    fi
}

# If executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    parse_flags "$@"
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <query> [max_tokens] [--json]" >&2
        exit 1
    fi
    r2r_rag "$1" "${2:-$DEFAULT_MAX_TOKENS}" "$JSON_OUTPUT"
fi
