#!/usr/bin/env bash
# R2R Knowledge Graph Commands
# Manage entities, relationships, and communities

source "$(dirname "$0")/../lib/common.sh"

# List entities in collection
graph_entities() {
    local collection_id=""
    local limit=20
    local offset=0
    local quiet=false
    local verbose=false
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ]; then
        print_error "Collection ID required"
        echo "Usage: graph entities <collection_id> [--limit <n>] [--offset <n>]"
        return 1
    fi

    local response=$(curl -s -X GET "${R2R_BASE_URL}/v3/graphs/${collection_id}/entities?limit=${limit}&offset=${offset}" \
        -H "Authorization: Bearer ${API_KEY}")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "$response" | jq -r '.results[] | "\(.name) [\(.id[:8] // "N/A")]"'
        return 0
    fi

    # Print header
    printf "🔷 Entities | collection:%s | limit:%s\n" "${collection_id:0:8}" "$limit"
    echo ""

    # Verbose mode
    if [ "$verbose" = true ]; then
        echo "$response" | jq -r '.results[] |
            "Name: \(.name)\n" +
            "Category: \(.category)\n" +
            "Description: \(.description)\n" +
            "ID: \(.id // "N/A")\n" +
            "---"'
    else
        # Default: ONE LINE per entity
        echo "$response" | jq -r '.results[] |
            "🔷 Entity | \(.id[:8] // "N/A") | \(.name) | category:\(.category) | \(.description[:60])..."'
    fi
}

# List relationships in collection
graph_relationships() {
    local collection_id=""
    local limit=20
    local offset=0
    local quiet=false
    local verbose=false
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ]; then
        print_error "Collection ID required"
        echo "Usage: graph relationships <collection_id> [--limit <n>] [--offset <n>]"
        return 1
    fi

    local response=$(curl -s -X GET "${R2R_BASE_URL}/v3/graphs/${collection_id}/relationships?limit=${limit}&offset=${offset}" \
        -H "Authorization: Bearer ${API_KEY}")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "$response" | jq -r '.results[] | "\(.subject) -> \(.predicate) -> \(.object)"'
        return 0
    fi

    # Print header
    printf "🔗 Relationships | collection:%s | limit:%s\n" "${collection_id:0:8}" "$limit"
    echo ""

    # Verbose mode
    if [ "$verbose" = true ]; then
        echo "$response" | jq -r '.results[] |
            "\(.subject) -> \(.predicate) -> \(.object)\n" +
            "Description: \(.description)\n" +
            "Weight: \(.weight // "N/A")\n" +
            "ID: \(.id // "N/A")\n" +
            "---"'
    else
        # Default: ONE LINE per relationship
        echo "$response" | jq -r '.results[] |
            "🔗 Rel | \(.id[:8] // "N/A") | \(.subject) -> \(.predicate) -> \(.object) | weight:\(.weight // "N/A")"'
    fi
}

# List communities in collection
graph_communities() {
    local collection_id=""
    local limit=20
    local offset=0
    local quiet=false
    local verbose=false
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ]; then
        print_error "Collection ID required"
        echo "Usage: graph communities <collection_id> [--limit <n>] [--offset <n>]"
        return 1
    fi

    local response=$(curl -s -X GET "${R2R_BASE_URL}/v3/graphs/${collection_id}/communities?limit=${limit}&offset=${offset}" \
        -H "Authorization: Bearer ${API_KEY}")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "$response" | jq -r '.results[] | "\(.name) [\(.id[:8])] - rating:\(.rating // "N/A")/10"'
        return 0
    fi

    # Print header
    printf "🌐 Communities | collection:%s | limit:%s\n" "${collection_id:0:8}" "$limit"
    echo ""

    # Verbose mode
    if [ "$verbose" = true ]; then
        echo "$response" | jq -r '.results[] |
            "ID: \(.id)\n" +
            "Name: \(.name)\n" +
            "Summary: \(.summary)\n" +
            "Rating: \(.rating // "N/A")/10\n" +
            "Findings:\n- \(.findings | join("\n- "))\n" +
            "---"'
    else
        # Default: ONE LINE per community
        echo "$response" | jq -r '.results[] |
            "🌐 Community | \(.id[:8]) | \(.name) | rating:\(.rating // "N/A")/10 | \(.summary[:50])..."'
    fi
}

