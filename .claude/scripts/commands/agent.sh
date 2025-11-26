#!/usr/bin/env bash
# R2R Agent Command
# Multi-turn agent with research/rag modes

source "$(dirname "$0")/../lib/common.sh"

# Print compact agent header (single line)
print_agent_header() {
    local mode="$1"
    local conv_id="$2"
    local is_new="$3"
    local search_count="$4"
    local thinking="$5"
    local tool_count="$6"

    local conv_status="🔵"  # continuing
    [ "$is_new" = "true" ] && conv_status="🟢"  # new

    local conv_short="${conv_id:0:8}"

    # Build info string
    local info=""
    if [ "$thinking" = "true" ]; then
        info=" | 🧠 thinking"
    elif [ -n "$search_count" ] && [ "$search_count" -gt 0 ]; then
        info=" | 📄 $search_count results"
    fi

    printf "🤖 R2R Agent | %-8s | %s conv:%s%s\n" "$mode" "$conv_status" "$conv_short" "$info"
}

# Print verbose header
print_agent_header_verbose() {
    local query="$1"
    local mode="$2"
    local conv_id="$3"
    local is_new="$4"
    local max_tokens="$5"
    local search_mode="$6"
    local tools="$7"

    echo "╭─ R2R Agent Request ─────────────────────────────────╮"
    printf "│ Query: %-46s │\n" "${query:0:46}"
    printf "│ Mode: %-47s │\n" "$mode"

    local conv_status="new"
    [ "$is_new" = "false" ] && conv_status="continuing"
    printf "│ Conversation: %-36s (%-4s) │\n" "$conv_id" "$conv_status"
    printf "│ Max tokens: %-41s │\n" "$max_tokens"
    printf "│ Search mode: %-40s │\n" "$search_mode"
    printf "│ Tools available: %-36s │\n" "${tools:0:36}"
    echo "╰─────────────────────────────────────────────────────╯"
    echo ""
}

# Print citations
print_citations() {
    local citations="$1"

    if [ -n "$citations" ]; then
        echo ""
        echo "📚 Sources:"
        echo "$citations"
    fi
}

# Print tool calls
print_tool_calls() {
    local tools="$1"

    if [ -n "$tools" ]; then
        echo ""
        echo "🛠️  Tools Used:"
        echo "$tools"
    fi
}

