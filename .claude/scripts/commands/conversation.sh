#!/usr/bin/env bash
# R2R Conversation Management Command
# Create, list, get, delete conversations

source "$(dirname "$0")/../lib/common.sh"

# Create new conversation
conversation_create() {
    local name=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --name|-n)
                name="$2"
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
                # Positional: first arg is name
                if [ -z "$name" ]; then
                    name="$1"
                fi
                shift
                ;;
        esac
    done

    # Build payload with optional name
    local payload
    if [ -n "$name" ]; then
        payload=$(jq -n --arg name "$name" '{name: $name}')
    else
        payload='{}'
    fi

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/conversations" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -d "$payload")

    # Handle JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    local conv_id=$(echo "$response" | jq -r '.results.id // empty')

    if [ -n "$conv_id" ]; then
        # Save to temp file for easy reuse
        echo "$conv_id" > /tmp/.r2r_conversation_id

        if [ "$quiet" = true ]; then
            echo "$conv_id"
        else
            printf "💬 Created | conversation:%s" "${conv_id:0:8}"
            [ -n "$name" ] && printf " | %s" "$name"
            printf "\n"
        fi
    else
        echo "$response" | jq '.'
    fi
}

# List all conversations
conversation_list() {
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

    local response=$(curl -s -X GET "${R2R_BASE_URL}/v3/conversations?limit=${limit}&offset=${offset}" \
        -H "Authorization: Bearer ${API_KEY}")

    # Handle JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    # Quiet mode
    if [ "$quiet" = true ]; then
        echo "$response" | jq -r '.results[] | "\(.name // "Unnamed") [\(.id[:8])]"'
        return 0
    fi

    # Default: ONE LINE per conversation
    echo "$response" | jq -r '.results[] |
        "💬 Conversation | \(.id[:8]) | \(.name // "Unnamed") | created:\(.created_at[:10])"'
}

# Get conversation details
conversation_get() {
    local id=""
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
                if [ -z "$id" ]; then
                    id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$id" ]; then
        print_error "Conversation ID required"
        echo "Usage: conversation get <id> [options]"
        return 1
    fi

    local response=$(curl -s -X GET "${R2R_BASE_URL}/v3/conversations/${id}" \
        -H "Authorization: Bearer ${API_KEY}")

    # Handle JSON output (always show full response for get)
    if [ "$json_output" = true ] || [ "$quiet" != true ]; then
        echo "$response" | jq '.'
    else
        # Quiet mode: just basic info
        local name=$(echo "$response" | jq -r '.results.name // "Unnamed"')
        echo "$name [$id]"
    fi
}

# Delete conversation
conversation_delete() {
    local id=""
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
                if [ -z "$id" ]; then
                    id="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$id" ]; then
        print_error "Conversation ID required"
        echo "Usage: conversation delete <id> [options]"
        return 1
    fi

    local response=$(curl -s -X DELETE "${R2R_BASE_URL}/v3/conversations/${id}" \
        -H "Authorization: Bearer ${API_KEY}")

    # Handle JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    if [ "$quiet" = true ]; then
        echo "Deleted"
    else
        printf "🗑️  Deleted | conversation:%s\n" "${id:0:8}"
    fi
}