# Build communities for collection
graph_build_communities() {
    local collection_id=""
    local leiden_params=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --leiden-params)
                leiden_params="$2"
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ]; then
        print_error "Collection ID required"
        echo "Usage: graph build-communities <collection_id> [--leiden-params <json>]"
        return 1
    fi

    local payload
    if [ -n "$leiden_params" ]; then
        payload=$(jq -n \
            --argjson params "$leiden_params" \
            '{graph_enrichment_settings: {leiden_params: $params}}')
    else
        payload='{"message":"Building communities"}'
    fi

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/communities/build" \
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
        echo "Building"
        return 0
    fi

    # Default: ONE LINE
    printf "🏗️  Building communities | collection:%s\n" "${collection_id:0:8}"
}

# Pull graph data (sync)
graph_pull() {
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
        echo "Usage: graph pull <collection_id> [--quiet|-q] [--json]"
        return 1
    fi

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/pull" \
        -H "Authorization: Bearer ${API_KEY}")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "Synced"
        return 0
    fi

    # Default: ONE LINE
    printf "🔄 Graph synced | collection:%s\n" "${collection_id:0:8}"
}

# Reset graph
graph_reset() {
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
        echo "Usage: graph reset <collection_id> [--quiet|-q] [--json]"
        return 1
    fi

    if [ "$quiet" != true ]; then
        print_info "⚠️  WARNING: This will delete all entities, relationships, and communities!"
    fi

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/reset" \
        -H "Authorization: Bearer ${API_KEY}")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "Reset"
        return 0
    fi

    # Default: ONE LINE
    printf "🔄 Graph reset | collection:%s\n" "${collection_id:0:8}"
}

# Update graph metadata
graph_update() {
    local collection_id=""
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ]; then
        print_error "Collection ID required"
        echo "Usage: graph update <collection_id> [--name <name>] [--description <desc>]"
        return 1
    fi

    local payload
    payload=$(jq -n \
        --arg name "$name" \
        --arg desc "$description" \
        '{} | if $name != "" then .name = $name else . end | if $desc != "" then .description = $desc else . end')

    local response=$(curl -s -X PUT "${R2R_BASE_URL}/v3/graphs/${collection_id}" \
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
        echo "Updated"
        return 0
    fi

    # Default: ONE LINE
    printf "✏️  Graph updated | collection:%s\n" "${collection_id:0:8}"
}

# Create entity
graph_create_entity() {
    local collection_id=""
    local name=""
    local description=""
    local category="Concept"
    local metadata=""
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
            --category|--cat|-c)
                category="$2"
                shift 2
                ;;
            --metadata|-m)
                metadata="$2"
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ] || [ -z "$name" ] || [ -z "$description" ]; then
        print_error "Collection ID, name, and description required"
        echo "Usage: graph create-entity <collection_id> --name <name> --description <desc> [--category <cat>] [--metadata <json>]"
        return 1
    fi

    local payload
    payload=$(jq -n \
        --arg name "$name" \
        --arg desc "$description" \
        --arg cat "$category" \
        '{name: $name, description: $desc, category: $cat}')

    if [ -n "$metadata" ]; then
        payload=$(echo "$payload" | jq --argjson meta "$metadata" '. + {metadata: $meta}')
    fi

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/entities" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$payload")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    local entity_id=$(echo "$response" | jq -r '.results.id // empty')

    # Quiet mode
    if [ "$quiet" = true ]; then
        [ -n "$entity_id" ] && echo "$entity_id" || echo "Creation failed"
        return 0
    fi

    # Default: ONE LINE
    if [ -n "$entity_id" ]; then
        printf "✅ Entity created | %s | %s | category:%s\n" "${entity_id:0:8}" "$name" "$category"
    else
        echo "❌ Entity creation failed"
        echo "$response" | jq '.'
    fi
}

# Update entity
graph_update_entity() {
    local collection_id=""
    local entity_id=""
    local name=""
    local description=""
    local category=""
    local metadata=""
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
            --category|--cat|-c)
                category="$2"
                shift 2
                ;;
            --metadata|-m)
                metadata="$2"
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                elif [ -z "$entity_id" ]; then
                    entity_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ] || [ -z "$entity_id" ]; then
        print_error "Collection ID and Entity ID required"
        echo "Usage: graph update-entity <collection_id> <entity_id> [--name <name>] [--description <desc>] [--category <cat>] [--metadata <json>]"
        return 1
    fi

    local payload="{}"
    [ -n "$name" ] && payload=$(echo "$payload" | jq --arg n "$name" '. + {name: $n}')
    [ -n "$description" ] && payload=$(echo "$payload" | jq --arg d "$description" '. + {description: $d}')
    [ -n "$category" ] && payload=$(echo "$payload" | jq --arg c "$category" '. + {category: $c}')
    [ -n "$metadata" ] && payload=$(echo "$payload" | jq --argjson m "$metadata" '. + {metadata: $m}')

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/entities/${entity_id}" \
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
        echo "Updated"
        return 0
    fi

    # Default: ONE LINE
    printf "✏️  Entity updated | %s\n" "${entity_id:0:8}"
}

