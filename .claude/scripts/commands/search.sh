#!/usr/bin/env bash
# R2R Search Command
# Hybrid search (semantic + fulltext)

source "$(dirname "$0")/../lib/common.sh"

r2r_search() {
    local query="$1"
    local limit="${2:-$DEFAULT_LIMIT}"
    local json_output="${3:-false}"
    local verbose="${4:-false}"

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/retrieval/search" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -d "{\"query\":\"${query}\",\"limit\":${limit},\"search_settings\":{\"use_hybrid_search\":true}}")

    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return
    fi

    if [ "$verbose" = true ]; then
        echo "$response" | jq -r '.results.chunk_search_results[] |
            "Score: \(.score | tonumber | . * 100 | round / 100)\n" +
            "Document ID: \(.document_id)\n" +
            "Chunk ID: \(.id[:8])\n" +
            "Title: \(.metadata.title // "Unknown")\n" +
            "Collection IDs: \(.collection_ids | join(", "))\n" +
            "Text:\n\(.text)\n" +
            "---"'
    else
        echo "$response" | jq -r '.results.chunk_search_results[] |
            "Score: \(.score | tonumber | . * 100 | round / 100)\n" +
            "Doc: \(.metadata.title // "Unknown") [\(.id[:8])]\n" +
            "\(.text)\n" +
            "---"'
    fi
}

# If executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    parse_flags "$@"
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <query> [limit] [--json] [--verbose]" >&2
        exit 1
    fi
    r2r_search "$1" "${2:-$DEFAULT_LIMIT}" "$JSON_OUTPUT" "$VERBOSE"
fi