# Add message to conversation
conversation_add_message() {
    local id=""
    local role=""
    local content=""
    local quiet=false
    local json_output=false

    # Parse flags
    while [ $# -gt 0 ]; do
        case "$1" in
            --conversation|--conv|-c)
                id="$2"
                shift 2
                ;;
            --role|-r)
                role="$2"
                shift 2
                ;;
            --message|--msg|-m)
                content="$2"
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
                # Positional: id, role, content
                if [ -z "$id" ]; then
                    id="$1"
                elif [ -z "$role" ]; then
                    role="$1"
                elif [ -z "$content" ]; then
                    content="$1"
                fi
                shift
                ;;
        esac
    done

    if [ -z "$id" ] || [ -z "$role" ] || [ -z "$content" ]; then
        print_error "Conversation ID, role, and content required"
        echo "Usage: conversation add-message <id> <role> <content> [options]"
        return 1
    fi

    local payload=$(jq -n \
        --arg role "$role" \
        --arg content "$content" \
        '{role: $role, content: $content}')

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/conversations/${id}/messages" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -d "$payload")

    # Handle JSON output
    if [ "$json_output" = true ]; then
        echo "$response" | jq '.'
        return 0
    fi

    local message_id=$(echo "$response" | jq -r '.results.id // empty')

    if [ -n "$message_id" ]; then
        if [ "$quiet" = true ]; then
            echo "$message_id"
        else
            printf "✉️  Added | msg:%s | role:%s → conversation:%s\n" "${message_id:0:8}" "$role" "${id:0:8}"
        fi
    else
        echo "$response" | jq '.'
    fi
}

# Show help
show_help() {
    cat << 'EOF'
R2R Conversation Management

USAGE:
    conversation <subcommand> [arguments] [options]

SUBCOMMANDS:
    create [name]                   Create new conversation (optional name)
    list                            List all conversations
    get <id>                        Get conversation details
    delete <id>                     Delete conversation
    add-message <id> <role> <msg>   Add message to conversation

OPTIONS:
    --name, -n <name>         Conversation name (create only)
    --limit, -l <num>         Number of results (list only, default: 10)
    --offset, -o <num>        Skip N results (list only, default: 0)
    --conversation, -c <id>   Conversation ID (add-message)
    --role, -r <role>         Message role: user|assistant|system (add-message)
    --message, -m <content>   Message content (add-message)
    --quiet, -q               Minimal output
    --json                    Pretty JSON output

OUTPUT MODES:
    Default - ONE LINE per conversation (list):
        💬 Conversation | abc123 | My Conversation | created:2024-01-15

    Default - ONE LINE (create):
        💬 Created | conversation:abc123 | Research Session

    Default - ONE LINE (add-message):
        ✉️  Added | msg:def456 | role:user → conversation:abc123

    Quiet - minimal output:
        My Conversation [abc123]

    JSON - full API response

EXAMPLES:
    # Create new conversation
    conversation create "Research Session"
    conversation create --name "My Session"
    conversation create -n "Quick Chat"

    # Create unnamed conversation
    conversation create

    # Reuse last created conversation_id (from temp file)
    CONV_ID=$(head -1 /tmp/.r2r_conversation_id)
    conversation add-message $CONV_ID system "You are an expert"

    # List all conversations
    conversation list
    conversation list --limit 20
    conversation list -l 20 -o 10

    # Get conversation details
    conversation get abc123-def456
    conversation get abc123 --json

    # Delete conversation
    conversation delete abc123-def456
    conversation delete abc123 --quiet

    # Add system message
    conversation add-message abc123 system "You are an expert assistant"
    conversation add-message --conversation abc123 --role system --message "Be helpful"
    conversation add-message -c abc123 -r system -m "Be concise"

    # Add user message
    conversation add-message abc123 user "What is R2R?"
    conversation add-message -c abc123 -r user -m "Explain RAG"

    # Complete workflow with CONV_ID
    conversation create "My Session"
    CONV_ID=$(head -1 /tmp/.r2r_conversation_id)
    conversation add-message $CONV_ID system "Be helpful"
    conversation add-message $CONV_ID user "Hello"

    # JSON output
    conversation list --json
    conversation get abc123 --json
EOF
}

# Command dispatcher
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

SUBCOMMAND="$1"
shift

case "$SUBCOMMAND" in
    create)
        conversation_create "$@"
        ;;
    list)
        conversation_list "$@"
        ;;
    get)
        conversation_get "$@"
        ;;
    delete)
        conversation_delete "$@"
        ;;
    add-message|add-msg)
        conversation_add_message "$@"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown subcommand '$SUBCOMMAND'" >&2
        echo "Run 'conversation help' for usage" >&2
        exit 1
        ;;
esac
