# R2R CLI Scripts

Модульная система bash скриптов для взаимодействия с R2R v3 REST API.

## 🏗️ Архитектура

```text
.claude/scripts/
├── r2r                    # Главный CLI dispatcher
├── lib/
│   └── common.sh          # Общие функции и переменные
├── commands/              # Модульные команды (8 команд, 48 подкоманд)
│   ├── search.sh          # Hybrid search с фильтрами
│   ├── rag.sh             # RAG retrieval + generation
│   ├── agent.sh           # Multi-turn agent
│   ├── docs.sh            # Document management (14 команд)
│   ├── collections.sh     # Collection management (6 команд)
│   ├── conversation.sh    # Conversation management (5 команд)
│   ├── graph.sh           # Knowledge graph ops (20 команд)
│   └── analytics.sh       # System analytics (3 команды)
└── helpers/               # Helper scripts (4 скрипта)
    ├── examples.sh        # Interactive examples (50+ примеров)
    ├── workflows.sh       # Automated workflows (5 workflows)
    ├── quick.sh           # Quick tasks (10 tasks)
    └── aliases.sh         # Shell aliases and functions
```

## 🚀 Быстрый старт

### Установка

```bash
# 1. Настрой .env файл
cat > .claude/config/.env << 'EOF'
R2R_BASE_URL=https://api.136-119-36-216.nip.io
API_KEY=your-api-key-here
EOF

# 2. Сделай r2r исполняемым
chmod +x .claude/scripts/r2r

# 3. Добавь в PATH (опционально)
export PATH="$PATH:$(pwd)/.claude/scripts"
```

### Базовое использование

```bash
# Search
r2r search "machine learning" --limit 5
r2r search "AI" -l 10 -q                    # quiet mode

# RAG
r2r rag "Explain transformers"
r2r rag "What is R2R?" --show-sources

# Agent
r2r agent "What is DeepSeek R1?"
r2r agent "Analyze this" --mode research --thinking
```

## 📚 Команды

### Core Commands (3)

#### `search` - Hybrid Search
Комбинирует semantic и fulltext поиск.

```bash
# Basic usage
r2r search "query" --limit 5

# With filters
r2r search "ML papers" --filter category=research

# With graph search
r2r search "entities" --graph --collection abc123

# Quiet mode (one line per result)
r2r search "quick query" -l 3 -q
```

**Флаги:**
- `--limit, -l <num>` - Number of results (default: 3)
- `--filter, -f <field=value>` - Filter results
- `--strategy, -s <name>` - vanilla|rag_fusion|hyde (default: vanilla)
- `--graph, -g` - Enable graph search
- `--collection, -c <id>` - Search in specific collection
- `--quiet, -q` - Minimal output
- `--json` - Raw JSON output

---

#### `rag` - RAG Query with Generation
Retrieval + LLM generation.

```bash
# Basic usage
r2r rag "Explain transformers"

# With options
r2r rag "Question" --max-tokens 8000 --show-sources

# Quiet mode
r2r rag "Question" -t 4000 -q
```

**Флаги:**
- `--max-tokens, -t <num>` - Max tokens (default: 4000)
- `--filter, -f <field=value>` - Filter search
- `--graph, -g` - Enable graph search
- `--collection, -c <id>` - Search in collection
- `--show-sources` - Show retrieved chunks
- `--show-metadata` - Show metadata
- `--quiet, -q` - Minimal output
- `--json` - Raw JSON

---

#### `agent` - Multi-turn Agent
Conversational agent with tools.

```bash
# Single query
r2r agent "What is R2R?"

# Research mode with thinking
r2r agent "Analyze DeepSeek R1" --mode research --thinking

# Continue conversation
r2r agent "Tell me more" --conversation abc123

# Quiet mode
r2r agent "Quick question" -m rag -q
```

**Флаги:**
- `--mode, -m <mode>` - research|rag (default: research)
- `--conversation, -c <id>` - Continue conversation
- `--thinking` - Extended thinking (4096 tokens)
- `--show-tools` - Show tool calls
- `--show-sources` - Show citations
- `--quiet, -q` - Minimal output
- `--json` - Raw JSON