# Delete entity
graph_delete_entity() {
    local collection_id=""
    local entity_id=""
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
                elif [ -z "$entity_id" ]; then
                    entity_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ] || [ -z "$entity_id" ]; then
        print_error "Collection ID and Entity ID required"
        echo "Usage: graph delete-entity <collection_id> <entity_id> [--quiet|-q] [--json]"
        return 1
    fi

    local response=$(curl -s -X DELETE "${R2R_BASE_URL}/v3/graphs/${collection_id}/entities/${entity_id}" \
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
    printf "🗑️  Entity deleted | %s\n" "${entity_id:0:8}"
}

# Create relationship
graph_create_relationship() {
    local collection_id=""
    local subject=""
    local predicate=""
    local object=""
    local description=""
    local weight=""
    local subject_id=""
    local object_id=""
    local metadata=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --subject|-s)
                subject="$2"
                shift 2
                ;;
            --predicate|--pred|-p)
                predicate="$2"
                shift 2
                ;;
            --object|--obj|-o)
                object="$2"
                shift 2
                ;;
            --description|--desc|-d)
                description="$2"
                shift 2
                ;;
            --weight|-w)
                weight="$2"
                shift 2
                ;;
            --subject-id)
                subject_id="$2"
                shift 2
                ;;
            --object-id)
                object_id="$2"
                shift 2
                ;;
            --metadata|-m)
                metadata="$2"
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ] || [ -z "$subject" ] || [ -z "$predicate" ] || [ -z "$object" ]; then
        print_error "Collection ID, subject, predicate, and object required"
        echo "Usage: graph create-relationship <collection_id> --subject <name> --predicate <type> --object <name> [options]"
        return 1
    fi

    local payload
    payload=$(jq -n \
        --arg subj "$subject" \
        --arg pred "$predicate" \
        --arg obj "$object" \
        '{subject: $subj, predicate: $pred, object: $obj}')

    [ -n "$description" ] && payload=$(echo "$payload" | jq --arg d "$description" '. + {description: $d}')
    [ -n "$weight" ] && payload=$(echo "$payload" | jq --argjson w "$weight" '. + {weight: $w}')
    [ -n "$subject_id" ] && payload=$(echo "$payload" | jq --arg sid "$subject_id" '. + {subject_id: $sid}')
    [ -n "$object_id" ] && payload=$(echo "$payload" | jq --arg oid "$object_id" '. + {object_id: $oid}')
    [ -n "$metadata" ] && payload=$(echo "$payload" | jq --argjson m "$metadata" '. + {metadata: $m}')

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/relationships" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$payload")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    local rel_id=$(echo "$response" | jq -r '.results.id // empty')

    # Quiet mode
    if [ "$quiet" = true ]; then
        [ -n "$rel_id" ] && echo "$rel_id" || echo "Creation failed"
        return 0
    fi

    # Default: ONE LINE
    if [ -n "$rel_id" ]; then
        printf "✅ Relationship created | %s | %s -> %s -> %s\n" "${rel_id:0:8}" "$subject" "$predicate" "$object"
    else
        echo "❌ Relationship creation failed"
        echo "$response" | jq '.'
    fi
}

