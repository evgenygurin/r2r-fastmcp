# План рефакторинга Slash Commands

## 🎯 Цель

Привести все slash commands в соответствие с официальными best practices Claude Code, улучшить структуру frontmatter, аргументы, документацию и интеграцию с bash скриптами.

## 📊 Текущее состояние

**Количество команд:** 15 файлов
- **R2R команды (9):** r2r.md, r2r-search.md, r2r-rag.md, r2r-agent.md, r2r-collections.md, r2r-upload.md, r2r-examples.md, r2r-workflows.md, r2r-quick.md
- **Claude Code документация (6):** cc.md, cc-hooks.md, cc-commands.md, cc-mcp.md, cc-subagents.md, cc-setup.md

## 🔍 Анализ текущей реализации

### ✅ Что уже хорошо

1. **Frontmatter присутствует** во всех командах с полями:
   - `name` - имя команды
   - `description` - краткое описание
   - `allowed-tools` - разрешенные инструменты
   - `denied-tools` - запрещенные инструменты

2. **Структурированная документация:**
   - Четкие заголовки и разделы
   - Примеры использования
   - Инструкции для пользователя

3. **Bash интеграция:**
   - Используется `.claude/scripts/r2r` как unified CLI
   - Команды вызывают соответствующие bash скрипты

### ❌ Проблемы и несоответствия

1. **Аргументы не соответствуют официальному формату:**
   - **Текущий формат:** `$1`, `$2`, `$3` (позиционные параметры)
   - **Правильный формат:** `{arg1}`, `{arg2}`, `{arg3}` (placeholders в фигурных скобках)

2. **Отсутствует `argument-hint`:**
   - Нет формального определения аргументов в frontmatter
   - Пользователи не видят структуру команды при автодополнении

3. **Недостаточное использование file references:**
   - Команды документации (cc-*) могли бы ссылаться на реальные файлы через `@`
   - Это улучшило бы контекст и актуальность информации

4. **Отсутствие bash command execution в документации:**
   - Команды cc-* читают только статическую markdown документацию
   - Могли бы использовать `!` для динамического получения информации

5. **Неоптимальная структура instructions:**
   - Слишком много текста для пользователя
   - Можно сделать более кратко и action-oriented

## 📋 Официальные Best Practices

### 1. Frontmatter Fields

**Обязательные:**
```yaml
name: command-name
description: Brief one-line description
```

**Рекомендуемые:**
```yaml
argument-hint: <arg1> [arg2] [--flag]  # Показывает структуру команды
allowed-tools: Bash, Read              # Разрешенные инструменты
denied-tools: Write, Edit              # Запрещенные инструменты
model: claude-3-7-sonnet              # Специфичная модель (optional)
disable-model-invocation: false       # Отключить auto-execution (optional)
```

### 2. Argument Placeholders

**Правильный формат:**
```markdown
Query: **{query}**
Limit: **{limit}** (default: 3)
Mode: **{mode}** (rag/research, default: research)
```

**Argument Hint Format:**
```yaml
# Обязательные и опциональные аргументы
argument-hint: <query> [limit] [--verbose]

# Несколько вариантов (pipe-separated)
argument-hint: list | create <name> <desc> | delete <id>

# Флаги
argument-hint: <file> [collection_ids] [--json] [--quiet]
```

### 3. File References

**Использование `@` для включения файлов:**
```markdown
Review the implementation in @.claude/scripts/r2r

The configuration is in @.claude/config/.env

Refer to documentation at @docs/r2r/README.md
```

### 4. Bash Command Execution

**Использование `!` для динамических данных:**
```markdown
Current git status:
!git status

Available collections:
!.claude/scripts/r2r collections list --limit 5 --quiet

System status:
!.claude/scripts/r2r analytics system
```

### 5. Command Structure

**Оптимальная структура:**
```markdown
---
name: command-name
description: Brief one-line description
argument-hint: <arg1> [arg2] [--flag]
allowed-tools: Bash, Read
denied-tools: Write, Edit
---

# Command Title

**Query:** {query}
**Options:** {options}

## Instructions

Clear, concise instructions for Claude on what to do.

Execute command:
```bash
.claude/scripts/command {query} {options}
```

Present results in format:
- Result 1
- Result 2

## Examples

```bash
/command-name "example" option
```
```

## 🎯 План рефакторинга по командам

### R2R Core Commands

#### 1. `/r2r` (r2r.md)
**Тип:** Reference / Read-only

