#!/usr/bin/env bash
# R2R API Client using curl
# Enhanced version with hybrid search, multiple modes, and advanced features

set -euo pipefail

# Load environment variables from .claude/config/.env
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
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
DEFAULT_LIMIT=3
DEFAULT_MAX_TOKENS=4000
DEFAULT_MODE="research"
DEFAULT_SEARCH_STRATEGY="vanilla"  # vanilla, rag_fusion, hyde

# Parse flags
parse_flags() {
    JSON_OUTPUT=false
    VERBOSE=false
    EXTENDED_THINKING=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --json) JSON_OUTPUT=true; shift ;;
            --verbose) VERBOSE=true; shift ;;
            --thinking) EXTENDED_THINKING=true; shift ;;
            *) break ;;
        esac
    done
}

# Search function with hybrid search
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

# RAG function with hybrid search and strategy
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

# Agent function with modes and conversation support
r2r_agent() {
    local query="$1"
    local mode="${2:-$DEFAULT_MODE}"
    local conversation_id="${3:-}"
    local max_tokens="${4:-$DEFAULT_MAX_TOKENS}"
    local json_output="${5:-false}"
    local extended_thinking="${6:-false}"

    local conv_param=""
    if [ -n "$conversation_id" ]; then
        conv_param=",\"conversation_id\":\"${conversation_id}\""
    fi

    # Select tools based on mode
    local tools_param=""
    if [ "$mode" = "rag" ]; then
        tools_param=",\"rag_tools\":[\"search_file_knowledge\",\"search_file_descriptions\",\"get_file_content\",\"web_search\",\"web_scrape\"]"
    elif [ "$mode" = "research" ]; then
        tools_param=",\"research_tools\":[\"rag\",\"reasoning\",\"critique\",\"python_executor\"]"
    fi

    # Configure generation settings with optional extended thinking
    local gen_config="{\"max_tokens\":${max_tokens}"
    if [ "$extended_thinking" = "true" ]; then
        gen_config="${gen_config},\"extended_thinking\":true,\"thinking_budget\":4096,\"temperature\":1"
    fi
    gen_config="${gen_config}}"

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/retrieval/agent" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -d "{\"message\":{\"role\":\"user\",\"content\":\"${query}\"},\"mode\":\"${mode}\",\"search_mode\":\"advanced\",\"search_settings\":{\"use_hybrid_search\":true},\"rag_generation_config\":${gen_config}${tools_param}${conv_param}}")

    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
    else
        # Extract conversation_id for follow-up
        local new_conv_id=$(echo "$response" | jq -r '.conversation_id // empty')
        if [ -n "$new_conv_id" ] && [ -z "$conversation_id" ]; then
            echo "[Conversation ID: $new_conv_id]" >&2
            echo "" >&2
        fi

        echo "$response" | jq -r '.results.messages[0].content'
    fi
}