# Update relationship
graph_update_relationship() {
    local collection_id=""
    local relationship_id=""
    local subject=""
    local predicate=""
    local object=""
    local description=""
    local weight=""
    local metadata=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --subject|-s)
                subject="$2"
                shift 2
                ;;
            --predicate|--pred|-p)
                predicate="$2"
                shift 2
                ;;
            --object|--obj|-o)
                object="$2"
                shift 2
                ;;
            --description|--desc|-d)
                description="$2"
                shift 2
                ;;
            --weight|-w)
                weight="$2"
                shift 2
                ;;
            --metadata|-m)
                metadata="$2"
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                elif [ -z "$relationship_id" ]; then
                    relationship_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ] || [ -z "$relationship_id" ]; then
        print_error "Collection ID and Relationship ID required"
        echo "Usage: graph update-relationship <collection_id> <relationship_id> [options]"
        return 1
    fi

    local payload="{}"
    [ -n "$subject" ] && payload=$(echo "$payload" | jq --arg s "$subject" '. + {subject: $s}')
    [ -n "$predicate" ] && payload=$(echo "$payload" | jq --arg p "$predicate" '. + {predicate: $p}')
    [ -n "$object" ] && payload=$(echo "$payload" | jq --arg o "$object" '. + {object: $o}')
    [ -n "$description" ] && payload=$(echo "$payload" | jq --arg d "$description" '. + {description: $d}')
    [ -n "$weight" ] && payload=$(echo "$payload" | jq --argjson w "$weight" '. + {weight: $w}')
    [ -n "$metadata" ] && payload=$(echo "$payload" | jq --argjson m "$metadata" '. + {metadata: $m}')

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/relationships/${relationship_id}" \
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
        echo "Updated"
        return 0
    fi

    # Default: ONE LINE
    printf "✏️  Relationship updated | %s\n" "${relationship_id:0:8}"
}

# Delete relationship
graph_delete_relationship() {
    local collection_id=""
    local relationship_id=""
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
                elif [ -z "$relationship_id" ]; then
                    relationship_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ] || [ -z "$relationship_id" ]; then
        print_error "Collection ID and Relationship ID required"
        echo "Usage: graph delete-relationship <collection_id> <relationship_id> [--quiet|-q] [--json]"
        return 1
    fi

    local response=$(curl -s -X DELETE "${R2R_BASE_URL}/v3/graphs/${collection_id}/relationships/${relationship_id}" \
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
    printf "🗑️  Relationship deleted | %s\n" "${relationship_id:0:8}"
}

# Create community
graph_create_community() {
    local collection_id=""
    local name=""
    local summary=""
    local findings=""
    local rating=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --name|-n)
                name="$2"
                shift 2
                ;;
            --summary|-s)
                summary="$2"
                shift 2
                ;;
            --findings|-f)
                findings="$2"
                shift 2
                ;;
            --rating|-r)
                rating="$2"
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ] || [ -z "$name" ]; then
        print_error "Collection ID and name required"
        echo "Usage: graph create-community <collection_id> --name <name> [--summary <text>] [--findings <json_array>] [--rating <1-10>]"
        return 1
    fi

    local payload
    payload=$(jq -n --arg n "$name" '{name: $n}')

    [ -n "$summary" ] && payload=$(echo "$payload" | jq --arg s "$summary" '. + {summary: $s}')
    [ -n "$findings" ] && payload=$(echo "$payload" | jq --argjson f "$findings" '. + {findings: $f}')
    [ -n "$rating" ] && payload=$(echo "$payload" | jq --argjson r "$rating" '. + {rating: $r}')

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/communities" \
        -H "Authorization: Bearer ${API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$payload")

    # JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    local comm_id=$(echo "$response" | jq -r '.results.id // empty')

    # Quiet mode
    if [ "$quiet" = true ]; then
        [ -n "$comm_id" ] && echo "$comm_id" || echo "Creation failed"
        return 0
    fi

    # Default: ONE LINE
    if [ -n "$comm_id" ]; then
        printf "✅ Community created | %s | %s\n" "${comm_id:0:8}" "$name"
    else
        echo "❌ Community creation failed"
        echo "$response" | jq '.'
    fi
}

# Update community
graph_update_community() {
    local collection_id=""
    local community_id=""
    local name=""
    local summary=""
    local findings=""
    local rating=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --name|-n)
                name="$2"
                shift 2
                ;;
            --summary|-s)
                summary="$2"
                shift 2
                ;;
            --findings|-f)
                findings="$2"
                shift 2
                ;;
            --rating|-r)
                rating="$2"
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                elif [ -z "$community_id" ]; then
                    community_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ] || [ -z "$community_id" ]; then
        print_error "Collection ID and Community ID required"
        echo "Usage: graph update-community <collection_id> <community_id> [options]"
        return 1
    fi

    local payload="{}"
    [ -n "$name" ] && payload=$(echo "$payload" | jq --arg n "$name" '. + {name: $n}')
    [ -n "$summary" ] && payload=$(echo "$payload" | jq --arg s "$summary" '. + {summary: $s}')
    [ -n "$findings" ] && payload=$(echo "$payload" | jq --argjson f "$findings" '. + {findings: $f}')
    [ -n "$rating" ] && payload=$(echo "$payload" | jq --argjson r "$rating" '. + {rating: $r}')

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/communities/${community_id}" \
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
        echo "Updated"
        return 0
    fi

    # Default: ONE LINE
    printf "✏️  Community updated | %s\n" "${community_id:0:8}"
}