**Текущие проблемы:**
- ❌ Denied tools включает Read (неправильно для reference команды)
- ❌ Нет argument-hint
- ❌ Статический контент, можно сделать динамическим

**Изменения:**
```yaml
---
name: r2r
description: Show R2R quick reference with modular CLI commands
allowed-tools: Read, Bash
denied-tools: Write, Edit
---

# R2R Quick Reference

## Modular R2R CLI

!.claude/scripts/r2r help

## Available Commands

Refer to @.claude/scripts/README.md for complete documentation.

### Core Commands
- `search` - @.claude/commands/r2r-search.md
- `rag` - @.claude/commands/r2r-rag.md
- `agent` - @.claude/commands/r2r-agent.md
...
```

**Обоснование:**
- ✅ Разрешаем Read для чтения документации
- ✅ Разрешаем Bash для `!r2r help` (динамическая информация)
- ✅ Используем `@` для ссылок на документацию
- ✅ Добавляем `!` для актуальной информации о CLI

#### 2. `/r2r-search` (r2r-search.md)
**Тип:** Action / Execute

**Текущие проблемы:**
- ❌ Аргументы в формате `$1`, `$2` вместо `{query}`, `{limit}`
- ❌ Нет argument-hint
- ❌ Instructions слишком подробные

**Изменения:**
```yaml
---
name: r2r-search
description: Search R2R knowledge base with semantic/hybrid search
argument-hint: <query> [limit] [--verbose|--json|--quiet]
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R Knowledge Base Search

**Query:** {query}
**Limit:** {limit} (default: 3)

## Instructions

Execute hybrid search using modular R2R CLI:

```bash
.claude/scripts/r2r search "{query}" --limit {limit}
```

Present results clearly:
1. **Score:** X.XX
2. **Document:** Title [ID]
3. **Text:** Excerpt

Available flags: --quiet, --json, --verbose, --graph, --collection <id>

## Examples

```bash
# Basic search
/r2r-search "machine learning" 5

# With flags
/r2r-search "transformers" 3 --verbose
```
```

**Обоснование:**
- ✅ Используем `{query}`, `{limit}` вместо `$1`, `$2`
- ✅ Добавляем argument-hint с опциональными флагами
- ✅ Упрощаем instructions
- ✅ Сохраняем allowed-tools: Bash (единственное что нужно)

#### 3. `/r2r-rag` (r2r-rag.md)
**Тип:** Action / Execute

**Текущие проблемы:**
- ❌ Аргументы `$1`, `$2` вместо `{query}`, `{max_tokens}`
- ❌ Нет argument-hint
- ❌ Слишком много текста в instructions

**Изменения:**
```yaml
---
name: r2r-rag
description: RAG query to R2R with answer generation
argument-hint: <query> [max_tokens] [--json|--show-sources]
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R RAG Query

**Query:** {query}
**Max Tokens:** {max_tokens} (default: 8000)

## Instructions

Execute RAG query with hybrid search + generation:

```bash
.claude/scripts/r2r rag "{query}" --max-tokens {max_tokens}
```

Present:
- **Generated Answer:** [clean text response]
- **Sources:** [brief context note]

Flags: --json, --show-sources, --show-metadata, --graph, --collection <id>

## Examples

```bash
/r2r-rag "What is FastMCP?" 8000
/r2r-rag "Explain transformers" 12000 --show-sources
```
```

**Обоснование:**
- ✅ `{query}`, `{max_tokens}` placeholders
- ✅ Краткие instructions
- ✅ argument-hint с опциями

#### 4. `/r2r-agent` (r2r-agent.md)
**Тип:** Action / Interactive

**Текущие проблемы:**
- ❌ Аргументы `$1`, `$2`, `$3`, `$4` вместо именованных
- ❌ Нет argument-hint
- ❌ Сложные instructions

**Изменения:**
```yaml
---
name: r2r-agent
description: Multi-turn conversation with R2R agent
argument-hint: <message> [mode] [conversation_id] [--thinking|--json]
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R Agent Conversation

**Message:** {message}
**Mode:** {mode} (rag/research, default: research)
**Conversation ID:** {conversation_id} (optional, auto-reused from /tmp/.r2r_conversation_id)

## Instructions

Execute agent conversation:

```bash
.claude/scripts/r2r agent "{message}" --mode {mode} ${conversation_id:+--conversation {conversation_id}}
```

**Modes:**
- `research` (default): Advanced reasoning, critique, code execution
- `rag`: Standard knowledge base queries

Present:
- **Response:** [agent's answer]
- **Conversation ID:** [auto-saved to /tmp/.r2r_conversation_id]
- **Mode:** [current mode]

Flags: --thinking (4096 token budget), --show-tools, --show-sources, --json

## Examples

```bash
/r2r-agent "What is DeepSeek R1?"
/r2r-agent "Continue discussion" research <conv_id>
/r2r-agent "Deep analysis" research "" --thinking
```
```

