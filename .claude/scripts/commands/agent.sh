#!/usr/bin/env bash
# R2R Agent Command
# Multi-turn agent with research/rag modes

source "$(dirname "$0")/../lib/common.sh"

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

# If executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    parse_flags "$@"
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <query> [mode] [conversation_id] [max_tokens] [--json] [--thinking]" >&2
        exit 1
    fi
    r2r_agent "$1" "${2:-$DEFAULT_MODE}" "${3:-}" "${4:-$DEFAULT_MAX_TOKENS}" "$JSON_OUTPUT" "$EXTENDED_THINKING"
fi