# Delete community
graph_delete_community() {
    local collection_id=""
    local community_id=""
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
                elif [ -z "$community_id" ]; then
                    community_id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ] || [ -z "$community_id" ]; then
        print_error "Collection ID and Community ID required"
        echo "Usage: graph delete-community <collection_id> <community_id> [--quiet|-q] [--json]"
        return 1
    fi

    local response=$(curl -s -X DELETE "${R2R_BASE_URL}/v3/graphs/${collection_id}/communities/${community_id}" \
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
    printf "🗑️  Community deleted | %s\n" "${community_id:0:8}"
}

# Export entities
graph_export_entities() {
    local collection_id=""
    local output_file=""
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                elif [ -z "$output_file" ]; then
                    output_file="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ]; then
        print_error "Collection ID required"
        echo "Usage: graph export-entities <collection_id> [--output <file>] [--filters <json>]"
        return 1
    fi

    [ -z "$output_file" ] && output_file="entities_${collection_id}.csv"

    local payload='{"include_header":true}'
    if [ -n "$filters" ]; then
        payload=$(jq -n --argjson f "$filters" '{include_header: true, filters: $f}')
    fi

    curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/entities/export" \
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
    printf "📥 Entities exported | collection:%s | file:%s\n" "${collection_id:0:8}" "$output_file"
    echo ""
    head -5 "$output_file"
}

# Export relationships
graph_export_relationships() {
    local collection_id=""
    local output_file=""
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                elif [ -z "$output_file" ]; then
                    output_file="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ]; then
        print_error "Collection ID required"
        echo "Usage: graph export-relationships <collection_id> [--output <file>] [--filters <json>]"
        return 1
    fi

    [ -z "$output_file" ] && output_file="relationships_${collection_id}.csv"

    local payload='{"include_header":true}'
    if [ -n "$filters" ]; then
        payload=$(jq -n --argjson f "$filters" '{include_header: true, filters: $f}')
    fi

    curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/relationships/export" \
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
    printf "📥 Relationships exported | collection:%s | file:%s\n" "${collection_id:0:8}" "$output_file"
    echo ""
    head -5 "$output_file"
}

# Export communities
graph_export_communities() {
    local collection_id=""
    local output_file=""
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
                if [ -z "$collection_id" ]; then
                    collection_id="$1"
                elif [ -z "$output_file" ]; then
                    output_file="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$collection_id" ]; then
        print_error "Collection ID required"
        echo "Usage: graph export-communities <collection_id> [--output <file>] [--filters <json>]"
        return 1
    fi

    [ -z "$output_file" ] && output_file="communities_${collection_id}.csv"

    local payload='{"include_header":true}'
    if [ -n "$filters" ]; then
        payload=$(jq -n --argjson f "$filters" '{include_header: true, filters: $f}')
    fi

    curl -s -X POST "${R2R_BASE_URL}/v3/graphs/${collection_id}/communities/export" \
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
    printf "📥 Communities exported | collection:%s | file:%s\n" "${collection_id:0:8}" "$output_file"
    echo ""
    head -5 "$output_file"
}