**Обоснование:**
- ✅ Именованные placeholders
- ✅ Четкий argument-hint
- ✅ Краткие, action-oriented instructions

#### 5. `/r2r-collections` (r2r-collections.md)
**Тип:** Management / Multiple Actions

**Текущие проблемы:**
- ❌ Аргумент `$1` вместо `{action}`
- ❌ Нет argument-hint
- ❌ Множество подкоманд не структурированы

**Изменения:**
```yaml
---
name: r2r-collections
description: List and manage R2R collections
argument-hint: list | create <name> <desc> | add-doc <col_id> <doc_id> | delete <id>
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R Collections Management

**Action:** {action}

## Instructions

Use modular CLI for collection management:

**List:**
```bash
.claude/scripts/r2r collections list --limit 10
```

**Create:**
```bash
.claude/scripts/r2r collections create --name "{name}" --description "{desc}"
```

**Add document:**
```bash
.claude/scripts/r2r collections add-doc --collection {col_id} --document {doc_id}
```

**Get details:**
```bash
.claude/scripts/r2r collections get {collection_id}
```

**Delete:**
```bash
.claude/scripts/r2r collections delete {collection_id}
```

Present collections:
- **Collection ID:** [UUID]
- **Name:** [human-readable]
- **Description:** [purpose]
- **Documents:** [count if available]

Flags: --limit, --offset, --quiet, --json

## Examples

```bash
/r2r-collections list
/r2r-collections create "AI Research" "ML papers"
/r2r-collections add-doc <col_id> <doc_id>
```
```

**Обоснование:**
- ✅ argument-hint показывает все варианты с pipe-separator
- ✅ Структурированные подкоманды
- ✅ Placeholders вместо позиционных параметров

#### 6. `/r2r-upload` (r2r-upload.md)
**Тип:** Action / Potentially Destructive

**Текущие проблемы:**
- ❌ `$1`, `$2`, `$3` вместо именованных аргументов
- ❌ Нет argument-hint
- ❌ Могла бы использовать Glob для поиска файлов

**Изменения:**
```yaml
---
name: r2r-upload
description: Upload document to R2R knowledge base
argument-hint: <file_path> [collection_ids] [--title|--mode|--json]
allowed-tools: Bash, Read, Glob
denied-tools: Write, Edit
---

# Upload Document to R2R

**File Path:** {file_path}
**Collection IDs:** {collection_ids} (optional, comma-separated)

⚠️ **IMPORTANT:** This is a potentially destructive operation. Confirm with user before uploading.

## Instructions

If file not provided, list available documents using Glob:
```bash
# List uploadable files
```

Execute upload:
```bash
.claude/scripts/r2r docs upload "{file_path}" ${collection_ids:+--collections "{collection_ids}"}
```

After successful upload:
1. Extract document_id from response
2. Confirm upload status
3. Suggest next steps:
   - Extract knowledge graph: `.claude/scripts/r2r docs extract <document_id>`
   - Search document content
   - Build communities

Supported formats: PDF, MD, TXT, DOCX, HTML, JSON, CSV

Flags: --collections, --title, --mode (hi-res/fast), --quiet, --json

## Examples

```bash
/r2r-upload research.pdf
/r2r-upload paper.pdf "col1,col2"
/r2r-upload document.md "" --mode fast
```
```

**Обоснование:**
- ✅ Placeholders вместо `$1`, `$2`
- ✅ argument-hint с опциями
- ✅ Использование Glob для поиска файлов
- ✅ Явное предупреждение о destructive operation

### Helper Commands

#### 7. `/r2r-examples` (r2r-examples.md)
**Тип:** Interactive / Educational

**Текущие проблемы:**
- ❌ `$1` вместо `{category}`
- ❌ Нет argument-hint

