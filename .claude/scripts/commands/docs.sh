#!/usr/bin/env bash
# R2R Documents Management
# Create, list, delete, export, update documents and metadata

source "$(dirname "$0")/../lib/common.sh"

# List documents with filtering and pagination
docs_list() {
    local limit=10
    local offset=0
    local quiet=false
    local json_output=false
    local verbose=false

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
            --verbose|-v)
                verbose=true
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

    local response=$(curl -s -X GET "${R2R_BASE_URL}/v3/documents?offset=${offset}&limit=${limit}" \
        -H "Authorization: Bearer ${API_KEY}")

    # Handle JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode: minimal output
    if [ "$quiet" = true ]; then
        echo "$response" | jq -r '.results[] | "\(.metadata.title // "Untitled") [\(.id[:8])]"'
        return 0
    fi

    # Print header
    printf "📄 Documents | limit:%s | offset:%s\n" "$limit" "$offset"
    echo ""

    # Verbose mode: full details
    if [ "$verbose" = true ]; then
        echo "$response" | jq -r '.results[] |
            "ID: \(.id)\n" +
            "Title: \(.metadata.title // "Untitled")\n" +
            "Status: \(.ingestion_status)\n" +
            "Collections: \(.collection_ids | join(", "))\n" +
            "Created: \(.created_at)\n" +
            "---"'
    else
        # Default: ONE LINE per document
        echo "$response" | jq -r '.results[] |
            "📄 Doc | \(.id[:8]) | \(.metadata.title // "Untitled") | status:\(.ingestion_status) | 🗂️  \(.collection_ids | length) colls | \(.created_at[:10])"'
    fi
}

# Get document details
docs_get() {
    local doc_id=""
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
                if [ -z "$doc_id" ]; then
                    doc_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$doc_id" ]; then
        print_error "Document ID required"
        echo "Usage: docs get <doc_id> [--quiet|-q] [--json]"
        return 1
    fi

    local response=$(curl -s -X GET "${R2R_BASE_URL}/v3/documents/${doc_id}" \
        -H "Authorization: Bearer ${API_KEY}")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode
    if [ "$quiet" = true ]; then
        local title=$(echo "$response" | jq -r '.results.metadata.title // "Untitled"')
        echo "$title [$doc_id]"
        return 0
    fi

    # Default: pretty JSON
    echo "$response" | jq '.'
}

# Delete document
docs_delete() {
    local doc_id=""
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
                if [ -z "$doc_id" ]; then
                    doc_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$doc_id" ]; then
        print_error "Document ID required"
        echo "Usage: docs delete <doc_id> [--quiet|-q] [--json]"
        return 1
    fi

    local response=$(curl -s -X DELETE "${R2R_BASE_URL}/v3/documents/${doc_id}" \
        -H "Authorization: Bearer ${API_KEY}")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "Deleted"
        return 0
    fi

    # Default: ONE LINE
    printf "🗑️  Deleted | doc:%s\n" "${doc_id:0:8}"
}

# Delete documents by filter
docs_delete_by_filter() {
    local filters=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --filters|-f)
                filters="$2"
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
                if [ -z "$filters" ]; then
                    filters="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$filters" ]; then
        print_error "Filters JSON required"
        echo 'Usage: docs delete-by-filter <filters_json> or --filters <json>'
        echo 'Example: docs delete-by-filter '"'"'{"category":{"$eq":"outdated"}}'"'"
        return 1
    fi

    local response=$(curl -s -X DELETE "${R2R_BASE_URL}/v3/documents/by_filter" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$filters")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "Deleted"
        return 0
    fi

    # Default
    echo "🗑️  Documents deletion initiated"
    echo "$response" | jq '.'
}

