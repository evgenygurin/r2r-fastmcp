# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🎯 Обзор проекта

Это **репозиторий документации** (не кодовая база), содержащий русскоязычные руководства для трех AI-технологий:

- **R2R v3** - Production RAG система (8 разделов документации)
- **FastMCP 2.x** - Pythonic MCP фреймворк (8 разделов)
- **Claude Code 1.0.58+** - AI CLI от Anthropic (13 разделов)

**Ключевое отличие:** В проекте нет исходного кода для компиляции/тестирования. Только markdown документация + bash скрипты для интеграции с R2R API.

## 📁 Структура проекта

```text
r2r-fastmcp/
├── docs/                          # 📚 Основная документация
│   ├── r2r/                       # 8 разделов (01-08-*.md + README.md)
│   ├── fastmcp/                   # 8 разделов (01-08-*.md + README.md)
│   └── claude_code/               # 13 разделов (01-13-*.md + README.md + SUMMARY.md)
├── .claude/                       # ⚙️ Интеграция с R2R API
│   ├── scripts/                   # Bash клиенты для R2R v3 API
│   │   ├── r2r_client.sh         # search, rag, agent (основной)
│   │   ├── r2r_advanced.sh       # documents, collections, graphs
│   │   └── README.md
│   ├── commands/                  # 10 slash commands для Claude Code
│   │   ├── /r2r-search           # Поиск в knowledge base
│   │   ├── /r2r-rag              # RAG запросы с генерацией
│   │   ├── /r2r-agent            # Multi-turn агент
│   │   ├── /r2r-collections      # Управление коллекциями
│   │   ├── /r2r-upload           # Загрузка документов
│   │   ├── /doc-search           # Поиск по локальной документации
│   │   └── /r2r                  # Quick reference
│   ├── agents/                    # 3 специализированных агента
│   │   ├── research-assistant.md # Research mode с reasoning
│   │   ├── doc-analyst.md        # RAG-анализ документов
│   │   └── knowledge-explorer.md # Exploration + knowledge graph
│   ├── hooks/                     # Lifecycle hooks
│   │   └── SessionStart/         # check-r2r.md - статус API
│   ├── config/                    # Конфигурация
│   │   └── .env                  # R2R_BASE_URL, API_KEY
│   └── settings.json              # Пустой (hooks удалены после миграции)
├── README.md                      # Главная страница проекта
└── .claude/SEARCH_STRATEGIES.md   # Troubleshooting для R2R стратегий
```

## 🔧 Основные команды

### R2R API Integration (через bash скрипты)

**Конфигурация:** `.claude/config/.env`
```bash
R2R_BASE_URL=https://api.136-119-36-216.nip.io
API_KEY=your-api-key-here
```

**Прямые вызовы bash скриптов:**

```bash
# Search (hybrid: semantic + fulltext)
.claude/scripts/r2r_client.sh search "query" 5
.claude/scripts/r2r_client.sh search "query" 10 --verbose
.claude/scripts/r2r_client.sh search "query" --json

# RAG (retrieval + generation)
.claude/scripts/r2r_client.sh rag "question" 4000
.claude/scripts/r2r_client.sh rag "question" --json

# Agent (research/rag modes, multi-turn)
.claude/scripts/r2r_client.sh agent "query"
.claude/scripts/r2r_client.sh agent "query" research
.claude/scripts/r2r_client.sh agent "query" research "conversation_id"
.claude/scripts/r2r_client.sh agent "query" research "" "" --thinking

# Documents management
.claude/scripts/r2r_advanced.sh docs list
.claude/scripts/r2r_advanced.sh docs create path/to/file.pdf
.claude/scripts/r2r_advanced.sh docs delete document_id

# Collections
.claude/scripts/r2r_advanced.sh collections list
.claude/scripts/r2r_advanced.sh collections create "Collection Name"

# Knowledge Graph
.claude/scripts/r2r_advanced.sh graph pull collection_id
.claude/scripts/r2r_advanced.sh graph entities collection_id
```

**Slash команды Claude Code:**

```bash
/r2r-search "query" [limit]        # Поиск в knowledge base
/r2r-rag "question"                # RAG запрос с генерацией
/r2r-agent "query"                 # Multi-turn research agent
/r2r-collections                   # Управление коллекциями
/r2r-upload path/to/file          # Загрузить документ
/r2r                              # Quick reference
/doc-search "keyword"              # Поиск по локальной документации
```

### Работа с документацией

```bash
# Поиск по содержимому (ВСЕГДА используй rg вместо grep)
rg "search term" docs/
rg "API endpoint" docs/r2r/
rg "decorator" docs/fastmcp/

# Поиск файлов (ВСЕГДА используй fd вместо find)
fd -e md . docs/
fd "README" docs/

# Статистика
fd -e md . docs | wc -l           # Количество файлов
du -sh docs/r2r docs/fastmcp docs/claude_code
```

