# .claude Directory Structure

Конфигурация и интеграция Claude Code с R2R API.

## 📁 Структура

```text
.claude/
├── agents/              # Специализированные агенты (3)
│   ├── research-assistant.md
│   ├── doc-analyst.md
│   ├── knowledge-explorer.md
│   └── README.md
├── commands/            # Slash commands (6)
│   ├── r2r-search.md
│   ├── r2r-rag.md
│   ├── r2r-agent.md
│   ├── r2r-collections.md
│   ├── r2r-upload.md
│   └── r2r.md
├── config/              # Конфигурация
│   └── .env             # R2R_BASE_URL, API_KEY
├── docs/                # Документация
│   └── migration/       # Архив миграции MCP → Bash
│       ├── SUMMARY.md
│       ├── VERIFICATION.md
│       └── README.md
├── hooks/               # Lifecycle hooks
│   ├── SessionStart/
│   │   └── check-r2r.md
│   └── README.md
├── scripts/             # Модульная CLI система для R2R API
│   ├── r2r              # Главный dispatcher
│   ├── lib/             # Общие функции (common.sh)
│   ├── commands/        # 8 модульных команд (48 подкоманд)
│   │   ├── search.sh    # Hybrid search
│   │   ├── rag.sh       # RAG generation
│   │   ├── agent.sh     # Multi-turn agent
│   │   ├── docs.sh      # Document management (14 команд)
│   │   ├── collections.sh  # Collection management (6 команд)
│   │   ├── conversation.sh # Conversation management (5 команд)
│   │   ├── graph.sh     # Knowledge graph ops (20 команд)
│   │   └── analytics.sh # System analytics (3 команды)
│   └── README.md        # Полное руководство
├── skills/              # Описание возможностей (3)
│   ├── r2r-search.md
│   ├── r2r-rag.md
│   └── r2r-graph.md
├── settings.json        # Конфигурация Claude Code (пустой)
├── SEARCH_STRATEGIES.md # Troubleshooting для R2R стратегий
└── README.md            # Этот файл
```

## 🎯 Основные компоненты

### 1. Bash Scripts (`scripts/`)
**Модульная CLI система с GNU-style интерфейсом**

Унифицированный интерфейс `r2r` с 8 командами и 48 подкомандами:

**Core Commands (3):**
- `search` - Hybrid search (semantic + fulltext)
- `rag` - RAG retrieval + generation
- `agent` - Multi-turn conversational agent

**Management Commands (5):**
- `docs` - Document management (14 подкоманд)
- `collections` - Collection management (6 подкоманд)
- `conversation` - Conversation management (5 подкоманд)
- `graph` - Knowledge graph operations (20 подкоманд)
- `analytics` - System analytics (3 подкоманды)

**Ключевые особенности:**
- GNU-style флаги (`--long` / `-short`)
- Три режима вывода: default (emoji), quiet, JSON
- ONE LINE компактный формат
- Консистентные визуальные индикаторы

**Документация:**
- `scripts/README.md` - полное руководство (467 строк)

### 2. Slash Commands (`commands/`)
**Интеграция с Claude Code CLI**

Использование: `/r2r-search "query"`, `/r2r-rag "question"`, `/r2r-agent "message"`

Все команды используют bash скрипты под капотом.

### 3. Agents (`agents/`)
**Специализированные агенты для разных задач**

- `research-assistant.md` - research mode с reasoning/critique
- `doc-analyst.md` - RAG-анализ документов
- `knowledge-explorer.md` - поиск + knowledge graph

### 4. Configuration (`config/`)
**Конфигурация подключения к R2R**

```bash
# config/.env
R2R_BASE_URL=https://api.136-119-36-216.nip.io
API_KEY=your-api-key-here
```

### 5. Hooks (`hooks/`)
**Lifecycle automation**

- `SessionStart/check-r2r.md` - проверка доступности R2R API при старте

### 6. Skills (`skills/`)
**Описательная документация возможностей R2R**

Универсальные описания API, не зависят от реализации.

## 🚀 Quick Start

### Использование через Модульный CLI
```bash
# Core commands
r2r search "machine learning" --limit 5
r2r rag "What is RAG?" --show-sources
r2r agent "Explain transformers" --mode research

# Management commands
r2r docs list -l 10 -q
r2r collections create "My Collection"
r2r graph entities abc123 --limit 50

# Короткие формы флагов
r2r search "AI" -l 10 -q          # --limit + --quiet
r2r rag "Question" -t 8000        # --max-tokens
r2r agent "Query" -m rag          # --mode
```

### Использование через Slash Commands
```bash
/r2r-search "machine learning" 5
/r2r-rag "What is RAG?"
/r2r-agent "Explain transformers"
```

### Проверка конфигурации
```bash
# Проверить .env
cat .claude/config/.env

# Тест подключения (новый CLI)
r2r search "test" --limit 1

# Или через полный путь
.claude/scripts/r2r search "test" -l 1
```

## 📚 Документация

### Основная
- `scripts/README.md` - полное руководство (467 строк)
  - Архитектура модульной CLI системы
  - Все 8 команд и 48 подкоманд
  - GNU-style флаги и режимы вывода
  - Примеры использования
- `SEARCH_STRATEGIES.md` - troubleshooting для search strategies

### Агенты и команды
- `agents/README.md` - описание специализированных агентов
- `hooks/README.md` - статус и использование hooks
- `commands/r2r.md` - quick reference для R2R API

### Архивная
- `docs/migration/` - история миграции от MCP к bash

## ⚠️ Важные заметки

### Search Strategies
**Только `vanilla` стратегия работает** на текущем R2R сервере.

`hyde` и `rag_fusion` вызывают ошибки VertexAI. См. `SEARCH_STRATEGIES.md` для деталей.

### Defaults
```bash
DEFAULT_LIMIT=3                    # результатов поиска
DEFAULT_MAX_TOKENS=4000            # токенов для генерации
DEFAULT_MODE="research"            # agent mode
DEFAULT_SEARCH_STRATEGY="vanilla"  # ⚠️ только vanilla работает
```

### Hybrid Search
Включен по умолчанию во всех скриптах (semantic + fulltext).

## 🔗 См. также

- `../CLAUDE.md` - основная документация для Claude Code
- `../README.md` - обзор всего проекта
- `../docs/r2r/` - полная документация R2R v3
