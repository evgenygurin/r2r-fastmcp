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
├── scripts/             # Bash клиенты для R2R API
│   ├── r2r_client.sh    # search, rag, agent
│   ├── r2r_advanced.sh  # docs, collections, graphs
│   ├── R2R_EXAMPLES.md  # 26+ примеров
│   └── README.md
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
**Основной способ взаимодействия с R2R API**

- `r2r_client.sh` - основные операции:
  - `search` - hybrid search (semantic + fulltext)
  - `rag` - RAG с генерацией (до 4000 токенов)
  - `agent` - multi-turn research agent

- `r2r_advanced.sh` - расширенные операции:
  - `docs` - управление документами
  - `collections` - коллекции и доступ
  - `graph` - knowledge graphs

**Документация:**
- `scripts/README.md` - полное руководство
- `scripts/R2R_EXAMPLES.md` - практические примеры

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

### Использование через Slash Commands
```bash
/r2r-search "machine learning" 5
/r2r-rag "What is RAG?"
/r2r-agent "Explain transformers"
```

### Прямое использование скриптов
```bash
.claude/scripts/r2r_client.sh search "query" 5
.claude/scripts/r2r_client.sh rag "question"
.claude/scripts/r2r_client.sh agent "message" research
```

### Проверка конфигурации
```bash
# Проверить .env
cat .claude/config/.env

# Тест подключения
.claude/scripts/r2r_client.sh search "test" 1
```

## 📚 Документация

### Основная
- `scripts/README.md` - полное руководство по bash скриптам
- `scripts/R2R_EXAMPLES.md` - 26+ практических примеров
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