**Изменения:**
```yaml
---
name: r2r-examples
description: Interactive R2R examples and tutorials (50+ demonstrations)
argument-hint: [category]
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R Interactive Examples

**Category:** {category} (search, rag, agent, docs, collections, graph, workflows, all)

## Instructions

Execute interactive examples script:

```bash
.claude/scripts/examples.sh {category}
```

Features:
- 50+ ready-to-use demonstrations
- Interactive step-by-step execution
- Safe execution with confirmations

Categories:
- `search` - Search examples (basic, quiet, JSON, collection, graph)
- `rag` - RAG queries (basic, extended, show-sources)
- `agent` - Agent modes (research, rag, thinking, conversation)
- `docs` - Document management
- `collections` - Collection operations
- `graph` - Knowledge graph features
- `workflows` - Complete multi-step workflows
- `all` - All examples

## Examples

```bash
/r2r-examples
/r2r-examples search
/r2r-examples workflows
```
```

**Обоснование:**
- ✅ `{category}` placeholder
- ✅ Опциональный аргумент в hint `[category]`
- ✅ Четкий список категорий

#### 8. `/r2r-workflows` (r2r-workflows.md)
**Тип:** Automation / Multi-step

**Текущие проблемы:**
- ❌ `$1`, `$2`, `$3` вместо именованных
- ❌ Нет argument-hint

**Изменения:**
```yaml
---
name: r2r-workflows
description: Automated R2R workflows for common multi-step tasks
argument-hint: upload <file> [col_id] | create-collection <name> <desc> <files...> | research <query> [mode] | analyze <doc_id> | batch-upload <dir> [col_id] [pattern]
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R Automated Workflows

**Workflow:** {workflow}
**Arguments:** {args}

## Instructions

Execute multi-step automated workflow:

```bash
.claude/scripts/workflows.sh {workflow} {args}
```

## Available Workflows

### upload <file> [collection_id]
Upload + extract + verify workflow

### create-collection <name> <desc> <files...>
Create collection + upload + extract + build communities

### research <query> [mode]
Interactive research session with follow-ups

### analyze <document_id>
Comprehensive document analysis (metadata + search + graph + RAG)

### batch-upload <directory> [collection_id] [pattern]
Mass upload with progress tracking

## Examples

```bash
/r2r-workflows upload paper.pdf
/r2r-workflows create-collection "Research" "AI papers" *.pdf
/r2r-workflows research "What is RAG?"
/r2r-workflows analyze <doc_id>
/r2r-workflows batch-upload ./papers collection123 "*.pdf"
```
```

**Обоснование:**
- ✅ Полный argument-hint со всеми workflow вариантами
- ✅ Именованные placeholders
- ✅ Краткая документация каждого workflow

#### 9. `/r2r-quick` (r2r-quick.md)
**Тип:** Quick Tasks / Shortcuts

**Текущие проблемы:**
- ❌ `$1`, `$2`, `$3` вместо именованных
- ❌ Нет argument-hint со всеми tasks

**Изменения:**
```yaml
---
name: r2r-quick
description: Quick one-line R2R tasks and shortcuts
argument-hint: ask <query> | status | up <file> [col_id] | col <name> [desc] | col-search <query> | continue <msg> | graph <col_id> | batch [pattern] | find <term> | cleanup
allowed-tools: Bash
denied-tools: Write, Edit
---

# R2R Quick Tasks

**Task:** {task}
**Arguments:** {args}

## Instructions

Execute quick task:

```bash
.claude/scripts/quick.sh {task} {args}
```

## Available Tasks

| Task | Description | Usage |
|------|-------------|-------|
| `ask <query>` | Search + RAG answer | `ask "What is RAG?"` |
| `status` | System status | `status` |
| `up <file> [col]` | Upload + extract | `up paper.pdf` |
| `col <name> [desc]` | Create collection | `col "Research"` |
| `col-search <q>` | Search last collection | `col-search "transformers"` |
| `continue <msg>` | Continue last conversation | `continue "Tell more"` |
| `graph <col_id>` | Graph overview | `graph <id>` |
| `batch [pattern]` | Batch upload | `batch "*.pdf"` |
| `find <term>` | Find by title | `find "machine"` |
| `cleanup` | Delete failed docs | `cleanup` |

## Examples

```bash
/r2r-quick ask "What is R2R?"
/r2r-quick up paper.pdf
/r2r-quick status
/r2r-quick continue "Elaborate"
```
```

**Обоснование:**
- ✅ Полный argument-hint со всеми tasks
- ✅ Таблица для быстрого reference
- ✅ Именованные placeholders

### Documentation Commands