# Show help
show_help() {
    cat << 'EOF'
R2R Knowledge Graph Commands

USAGE:
    graph <action> [arguments] [options]

LISTING:
    entities <collection_id> [opts]     List entities
        --limit, -l <n>                 Number of results (default: 20)
        --offset, -o <n>                Skip first N results (default: 0)
        --verbose, -v                   Show full details
        --quiet, -q                     Minimal output
        --json                          Raw JSON output

    relationships <col_id> [opts]       List relationships
        --limit, -l <n>                 Number of results (default: 20)
        --offset, -o <n>                Skip first N results (default: 0)
        --verbose, -v                   Show full details
        --quiet, -q                     Minimal output
        --json                          Raw JSON output

    communities <collection_id> [opts]  List communities
        --limit, -l <n>                 Number of results (default: 20)
        --offset, -o <n>                Skip first N results (default: 0)
        --verbose, -v                   Show full details
        --quiet, -q                     Minimal output
        --json                          Raw JSON output

GRAPH OPERATIONS:
    pull <collection_id> [options]      Sync graph data from documents
        --quiet, -q                     Minimal output
        --json                          Raw JSON output

    reset <collection_id> [options]     Reset graph (deletes all data)
        --quiet, -q                     Minimal output
        --json                          Raw JSON output

    update <collection_id> [options]    Update graph metadata
        --name, -n <name>               Graph name
        --description, -d <desc>        Graph description
        --quiet, -q                     Minimal output
        --json                          Raw JSON output

ENTITY MANAGEMENT:
    create-entity <col_id> [options]    Create new entity
        --name, -n <name>               Entity name (required)
        --description, -d <desc>        Entity description (required)
        --category, -c <type>           Entity category (default: Concept)
        --metadata, -m <json>           Additional metadata
        --quiet, -q                     Minimal output (just ID)
        --json                          Raw JSON output

    update-entity <col_id> <ent_id>     Update existing entity
        --name, -n <name>               New name
        --description, -d <desc>        New description
        --category, -c <type>           New category
        --metadata, -m <json>           New metadata
        --quiet, -q                     Minimal output
        --json                          Raw JSON output

    delete-entity <col_id> <entity_id>  Delete entity
        --quiet, -q                     Minimal output
        --json                          Raw JSON output

RELATIONSHIP MANAGEMENT:
    create-relationship <col_id> [opts] Create new relationship
        --subject, -s <name>            Subject entity (required)
        --predicate, -p <type>          Relationship type (required)
        --object, -o <name>             Object entity (required)
        --description, -d <desc>        Relationship description
        --weight, -w <number>           Relationship weight
        --subject-id <id>               Subject entity ID
        --object-id <id>                Object entity ID
        --metadata, -m <json>           Additional metadata
        --quiet, -q                     Minimal output (just ID)
        --json                          Raw JSON output

    update-relationship <col> <rel_id>  Update existing relationship
        --subject, -s <name>            New subject
        --predicate, -p <type>          New predicate
        --object, -o <name>             New object
        --description, -d <desc>        New description
        --weight, -w <number>           New weight
        --metadata, -m <json>           New metadata
        --quiet, -q                     Minimal output
        --json                          Raw JSON output

    delete-relationship <col> <rel_id>  Delete relationship
        --quiet, -q                     Minimal output
        --json                          Raw JSON output

COMMUNITY MANAGEMENT:
    build-communities <col_id> [opts]   Build communities automatically
        --leiden-params <json>          Leiden algorithm parameters
        --quiet, -q                     Minimal output
        --json                          Raw JSON output

    create-community <col_id> [options] Create community manually
        --name, -n <name>               Community name (required)
        --summary, -s <text>            Community summary
        --findings, -f <json_array>     Key findings
        --rating, -r <1-10>             Quality rating
        --quiet, -q                     Minimal output (just ID)
        --json                          Raw JSON output

    update-community <col> <com_id>     Update existing community
        --name, -n <name>               New name
        --summary, -s <text>            New summary
        --findings, -f <json_array>     New findings
        --rating, -r <1-10>             New rating
        --quiet, -q                     Minimal output
        --json                          Raw JSON output

    delete-community <col> <com_id>     Delete community
        --quiet, -q                     Minimal output
        --json                          Raw JSON output

EXPORT:
    export-entities <col_id> [options]  Export entities to CSV
        --output, -o <file>             Output file (default: entities_{id}.csv)
        --filters, -f <json>            Filter entities to export
        --quiet, -q                     Minimal output (just filename)

    export-relationships <col> [opts]   Export relationships to CSV
        --output, -o <file>             Output file (default: relationships_{id}.csv)
        --filters, -f <json>            Filter relationships
        --quiet, -q                     Minimal output (just filename)

    export-communities <col_id> [opts]  Export communities to CSV
        --output, -o <file>             Output file (default: communities_{id}.csv)
        --filters, -f <json>            Filter communities
        --quiet, -q                     Minimal output (just filename)

OUTPUT MODES:
    Default - ONE LINE per item (list):
        🔷 Entities | collection:abc123 | limit:20

        🔷 Entity | ent-123 | Claude | category:Technology | AI assistant...

    Verbose (--verbose):
        Name: Claude
        Category: Technology
        Description: AI assistant
        ID: ent-123...
        ---

    Quiet (--quiet):
        Claude [ent-123]

    JSON (--json):
        {"results": [...]}

EXAMPLES:
    # List operations
    graph entities abc123
    graph entities abc123 --limit 50 --offset 10
    graph entities abc123 -l 50 -o 10
    graph entities abc123 --verbose
    graph entities abc123 -v
    graph entities abc123 --quiet
    graph entities abc123 -q
    graph relationships abc123 -l 30
    graph communities abc123

    # Graph operations
    graph pull abc123
    graph pull abc123 --quiet
    graph update abc123 --name "Research Graph" --description "AI Research"
    graph update abc123 -n "Graph" -d "Description" -q
    graph reset abc123
    graph reset abc123 --json

    # Entity management
    graph create-entity abc123 --name "Claude" --description "AI assistant" --category "Technology"
    graph create-entity abc123 -n "Claude" -d "AI assistant" -c "Technology"
    graph create-entity abc123 -n "Anthropic" -d "AI company" --metadata '{"founded":"2021"}' -q
    graph update-entity abc123 ent-123 --description "Updated description"
    graph update-entity abc123 ent-123 -d "New desc" -q
    graph delete-entity abc123 ent-123
    graph delete-entity abc123 ent-123 --json

    # Relationship management
    graph create-relationship abc123 --subject "Claude" --predicate "developed_by" --object "Anthropic"
    graph create-relationship abc123 -s "Claude" -p "developed_by" -o "Anthropic"
    graph create-relationship abc123 -s "Claude" -p "uses" -o "Transformers" --weight 1.5
    graph create-relationship abc123 -s "A" -p "rel" -o "B" -w 2.0 -q
    graph update-relationship abc123 rel-456 --weight 2.0 --description "Strong connection"
    graph update-relationship abc123 rel-456 -w 2.0 -d "Connection" -q
    graph delete-relationship abc123 rel-456

    # Community management
    graph build-communities abc123
    graph build-communities abc123 --leiden-params '{"resolution":0.8}'
    graph build-communities abc123 --quiet
    graph create-community abc123 --name "AI Research" --summary "AI-related entities"
    graph create-community abc123 -n "AI Research" -s "Summary" -r 9
    graph update-community abc123 com-789 --rating 9
    graph update-community abc123 com-789 -r 9 -q
    graph delete-community abc123 com-789

    # Export operations
    graph export-entities abc123
    graph export-entities abc123 --output entities.csv
    graph export-entities abc123 -o entities.csv -q
    graph export-relationships abc123 -o relationships.csv
    graph export-communities abc123 --filters '{"rating":{"$gte":8}}'

ENTITY CATEGORIES:
    Person, Organization, Technology, Concept, Location, Event, etc.

COMMON PREDICATES:
    works_at, developed_by, uses, part_of, related_to, located_in, etc.

ALIASES:
    relationships -> rels
    build-communities -> build
    pull -> sync
    create-entity -> add-entity
    create-relationship -> add-rel, create-rel
EOF
}