# Help function
show_help() {
    cat << EOF
R2R API Client - Enhanced Edition

USAGE:
    $0 <command> [options] <query> [parameters]

COMMANDS:
    search <query> [limit]              Search knowledge base (hybrid search)
    rag <query> [max_tokens]            RAG query with generation
    agent <query> [mode] [conv_id]     Agent conversation with tools

GLOBAL FLAGS:
    --json                              Output raw JSON response
    --verbose                           Show detailed metadata (search only)
    --thinking                          Enable extended thinking (agent only)

SEARCH:
    $0 search "What is machine learning?" 5
    $0 search "FastMCP decorators" 10 --verbose
    $0 search "neural networks" --json

    Parameters:
        query       - Search query (required)
        limit       - Number of results (default: $DEFAULT_LIMIT)

RAG:
    $0 rag "Explain R2R architecture"
    $0 rag "How to use FastMCP?" 12000
    $0 rag "What is Claude Code?" --json

    Parameters:
        query       - RAG query (required)
        max_tokens  - Maximum tokens in response (default: $DEFAULT_MAX_TOKENS)

AGENT:
    $0 agent "What is DeepSeek R1?"
    $0 agent "Simple query" rag
    $0 agent "Follow-up question" research <conversation_id>
    $0 agent "Complex analysis" research "" --json
    $0 agent "Deep philosophical question" research "" "" --thinking

    Parameters:
        query       - Agent query (required)
        mode        - Agent mode: 'rag' or 'research' (default: research)
        conv_id     - Conversation ID for multi-turn (optional)
        max_tokens  - Maximum tokens in response (default: $DEFAULT_MAX_TOKENS)

    Modes:
        research    - Advanced mode with reasoning, critique, and code execution (DEFAULT)
                      Tools: rag, reasoning, critique, python_executor
        rag         - Standard RAG with knowledge base search
                      Tools: search_file_knowledge, search_file_descriptions,
                             get_file_content, web_search, web_scrape

    Extended Thinking:
        --thinking  - Enables extended reasoning with 4096 token thinking budget
                      Best for complex analysis, philosophical questions,
                      multi-step reasoning, and deep exploration

EXAMPLES:
    # Simple search with 5 results
    $0 search "machine learning basics" 5

    # Verbose search showing all metadata
    $0 search "FastMCP tools" 3 --verbose

    # RAG with extended response
    $0 rag "Explain R2R collections" 10000

    # Research mode agent (default)
    $0 agent "What are the implications of AI?"

    # RAG mode agent
    $0 agent "Simple factual question" rag

    # Extended thinking for deep analysis
    $0 agent "Analyze the philosophical implications of RAG systems" research "" "" --thinking

    # Multi-turn conversation
    response1=\$($0 agent "What is R2R?" --json)
    conv_id=\$(echo "\$response1" | jq -r '.conversation_id')
    $0 agent "Tell me more" research "\$conv_id"

    # Extended thinking with conversation context
    $0 agent "Deep analysis question" research "\$conv_id" "" --thinking

    # JSON output for processing
    $0 search "query" --json | jq '.results.chunk_search_results[0].score'

FEATURES:
    ✓ Hybrid search (semantic + fulltext) for better relevance
    ✓ Extended responses up to 8000 tokens by default
    ✓ Research mode with reasoning, critique, and code execution
    ✓ Extended thinking mode with 4096 token reasoning budget
    ✓ Multi-turn conversations with context preservation
    ✓ RAG mode with comprehensive knowledge base tools
    ✓ Detailed metadata in verbose mode
    ✓ JSON output for scripting and automation

EOF
}

# Main dispatcher
COMMAND="${1:-help}"

case "$COMMAND" in
    search)
        shift
        parse_flags "$@"
        if [ $# -lt 1 ]; then
            echo "Error: search requires a query" >&2
            echo "Usage: $0 search <query> [limit] [--json] [--verbose]" >&2
            exit 1
        fi
        r2r_search "$1" "${2:-$DEFAULT_LIMIT}" "$JSON_OUTPUT" "$VERBOSE"
        ;;

    rag)
        shift
        parse_flags "$@"
        if [ $# -lt 1 ]; then
            echo "Error: rag requires a query" >&2
            echo "Usage: $0 rag <query> [max_tokens] [--json]" >&2
            exit 1
        fi
        r2r_rag "$1" "${2:-$DEFAULT_MAX_TOKENS}" "$JSON_OUTPUT"
        ;;

    agent)
        shift
        parse_flags "$@"
        if [ $# -lt 1 ]; then
            echo "Error: agent requires a query" >&2
            echo "Usage: $0 agent <query> [mode] [conversation_id] [max_tokens] [--json] [--thinking]" >&2
            exit 1
        fi
        r2r_agent "$1" "${2:-$DEFAULT_MODE}" "${3:-}" "${4:-$DEFAULT_MAX_TOKENS}" "$JSON_OUTPUT" "$EXTENDED_THINKING"
        ;;

    help|--help|-h)
        show_help
        ;;

    *)
        echo "Error: Unknown command '$COMMAND'" >&2
        echo "Run '$0 help' for usage information" >&2
        exit 1
        ;;
esac