# Upload document with advanced options
docs_upload() {
    local file_path=""
    local collection_ids=""
    local metadata_title=""
    local ingestion_mode="hi-res"
    local ingestion_config=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --collections|--coll|-c)
                collection_ids="$2"
                shift 2
                ;;
            --title|-t)
                metadata_title="$2"
                shift 2
                ;;
            --mode|-m)
                ingestion_mode="$2"
                shift 2
                ;;
            --config)
                ingestion_config="$2"
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
                if [ -z "$file_path" ]; then
                    file_path="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$file_path" ]; then
        print_error "File path required"
        echo "Usage: docs upload <file> [--collections <ids>] [--title <title>] [--mode <hi-res|fast|custom>] [--config <json>]"
        return 1
    fi

    if [ ! -f "$file_path" ]; then
        print_error "File not found: $file_path"
        return 1
    fi

    # Build JSON payload using jq
    local payload

    if [ -n "$ingestion_config" ]; then
        payload=$(jq -n \
            --argjson config "$ingestion_config" \
            '{ingestion_mode: "custom", ingestion_config: $config}')
    else
        payload=$(jq -n \
            --arg mode "$ingestion_mode" \
            '{ingestion_mode: $mode}')
    fi

    # Add collection_ids if provided
    if [ -n "$collection_ids" ]; then
        local ids_array
        ids_array=$(echo "$collection_ids" | jq -R 'split(",")')
        payload=$(echo "$payload" | jq --argjson ids "$ids_array" '. + {collection_ids: $ids}')
    fi

    # Add metadata if provided
    if [ -n "$metadata_title" ]; then
        local metadata
        metadata=$(jq -n --arg title "$metadata_title" '{title: $title}')
        payload=$(echo "$payload" | jq --argjson meta "$metadata" '. + {metadata: $meta}')
    fi

    # Upload with multipart/form-data
    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/documents" \
        -H "Authorization: Bearer ${API_KEY}" \
        -F "file=@${file_path}" \
        -F "request=$(echo "$payload" | jq -c .)")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    local doc_id=$(echo "$response" | jq -r '.results.id // empty')

    # Quiet mode
    if [ "$quiet" = true ]; then
        [ -n "$doc_id" ] && echo "$doc_id" || echo "Upload failed"
        return 0
    fi

    # Default: ONE LINE
    if [ -n "$doc_id" ]; then
        local filename=$(basename "$file_path")
        printf "📤 Uploaded | doc:%s | %s | mode:%s\n" "${doc_id:0:8}" "$filename" "$ingestion_mode"
    else
        echo "❌ Upload failed"
        echo "$response" | jq '.'
    fi
}

# Update document content
docs_update() {
    local doc_id=""
    local file_path=""
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
                if [ -z "$doc_id" ]; then
                    doc_id="$1"
                elif [ -z "$file_path" ]; then
                    file_path="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$doc_id" ] || [ -z "$file_path" ]; then
        print_error "Document ID and file path required"
        echo "Usage: docs update <doc_id> <file_path> [--quiet|-q] [--json]"
        return 1
    fi

    if [ ! -f "$file_path" ]; then
        print_error "File not found: $file_path"
        return 1
    fi

    local response=$(curl -s -X PUT "${R2R_BASE_URL}/v3/documents/${doc_id}" \
        -H "Authorization: Bearer ${API_KEY}" \
        -F "file=@${file_path}")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "Updated"
        return 0
    fi

    # Default: ONE LINE
    printf "✏️  Updated | doc:%s | %s\n" "${doc_id:0:8}" "$(basename "$file_path")"
}

# Replace all metadata (PUT)
docs_metadata_put() {
    local doc_id=""
    local metadata_json=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --metadata|-m)
                metadata_json="$2"
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
                if [ -z "$doc_id" ]; then
                    doc_id="$1"
                elif [ -z "$metadata_json" ]; then
                    metadata_json="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$doc_id" ] || [ -z "$metadata_json" ]; then
        print_error "Document ID and metadata JSON required"
        echo "Usage: docs metadata-put <doc_id> <metadata_json> or --metadata <json>"
        echo 'Example: docs metadata-put abc123 '"'"'{"title":"New Title"}'"'"
        return 1
    fi

    local response=$(curl -s -X PUT "${R2R_BASE_URL}/v3/documents/${doc_id}/metadata" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$metadata_json")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "Replaced"
        return 0
    fi

    # Default: ONE LINE
    printf "🔄 Metadata replaced | doc:%s\n" "${doc_id:0:8}"
}