#### 10-15. CC Commands (cc.md, cc-hooks.md, cc-commands.md, cc-mcp.md, cc-subagents.md, cc-setup.md)
**Тип:** Documentation / Read-only

**Текущие проблемы:**
- ❌ Denied tools включает Read (противоречие)
- ❌ Статический контент, не используются file references
- ❌ Нет динамических данных через bash

**Общие изменения для всех CC команд:**
```yaml
---
name: cc-*
description: Claude Code documentation reference for [topic]
allowed-tools: Read
denied-tools: Bash, Write, Edit
---

# Claude Code [Topic]

Refer to comprehensive documentation at @docs/claude_code/[NN-topic].md

[Brief summary or key points]

## Quick Reference

[1-2 most important points]

## Related Commands

- `/cc` - Quick reference
- `/cc-[other]` - Related topics

## Full Documentation

For complete details, see @docs/claude_code/README.md
```

**Специфичные изменения:**

**cc.md:**
```yaml
---
name: cc
description: Claude Code quick reference and command overview
allowed-tools: Read
denied-tools: Bash, Write, Edit
---

# Claude Code Quick Reference

Comprehensive Claude Code documentation available at @docs/claude_code/README.md

## Key Topics

- **Installation & Setup:** @docs/claude_code/02-installation-and-setup.md
- **Core Features:** @docs/claude_code/03-core-features.md
- **Commands:** @docs/claude_code/04-commands-and-usage.md
- **Hooks:** @docs/claude_code/05-hooks-and-customization.md
- **Subagents:** @docs/claude_code/06-subagents.md
- **MCP Integration:** @docs/claude_code/07-mcp-integration.md

## Custom Commands

This project has 15 slash commands:
- `/r2r-*` - R2R API operations (9 commands)
- `/cc-*` - Claude Code documentation (6 commands)

Use `/help` to see all available commands.

## Documentation Commands

- `/cc-hooks` - Hooks documentation
- `/cc-commands` - Custom commands guide
- `/cc-mcp` - MCP integration
- `/cc-subagents` - Subagents guide
- `/cc-setup` - Installation guide
```

**Обоснование:**
- ✅ Используем `@` для ссылок на документацию
- ✅ Read разрешен (нужен для чтения файлов)
- ✅ Bash запрещен (не нужен для документации)
- ✅ Краткий overview с ссылками на полную документацию

## 🔧 Дополнительные улучшения

### 1. Namespacing (опционально)

Можно организовать команды через subdirectories:

```
.claude/commands/
├── r2r/
│   ├── core/
│   │   ├── search.md      → /r2r:core:search
│   │   ├── rag.md         → /r2r:core:rag
│   │   └── agent.md       → /r2r:core:agent
│   ├── management/
│   │   ├── docs.md        → /r2r:management:docs
│   │   └── collections.md → /r2r:management:collections
│   └── helpers/
│       ├── quick.md       → /r2r:helpers:quick
│       ├── workflows.md   → /r2r:helpers:workflows
│       └── examples.md    → /r2r:helpers:examples
└── docs/
    ├── cc.md              → /docs:cc
    ├── hooks.md           → /docs:hooks
    └── ...
```

**Плюсы:**
- Логическая группировка
- Избежание конфликтов имен
- Улучшенная организация

**Минусы:**
- Более длинные команды
- Требует обновления всех ссылок

**Решение:** Отложить namespacing для будущего рефакторинга, сохранить текущую flat структуру.

### 2. Model-specific Commands

Некоторые команды могут использовать специфичные модели:

```yaml
# Для сложных reasoning задач
---
name: r2r-agent
model: claude-3-7-sonnet  # Самая мощная модель
---

# Для простых reference команд
---
name: cc
model: claude-3-5-haiku  # Быстрая модель
---
```

**Решение:** Добавить в план как опциональное улучшение.

### 3. Disable Model Invocation

Некоторые команды не должны auto-execute:

```yaml
---
name: r2r-upload
disable-model-invocation: true  # Требует явного подтверждения
---
```

**Решение:** Добавить для потенциально destructive команд.

## 📝 Порядок выполнения рефакторинга

### Фаза 1: Core Commands (Priority 1)
1. ✅ `/r2r-search` - базовая search команда
2. ✅ `/r2r-rag` - базовая RAG команда
3. ✅ `/r2r-agent` - agent команда

### Фаза 2: Management Commands (Priority 2)
4. ✅ `/r2r-collections` - управление коллекциями
5. ✅ `/r2r-upload` - загрузка документов

