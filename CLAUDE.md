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
│   ├── scripts/                   # Модульная CLI система для R2R API
│   │   ├── r2r                    # Главный dispatcher
│   │   ├── lib/common.sh          # Общие функции (43 строки)
│   │   ├── commands/              # 8 команд (48 подкоманд)
│   │   │   ├── search.sh          # Hybrid search
│   │   │   ├── rag.sh             # RAG generation
│   │   │   ├── agent.sh           # Multi-turn agent
│   │   │   ├── docs.sh            # Document management (14 команд)
│   │   │   ├── collections.sh     # Collection management (6 команд)
│   │   │   ├── conversation.sh    # Conversation management (5 команд)
│   │   │   ├── graph.sh           # Knowledge graph (20 команд)
│   │   │   └── analytics.sh       # System analytics (3 команды)
│   │   ├── examples.sh            # Interactive examples (50+)
│   │   ├── workflows.sh           # Automated workflows (5)
│   │   ├── quick.sh               # Quick tasks (10)
│   │   ├── aliases.sh             # Shell aliases
│   │   └── README.md
│   ├── commands/                  # Slash commands (15)
│   │   ├── r2r*.md                # R2R команды (9)
│   │   │   ├── r2r.md, r2r-search.md, r2r-rag.md
│   │   │   ├── r2r-agent.md, r2r-collections.md, r2r-upload.md
│   │   │   └── r2r-examples.md, r2r-workflows.md, r2r-quick.md
│   │   └── cc*.md                 # Claude Code документация (6)
│   │       ├── cc.md, cc-hooks.md, cc-commands.md
│   │       └── cc-mcp.md, cc-subagents.md, cc-setup.md
│   ├── agents/                    # 3 специализированных агента
│   │   ├── research-assistant.md # Research mode с reasoning
│   │   ├── doc-analyst.md        # RAG-анализ документов
│   │   └── knowledge-explorer.md # Exploration + knowledge graph
│   ├── skills/                    # 3 описания возможностей R2R
│   │   ├── r2r-search.md         # Search capabilities (307 строк)
│   │   ├── r2r-rag.md            # RAG capabilities (400 строк)
│   │   └── r2r-graph.md          # Graph capabilities (465 строк)
│   ├── hooks/                     # Lifecycle hooks
│   │   └── SessionStart/         # check-r2r.md - статус API
│   ├── docs/                      # Документация и troubleshooting
│   │   ├── SEARCH_STRATEGIES.md  # Troubleshooting для R2R стратегий
│   │   └── migration/            # Архив миграции MCP → Bash
│   ├── config/                    # Конфигурация
│   │   └── .env                  # R2R_BASE_URL, API_KEY
│   ├── settings.json              # Пустой (hooks удалены после миграции)
│   └── README.md                  # Структура и quick start для .claude/
├── README.md                      # Главная страница проекта
```

## 🔧 Основные команды

### R2R API Integration (через bash скрипты)

**Конфигурация:** `.claude/config/.env`
```bash
R2R_BASE_URL=<your-r2r-api-url>
API_KEY=<your-api-key>
```

**Модульный CLI (8 команд, 48 подкоманд):**

```bash
# Core commands
.claude/scripts/r2r search "query" --limit 5
.claude/scripts/r2r rag "question" --max-tokens 8000
.claude/scripts/r2r agent "query" --mode research --thinking

# Management commands
.claude/scripts/r2r docs list -l 10 -q
.claude/scripts/r2r collections create -n "Name" -d "Description"
.claude/scripts/r2r conversation list
.claude/scripts/r2r graph entities <collection_id> -l 50
.claude/scripts/r2r analytics system
```

**Slash команды Claude Code (15):**

```bash
# Core Operations
/r2r-search "query" [limit]
/r2r-rag "question" [max_tokens]
/r2r-agent "message" [mode]
/r2r-collections [action]
/r2r-upload <file> [collection_id]

# Helper Scripts
/r2r-quick <task> [args]      # ask, status, up, col, continue, etc.
/r2r-workflows <workflow>     # upload, create-collection, research, etc.
/r2r-examples [category]      # search, rag, agent, docs, etc.

# Claude Code Documentation
/cc                           # Quick reference
/cc-hooks                     # Hooks documentation
/cc-commands                  # Custom commands guide
/cc-mcp                       # MCP integration
/cc-subagents                 # Subagents guide
/cc-setup                     # Installation guide
```

**Helper Scripts:**

```bash
# Quick Tasks (.claude/scripts/quick.sh)
./quick.sh ask "query"        # Search + RAG answer
./quick.sh status             # System status
./quick.sh up file.pdf        # Quick upload