# Update specific metadata fields (PATCH)
docs_metadata_patch() {
    local doc_id=""
    local metadata_json=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --metadata|-m)
                metadata_json="$2"
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
                if [ -z "$doc_id" ]; then
                    doc_id="$1"
                elif [ -z "$metadata_json" ]; then
                    metadata_json="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$doc_id" ] || [ -z "$metadata_json" ]; then
        print_error "Document ID and metadata JSON required"
        echo "Usage: docs metadata-patch <doc_id> <metadata_json> or --metadata <json>"
        echo 'Example: docs metadata-patch abc123 '"'"'{"reviewed":true}'"'"
        return 1
    fi

    local response=$(curl -s -X PATCH "${R2R_BASE_URL}/v3/documents/${doc_id}/metadata" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$metadata_json")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "Updated"
        return 0
    fi

    # Default: ONE LINE
    printf "🔄 Metadata updated | doc:%s\n" "${doc_id:0:8}"
}

# Export documents to CSV
docs_export() {
    local output_file="documents_export.csv"
    local filters=""
    local quiet=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --output|-o)
                output_file="$2"
                shift 2
                ;;
            --filters|-f)
                filters="$2"
                shift 2
                ;;
            --quiet|-q)
                quiet=true
                shift
                ;;
            -*)
                print_error "Unknown flag: $1"
                return 1
                ;;
            *)
                output_file="$1"
                shift
                ;;
        esac
    done

    local payload='{"include_header":true}'
    if [ -n "$filters" ]; then
        payload=$(jq -n --argjson f "$filters" '{include_header: true, filters: $f}')
    fi

    curl -s -X POST "${R2R_BASE_URL}/v3/documents/export" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$payload" \
        > "$output_file"

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "$output_file"
        return 0
    fi

    # Default
    printf "📥 Exported | file:%s\n" "$output_file"
    echo ""
    head -5 "$output_file"
}

# Extract knowledge graph from document
docs_extract() {
    local doc_id=""
    local entity_types="Person,Organization,Technology,Concept"
    local relation_types="works_at,developed,uses,part_of,related_to"
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --entities|-e)
                entity_types="$2"
                shift 2
                ;;
            --relations|-r)
                relation_types="$2"
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
                if [ -z "$doc_id" ]; then
                    doc_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$doc_id" ]; then
        print_error "Document ID required"
        echo "Usage: docs extract <doc_id> [--entities <types>] [--relations <types>]"
        return 1
    fi

    # Convert comma-separated strings to JSON arrays
    local entity_array
    local relation_array
    entity_array=$(echo "$entity_types" | jq -R 'split(",")')
    relation_array=$(echo "$relation_types" | jq -R 'split(",")')

    # Build payload
    local payload
    payload=$(jq -n \
        --argjson entities "$entity_array" \
        --argjson relations "$relation_array" \
        '{entity_types: $entities, relation_types: $relations}')

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/documents/${doc_id}/extract" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$payload")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "Extraction initiated"
        return 0
    fi

    # Default: ONE LINE
    printf "🔍 Extraction initiated | doc:%s | entities:%d types | relations:%d types\n" \
        "${doc_id:0:8}" \
        "$(echo "$entity_array" | jq 'length')" \
        "$(echo "$relation_array" | jq 'length')"
}

# Deduplicate entities in document
docs_deduplicate() {
    local doc_id=""
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
                if [ -z "$doc_id" ]; then
                    doc_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$doc_id" ]; then
        print_error "Document ID required"
        echo "Usage: docs deduplicate <doc_id> [--quiet|-q] [--json]"
        return 1
    fi

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/documents/${doc_id}/deduplicate" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "Deduplication initiated"
        return 0
    fi

    # Default: ONE LINE
    printf "🔄 Deduplication initiated | doc:%s\n" "${doc_id:0:8}"
}

