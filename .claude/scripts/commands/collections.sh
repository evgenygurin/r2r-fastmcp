#!/usr/bin/env bash
# R2R Collections Management
# Create, list, delete collections and manage document membership

source "$(dirname "$0")/../lib/common.sh"

# List collections
collections_list() {
    local limit=10
    local offset=0
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --limit|-l)
                limit="$2"
                shift 2
                ;;
            --offset|-o)
                offset="$2"
                shift 2
                ;;
            --quiet|-q)
                quiet=true
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
                shift
                ;;
        esac
    done

    local response=$(curl -s -X GET "${R2R_BASE_URL}/v3/collections?limit=${limit}&offset=${offset}" \
        -H "Authorization: Bearer ${API_KEY}")

    # Handle JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode: minimal output
    if [ "$quiet" = true ]; then
        echo "$response" | jq -r '.results[] | "\(.name) [\(.id[:8])] - \(.document_count) docs"'
        return 0
    fi

    # Default mode: ONE LINE per collection
    echo "$response" | jq -r '.results[] |
        "🗂️  Collection | \(.id[:8]) | \(.name) | 📄 \(.document_count) docs | 👥 \(.user_count) users | graph:\(.graph_cluster_status)"'
}

# Get collection details
collections_get() {
    local collection_id=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --quiet|-q)
                quiet=true
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ]; then
        print_error "Collection ID required"
        echo "Usage: collections get <collection_id> [options]"
        return 1
    fi

    local response=$(curl -s -X GET "${R2R_BASE_URL}/v3/collections/${collection_id}" \
        -H "Authorization: Bearer ${API_KEY}")

    # Handle JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Extract info
    local name=$(echo "$response" | jq -r '.results.name // "Unknown"')
    local doc_count=$(echo "$response" | jq -r '.results.document_count // 0')
    local user_count=$(echo "$response" | jq -r '.results.user_count // 0')
    local graph_status=$(echo "$response" | jq -r '.results.graph_cluster_status // "unknown"')
    local description=$(echo "$response" | jq -r '.results.description // "none"')

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "$name [$collection_id] - $doc_count docs, $user_count users"
        return 0
    fi

    # Default: ONE LINE
    printf "🗂️  Collection | %s | %s | 📄 %s docs | 👥 %s users | graph:%s | desc:%s\n" \
        "${collection_id:0:8}" "$name" "$doc_count" "$user_count" "$graph_status" "${description:0:50}"
}

# Create collection
collections_create() {
    local name=""
    local description=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --name|-n)
                name="$2"
                shift 2
                ;;
            --description|--desc|-d)
                description="$2"
                shift 2
                ;;
            --quiet|-q)
                quiet=true
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
                # Positional: first arg is name, second is description
                if [ -z "$name" ]; then
                    name="$1"
                elif [ -z "$description" ]; then
                    description="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$name" ]; then
        print_error "Collection name required"
        echo "Usage: collections create <name> [description] or collections create --name <name> --desc <desc>"
        return 1
    fi

    local payload=$(jq -n \
        --arg name "$name" \
        --arg desc "$description" \
        '{name: $name, description: $desc}')

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/collections" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$payload")

    # Handle JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    local collection_id=$(echo "$response" | jq -r '.results.id // empty')

    if [ -n "$collection_id" ]; then
        if [ "$quiet" = true ]; then
            echo "$collection_id"
        else
            printf "✅ Created | collection:%s | %s\n" "${collection_id:0:8}" "$name"
        fi
    else
        echo "$response" | jq '.'
    fi
}

# Delete collection
collections_delete() {
    local collection_id=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --quiet|-q)
                quiet=true
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ]; then
        print_error "Collection ID required"
        echo "Usage: collections delete <collection_id> [options]"
        return 1
    fi

    local response=$(curl -s -X DELETE "${R2R_BASE_URL}/v3/collections/${collection_id}" \
        -H "Authorization: Bearer ${API_KEY}")

    # Handle JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    if [ "$quiet" = true ]; then
        echo "Deleted"
    else
        printf "🗑️  Deleted | collection:%s\n" "${collection_id:0:8}"
    fi
}

