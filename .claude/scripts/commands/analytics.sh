#!/usr/bin/env bash
# R2R Analytics Commands
# Collection and document statistics

source "$(dirname "$0")/../lib/common.sh"

# Print compact analytics header (single line)
print_analytics_header() {
    local type="$1"
    local target="$2"

    case "$type" in
        collection)
            printf "📊 Analytics | collection | 🗂️  %s\n" "${target:0:8}"
            ;;
        document)
            printf "📊 Analytics | document   | 📄 %s\n" "${target:0:8}"
            ;;
        system)
            printf "📊 Analytics | system\n"
            ;;
    esac
}

# Print compact stats footer (single line, only non-zero values)
print_analytics_stats() {
    local stat_type="$1"
    shift
    local parts=()

    case "$stat_type" in
        collection)
            local docs="$1"
            local users="$2"
            local entities="$3"
            local rels="$4"
            local comms="$5"

            [ "$docs" -gt 0 ] && parts+=("📄 $docs docs")
            [ "$users" -gt 0 ] && parts+=("👥 $users users")
            [ "$entities" -gt 0 ] && parts+=("🔷 $entities entities")
            [ "$rels" -gt 0 ] && parts+=("🔗 $rels relationships")
            [ "$comms" -gt 0 ] && parts+=("🌐 $comms communities")
            ;;
        system)
            local docs="$1"
            local colls="$2"

            [ "$docs" -gt 0 ] && parts+=("📄 $docs documents")
            [ "$colls" -gt 0 ] && parts+=("🗂️  $colls collections")
            ;;
    esac

    # If no stats, don't print anything
    if [ ${#parts[@]} -eq 0 ]; then
        return
    fi

    echo ""
    local IFS=" | "
    echo "${parts[*]}"
}

# Get collection statistics
analytics_collection() {
    local collection_id=""
    local verbose=false
    local quiet=false
    local json_output=false
    local show_graph=false
    local show_stats=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --verbose|-v)
                verbose=true
                shift
                ;;
            --quiet|-q)
                quiet=true
                shift
                ;;
            --json)
                json_output=true
                shift
                ;;
            --show-graph|-g)
                show_graph=true
                shift
                ;;
            --show-stats|-s)
                show_stats=true
                shift
                ;;
            -*)
                print_error "Unknown flag: $1"
                return 1
                ;;
            *)
                # Positional argument
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                fi
                shift
                ;;
        esac
    done

    # Validation
    if [ -z "$collection_id" ]; then
        print_error "Collection ID required"
        echo "Usage: analytics collection <collection_id> [options]"
        return 1
    fi

    # Get collection info
    local response=$(curl -s -X GET "${R2R_BASE_URL}/v3/collections/${collection_id}" \
        -H "Authorization: Bearer ${API_KEY}")

    # Handle JSON output (bypass all formatting)
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Extract basic info (response has .results wrapper)
    local name=$(echo "$response" | jq -r '.results.name // "Unknown"')
    local doc_count=$(echo "$response" | jq -r '.results.document_count // 0')
    local user_count=$(echo "$response" | jq -r '.results.user_count // 0')
    local graph_status=$(echo "$response" | jq -r '.results.graph_cluster_status // "unknown"')
    local created=$(echo "$response" | jq -r '.created_at // "unknown"')
    local updated=$(echo "$response" | jq -r '.updated_at // "unknown"')

    # Get graph stats by default (skip only in quiet mode)
    local entity_count=0
    local rel_count=0
    local comm_count=0

    if [ "$quiet" != true ]; then
        entity_count=$(curl -s -X GET "${R2R_BASE_URL}/v3/graphs/${collection_id}/entities?limit=1" \
            -H "Authorization: Bearer ${API_KEY}" \
            | jq -r '.total_entries // 0')

        rel_count=$(curl -s -X GET "${R2R_BASE_URL}/v3/graphs/${collection_id}/relationships?limit=1" \
            -H "Authorization: Bearer ${API_KEY}" \
            | jq -r '.total_entries // 0')

        comm_count=$(curl -s -X GET "${R2R_BASE_URL}/v3/graphs/${collection_id}/communities?limit=1" \
            -H "Authorization: Bearer ${API_KEY}" \
            | jq -r '.total_entries // 0')
    fi

    # Quiet mode: minimal output
    if [ "$quiet" = true ]; then
        echo "$name [$collection_id] - $doc_count docs, $user_count users"
        return 0
    fi

    # Default mode: EVERYTHING in ONE line (readable format)
    printf "📊 Analytics | collection:%s | %s | 📄 %s docs | 👥 %s users | graph:%s | 🔷 %s entities | 🔗 %s rels | 🌐 %s comms\n" \
        "${collection_id:0:8}" "$name" "$doc_count" "$user_count" "$graph_status" "$entity_count" "$rel_count" "$comm_count"
}