# Export entities from document
docs_export_entities() {
    local doc_id=""
    local output_file=""
    local quiet=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --output|-o)
                output_file="$2"
                shift 2
                ;;
            --quiet|-q)
                quiet=true
                shift
                ;;
            -*)
                print_error "Unknown flag: $1"
                return 1
                ;;
            *)
                if [ -z "$doc_id" ]; then
                    doc_id="$1"
                elif [ -z "$output_file" ]; then
                    output_file="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$doc_id" ]; then
        print_error "Document ID required"
        echo "Usage: docs export-entities <doc_id> [--output <file>]"
        return 1
    fi

    [ -z "$output_file" ] && output_file="entities_${doc_id}.csv"

    curl -s -X POST "${R2R_BASE_URL}/v3/documents/${doc_id}/entities/export" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"include_header":true}' \
        > "$output_file"

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "$output_file"
        return 0
    fi

    # Default
    printf "📥 Entities exported | doc:%s | file:%s\n" "${doc_id:0:8}" "$output_file"
    echo ""
    head -5 "$output_file"
}

# Export relationships from document
docs_export_relationships() {
    local doc_id=""
    local output_file=""
    local quiet=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --output|-o)
                output_file="$2"
                shift 2
                ;;
            --quiet|-q)
                quiet=true
                shift
                ;;
            -*)
                print_error "Unknown flag: $1"
                return 1
                ;;
            *)
                if [ -z "$doc_id" ]; then
                    doc_id="$1"
                elif [ -z "$output_file" ]; then
                    output_file="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$doc_id" ]; then
        print_error "Document ID required"
        echo "Usage: docs export-relationships <doc_id> [--output <file>]"
        return 1
    fi

    [ -z "$output_file" ] && output_file="relationships_${doc_id}.csv"

    curl -s -X POST "${R2R_BASE_URL}/v3/documents/${doc_id}/relationships/export" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"include_header":true}' \
        > "$output_file"

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "$output_file"
        return 0
    fi

    # Default
    printf "📥 Relationships exported | doc:%s | file:%s\n" "${doc_id:0:8}" "$output_file"
    echo ""
    head -5 "$output_file"
}

