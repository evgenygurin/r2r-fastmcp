#!/usr/bin/env bash
# R2R Shell Aliases and Functions
# Source this file in your .bashrc or .zshrc:
#   source /path/to/r2r-fastmcp/.claude/scripts/aliases.sh

# Get script directory
R2R_SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Core command aliases (short forms)
alias r2r-s='r2r search'
alias r2r-r='r2r rag'
alias r2r-a='r2r agent'
alias r2r-d='r2r docs'
alias r2r-c='r2r collections'
alias r2r-g='r2r graph'

# Quick script aliases
alias r2r-quick="${R2R_SCRIPTS_DIR}/quick.sh"
alias r2r-q="${R2R_SCRIPTS_DIR}/quick.sh"
alias r2r-wf="${R2R_SCRIPTS_DIR}/workflows.sh"
alias r2r-ex="${R2R_SCRIPTS_DIR}/examples.sh"

# Ultra-short aliases
alias rq="${R2R_SCRIPTS_DIR}/quick.sh"
alias rw="${R2R_SCRIPTS_DIR}/workflows.sh"
alias rx="${R2R_SCRIPTS_DIR}/examples.sh"

# Common tasks
alias r2r-status="${R2R_SCRIPTS_DIR}/quick.sh status"
alias r2r-st="${R2R_SCRIPTS_DIR}/quick.sh status"

# Search shortcuts
alias rs='r2r search'
alias rsl='r2r search -l'      # with limit
alias rsq='r2r search -q'      # quiet mode
alias rsj='r2r search --json'  # JSON output

# RAG shortcuts
alias rr='r2r rag'
alias rrt='r2r rag --max-tokens'        # with token limit
alias rrs='r2r rag --show-sources'      # with sources
alias rrm='r2r rag --show-metadata'     # with metadata

# Agent shortcuts
alias ra='r2r agent'
alias ram='r2r agent --mode'            # with mode
alias rat='r2r agent --thinking'        # with thinking
alias rac='r2r agent -c'                # continue conversation
alias rar='r2r agent --mode research'   # research mode
alias rarag='r2r agent --mode rag'      # rag mode

# Document management shortcuts
alias rd='r2r docs'
alias rdl='r2r docs list'
alias rdlq='r2r docs list -l 10 -q'
alias rdg='r2r docs get'
alias rdu='r2r docs upload'
alias rdd='r2r docs delete'
alias rde='r2r docs extract'

# Collection shortcuts
alias rc='r2r collections'
alias rcl='r2r collections list'
alias rclq='r2r collections list -l 10 -q'
alias rcc='r2r collections create'
alias rcg='r2r collections get'
alias rca='r2r collections add-doc'
alias rcr='r2r collections remove-doc'

# Graph shortcuts
alias rg='r2r graph'
alias rge='r2r graph entities'
alias rgr='r2r graph relationships'
alias rgc='r2r graph communities'
alias rgp='r2r graph pull'
alias rgb='r2r graph build-communities'

# Helper functions

# Quick search and ask
r2r-ask() {
    local query="$*"
    [ -z "$query" ] && { echo "Usage: r2r-ask <query>"; return 1; }
    ${R2R_SCRIPTS_DIR}/quick.sh ask "$query"
}

# Quick upload
r2r-up() {
    local file="$1"
    local collection="${2:-}"
    [ -z "$file" ] && { echo "Usage: r2r-up <file> [collection_id]"; return 1; }
    ${R2R_SCRIPTS_DIR}/quick.sh up "$file" "$collection"
}

# Quick continue conversation
r2r-cont() {
    local message="$*"
    [ -z "$message" ] && { echo "Usage: r2r-cont <message>"; return 1; }
    ${R2R_SCRIPTS_DIR}/quick.sh continue "$message"
}

# Search in last collection
r2r-cs() {
    local query="$*"
    [ -z "$query" ] && { echo "Usage: r2r-cs <query>"; return 1; }
    ${R2R_SCRIPTS_DIR}/quick.sh col-search "$query"
}

# Create collection
r2r-col() {
    local name="$1"
    local desc="${2:-}"
    [ -z "$name" ] && { echo "Usage: r2r-col <name> [description]"; return 1; }
    ${R2R_SCRIPTS_DIR}/quick.sh col "$name" "$desc"
}

# Batch upload current directory
r2r-batch() {
    local pattern="${1:-*.pdf}"
    ${R2R_SCRIPTS_DIR}/quick.sh batch "$pattern"
}

# Find documents by title
r2r-find() {
    local term="$*"
    [ -z "$term" ] && { echo "Usage: r2r-find <search term>"; return 1; }
    ${R2R_SCRIPTS_DIR}/quick.sh find "$term"
}

# Workflow shortcuts
r2r-wf-upload() {
    local file="$1"
    local collection="${2:-}"
    [ -z "$file" ] && { echo "Usage: r2r-wf-upload <file> [collection_id]"; return 1; }
    ${R2R_SCRIPTS_DIR}/workflows.sh upload "$file" "$collection"
}

r2r-wf-research() {
    local query="$*"
    [ -z "$query" ] && { echo "Usage: r2r-wf-research <query>"; return 1; }
    ${R2R_SCRIPTS_DIR}/workflows.sh research "$query"
}

# Completion functions
_r2r_comp() {
    local cur prev
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_WORDS_INDEX]}"
    prev="${COMP_WORDS[COMP_WORDS_INDEX-1]}"

    case "$prev" in
        r2r)
            COMPREPLY=($(compgen -W "search rag agent docs collections conversation graph analytics help" -- "$cur"))
            ;;
        search)
            COMPREPLY=($(compgen -W "--limit --quiet --json --graph --collection --filter --strategy" -- "$cur"))
            ;;
        rag)
            COMPREPLY=($(compgen -W "--max-tokens --quiet --json --show-sources --show-metadata --graph --collection --filter" -- "$cur"))
            ;;
        agent)
            COMPREPLY=($(compgen -W "--mode --conversation --thinking --show-tools --show-sources --quiet --json" -- "$cur"))
            ;;
    esac

    return 0
}

# Register completion (bash)
if [ -n "$BASH_VERSION" ]; then
    complete -F _r2r_comp r2r
    complete -F _r2r_comp rs rr ra
fi

# Print info when sourced
echo "R2R aliases loaded!"
echo ""
echo "Quick commands:"
echo "  r2r-ask <query>     - Search + RAG answer"
echo "  r2r-up <file>       - Upload document"
echo "  r2r-cont <message>  - Continue conversation"
echo "  r2r-status          - Show status"
echo ""
echo "Core aliases:"
echo "  rs   = r2r search"
echo "  rr   = r2r rag"
echo "  ra   = r2r agent"
echo "  rd   = r2r docs"
echo "  rc   = r2r collections"
echo "  rg   = r2r graph"
echo ""
echo "Quick scripts:"
echo "  rq   = quick.sh"
echo "  rw   = workflows.sh"
echo "  rx   = examples.sh"
echo ""
echo "Run 'r2r help' for full documentation"
