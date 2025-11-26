#!/usr/bin/env bash
# R2R RAG Command
# RAG query with retrieval and generation

source "$(dirname "$0")/../lib/common.sh"

# Print compact RAG header (single line)
print_rag_header() {
    local max_tokens="$1"
    local strategy="$2"
    local graph_enabled="$3"
    local collection="$4"

    # Build info parts
    local parts=()
    parts+=("tokens:$max_tokens")
    [ "$strategy" != "vanilla" ] && parts+=("strategy:$strategy")
    [ "$graph_enabled" = "true" ] && parts+=("🔗 graph")
    [ -n "$collection" ] && parts+=("📁 ${collection:0:8}")

    # Join with pipes
    local IFS=" | "
    printf "💬 RAG | %s\n" "${parts[*]}"
}

# Print RAG stats footer (single line)
print_rag_stats() {
    local citation_count="$1"
    local chunk_count="$2"

    local parts=()
    [ "$citation_count" -gt 0 ] && parts+=("📚 $citation_count sources")
    [ "$chunk_count" -gt 0 ] && parts+=("📄 $chunk_count chunks")

    if [ ${#parts[@]} -eq 0 ]; then
        return
    fi

    local IFS=" | "
    echo ""
    echo "${parts[*]}"
}

r2r_rag() {
    local query=""
    local max_tokens="$DEFAULT_MAX_TOKENS"
    local filter_field=""
    local filter_value=""
    local search_strategy="vanilla"
    local use_graph_search=false
    local collection_id=""
    local generation_model=""
    local json_output=false
    local verbose=false
    local quiet=false
    local show_sources=false
    local show_metadata=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --max-tokens|-t)
                max_tokens="$2"
                shift 2
                ;;
            --filter|-f)
                if [[ "$2" =~ ^([^=]+)=(.+)$ ]]; then
                    filter_field="${BASH_REMATCH[1]}"
                    filter_value="${BASH_REMATCH[2]}"
                    shift 2
                else
                    print_error "--filter requires format 'field=value'"
                    return 1
                fi
                ;;
            --strategy|-s)
                search_strategy="$2"
                shift 2
                ;;
            --graph|-g)
                use_graph_search=true
                shift
                ;;
            --collection|-c)
                collection_id="$2"
                shift 2
                ;;
            --model|-m)
                generation_model="$2"
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
            --show-metadata)
                show_metadata=true
                shift
                ;;
            --json)
                json_output=true
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

    # Validation
    if [ -z "$query" ]; then
        print_error "Query required"
        echo "Usage: rag <query> [--max-tokens <n>] [options]"
        return 1
    fi

    # Build filters using jq
    local filters=$(jq -n '{}')

    if [ -n "$filter_field" ] && [ -n "$filter_value" ]; then
        filters=$(echo "$filters" | jq \
            --arg field "$filter_field" \
            --arg value "$filter_value" \
            '. + {($field): {"$eq": $value}}')
    fi

    if [ -n "$collection_id" ]; then
        filters=$(echo "$filters" | jq \
            --arg cid "$collection_id" \
            '. + {"collection_ids": {"$overlap": [$cid]}}')
    fi

    # Build search settings using jq
    local use_graph_json="false"
    [ "$use_graph_search" = true ] && use_graph_json="true"

    # For hyde/rag_fusion, require generation model
    if [ "$search_strategy" = "hyde" ] || [ "$search_strategy" = "rag_fusion" ]; then
        if [ -z "$generation_model" ]; then
            generation_model="openai/gpt-4o-mini"
            [ "$quiet" != true ] && print_info "Using default model for $search_strategy: $generation_model"
        fi
    fi

    # Build base search settings
    local search_settings=$(jq -n \
        --arg strategy "$search_strategy" \
        --argjson use_graph "$use_graph_json" \
        --argjson filters "$filters" \
        '{
            use_hybrid_search: true,
            search_strategy: $strategy,
            filters: $filters
        } + (if $use_graph then {use_graph_search: true} else {} end)')

    # Add generation_config for hyde/rag_fusion
    if [ -n "$generation_model" ]; then
        search_settings=$(echo "$search_settings" | jq \
            --arg model "$generation_model" \
            '. + {generation_config: {model: $model}}')
    fi

    # Build RAG generation config
    local rag_config=$(jq -n \
        --argjson tokens "$max_tokens" \
        '{max_tokens: $tokens}')

    # Build complete payload
    local payload=$(jq -n \
        --arg q "$query" \
        --argjson settings "$search_settings" \
        --argjson config "$rag_config" \
        '{query: $q, search_settings: $settings, rag_generation_config: $config}')

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/retrieval/rag" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -d "$payload")

    # Handle JSON output (bypass all formatting)
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Extract answer and metadata
    local answer=$(echo "$response" | jq -r '.results.generated_answer // empty')
    local search_results=$(echo "$response" | jq -r '.results.search_results.chunk_search_results // []')
    local chunk_count=$(echo "$search_results" | jq 'length')

    # Extract citations (if available)
    local citations=$(echo "$search_results" | jq -r '
        if length > 0 then
            to_entries | map("  [\(.key + 1)] \(.value.metadata.title // "Unknown") [\(.value.id[:8])] (score: \(.value.score | tonumber | . * 100 | round / 100))") | join("\n")
        else
            ""
        end
    ')
    local citation_count=$(echo "$search_results" | jq 'length')

    # Quiet mode: minimal output
    if [ "$quiet" = true ]; then
        echo "$answer"
        return 0
    fi

    # Print header (unless quiet)
    print_rag_header "$max_tokens" "$search_strategy" "$use_graph_search" "$collection_id"
    echo ""

    # Print answer
    if [ -z "$answer" ]; then
        # Fallback to full JSON if no answer
        echo "$response" | jq '.'
    else
        echo "$answer"
    fi

    # Print citations (if verbose or explicitly requested)
    if [ -n "$citations" ] && [ "$citation_count" -gt 0 ]; then
        if [ "$verbose" = true ] || [ "$show_sources" = true ]; then
            echo ""
            echo "📚 Sources:"
            echo "$citations"
        fi
    fi

    # Print footer stats (if verbose or show_metadata)
    if [ "$verbose" = true ] || [ "$show_metadata" = true ]; then
        print_rag_stats "$citation_count" "$chunk_count"
    fi
}