# Show help
show_help() {
    cat << 'EOF'
R2R Documents Commands

USAGE:
    docs <action> [arguments] [options]

DOCUMENT MANAGEMENT:
    list [options]                     List documents
        --limit, -l <num>              Number of results (default: 10)
        --offset, -o <num>             Skip N results (default: 0)
        --verbose, -v                  Show full details
        --quiet, -q                    Minimal output
        --json                         Raw JSON output

    get <doc_id> [options]             Get document details
        --quiet, -q                    Minimal output
        --json                         Raw JSON output

    delete <doc_id> [options]          Delete document by ID
        --quiet, -q                    Minimal output
        --json                         Raw JSON output

    delete-by-filter <filters> [opts]  Delete documents by filter
        --filters, -f <json>           Filter JSON
        --quiet, -q                    Minimal output
        --json                         Raw JSON output

    update <doc_id> <file> [options]   Update document content
        --quiet, -q                    Minimal output
        --json                         Raw JSON output

DOCUMENT UPLOAD:
    upload <file> [options]            Upload document (hi-res by default)
        --collections, -c <ids>        Comma-separated collection IDs
        --title, -t <title>            Document title
        --mode, -m <mode>              hi-res (default), fast, or custom
        --config <json>                Custom ingestion config JSON
        --quiet, -q                    Minimal output (just doc ID)
        --json                         Raw JSON output

METADATA MANAGEMENT:
    metadata-put <doc_id> <json>       Replace all metadata
        --metadata, -m <json>          Metadata JSON (alternative syntax)
        --quiet, -q                    Minimal output
        --json                         Raw JSON output

    metadata-patch <doc_id> <json>     Update specific metadata fields
        --metadata, -m <json>          Metadata JSON (alternative syntax)
        --quiet, -q                    Minimal output
        --json                         Raw JSON output

EXPORT:
    export [options]                   Export documents to CSV
        --output, -o <file>            Output file (default: documents_export.csv)
        --filters, -f <json>           Filter documents to export
        --quiet, -q                    Minimal output

    export-entities <doc_id> [opts]    Export entities from document
        --output, -o <file>            Output file (default: entities_{id}.csv)
        --quiet, -q                    Minimal output

    export-relationships <doc_id>      Export relationships from document
        --output, -o <file>            Output file (default: relationships_{id}.csv)
        --quiet, -q                    Minimal output

KNOWLEDGE GRAPH:
    extract <doc_id> [options]         Extract knowledge graph
        --entities, -e <types>         Entity types (comma-separated)
        --relations, -r <types>        Relation types (comma-separated)
        --quiet, -q                    Minimal output
        --json                         Raw JSON output

    deduplicate <doc_id> [options]     Deduplicate entities
        --quiet, -q                    Minimal output
        --json                         Raw JSON output

OUTPUT MODES:
    Default - ONE LINE per document (list):
        📄 Documents | limit:10 | offset:0

        📄 Doc | abc123 | Document.pdf | status:success | 🗂️  2 colls | 2024-01-15

    Verbose (--verbose):
        ID: abc123-def456-...
        Title: Document.pdf
        Status: success
        Collections: coll1, coll2
        Created: 2024-01-15T10:30:00Z
        ---

    Quiet (--quiet):
        Document.pdf [abc123]

    JSON (--json):
        {"results": [...]}

EXAMPLES:
    # Basic operations
    docs list
    docs list --limit 20
    docs list -l 20 -o 10
    docs list --verbose
    docs list -v
    docs list --quiet
    docs list -q

    # Get document
    docs get abc123-def456-ghi789
    docs get abc123 --json
    docs get abc123 -q

    # Delete
    docs delete abc123-def456-ghi789
    docs delete abc123 --quiet
    docs delete-by-filter '{"category":{"$eq":"outdated"}}'
    docs delete-by-filter --filters '{"status":{"$eq":"failed"}}'

    # Upload with options
    docs upload document.pdf
    docs upload document.pdf --collections "coll1,coll2"
    docs upload document.pdf -c "coll1" -t "My Doc" -m fast
    docs upload doc.pdf --config '{"chunk_size":512}' --quiet
    docs upload doc.pdf -c "coll1" -t "Doc" -m hi-res --json

    # Update
    docs update abc123 new_version.pdf
    docs update abc123 file.pdf --quiet

    # Metadata management
    docs metadata-put abc123 '{"title":"New Title","author":"John Doe"}'
    docs metadata-put abc123 --metadata '{"title":"Title"}' --quiet
    docs metadata-patch abc123 '{"reviewed":true,"version":"2.0"}'
    docs metadata-patch abc123 -m '{"status":"published"}' -q

    # Knowledge graph extraction
    docs extract abc123
    docs extract abc123 --entities "Person,Organization"
    docs extract abc123 -e "Person" -r "works_at,located_in"
    docs extract abc123 --quiet
    docs deduplicate abc123
    docs deduplicate abc123 --json

    # Export operations
    docs export
    docs export --output my_docs.csv
    docs export -o filtered.csv --filters '{"status":{"$eq":"published"}}'
    docs export --quiet
    docs export-entities abc123
    docs export-entities abc123 --output entities.csv
    docs export-entities abc123 -o entities.csv -q
    docs export-relationships abc123 -o relationships.csv

INGESTION MODES:
    hi-res  - Comprehensive parsing with summaries (DEFAULT for quality)
    fast    - Speed-focused, skip enrichment
    custom  - Full control via ingestion_config (auto-enabled with config param)

METADATA OPERATIONS:
    PUT    - Replace ALL metadata (deletes unspecified fields)
    PATCH  - Update ONLY specified fields (preserves others)
EOF
}

# Command dispatcher
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    ACTION="${1:-help}"
    shift || true

    case "$ACTION" in
        list) docs_list "$@" ;;
        get) docs_get "$@" ;;
        delete) docs_delete "$@" ;;
        delete-by-filter) docs_delete_by_filter "$@" ;;
        update) docs_update "$@" ;;
        upload) docs_upload "$@" ;;
        metadata-put) docs_metadata_put "$@" ;;
        metadata-patch) docs_metadata_patch "$@" ;;
        export) docs_export "$@" ;;
        export-entities) docs_export_entities "$@" ;;
        export-relationships) docs_export_relationships "$@" ;;
        extract) docs_extract "$@" ;;
        deduplicate) docs_deduplicate "$@" ;;
        help|--help|-h) show_help ;;
        *) echo "Unknown action: $ACTION" >&2; show_help; exit 1 ;;
    esac
fi