**Agent Modes:**
- **research** - reasoning, critique, python_executor (complex analysis)
- **rag** - search, get_content, web_search (direct questions)

---

### Management Commands (5)

#### `docs` - Document Management (14 commands)
```bash
# List documents
r2r docs list --limit 20
r2r docs list -l 10 -o 5 -q                 # with offset, quiet

# Get document
r2r docs get abc123-def456
r2r docs get abc123 --json

# Upload document
r2r docs upload path/to/file.pdf
r2r docs upload file.txt --collection abc123

# Delete document
r2r docs delete abc123-def456

# Extract knowledge graph
r2r docs extract abc123

# Full command list
r2r docs help
```

---

#### `collections` - Collection Management (6 commands)
```bash
# List collections
r2r collections list --limit 10
r2r collections list -l 5 -q

# Get collection
r2r collections get abc123-def456

# Create collection
r2r collections create "My Collection" "Description"
r2r collections create --name "Collection" --desc "Info"
r2r collections create -n "Quick Create"

# Delete collection
r2r collections delete abc123

# Add document to collection
r2r collections add-doc collection123 doc456
r2r collections add-doc -c collection123 -d doc456

# Remove document from collection
r2r collections remove-doc collection123 doc456

# Full command list
r2r collections help
```

---

#### `conversation` - Conversation Management (5 commands)
```bash
# Create conversation
r2r conversation create "Research Session"
r2r conversation create -n "My Session"

# List conversations
r2r conversation list --limit 10
r2r conversation list -l 5 -q

# Get conversation
r2r conversation get abc123-def456

# Add message
r2r conversation add-message abc123 system "Be helpful"
r2r conversation add-message -c abc123 -r user -m "Hello"

# Delete conversation
r2r conversation delete abc123

# Workflow with CONV_ID
r2r conversation create "Session"
CONV_ID=$(head -1 /tmp/.r2r_conversation_id)
r2r conversation add-message $CONV_ID system "Expert mode"

# Full command list
r2r conversation help
```

---

#### `graph` - Knowledge Graph Operations (20 commands)
```bash
# List entities
r2r graph entities abc123 --limit 50

# List relationships
r2r graph relationships abc123 --limit 30

# List communities
r2r graph communities abc123

# Create entity
r2r graph create-entity abc123 "Entity Name" "Description" "Category"

# Build communities
r2r graph build-communities abc123

# Pull (sync) graph
r2r graph pull abc123

# Full command list
r2r graph help
```

---

#### `analytics` - System Analytics (3 commands)
```bash
# System stats
r2r analytics system
r2r analytics system -q                     # quiet: one line

# Collection analytics
r2r analytics collection abc123
r2r analytics collection abc123 --json

# Document analytics
r2r analytics document abc123
r2r analytics document abc123 -q

# Full command list
r2r analytics help
```

---

## 🎨 Output Modes

Все команды поддерживают три режима вывода:

### Default - Readable Format
Компактный, читабельный вывод с эмодзи индикаторами.

```bash
$ r2r search "transformers" -l 3

🔍 Search | limit:3

[0.92] Attention is All You Need[abc12345] | The dominant sequence transduction models are based...
[0.85] BERT: Pre-training[def67890] | We introduce a new language representation model...
[0.78] GPT-3: Language Models[ghi11223] | We trained a 175 billion parameter model...
```

### Quiet Mode (`--quiet` / `-q`)
Минимальный вывод для скриптов и пайпов.

```bash
$ r2r search "transformers" -l 3 -q

Attention is All You Need [abc12345]
BERT: Pre-training [def67890]
GPT-3: Language Models [ghi11223]
```

### JSON Mode (`--json`)
Raw JSON для парсинга и автоматизации.

```bash
$ r2r search "transformers" -l 3 --json

{
  "results": {
    "chunk_search_results": [...]
  }
}
```