# Show help
show_help() {
    cat << 'EOF'
R2R RAG Command

USAGE:
    rag <query> [options]

REQUIRED:
    <query>                         The question or query text

OPTIONS:
    --max-tokens <n>                Max tokens for generation (default: 4000)
    -t <n>                          Short form for --max-tokens
    --filter <field=value>          Filter by metadata field
    -f <field=value>                Short form for --filter
    --strategy <name>               Search strategy (default: vanilla)
    -s <name>                       Short form for --strategy
    --collection <id>               Filter by collection ID
    -c <id>                         Short form for --collection
    --model <name>                  Model for hyde/rag_fusion strategies
    -m <name>                       Short form for --model
    --graph                         Enable graph search (entities + relationships)
    -g                              Short form for --graph

OUTPUT CONTROL:
    Default: Minimalist (header + answer only)

    --verbose, -v                   Show full sources with metadata
    --quiet, -q                     Ultra-minimal (answer only)
    --show-sources                  Show sources list (even in compact mode)
    --show-metadata                 Show footer stats (citation count, chunks)
    --json                          Output raw JSON response

SEARCH STRATEGIES:
    vanilla (default)               Standard hybrid search (recommended)
    hyde                            Hypothetical Document Embeddings
    rag_fusion                      Multiple queries + RRF reranking

    Note: hyde and rag_fusion require --model (default: openai/gpt-4o-mini)

OUTPUT MODES:
    Default (minimalist):
        💬 RAG | tokens:4000 | strategy:vanilla

        Generated answer based on retrieved context...

    Verbose (--verbose):
        💬 RAG | tokens:4000 | strategy:vanilla

        Generated answer based on retrieved context...

        📚 Sources:
          [1] Document Title [abc123] (score: 0.92)
          [2] Another Doc [def456] (score: 0.85)

        📚 2 sources | 📄 5 chunks

    Quiet (--quiet):
        Generated answer only...

EXAMPLES:
    # Basic RAG query (minimalist output)
    rag "What is R2R?"
    rag "Explain transformers" --max-tokens 2000
    rag "Python best practices" -t 3000          # short form

    # With filters
    rag "API documentation" --filter type=pdf
    rag "guides" -f category=tutorial            # short form

    # Search strategies
    rag "What are LLMs?" --strategy vanilla
    rag "Explain RAG" -s hyde                    # short form with hyde
    rag "AI trends" -s rag_fusion -m openai/gpt-4o

    # Graph search
    rag "knowledge graphs overview" --graph
    rag "entity relationships" -g                # short form

    # In specific collection
    rag "API reference" --collection abc123
    rag "tutorials" -c abc123                    # short form

    # Output control
    rag "question" --verbose                     # full sources
    rag "question" -v                            # short form
    rag "question" --quiet                       # minimal output
    rag "question" -q                            # short form
    rag "question" --show-sources                # with source list
    rag "question" --show-metadata               # with footer stats
    rag "question" --json                        # raw JSON

    # Combined options
    rag "deep learning guide" -t 8000 -f type=pdf -s vanilla -g -v
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
    r2r_rag "$@"
fi