## 🏗️ Архитектура

### Документация - три независимых раздела

Каждая технология имеет:
- **README.md** - навигационный hub со структурой разделов
- **NN-section-name.md** - пронумерованные разделы (01-08 или 01-13)
- **Единый стиль** - эмодзи в H2, практические примеры, русский текст + английские термины

### R2R Integration Architecture

```text
┌─────────────────┐
│  Claude Code    │  CLI (10 slash commands)
│  (Frontend)     │
└────────┬────────┘
         │ Bash scripts (.claude/scripts/)
         │
┌────────▼────────┐
│ Modular Scripts │  search, rag, agent, docs, collections, graph, analytics
│  (Middleware)   │  Main: r2r CLI → commands/*.sh → lib/common.sh
└────────┬────────┘
         │ curl + jq → JSON payloads → R2R v3 REST API
         │
┌────────▼────────┐
│      R2R        │  https://api.136-119-36-216.nip.io
│   (Backend)     │  PostgreSQL + pgvector + Hatchet
└─────────────────┘
```

**Важно:**
- Ранее использовался FastMCP bridge (MCP сервер), но удален в пользу прямых bash скриптов
- Монолитные r2r_client.sh и r2r_advanced.sh заменены модульной структурой commands/
- **Используется jq для формирования JSON** - избегает проблем с экранированием и валидностью

### R2R API Defaults

Конфигурация в `lib/common.sh`:
```bash
DEFAULT_LIMIT=3                    # Результатов поиска
DEFAULT_MAX_TOKENS=4000            # Токенов для генерации
DEFAULT_MODE="research"            # Agent mode (research/rag)
DEFAULT_SEARCH_STRATEGY="vanilla"  # ⚠️ ТОЛЬКО vanilla работает
```

**⚠️ Известная проблема:** Search strategies `hyde` и `rag_fusion` не работают из-за ошибки конфигурации VertexAI на R2R сервере. См. `.claude/SEARCH_STRATEGIES.md` для деталей.

## 🚫 Запрещенные действия

1. **НЕ создавай** build scripts, test files, CI/CD конфиги - это репозиторий документации
2. **НЕ добавляй** package.json, pyproject.toml, requirements.txt - нет кодовой базы
3. **НЕ меняй** язык документации на английский без явного запроса
4. **НЕ удаляй** эмодзи из заголовков - это часть стиля
5. **НЕ создавай** .cursorrules, AGENTS.md и подобные файлы - используй только CLAUDE.md
6. **НЕ используй** grep, find, cat - используй rg, fd, bat (современные альтернативы)

## ✅ Обязательные практики

### При работе с документацией

1. **ВСЕГДА используй Read tool перед редактированием** существующих файлов
2. **Сохраняй структуру** - не меняй порядок разделов без необходимости
3. **Проверяй внутренние ссылки** - относительные пути должны работать
4. **Обновляй table of contents** в README.md при изменении заголовков
5. **Следуй нумерации** - 01-NN-section-name.md для последовательности
6. **Используй эмодзи в H2** - 🎯, 📁, 🔍, ⚙️, 📚, 🔗, ⚠️, ✅, ❌

### При работе с R2R API

1. **Загружай .env** перед curl запросами:
   ```bash
   bash -c 'source .claude/config/.env && curl ...'
   ```
2. **Используй vanilla стратегию** - hyde и rag_fusion не работают
3. **Hybrid search включен по умолчанию** в всех скриптах
4. **Research mode** предпочтительнее RAG mode для сложных запросов

### Git workflow

```bash
# Коммиты ВСЕГДА одной строкой, БЕЗ подписей Co-Authored-By
git commit -m "docs(r2r): add hybrid search examples"
git commit -m "fix(scripts): correct API endpoint URL"
git commit -m "feat(commands): add /r2r-upload slash command"
```

**Типы:** `docs`, `fix`, `feat`, `refactor`, `chore`

## 📋 R2R Quick Reference

### API Endpoints (v3)

```sql
POST /v3/retrieval/search          # Hybrid search (semantic + fulltext)
POST /v3/retrieval/rag             # RAG with generation
POST /v3/retrieval/agent           # Multi-turn agent

POST /v3/documents                 # Create document
GET  /v3/documents                 # List documents
DELETE /v3/documents/{id}          # Delete document

POST /v3/collections               # Create collection
GET  /v3/collections               # List collections
POST /v3/collections/{id}/documents  # Add document to collection

POST /v3/graphs/{id}/pull          # Sync knowledge graph
POST /v3/graphs/{id}/entities      # Create entity
```

### Search Settings