### Фаза 3: Helper Commands (Priority 3)
6. ✅ `/r2r-quick` - quick tasks
7. ✅ `/r2r-workflows` - workflows
8. ✅ `/r2r-examples` - examples

### Фаза 4: Reference Commands (Priority 4)
9. ✅ `/r2r` - quick reference
10-15. ✅ CC Commands (cc.md, cc-hooks.md, cc-commands.md, cc-mcp.md, cc-subagents.md, cc-setup.md)

## ✅ Критерии успешного рефакторинга

### Технические критерии

1. **Frontmatter:**
   - ✅ Все команды имеют `name` и `description`
   - ✅ Добавлен `argument-hint` где применимо
   - ✅ `allowed-tools` и `denied-tools` корректны
   - ✅ Нет противоречий в permissions

2. **Аргументы:**
   - ✅ Используются `{placeholder}` вместо `$1`, `$2`
   - ✅ Опциональные аргументы в `[brackets]`
   - ✅ Обязательные аргументы в `<brackets>`
   - ✅ Флаги указаны с `--` или `-`

3. **File References:**
   - ✅ Используется `@` для ссылок на документацию
   - ✅ Используется `!` для bash commands где нужны динамические данные
   - ✅ Пути корректны и файлы существуют

4. **Instructions:**
   - ✅ Краткие и action-oriented
   - ✅ Четкие bash команды с placeholders
   - ✅ Явные инструкции по output format
   - ✅ Примеры использования

### Функциональные критерии

1. **Команды работают:**
   - ✅ Все bash скрипты вызываются корректно
   - ✅ Аргументы передаются правильно
   - ✅ Output форматируется как ожидается

2. **Документация полная:**
   - ✅ Описания понятны
   - ✅ Примеры актуальны
   - ✅ Флаги документированы
   - ✅ Ссылки на связанные команды

3. **Пользовательский опыт:**
   - ✅ Autocomplete показывает argument hints
   - ✅ `/help` отображает корректные описания
   - ✅ Команды интуитивны
   - ✅ Ошибки понятны

## 🧪 План тестирования

### 1. Syntax Tests
```bash
# Проверка frontmatter
for cmd in .claude/commands/*.md; do
  echo "Checking $cmd"
  head -20 "$cmd" | grep -q "^name:" || echo "Missing name in $cmd"
  head -20 "$cmd" | grep -q "^description:" || echo "Missing description in $cmd"
done
```

### 2. Placeholder Tests
```bash
# Проверка что нет старых $1, $2
rg '\$[0-9]' .claude/commands/*.md
# Должно быть 0 результатов после рефакторинга
```

### 3. Functional Tests
```bash
# Протестировать каждую команду
/r2r-search "test" 3
/r2r-rag "test question"
/r2r-agent "test message"
/r2r-collections list
/r2r-quick status
```

### 4. File Reference Tests
```bash
# Проверить что все @ ссылки корректны
rg '@[a-zA-Z0-9_/.-]+' .claude/commands/*.md -o | while read ref; do
  file="${ref#@}"
  [ -f "$file" ] || echo "File not found: $file"
done
```

## 📊 Метрики успеха

**До рефакторинга:**
- 15 команд
- 0 команд с `argument-hint`
- 0 команд с file references
- 0 команд с bash execution
- 100% используют `$1`, `$2` аргументы

**После рефакторинга:**
- 15 команд
- 15 команд с `argument-hint` (100%)
- 10+ команд с file references (66%+)
- 2+ команд с bash execution (13%+)
- 0 команд с `$N` аргументами (0%)

## 🔗 Ссылки

### Официальная документация
- [Slash Commands](https://code.claude.com/docs/en/slash-commands)
- [Custom Commands](https://code.claude.com/docs/en/common-workflows)
- [Frontmatter Reference](https://code.claude.com/docs/en/slash-commands#frontmatter)

### Примеры из Context7
- `/anthropics/claude-code` - official repo
- `/websites/code_claude_en` - documentation
- `/davila7/claude-code-templates` - templates

### Проектная документация
- `docs/claude_code/04-commands-and-usage.md` - Commands documentation
- `docs/claude_code/09-plugins-and-marketplaces.md` - Plugin commands
- `.claude/scripts/README.md` - CLI documentation

---

**Статус:** 📝 Draft
**Версия:** 1.0
**Дата создания:** 2025-01-XX
**Автор:** Claude Code + Human