# Command dispatcher
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    ACTION="${1:-help}"
    shift || true

    case "$ACTION" in
        # Listing
        entities) graph_entities "$@" ;;
        relationships|rels) graph_relationships "$@" ;;
        communities) graph_communities "$@" ;;

        # Graph operations
        pull|sync) graph_pull "$@" ;;
        reset) graph_reset "$@" ;;
        update) graph_update "$@" ;;

        # Entity management
        create-entity|add-entity) graph_create_entity "$@" ;;
        update-entity) graph_update_entity "$@" ;;
        delete-entity) graph_delete_entity "$@" ;;

        # Relationship management
        create-relationship|create-rel|add-rel) graph_create_relationship "$@" ;;
        update-relationship|update-rel) graph_update_relationship "$@" ;;
        delete-relationship|delete-rel) graph_delete_relationship "$@" ;;

        # Community management
        build-communities|build) graph_build_communities "$@" ;;
        create-community|add-community) graph_create_community "$@" ;;
        update-community) graph_update_community "$@" ;;
        delete-community) graph_delete_community "$@" ;;

        # Export
        export-entities) graph_export_entities "$@" ;;
        export-relationships|export-rels) graph_export_relationships "$@" ;;
        export-communities) graph_export_communities "$@" ;;

        help|--help|-h) show_help ;;
        *) echo "Unknown action: $ACTION" >&2; show_help; exit 1 ;;
    esac
fi
