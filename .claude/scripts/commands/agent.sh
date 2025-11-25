#!/usr/bin/env bash
# R2R Agent Command
# Multi-turn agent with research/rag modes

source "$(dirname "$0")/../lib/common.sh"

# Agent-specific flags
AGENT_MODE=""
CONVERSATION_ID=""
MAX_TOKENS=""
EXTENDED_THINKING=false

r2r_agent() {
    local query="$1"
    local mode="${2:-$DEFAULT_MODE}"
    local conversation_id="${3:-}"
    local max_tokens="${4:-$DEFAULT_MAX_TOKENS}"
    local json_output="${5:-false}"
    local extended_thinking="${6:-false}"

    # Build message object
    local message=$(jq -n \
        --arg content "$query" \
        '{role: "user", content: $content}')

    # Build RAG generation config with optional extended thinking
    local rag_config=$(jq -n \
        --argjson tokens "$max_tokens" \
        '{max_tokens: $tokens}')

    if [ "$extended_thinking" = "true" ]; then
        rag_config=$(echo "$rag_config" | jq \
            '. + {extended_thinking: true, thinking_budget: 4096, temperature: 1}')
    fi

    # Build search settings
    local search_settings=$(jq -n \
        '{use_hybrid_search: true}')

    # Build base payload
    local payload=$(jq -n \
        --argjson msg "$message" \
        --arg mode "$mode" \
        --argjson search_settings "$search_settings" \
        --argjson rag_config "$rag_config" \
        '{
            message: $msg,
            mode: $mode,
            search_mode: "advanced",
            search_settings: $search_settings,
            rag_generation_config: $rag_config
        }')

    # Add tools based on mode
    if [ "$mode" = "rag" ]; then
        payload=$(echo "$payload" | jq \
            '.rag_tools = ["search_file_knowledge","search_file_descriptions","get_file_content","web_search","web_scrape"]')
    elif [ "$mode" = "research" ]; then
        payload=$(echo "$payload" | jq \
            '.research_tools = ["rag","reasoning","critique","python_executor"]')
    fi

    # Add conversation_id if provided
    if [ -n "$conversation_id" ]; then
        payload=$(echo "$payload" | jq \
            --arg cid "$conversation_id" \
            '. + {conversation_id: $cid}')
    fi

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/retrieval/agent" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -d "$payload")

    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
    else
        # Extract conversation_id for follow-up
        local new_conv_id=$(echo "$response" | jq -r '.results.conversation_id // empty')
        if [ -n "$new_conv_id" ] && [ -z "$conversation_id" ]; then
            # Output conversation_id to stderr without colors for easy copying
            echo "Conversation ID: $new_conv_id" >&2
            echo "" >&2
        fi

        # Extract and display the agent's response
        local agent_response=$(echo "$response" | jq -r '.results.messages[-1].content // empty')

        if [ -z "$agent_response" ]; then
            echo "$response" | jq '.'
        else
            echo "$agent_response"
        fi
    fi
}

# Show help
show_help() {
    cat << EOF
R2R Agent Command

USAGE:
    agent <query> [mode] [conversation_id] [max_tokens] [--json] [--thinking]

    Or with named flags:
    agent <query> [options]

POSITIONAL PARAMETERS (legacy):
    query               The question or instruction for the agent
    mode                Agent mode: research or rag (default: $DEFAULT_MODE)
    conversation_id     Continue existing conversation (optional)
    max_tokens          Max tokens for generation (default: $DEFAULT_MAX_TOKENS)

OPTIONS (named flags):
    --mode <name>               Agent mode: research or rag (default: $DEFAULT_MODE)
    --conversation <id>         Continue existing conversation
    --max-tokens <n>            Max tokens for generation (default: $DEFAULT_MAX_TOKENS)
    --thinking                  Enable extended thinking (research mode)
    --json                      Output raw JSON

MODES:
    research (default)          Multi-step reasoning with tools: rag, reasoning, critique, python_executor
    rag                         Document-focused with tools: search, get_content, web_search

EXTENDED THINKING:
    --thinking flag enables deep reasoning with:
    - thinking_budget: 4096 tokens
    - temperature: 1 (creative exploration)
    - Step-by-step thought process

MULTI-TURN CONVERSATIONS:
    The agent returns a conversation_id on first query.
    Use it as 3rd parameter or --conversation <id> to continue.

EXAMPLES:
    # Basic agent query (research mode, legacy style)
    agent "What is R2R?"

    # RAG mode (legacy style)
    agent "What is R2R?" rag

    # RAG mode with named flags
    agent "Explain hybrid search" --mode rag

    # Research mode with extended thinking
    agent "Analyze R2R architecture" --mode research --thinking

    # Continue conversation (legacy style)
    agent "What about FastMCP?" rag abc123-def456

    # Continue conversation (named flags)
    agent "What about FastMCP?" --mode rag --conversation abc123-def456

    # Custom token limit
    agent "Comprehensive guide" rag "" 8000
    agent "Comprehensive guide" --max-tokens 8000

    # JSON output
    agent "test" rag "" "" --json
    agent "test" --json
EOF
}

# If executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Parse named flags first, they set global variables
    ARGS=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --mode)
                AGENT_MODE="$2"
                shift 2
                ;;
            --conversation)
                CONVERSATION_ID="$2"
                shift 2
                ;;
            --max-tokens)
                MAX_TOKENS="$2"
                shift 2
                ;;
            --thinking)
                EXTENDED_THINKING=true
                shift
                ;;
            --json)
                JSON_OUTPUT=true
                shift
                ;;
            help|--help|-h)
                show_help
                exit 0
                ;;
            *)
                ARGS+=("$1")
                shift
                ;;
        esac
    done

    # Check if we have a query
    if [ ${#ARGS[@]} -lt 1 ]; then
        show_help
        exit 0
    fi

    # Build parameters: merge positional and named flags
    query="${ARGS[0]}"
    mode="${AGENT_MODE:-${ARGS[1]:-$DEFAULT_MODE}}"
    conversation_id="${CONVERSATION_ID:-${ARGS[2]:-}}"
    max_tokens="${MAX_TOKENS:-${ARGS[3]:-$DEFAULT_MAX_TOKENS}}"

    # Convert boolean flags
    json_output="false"
    [ "$JSON_OUTPUT" = true ] && json_output="true"

    extended_thinking="false"
    [ "$EXTENDED_THINKING" = true ] && extended_thinking="true"

    r2r_agent "$query" "$mode" "$conversation_id" "$max_tokens" "$json_output" "$extended_thinking"
fi