# Workflows (.claude/scripts/workflows.sh)
./workflows.sh upload paper.pdf
./workflows.sh create-collection "Name" "Desc" *.pdf
./workflows.sh research "query"

# Aliases (.claude/scripts/aliases.sh - source в .bashrc/.zshrc)
source .claude/scripts/aliases.sh
rs "query"   # r2r search
rr "q"       # r2r rag
ra "msg"     # r2r agent
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
│  Claude Code    │  Slash Commands (15)
│  (Frontend)     │  /r2r-* (9) + /cc-* (6)
└────────┬────────┘
         │
┌────────▼────────┐
│ Modular CLI     │  r2r dispatcher → commands/*.sh
│  (Middleware)   │  + helpers: examples, workflows, quick, aliases
└────────┬────────┘
         │ curl + jq → JSON
┌────────▼────────┐
│      R2R        │  $R2R_BASE_URL
│   (Backend)     │  8 команд, 48 подкоманд
└─────────────────┘
```

**Важно:**
- Ранее использовался FastMCP bridge (MCP сервер), но удален в пользу прямых bash скриптов
- Монолитные r2r_client.sh и r2r_advanced.sh заменены модульной структурой commands/
- **Используется jq для формирования JSON** - избегает проблем с экранированием и валидностью

### Skills - описательная документация возможностей

Директория `.claude/skills/` содержит подробные описания R2R capabilities:

- **r2r-search.md** (307 строк) - Search strategies, filter types, query optimization
- **r2r-rag.md** (400 строк) - Generation modes, temperature guidelines, citation formats
- **r2r-graph.md** (465 строк) - Entity types, relationship discovery, community analysis

**Назначение:** Универсальные описания API возможностей, не зависят от реализации (CLI/MCP/direct API). Используются для понимания полного спектра функциональности R2R системы.

### R2R API Defaults

Конфигурация в `lib/common.sh`:
```bash
DEFAULT_LIMIT=3                    # Результатов поиска
DEFAULT_MAX_TOKENS=4000            # Токенов для генерации
DEFAULT_MODE="research"            # Agent mode (research/rag)
DEFAULT_SEARCH_STRATEGY="vanilla"  # ⚠️ ТОЛЬКО vanilla работает
```

**⚠️ Известная проблема:** Search strategies `hyde` и `rag_fusion` не работают из-за ошибки конфигурации VertexAI на R2R сервере. См. `.claude/docs/SEARCH_STRATEGIES.md` для деталей.

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
1. Проверь `.claude/docs/SEARCH_STRATEGIES.md`
2. Убедись что `DEFAULT_SEARCH_STRATEGY="vanilla"`
3. Проверь `.claude/config/.env` на наличие `API_KEY`

**Проблема:** "API_KEY not set in .env file"

**Решение:**
```bash
# Создай .claude/config/.env
cat > .claude/config/.env << 'EOF'
R2R_BASE_URL=<your-r2r-api-url>
API_KEY=<your-api-key>
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
- `.claude/README.md` - структура и quick start для .claude/
- `.claude/config/.env` - API credentials
- `.claude/scripts/r2r` - main CLI dispatcher
- `.claude/scripts/lib/common.sh` - shared configuration
- `.claude/scripts/commands/` - 8 modular commands:
  - search.sh, rag.sh, agent.sh, docs.sh
  - collections.sh, conversation.sh, graph.sh, analytics.sh
- `.claude/scripts/` - 4 helper scripts:
  - examples.sh, workflows.sh, quick.sh, aliases.sh
- `.claude/skills/` - 3 описания возможностей R2R:
  - r2r-search.md (307 строк), r2r-rag.md (400 строк), r2r-graph.md (465 строк)
- `.claude/docs/SEARCH_STRATEGIES.md` - troubleshooting

### Документация навигация
- `docs/r2r/README.md` - R2R documentation index
- `docs/fastmcp/README.md` - FastMCP documentation index
- `docs/claude_code/README.md` - Claude Code documentation index
- `docs/claude_code/SUMMARY.md` - краткое содержание

### Миграция notes
- `.claude/docs/migration/SUMMARY.md`
- `.claude/docs/migration/VERIFICATION.md`
- `.claude/docs/migration/README.md`

## 🎯 Ключевые принципы

1. **Это документация, не код** - не создавай build tools, тесты, CI/CD
2. **Русский + English** - текст на русском, код/термины/API на английском
3. **Практичность** - каждый пример должен быть применимым
4. **Консистентность** - следуй существующему стилю во всех файлах
5. **Vanilla strategy only** - продвинутые R2R стратегии не работают
6. **Современные инструменты** - rg вместо grep, fd вместо find
7. **Одна строка коммитов** - без подписей, краткие описания