# Add document to collection
collections_add_document() {
    local collection_id=""
    local document_id=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --collection|-c)
                collection_id="$2"
                shift 2
                ;;
            --document|--doc|-d)
                document_id="$2"
                shift 2
                ;;
            --quiet|-q)
                quiet=true
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
                # Positional: first is collection_id, second is document_id
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                elif [ -z "$document_id" ]; then
                    document_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ] || [ -z "$document_id" ]; then
        print_error "Collection ID and Document ID required"
        echo "Usage: collections add-doc <collection_id> <document_id> [options]"
        return 1
    fi

    local payload=$(jq -n \
        --arg doc_id "$document_id" \
        '{document_id: $doc_id}')

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/collections/${collection_id}/documents" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$payload")

    # Handle JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    if [ "$quiet" = true ]; then
        echo "Added"
    else
        printf "➕ Added | doc:%s → collection:%s\n" "${document_id:0:8}" "${collection_id:0:8}"
    fi
}

# Remove document from collection
collections_remove_document() {
    local collection_id=""
    local document_id=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --collection|-c)
                collection_id="$2"
                shift 2
                ;;
            --document|--doc|-d)
                document_id="$2"
                shift 2
                ;;
            --quiet|-q)
                quiet=true
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
                # Positional: first is collection_id, second is document_id
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                elif [ -z "$document_id" ]; then
                    document_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ] || [ -z "$document_id" ]; then
        print_error "Collection ID and Document ID required"
        echo "Usage: collections remove-doc <collection_id> <document_id> [options]"
        return 1
    fi

    local response=$(curl -s -X DELETE "${R2R_BASE_URL}/v3/collections/${collection_id}/documents/${document_id}" \
        -H "Authorization: Bearer ${API_KEY}")

    # Handle JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    if [ "$quiet" = true ]; then
        echo "Removed"
    else
        printf "➖ Removed | doc:%s ← collection:%s\n" "${document_id:0:8}" "${collection_id:0:8}"
    fi
}

# Show help
show_help() {
    cat << 'EOF'
R2R Collections Commands

USAGE:
    collections <action> [arguments] [options]

ACTIONS:
    list                                        List collections
    get <collection_id>                         Get collection details
    create <name> [description]                 Create collection
    delete <collection_id>                      Delete collection
    add-doc <collection_id> <document_id>       Add document to collection
    remove-doc <collection_id> <document_id>    Remove document from collection

OPTIONS:
    --limit, -l <num>         Number of results (list only, default: 10)
    --offset, -o <num>        Skip N results (list only, default: 0)
    --name, -n <name>         Collection name (create only)
    --description, -d <desc>  Collection description (create only)
    --collection, -c <id>     Collection ID (add/remove-doc)
    --document, -d <id>       Document ID (add/remove-doc)
    --quiet, -q               Minimal output
    --json                    Pretty JSON output

OUTPUT MODES:
    Default - ONE LINE per collection (list):
        🗂️  Collection | abc123 | My Collection | 📄 42 docs | 👥 3 users | graph:success

    Default - ONE LINE (get):
        🗂️  Collection | abc123 | My Collection | 📄 42 docs | 👥 3 users | graph:success | desc:Research papers...

    Default - ONE LINE (create):
        ✅ Created | collection:abc123 | My Collection

    Quiet - minimal output:
        My Collection [abc123] - 42 docs, 3 users

    JSON - full API response

EXAMPLES:
    # List collections (default 10)
    collections list
    collections list --limit 20
    collections list -l 20 -o 10

    # Get collection details
    collections get abc123-def456
    collections get abc123 --quiet

    # Create collection
    collections create "My Collection" "Description here"
    collections create --name "My Collection" --desc "Description"
    collections create -n "Quick Create"

    # Delete collection
    collections delete abc123-def456
    collections delete abc123 --json

    # Add document to collection
    collections add-doc collection123 doc456
    collections add-doc --collection collection123 --document doc456
    collections add-doc -c collection123 -d doc456

    # Remove document from collection
    collections remove-doc collection123 doc456
    collections remove-doc -c collection123 -d doc456

    # JSON output
    collections list --json
    collections get abc123 --json
EOF
}

# Command dispatcher
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    ACTION="${1:-help}"
    shift || true

    case "$ACTION" in
        list) collections_list "$@" ;;
        get) collections_get "$@" ;;
        create) collections_create "$@" ;;
        delete) collections_delete "$@" ;;
        add-doc|add-document) collections_add_document "$@" ;;
        remove-doc|remove-document) collections_remove_document "$@" ;;
        help|--help|-h) show_help ;;
        *) echo "Unknown action: $ACTION" >&2; show_help; exit 1 ;;
    esac
fi