# Print compact stats footer (single line)
print_agent_stats() {
    local tool_count="$1"
    local citation_count="$2"
    local tokens="$3"

    # Build stats string with only non-zero values
    local parts=()

    [ "$tool_count" -gt 0 ] && parts+=("🛠️  $tool_count tools")
    [ "$citation_count" -gt 0 ] && parts+=("📚 $citation_count sources")
    [ "$tokens" != "N/A" ] && [ "$tokens" != "0" ] && parts+=("📊 $tokens tokens")

    # If no stats, don't print anything
    if [ ${#parts[@]} -eq 0 ]; then
        return
    fi

    echo ""
    # Join parts with " | "
    local IFS=" | "
    echo "${parts[*]}"
}

# Print verbose metadata footer
print_agent_metadata() {
    local conv_id="$1"
    local tool_details="$2"
    local citations="$3"
    local input_tokens="$4"
    local output_tokens="$5"
    local thinking_tokens="$6"

    echo ""
    echo "╭─ Response Metadata ─────────────────────────────────╮"
    printf "│ Conversation ID: %-36s │\n" "$conv_id"
    printf "│ Saved to: /tmp/.r2r_conversation_id                 │\n"
    echo "│                                                       │"

    if [ -n "$tool_details" ]; then
        echo "│ Tools Used:                                          │"
        echo "$tool_details"
        echo "│                                                       │"
    fi

    if [ -n "$citations" ]; then
        echo "│ Citations:                                           │"
        echo "$citations"
        echo "│                                                       │"
    fi

    local total=$((input_tokens + output_tokens + thinking_tokens))
    echo "│ Token Usage:                                         │"
    printf "│   • Input: %-43s │\n" "$input_tokens tokens"
    printf "│   • Output: %-42s │\n" "$output_tokens tokens"
    printf "│   • Thinking: %-40s │\n" "$thinking_tokens tokens"
    printf "│   • Total: %-43s │\n" "$total tokens"
    echo "╰─────────────────────────────────────────────────────╯"
}

r2r_agent() {
    local query=""
    local mode="$DEFAULT_MODE"
    local conversation_id=""
    local max_tokens="$DEFAULT_MAX_TOKENS"
    local extended_thinking=false
    local json_output=false
    local new_conversation=false
    local search_mode="advanced"
    local tools=""
    local filters=""
    local limit=""
    local verbose=false
    local quiet=false
    local show_sources=false
    local show_tools=false
    local no_header=false
    local no_stats=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --mode|-m)
                mode="$2"
                shift 2
                ;;
            --conversation|-c)
                conversation_id="$2"
                shift 2
                ;;
            --max-tokens)
                max_tokens="$2"
                shift 2
                ;;
            --thinking)
                extended_thinking=true
                shift
                ;;
            --new|-n)
                new_conversation=true
                shift
                ;;
            --json)
                json_output=true
                shift
                ;;
            --search-mode)
                search_mode="$2"
                shift 2
                ;;
            --tools)
                tools="$2"
                shift 2
                ;;
            --filters)
                filters="$2"
                shift 2
                ;;
            --limit|-l)
                limit="$2"
                shift 2
                ;;
            --verbose|-v)
                verbose=true
                shift
                ;;
            --quiet|-q)
                quiet=true
                shift
                ;;
            --show-sources)
                show_sources=true
                shift
                ;;
            --show-tools)
                show_tools=true
                shift
                ;;
            --no-header)
                no_header=true
                shift
                ;;
            --no-stats)
                no_stats=true
                shift
                ;;
            -*)
                print_error "Unknown flag: $1"
                return 1
                ;;
            *)
                # First positional argument is query
                if [ -z "$query" ]; then
                    query="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$query" ]; then
        print_error "Query required"
        echo "Usage: agent <query> [--mode <research|rag>] [--conversation <id>] [options]"
        return 1
    fi

    # If no conversation_id provided, try to reuse from temp file
    if [ -z "$conversation_id" ] && [ -f /tmp/.r2r_conversation_id ]; then
        conversation_id=$(head -1 /tmp/.r2r_conversation_id)
    fi

    # Handle --new flag: clear conversation_id and temp file
    if [ "$new_conversation" = true ]; then
        conversation_id=""
        rm -f /tmp/.r2r_conversation_id
    fi

    # Build message object
    local message=$(jq -n \
        --arg content "$query" \
        '{role: "user", content: $content}')

    # Build RAG generation config with optional extended thinking
    local rag_config=$(jq -n \
        --argjson tokens "$max_tokens" \
        '{max_tokens: $tokens}')

    if [ "$extended_thinking" = true ]; then
        rag_config=$(echo "$rag_config" | jq \
            '. + {extended_thinking: true, thinking_budget: 4096, temperature: 1}')
    fi

    # Build search settings
    local search_settings=$(jq -n '{use_hybrid_search: true}')

    # Add limit if provided
    if [ -n "$limit" ]; then
        search_settings=$(echo "$search_settings" | jq --argjson l "$limit" '. + {limit: $l}')
    fi

    # Add filters if provided
    if [ -n "$filters" ]; then
        search_settings=$(echo "$search_settings" | jq --argjson f "$filters" '. + {filters: $f}')
    fi

    # Build base payload
    local payload=$(jq -n \
        --argjson msg "$message" \
        --arg mode "$mode" \
        --arg search_mode "$search_mode" \
        --argjson search_settings "$search_settings" \
        --argjson rag_config "$rag_config" \
        '{
            message: $msg,
            mode: $mode,
            search_mode: $search_mode,
            search_settings: $search_settings,
            rag_generation_config: $rag_config
        }')

    # Add tools based on mode and --tools flag
    if [ -n "$tools" ]; then
        # Custom tools provided
        local tools_array
        tools_array=$(echo "$tools" | jq -R 'split(",")')
        if [ "$mode" = "rag" ]; then
            payload=$(echo "$payload" | jq --argjson tools "$tools_array" '.rag_tools = $tools')
        elif [ "$mode" = "research" ]; then
            payload=$(echo "$payload" | jq --argjson tools "$tools_array" '.research_tools = $tools')
        fi
    else
        # Default tools for mode
        if [ "$mode" = "rag" ]; then
            payload=$(echo "$payload" | jq \
                '.rag_tools = ["search_file_knowledge","search_file_descriptions","get_file_content","web_search"]')
        elif [ "$mode" = "research" ]; then
            payload=$(echo "$payload" | jq \
                '.research_tools = ["rag","reasoning","critique","python_executor"]')
        fi
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

    # Handle JSON output (bypass all formatting)
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Extract metadata from response
    local new_conv_id=$(echo "$response" | jq -r '.results.conversation_id // empty')
    local agent_response=$(echo "$response" | jq -r '.results.messages[-1].content // empty')
    local metadata=$(echo "$response" | jq -r '.results.messages[-1].metadata // {}')

    # Save conversation_id if new
    local is_new="false"
    if [ -n "$new_conv_id" ] && [ -z "$conversation_id" ]; then
        is_new="true"
        echo "$new_conv_id" > /tmp/.r2r_conversation_id
        conversation_id="$new_conv_id"
    fi

    # Extract citations
    local citations=$(echo "$metadata" | jq -r '
        if .citations then
            .citations | to_entries | map("  [\(.key + 1)] \(.value.id // "unknown") - \(.value.metadata.title // .value.source // "Unknown source")") | join("\n")
        else
            ""
        end
    ')
    local citation_count=$(echo "$metadata" | jq -r '.citations | length // 0')

    # Extract tool calls
    local tool_calls=$(echo "$metadata" | jq -r '
        if .tool_calls then
            .tool_calls | to_entries | map("  \(.key + 1). \(.value.name // .value.tool) - \(.value.description // "executed")") | join("\n")
        else
            ""
        end
    ')
    local tool_count=$(echo "$metadata" | jq -r '.tool_calls | length // 0')

    # Extract search results count
    local search_count=$(echo "$metadata" | jq -r '
        if .aggregated_search_result then
            .aggregated_search_result | fromjson | length
        else
            0
        end
    ')

    # Token counts (may not be available in API response)
    local tokens=$(echo "$response" | jq -r '.usage.total_tokens // 0')
    local input_tokens=$(echo "$response" | jq -r '.usage.prompt_tokens // 0')
    local output_tokens=$(echo "$response" | jq -r '.usage.completion_tokens // 0')
    local thinking_tokens=$(echo "$response" | jq -r '.usage.thinking_tokens // 0')

    # Get tools list for header
    local tools_list=""
    if [ "$mode" = "research" ]; then
        tools_list="rag, reasoning, critique, python"
    elif [ "$mode" = "rag" ]; then
        tools_list="search, get_content, web_search"
    fi
    local tool_count_total=4

    # Quiet mode: minimal output
    if [ "$quiet" = true ]; then
        echo "$agent_response"
        echo ""
        echo "[$conversation_id]"
        return 0
    fi

    # Print header (unless --no-header)
    if [ "$no_header" != true ]; then
        if [ "$verbose" = true ]; then
            print_agent_header_verbose "$query" "$mode" "$conversation_id" "$is_new" "$max_tokens" "$search_mode" "$tools_list"
        else
            print_agent_header "$mode" "$conversation_id" "$is_new" "$search_count" "$extended_thinking" "$tool_count_total"
        fi
    fi

    # Print agent response
    if [ -z "$agent_response" ]; then
        # Fallback to full JSON if no content
        echo "$response" | jq '.'
    else
        echo "$agent_response"
    fi

    # Print citations (if available and requested, but NOT in verbose mode - it shows in metadata box)
    if [ -n "$citations" ] && [ "$citation_count" -gt 0 ]; then
        if [ "$verbose" != true ] && [ "$show_sources" = true ]; then
            print_citations "$citations"
        fi
    fi

    # Print tool calls (if available and requested, but NOT in verbose mode - it shows in metadata box)
    if [ -n "$tool_calls" ] && [ "$tool_count" -gt 0 ]; then
        if [ "$verbose" != true ] && [ "$show_tools" = true ]; then
            print_tool_calls "$tool_calls"
        fi
    fi

    # Print footer stats ONLY if verbose or explicitly requested
    if [ "$verbose" = true ]; then
        print_agent_metadata "$conversation_id" "$tool_calls" "$citations" "$input_tokens" "$output_tokens" "$thinking_tokens"
    elif [ "$show_sources" = true ] || [ "$show_tools" = true ]; then
        # Show compact stats if user requested sources/tools
        if [ "$tokens" = "0" ]; then
            tokens="N/A"
        fi
        print_agent_stats "$tool_count" "$citation_count" "$tokens"
    fi
    # Otherwise: no footer stats by default (minimalist output)
}

# Show help
show_help() {
    cat << 'EOF'
R2R Agent Command

USAGE:
    agent <query> [options]

REQUIRED:
    <query>                         The question or instruction for the agent

OPTIONS:
    --mode <name>                   Agent mode: research or rag (default: research)
    -m <name>                       Short form for --mode
    --conversation <id>             Continue existing conversation
    -c <id>                         Short form for --conversation
    --max-tokens <n>                Max tokens for generation (default: 4000)
    --thinking                      Enable extended thinking (4096 token budget)
    --new                           Start new conversation (clears saved ID)
    -n                              Short form for --new
    --json                          Output raw JSON response

OUTPUT CONTROL:
    Default: Minimalist (header + response only)

    --verbose, -v                   Detailed output with full metadata boxes
    --quiet, -q                     Ultra-minimal (response + conversation_id only)
    --show-sources                  Show citations + compact stats
    --show-tools                    Show tool calls + compact stats
    --no-header                     Disable header line
    --no-stats                      Force disable stats (even with --show-*)

SEARCH OPTIONS:
    --search-mode <mode>            Search mode: basic, advanced, custom (default: advanced)
    --limit <n>                     Max search results to return
    -l <n>                          Short form for --limit
    --filters <json>                Search filters JSON

TOOL SELECTION:
    --tools <list>                  Comma-separated tool names
                                    Overrides default tools for the mode

MODES:
    research (default)              Multi-step reasoning with tools:
                                    - rag, reasoning, critique, python_executor
    rag                             Document-focused with tools:
                                    - search_file_knowledge, search_file_descriptions,
                                      get_file_content, web_search

EXTENDED THINKING:
    --thinking flag enables deep reasoning with:
    - thinking_budget: 4096 tokens
    - temperature: 1 (creative exploration)
    - Step-by-step thought process (Claude 3.7+ Sonnet only)

MULTI-TURN CONVERSATIONS:
    The agent returns a conversation_id on first query.
    The ID is automatically saved to /tmp/.r2r_conversation_id.

    Auto-reuse behavior:
    - If conversation_id exists in temp file, agent REUSES it automatically
    - No need to pass conversation_id explicitly
    - Use --new flag to start fresh conversation

    Manual conversation control:
    - CONV_ID=$(head -1 /tmp/.r2r_conversation_id)
    - agent "next question" --conversation $CONV_ID
    - agent "fresh topic" --new

OUTPUT MODES:
    Default (minimalist):
        🤖 R2R Agent | research | 🟢 conv:abc123
        Agent's response here...

    Verbose (--verbose):
        ╭─ R2R Agent Request ─────────────────╮
        │ Query: ...                          │
        │ Mode: research                      │
        ╰─────────────────────────────────────╯
        Response...
        ╭─ Response Metadata ─────────────────╮
        │ Tools, Citations, Token Usage      │
        ╰─────────────────────────────────────╯

    Quiet (--quiet):
        Agent's response only...
        [conversation-id-here]

EXAMPLES:
    # Basic queries (minimalist output)
    agent "What is R2R?"                                    # research mode
    agent "What is R2R?" --mode rag                        # RAG mode
    agent "What is R2R?" -m rag                            # short form

    # Extended thinking
    agent "Analyze architecture" --thinking

    # Output control
    agent "Question" --verbose                              # full metadata
    agent "Question" -v                                     # short form
    agent "Question" --quiet                                # ultra-minimal
    agent "Question" -q                                     # short form
    agent "Question" --show-sources                         # with citations
    agent "Question" --show-tools                           # with tool calls

    # Continue conversation
    agent "What about FastMCP?" --conversation abc123-def456
    agent "Follow-up question" -c abc123-def456            # short form

    # Reuse last conversation (auto-loads from temp file)
    agent "Another follow-up"                              # automatically continues

    # Start new conversation
    agent "Fresh topic" --new
    agent "New subject" -n                                 # short form

    # Custom token limit
    agent "Comprehensive guide" --max-tokens 8000

    # Search options
    agent "Find documents" --limit 5 --filters '{"category":"tech"}'
    agent "Search query" -l 10 --search-mode basic

    # Custom tools
    agent "Research query" --mode research --tools "rag,reasoning"
    agent "RAG query" -m rag --tools "search_file_knowledge,web_search"

    # JSON output (for scripting)
    agent "test query" --json

    # Complex example
    agent "Deep analysis of AI trends" \
        --mode research \
        --thinking \
        --max-tokens 8000 \
        --limit 10 \
        --filters '{"year":{"$gte":2024}}'

AVAILABLE TOOLS:
    RAG mode:
        - search_file_knowledge      Search document chunks
        - search_file_descriptions   Search document summaries
        - get_file_content          Retrieve full documents
        - web_search                Search the web (requires Serper API)
        - web_scrape                Extract web content

    Research mode:
        - rag                       Use underlying RAG agent
        - reasoning                 Dedicated reasoning model
        - critique                  Analyze for biases/flaws
        - python_executor           Execute Python code

NOTES:
    - Extended thinking requires Claude 3.7+ Sonnet model
    - Web search requires Serper API key configuration
    - Conversation IDs persist until explicitly cleared with --new
    - JSON output includes full conversation history
EOF
}

# If executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Check for help flag
    if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
        exit 0
    fi

    # Pass all arguments to main function
    r2r_agent "$@"
fi