```json
{
  "use_hybrid_search": true,         // ✅ Работает с vanilla
  "search_strategy": "vanilla",      // ⚠️ hyde, rag_fusion - НЕ работают
  "limit": 3,
  "filters": {
    "collection_ids": {"$overlap": ["collection_id"]}
  }
}
```

### RAG Generation Config

```json
{
  "max_tokens": 4000,
  "model": "openai/gpt-4.1",
  "temperature": 0.1,
  "stream": false
}
```

### Agent Modes

| Mode | Tools | Use Case |
|------|-------|----------|
| **research** | rag, reasoning, critique, python_executor | Сложный анализ, multi-step reasoning |
| **rag** | search_file_knowledge, get_file_content, web_search | Простые factual queries |

## 🔍 Типичные задачи

### Поиск информации в документации

```bash
# Найти примеры использования конкретного API
rg "client.documents.create" docs/

# Найти все Python примеры
rg "```python" docs/

# Найти разделы про аутентификацию
fd -e md authentication docs/
```

### Добавление нового раздела документации

1. Определи следующий номер: `fd -e md . docs/r2r/ | sort`
2. Создай файл: `docs/r2r/09-new-section.md`
3. Скопируй структуру из похожего раздела
4. Обнови `docs/r2r/README.md` - добавь в table of contents
5. Коммит: `git commit -m "docs(r2r): add section 09 - new topic"`

### Обновление существующего раздела

1. Читай перед редактированием: `Read` tool на файл
2. Сохраняй структуру заголовков
3. Проверь внутренние ссылки после изменений
4. Обнови README.md если меняешь заголовки

### Тестирование R2R интеграции

```bash
# Проверка доступности API (модульный CLI)
.claude/scripts/r2r search "test" 1

# Проверка JSON output
.claude/scripts/r2r search --json "test" 1 | jq .

# Проверка slash команды
/r2r-search "R2R documentation"

# Проверка agent mode
/r2r-agent "What is R2R?"
```

## 🐛 Troubleshooting

### R2R API Issues

**Проблема:** RAG запрос возвращает `null`

**Решение:**
1. Проверь `.claude/SEARCH_STRATEGIES.md`
2. Убедись что `DEFAULT_SEARCH_STRATEGY="vanilla"`
3. Проверь `.claude/config/.env` на наличие `API_KEY`

**Проблема:** "API_KEY not set in .env file"

**Решение:**
```bash
# Создай .claude/config/.env
cat > .claude/config/.env << 'EOF'
R2R_BASE_URL=https://api.136-119-36-216.nip.io
API_KEY=your-api-key-here
EOF
```

### Документация Issues

**Проблема:** Внутренние ссылки не работают

**Решение:** Используй относительные пути от текущей директории:
```markdown
[R2R Overview](./01-installation-and-setup.md)  # ✅ Правильно
[R2R Overview](/docs/r2r/01-...)                # ❌ Не работает в GitHub
```

**Проблема:** Inconsistent нумерация файлов

**Решение:**
```bash
# Проверь последовательность
fd -e md . docs/r2r/ | sort
# Должно быть: 01, 02, 03, ..., 08 без пропусков
```

## 📚 Ссылки на важные файлы

### Конфигурация R2R
- `.claude/config/.env` - API credentials
- `.claude/scripts/r2r` - main CLI entry point (dispatcher)
- `.claude/scripts/lib/common.sh` - shared configuration and utilities
- `.claude/scripts/commands/` - modular command implementations:
  - `search.sh` - hybrid search с фильтрами, стратегиями, graph search
  - `rag.sh` - RAG retrieval + generation
  - `agent.sh` - multi-turn agent (research/rag modes)
  - `docs.sh` - document management (list, get, upload, delete)
  - `collections.sh` - collection management
  - `graph.sh` - knowledge graph operations
  - `analytics.sh` - collection/document/system analytics
- `.claude/docs/SEARCH_STRATEGIES.md` - troubleshooting для стратегий

### Документация навигация
- `docs/r2r/README.md` - R2R documentation index
- `docs/fastmcp/README.md` - FastMCP documentation index
- `docs/claude_code/README.md` - Claude Code documentation index
- `docs/claude_code/SUMMARY.md` - краткое содержание

### Миграция notes
- `.claude/MIGRATION.md` - история миграции от MCP к bash
- `.claude/VERIFICATION.md` - verification report после миграции
- `.claude/DONE.md` - завершенные задачи

## 🎯 Ключевые принципы

1. **Это документация, не код** - не создавай build tools, тесты, CI/CD
2. **Русский + English** - текст на русском, код/термины/API на английском
3. **Практичность** - каждый пример должен быть применимым
4. **Консистентность** - следуй существующему стилю во всех файлах
5. **Vanilla strategy only** - продвинутые R2R стратегии не работают
6. **Современные инструменты** - rg вместо grep, fd вместо find
7. **Одна строка коммитов** - без подписей, краткие описания
