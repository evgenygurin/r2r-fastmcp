#!/usr/bin/env bash
# R2R Conversation Management Command
# Create, list, get, delete conversations

source "$(dirname "$0")/../lib/common.sh"

# Conversation-specific flags
CONVERSATION_NAME=""
CONVERSATION_ID=""
MESSAGE_ROLE=""
MESSAGE_CONTENT=""

# Create new conversation
r2r_conversation_create() {
    local name="${1:-}"

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

    if [ "$JSON_OUTPUT" = true ]; then
        echo "$response" | jq '.'
    else
        local conv_id=$(echo "$response" | jq -r '.results.id // empty')
        if [ -n "$conv_id" ]; then
            echo "Conversation created: $conv_id"
            [ -n "$name" ] && echo "Name: $name"
        else
            echo "$response" | jq '.'
        fi
    fi
}

# List all conversations
r2r_conversation_list() {
    local response=$(curl -s -X GET "${R2R_BASE_URL}/v3/conversations" \
        -H "Authorization: Bearer ${API_KEY}")

    if [ "$JSON_OUTPUT" = true ]; then
        echo "$response" | jq '.'
    else
        echo "$response" | jq -r '.results[] | "\(.id) - \(.name // "Unnamed") - Created: \(.created_at)"'
    fi
}

# Get conversation details
r2r_conversation_get() {
    local id="$1"

    if [ -z "$id" ]; then
        echo "Error: conversation_id required" >&2
        exit 1
    fi

    local response=$(curl -s -X GET "${R2R_BASE_URL}/v3/conversations/${id}" \
        -H "Authorization: Bearer ${API_KEY}")

    echo "$response" | jq '.'
}

# Delete conversation
r2r_conversation_delete() {
    local id="$1"

    if [ -z "$id" ]; then
        echo "Error: conversation_id required" >&2
        exit 1
    fi

    local response=$(curl -s -X DELETE "${R2R_BASE_URL}/v3/conversations/${id}" \
        -H "Authorization: Bearer ${API_KEY}")

    if [ "$JSON_OUTPUT" = true ]; then
        echo "$response" | jq '.'
    else
        echo "Conversation deleted: $id"
    fi
}

# Add message to conversation
r2r_conversation_add_message() {
    local id="$1"
    local role="$2"
    local content="$3"

    if [ -z "$id" ] || [ -z "$role" ] || [ -z "$content" ]; then
        echo "Error: conversation_id, role, and content required" >&2
        echo "Usage: conversation add-message <id> <role> <content>" >&2
        exit 1
    fi

    local payload=$(jq -n \
        --arg role "$role" \
        --arg content "$content" \
        '{role: $role, content: $content}')

    local response=$(curl -s -X POST "${R2R_BASE_URL}/v3/conversations/${id}/messages" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${API_KEY}" \
        -d "$payload")

    if [ "$JSON_OUTPUT" = true ]; then
        echo "$response" | jq '.'
    else
        local message_id=$(echo "$response" | jq -r '.results.id // empty')
        if [ -n "$message_id" ]; then
            echo "Message added to conversation: $id"
            echo "Message ID: $message_id"
            echo "Role: $role"
        else
            echo "$response" | jq '.'
        fi
    fi
}

# Show help
show_help() {
    cat << EOF
R2R Conversation Management

USAGE:
    conversation <subcommand> [options]

SUBCOMMANDS:
    create [name]                   Create new conversation (optional name)
    list                            List all conversations
    get <id>                        Get conversation details
    delete <id>                     Delete conversation
    add-message <id> <role> <msg>   Add message to conversation

OPTIONS:
    --json                          Output raw JSON

EXAMPLES:
    # Create new conversation
    conversation create "Research Session"

    # Create unnamed conversation
    conversation create

    # List all conversations
    conversation list

    # Get conversation details
    conversation get abc123-def456

    # Delete conversation
    conversation delete abc123-def456

    # Add system message
    conversation add-message abc123 system "You are an expert assistant"

    # Add user message
    conversation add-message abc123 user "What is R2R?"

    # JSON output
    conversation list --json
EOF
}

# Parse subcommand and arguments
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

SUBCOMMAND="$1"
shift

# Parse flags
ARGS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
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

# Execute subcommand
case "$SUBCOMMAND" in
    create)
        r2r_conversation_create "${ARGS[0]:-}"
        ;;
    list)
        r2r_conversation_list
        ;;
    get)
        r2r_conversation_get "${ARGS[0]}"
        ;;
    delete)
        r2r_conversation_delete "${ARGS[0]}"
        ;;
    add-message)
        r2r_conversation_add_message "${ARGS[0]}" "${ARGS[1]}" "${ARGS[2]}"
        ;;
    help)
        show_help
        ;;
    *)
        echo "Error: Unknown subcommand '$SUBCOMMAND'" >&2
        echo "Run 'conversation help' for usage" >&2
        exit 1
        ;;
esac