---

## 🏷️ GNU-Style Flags

Все команды следуют GNU стилю с короткими формами:

| Long Form | Short | Description |
|-----------|-------|-------------|
| `--limit 10` | `-l 10` | Number of results |
| `--quiet` | `-q` | Minimal output |
| `--verbose` | `-v` | Full details |
| `--json` | - | JSON output |
| `--filter key=val` | `-f key=val` | Filter results |
| `--graph` | `-g` | Enable graph |
| `--collection id` | `-c id` | Collection ID |
| `--max-tokens 8000` | `-t 8000` | Max tokens (RAG) |
| `--mode research` | `-m research` | Agent mode |

---

## 🔧 Configuration

### Environment Variables

`.claude/config/.env`:
```bash
R2R_BASE_URL=https://api.136-119-36-216.nip.io
API_KEY=your-api-key-here
```

### Default Settings

`lib/common.sh`:
```bash
DEFAULT_LIMIT=3                    # Search results
DEFAULT_MAX_TOKENS=4000            # RAG generation
DEFAULT_MODE="research"            # Agent mode
DEFAULT_SEARCH_STRATEGY="vanilla"  # Search strategy
```

---

## 📊 Performance

**Search:**
- Latency: ~200-500ms
- Optimal results: 3-10
- Hybrid search: 30-50% better relevance

**RAG:**
- Latency: ~2-5s (depends on max_tokens)
- Token limit: up to 16K
- Quality: High (hybrid search + GPT-4)

**Agent:**
- Research mode: ~3-10s
- RAG mode: ~2-4s
- Extended thinking: +2-5s overhead
- Context: Multi-turn preserved

---

## 🎯 Best Practices

1. **Use short forms** - `-l 10 -q` вместо `--limit 10 --quiet`
2. **Research mode default** - Лучшее reasoning для сложных вопросов
3. **Extended thinking** - Для аналитических задач с `--thinking`
4. **Hybrid search** - Баланс semantic + keyword matching
5. **Quiet mode** - Для скриптов и пайпов (`-q`)
6. **JSON mode** - Для автоматизации (`--json`)
7. **Multi-turn conversations** - Сохранение контекста через conversation_id

---

## 🛠️ Helper Scripts

Дополнительные скрипты для упрощения работы с R2R CLI.

### `examples.sh` - Interactive Examples

Интерактивные демонстрации с пошаговыми примерами:

```bash
# Show all examples
./examples.sh

# Specific category
./examples.sh search      # Search examples
./examples.sh rag         # RAG examples
./examples.sh agent       # Agent examples
./examples.sh workflows   # Complete workflows
```

**Features:**
- 50+ готовых примеров
- Интерактивное выполнение (выбираешь что запустить)
- Пояснения для каждого примера
- Практические workflows

### `workflows.sh` - Automated Workflows

Многошаговые автоматизированные процессы:

```bash
# Upload document with auto-extract
./workflows.sh upload paper.pdf [collection_id]

# Create collection and populate
./workflows.sh create-collection "Research" "AI papers" *.pdf

# Interactive research session
./workflows.sh research "What is RAG?"

# Analyze document
./workflows.sh analyze <document_id>

# Batch upload directory
./workflows.sh batch-upload ./docs [collection_id] "*.pdf"
```

**Workflows:**
- **upload** - Upload + extract + verify
- **create-collection** - Create + populate + build graph
- **research** - Multi-turn interactive session
- **analyze** - Comprehensive document analysis
- **batch-upload** - Mass upload with progress

### `quick.sh` - Quick Tasks

Одностроковые shortcuts для частых операций:

```bash
# Quick search + RAG answer
./quick.sh ask "What is RAG?"

# Show R2R status
./quick.sh status

# Quick upload with auto-extract
./quick.sh up paper.pdf [collection_id]

# Create collection
./quick.sh col "Research Papers" "AI research"

# Search in last collection
./quick.sh col-search "transformers"

# Continue last conversation
./quick.sh continue "Tell me more"

# Graph overview
./quick.sh graph <collection_id>

# Batch upload current directory
./quick.sh batch "*.pdf"

# Find documents by title
./quick.sh find "machine learning"

# Delete failed documents
./quick.sh cleanup
```