# Document insights
analytics_document() {
    local doc_id=""
    local verbose=false
    local quiet=false
    local json_output=false
    local show_metadata=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --verbose|-v)
                verbose=true
                shift
                ;;
            --quiet|-q)
                quiet=true
                shift
                ;;
            --json)
                json_output=true
                shift
                ;;
            --show-metadata|-m)
                show_metadata=true
                shift
                ;;
            -*)
                print_error "Unknown flag: $1"
                return 1
                ;;
            *)
                # Positional argument
                if [ -z "$doc_id" ]; then
                    doc_id="$1"
                fi
                shift
                ;;
        esac
    done

    # Validation
    if [ -z "$doc_id" ]; then
        print_error "Document ID required"
        echo "Usage: analytics document <document_id> [options]"
        return 1
    fi

    local response=$(curl -s -X GET "${R2R_BASE_URL}/v3/documents/${doc_id}" \
        -H "Authorization: Bearer ${API_KEY}")

    # Handle JSON output (bypass all formatting)
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Extract info (response has .results wrapper)
    local title=$(echo "$response" | jq -r '.results.title // .results.metadata.title // "Unknown"')
    local status=$(echo "$response" | jq -r '.results.ingestion_status // "unknown"')
    local collections=$(echo "$response" | jq -r '.results.collection_ids // [] | if length > 0 then join(", ") else "none" end')
    local created=$(echo "$response" | jq -r '.created_at // "unknown"')
    local updated=$(echo "$response" | jq -r '.updated_at // "unknown"')

    # Quiet mode: minimal output
    if [ "$quiet" = true ]; then
        echo "$title [$doc_id] - $status"
        return 0
    fi

    # Default mode: EVERYTHING in ONE line (readable format)
    printf "📊 Analytics | doc:%s | %s | status:%s | collections:%s\n" \
        "${doc_id:0:8}" "$title" "$status" "$collections"
}

# System statistics
analytics_system() {
    local verbose=false
    local quiet=false
    local json_output=false
    local show_stats=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --verbose|-v)
                verbose=true
                shift
                ;;
            --quiet|-q)
                quiet=true
                shift
                ;;
            --json)
                json_output=true
                shift
                ;;
            --show-stats|-s)
                show_stats=true
                shift
                ;;
            -*)
                print_error "Unknown flag: $1"
                return 1
                ;;
            *)
                shift
                ;;
        esac
    done

    # Get system stats
    local doc_response=$(curl -s -X GET "${R2R_BASE_URL}/v3/documents?limit=1" \
        -H "Authorization: Bearer ${API_KEY}")

    local coll_response=$(curl -s -X GET "${R2R_BASE_URL}/v3/collections?limit=1" \
        -H "Authorization: Bearer ${API_KEY}")

    local doc_count=$(echo "$doc_response" | jq -r '.total_entries // 0')
    local coll_count=$(echo "$coll_response" | jq -r '.total_entries // 0')

    # Handle JSON output (bypass all formatting)
    if [ "$json_output" = true ]; then
        jq -n \
            --argjson docs "$doc_count" \
            --argjson colls "$coll_count" \
            '{total_documents: $docs, total_collections: $colls}'
        return 0
    fi

    # Quiet mode: minimal output
    if [ "$quiet" = true ]; then
        echo "Documents: $doc_count | Collections: $coll_count"
        return 0
    fi

    # Default mode: EVERYTHING in ONE line (readable format)
    printf "📊 Analytics | system | 📄 %s docs | 🗂️  %s collections\n" "$doc_count" "$coll_count"
}

# Show help
show_help() {
    cat << 'EOF'
R2R Analytics Commands

USAGE:
    analytics <action> [arguments] [options]

ACTIONS:
    collection <collection_id>     Collection statistics and graph metrics
    document <document_id>         Document details and metadata
    system                         System-wide statistics

OPTIONS:
    --quiet, -q                     Ultra-minimal output (single line, no header)
    --json                          Pretty-printed JSON (multiline)

OUTPUT MODES:
    Default - ONE LINE (readable format with emojis):
        📊 Analytics | system | 📄 276 docs | 🗂️  10 collections

    Collection - ONE LINE:
        📊 Analytics | collection:abc123 | My Collection | 📄 42 docs | 👥 3 users | graph:pending | 🔷 150 entities | 🔗 320 rels | 🌐 12 comms

    Document - ONE LINE:
        📊 Analytics | doc:doc789 | My Document | status:success | collections:abc123, def456

    Quiet (--quiet) - single line, no header:
        Documents: 276 | Collections: 10

    JSON (--json) - pretty printed for scripting:
        {
          "total_documents": 276,
          "total_collections": 10
        }

EXAMPLES:
    # System analytics (readable format)
    analytics system
    # Output: 📊 Analytics | system | 📄 276 docs | 🗂️  10 collections

    # Collection analytics (all metrics in one line)
    analytics collection abc123-def456
    # Output: 📊 Analytics | collection:abc123 | My Collection | 📄 42 docs | 👥 3 users | graph:pending | 🔷 150 entities | 🔗 320 rels | 🌐 12 comms

    # Document analytics (metadata in one line)
    analytics document doc789-ghi012
    # Output: 📊 Analytics | doc:doc789 | My Document | status:success | collections:abc123, def456

    # Quiet mode (minimal, no header)
    analytics system -q
    # Output: Documents: 276 | Collections: 10

    # JSON mode (for scripting/parsing)
    analytics system --json
    # Output: {"total_documents": 276, "total_collections": 10}
EOF
}

# Command dispatcher
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Check for help flag
    if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        show_help
        exit 0
    fi

    ACTION="${1:-help}"
    shift || true

    case "$ACTION" in
        collection|coll) analytics_collection "$@" ;;
        document|doc) analytics_document "$@" ;;
        system|sys) analytics_system "$@" ;;
        help|--help|-h) show_help ;;
        *) echo "Unknown action: $ACTION" >&2; show_help; exit 1 ;;
    esac
fi