**Tasks:** ask, status, up, col, col-search, continue, graph, batch, find, cleanup

### `aliases.sh` - Shell Aliases

Shortcuts для bash/zsh:

```bash
# Source в shell
source .claude/scripts/aliases.sh

# Core aliases
rs "query"              # r2r search
rr "question"           # r2r rag
ra "message"            # r2r agent
rd                      # r2r docs
rc                      # r2r collections
rg                      # r2r graph

# Quick tasks
rq ask "query"          # quick.sh ask
rq up file.pdf          # quick.sh up
rq status               # quick.sh status

# Helper functions
r2r-ask "query"         # Search + RAG
r2r-up file.pdf         # Upload + extract
r2r-cont "message"      # Continue conversation
r2r-col "Name"          # Create collection
r2r-batch "*.pdf"       # Batch upload
```

**Installation:**
```bash
# Add to .bashrc or .zshrc
echo 'source /path/to/.claude/scripts/aliases.sh' >> ~/.bashrc
source ~/.bashrc
```

---

## 🐛 Troubleshooting

### API Key Error
```bash
# Check .env file
cat .claude/config/.env | grep API_KEY

# Test connection
source .claude/config/.env
curl -s "${R2R_BASE_URL}/v3/system/health" \
  -H "Authorization: Bearer ${API_KEY}"
```

### Empty Results
```bash
# Check if documents exist
r2r docs list -l 5

# Check collection
r2r collections list -l 5

# Verify search
r2r search "test" --json
```

### Conversation ID Lost
```bash
# Auto-saved to temp file
CONV_ID=$(head -1 /tmp/.r2r_conversation_id)
r2r agent "Continue" -c $CONV_ID

# Or extract from JSON
response=$(r2r agent "Start" --json)
conv_id=$(echo "$response" | jq -r '.conversation_id')
```

### Unknown Flag Error
```bash
# Check command help
r2r <command> help

# Examples:
r2r search help
r2r rag help
r2r agent help
```

---

## 📖 Documentation

- **Command Help**: `r2r <command> help`
- **R2R Docs**: `docs/r2r/`
- **CLAUDE.md**: R2R Quick Reference section
- **Slash Commands**: `.claude/commands/r2r-*.md`

---

## 🔗 Related

- **R2R v3 API**: https://r2r-docs.sciphi.ai/api-reference
- **R2R GitHub**: https://github.com/SciPhi-AI/R2R
- **FastMCP**: `docs/fastmcp/`
- **Claude Code**: `docs/claude_code/`

---

## 📈 Statistics

**Code Size:**
- Total: 5,419 строк (8 команд)
- `lib/common.sh`: 43 строки (optimized)
- `commands/`:
  - `docs.sh`: 1,067 строк (14 подкоманд)
  - `graph.sh`: 1,737 строк (20 подкоманд)
  - `agent.sh`: 616 строк
  - `search.sh`: 337 строк
  - `rag.sh`: 358 строк
  - `analytics.sh`: 382 строки
  - `collections.sh`: 484 строки
  - `conversation.sh`: 440 строк

**Refactoring History:**
- **2025-11-26**: Полный рефакторинг docs.sh и graph.sh
  - Добавлены GNU-style флаги для всех 34 подкоманд
  - Унифицирован ONE LINE output формат
  - Очищен lib/common.sh от неиспользуемых функций
  - Все 8 команд теперь следуют единому паттерну

- **2025-01-26**: Создание модульной архитектуры
  - Миграция от монолитных скриптов к модульным командам
  - Внедрение GNU-style флагов в core commands
  - Добавление трех режимов вывода (default/quiet/JSON)

---

**Last Updated**: 2025-11-26
**R2R API Version**: v3.x
**Script Version**: 2.1 (Fully Unified GNU-style)
