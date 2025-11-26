# План рефакторинга Claude Code Commands

## 📋 Резюме

Проект содержит 15 custom slash commands в `.claude/commands/`, которые используют базовые возможности Claude Code. Официальная документация Claude Code предлагает расширенные возможности, которые не используются в текущей реализации.

**Цель:** Привести все команды в соответствие с best practices официальной документации Claude Code, улучшив UX и функциональность без breaking changes.

---

## 🔍 Анализ текущего состояния

### Текущие команды (15)

**R2R Commands (9):**
- `r2r.md` - Main R2R interface
- `r2r-search.md` - Search knowledge base
- `r2r-rag.md` - RAG query with generation
- `r2r-agent.md` - Multi-turn agent conversation
- `r2r-collections.md` - Collection management
- `r2r-upload.md` - Document upload
- `r2r-examples.md` - Interactive examples
- `r2r-workflows.md` - Automated workflows
- `r2r-quick.md` - Quick shortcuts

**Claude Code Commands (6):**
- `cc.md` - Quick reference
- `cc-hooks.md` - Hooks documentation
- `cc-commands.md` - Commands guide
- `cc-mcp.md` - MCP integration
- `cc-subagents.md` - Subagents guide
- `cc-setup.md` - Installation guide

### Что используется сейчас

✅ **Используется:**
- YAML frontmatter с `name`, `description`
- `allowed-tools`, `denied-tools`
- Позиционные параметры `$1`, `$2`, `$3`
- Markdown body с инструкциями

❌ **НЕ используется:**
- `argument-hint` - подсказка синтаксиса
- `$ARGUMENTS` - паттерн для всех аргументов
- `!command` - bash pre-execution
- `model` - специфичная модель
- `disable-model-invocation` - отключение LLM вызова

---

## 🎯 Выявленные проблемы

### 1. Отсутствие argument-hint

**Проблема:** Пользователи должны угадывать синтаксис команды.

**Официальная рекомендация:**
```yaml
---
argument-hint: "[pr-number] [priority] [assignee]"
description: Review pull request
---
```

**Текущее состояние:**
```yaml
---
description: Search R2R knowledge base with semantic/hybrid search
---
```

**Влияние:** Снижение user experience, больше ошибок при вызове команд.

### 2. Непоследовательное использование параметров

**Проблема:** Смешение `$1, $2, $3` vs потенциального `$ARGUMENTS`.

**Официальная рекомендация:**
- `$1, $2, $3` - для фиксированных позиционных аргументов
- `$ARGUMENTS` - для переменного числа аргументов или всех аргументов как строки

**Примеры из проекта:**

`r2r-search.md`:
```markdown
Search query: **$1**
Limit: **$2** (default: 3 results)
```
✅ Правильно - фиксированные параметры

`r2r-workflows.md`:
```markdown
Workflow: **$1** (upload, create-collection, research, analyze, batch-upload)
Arguments: **$2**, **$3**, **$4**...
```
⚠️ Должно использовать `$ARGUMENTS` - переменное число аргументов

### 3. Отсутствие bash pre-execution

**Проблема:** Команды не могут динамически получать контекст перед выполнением.

**Официальная рекомендация:**
```markdown
---
allowed-tools: Bash(git status:*), Bash(git diff:*)
---

## Context

- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`
- Git status: !`git status`

## Your task
...
```

**Потенциальное применение:**
- `r2r-upload.md` - проверить существование файла перед загрузкой
- `r2r-collections.md` - показать список существующих коллекций
- `cc-hooks.md` - показать существующие hooks

### 4. Избыточные denied-tools

**Проблема:** `denied-tools: Write, Edit` часто указывается, когда достаточно `allowed-tools: Bash`.

**Официальная рекомендация:**
```yaml
---
allowed-tools: Read, Grep, Glob
# denied-tools не нужен - все остальное запрещено по умолчанию
---
```

**Текущее состояние:**
```yaml
---
allowed-tools: Bash
denied-tools: Write, Edit  # Избыточно
---
```

### 5. Неполные descriptions

**Проблема:** Некоторые descriptions слишком краткие.

**Примеры:**

✅ Хорошо:
```yaml
description: Search R2R knowledge base with semantic/hybrid search
```

⚠️ Можно лучше:
```yaml
description: Claude Code quick reference
# Лучше: "Claude Code documentation quick reference with navigation links"
```

### 6. Отсутствие model field

**Проблема:** Некоторые команды могут выиграть от специфичных моделей.

**Официальная рекомендация:**
```yaml
---
model: claude-3-5-haiku-20241022  # Для быстрых команд
---
```

**Потенциальное применение:**
- Documentation commands (cc-*) - могут использовать быстрые модели (haiku)
- Complex analysis commands - могут требовать sonnet/opus

---

## 📊 Audit Matrix

| Command | argument-hint | $ARGUMENTS | !bash | model | Description | Priority |
|---------|---------------|------------|-------|-------|-------------|----------|
| r2r.md | ❌ | ✅ Candidate | ❌ | ❌ | ⚠️ OK | Medium |
| r2r-search.md | ❌ | ❌ OK | ❌ | ❌ | ✅ Good | High |
| r2r-rag.md | ❌ | ❌ OK | ❌ | ❌ | ✅ Good | High |
| r2r-agent.md | ❌ | ❌ OK | ❌ | ❌ | ✅ Good | High |
| r2r-collections.md | ❌ | ✅ Candidate | ✅ Candidate | ❌ | ⚠️ OK | Medium |
| r2r-upload.md | ❌ | ❌ OK | ✅ Candidate | ❌ | ✅ Good | High |
| r2r-examples.md | ❌ | ✅ Candidate | ❌ | ❌ | ⚠️ OK | Low |
| r2r-workflows.md | ❌ | ✅ **Required** | ❌ | ❌ | ✅ Good | High |
| r2r-quick.md | ❌ | ✅ **Required** | ❌ | ❌ | ✅ Good | High |
| cc.md | ❌ | N/A | ❌ | ✅ haiku | ⚠️ Short | Low |
| cc-hooks.md | ❌ | N/A | ✅ Candidate | ✅ haiku | ✅ Good | Low |
| cc-commands.md | ❌ | N/A | ❌ | ✅ haiku | ✅ Good | Low |
| cc-mcp.md | ❌ | N/A | ❌ | ✅ haiku | ✅ Good | Low |
| cc-subagents.md | ❌ | N/A | ❌ | ✅ haiku | ✅ Good | Low |
| cc-setup.md | ❌ | N/A | ❌ | ✅ haiku | ✅ Good | Low |

**Legend:**
- ✅ Good - соответствует best practices
- ⚠️ OK - работает, но можно улучшить
- ❌ Missing - отсутствует
- N/A - не применимо
- Candidate - может выиграть от использования
- **Required** - обязательно нужно изменить

---

## 🚀 План рефакторинга

### Phase 1: Quick Wins (1-2 часа)

**Цель:** Улучшить UX без breaking changes.

#### 1.1 Добавить argument-hint ко всем командам

**Приоритет:** HIGH

**Команды для обновления (15):**

```yaml
# r2r-search.md
---
argument-hint: "<query> [limit]"
description: Search R2R knowledge base with semantic/hybrid search
---

# r2r-rag.md
---
argument-hint: "<question> [max_tokens]"
description: RAG query to R2R with answer generation
---

# r2r-agent.md
---
argument-hint: "<message> [mode] [conversation_id] [max_tokens]"
description: Multi-turn conversation with R2R agent (rag/research modes)
---

# r2r-collections.md
---
argument-hint: "[action]"
description: Manage R2R collections (list/create/delete/docs)
---

# r2r-upload.md
---
argument-hint: "<file> [collection_id]"
description: Upload document to R2R with automatic processing
---

# r2r-workflows.md
---
argument-hint: "<workflow> [args...]"
description: Automated R2R workflows (upload/create-collection/research/analyze/batch-upload)
---

# r2r-quick.md
---
argument-hint: "<task> [args...]"
description: Quick R2R shortcuts (ask/status/up/col/continue/last/etc)
---

# r2r-examples.md
---
argument-hint: "[category]"
description: Interactive R2R examples (search/rag/agent/docs/collections/graph)
---

# r2r.md
---
argument-hint: "<command> [args...]"
description: Main R2R CLI interface (search/rag/agent/docs/collections/conversation/graph/analytics)
---

# cc-*.md commands (no arguments, N/A)
---
# No argument-hint needed - these are documentation commands
---
```

**Результат:** Пользователи сразу видят ожидаемый синтаксис при `/help`.

#### 1.2 Улучшить descriptions

**Приоритет:** MEDIUM

```yaml
# cc.md - ДО
description: Claude Code quick reference

# cc.md - ПОСЛЕ
description: Claude Code documentation quick reference with navigation links and core capabilities overview

# r2r-collections.md - ДО
description: Manage R2R collections (list/create/delete/docs)

# r2r-collections.md - ПОСЛЕ
description: Manage R2R collections - list, create, delete, add/remove documents, show details
```

#### 1.3 Удалить избыточные denied-tools

**Приоритет:** LOW

```yaml
# ДО
---
allowed-tools: Bash
denied-tools: Write, Edit
---

# ПОСЛЕ
---
allowed-tools: Bash
---
```

**Применить к:** r2r-search.md, r2r-rag.md, r2r-agent.md, r2r-upload.md, r2r-workflows.md, r2r-quick.md, r2r-examples.md

---

### Phase 2: Standardization (2-3 часа)

**Цель:** Привести параметры к единому стилю.

#### 2.1 Конвенция использования параметров

**Решение:**

| Паттерн | Использование | Примеры команд |
|---------|---------------|----------------|
| `$1, $2, $3` | Фиксированные позиционные параметры с известным количеством | r2r-search, r2r-rag, r2r-agent, r2r-upload |
| `$ARGUMENTS` | Переменное число параметров ИЛИ все параметры как одна строка | r2r-workflows, r2r-quick, r2r |
| N/A | Команды без параметров | cc-*, r2r-collections (subcommands), r2r-examples (optional) |

#### 2.2 Рефакторинг команд на $ARGUMENTS

**Приоритет:** HIGH

**Команды требующие изменений:**

1. **r2r-workflows.md** - переменное число аргументов

```markdown
# ДО
Workflow: **$1** (upload, create-collection, research, analyze, batch-upload)
Arguments: **$2**, **$3**, **$4**...

Execute workflow:
```bash
.claude/scripts/workflows.sh "$1" "${@:2}"
```

# ПОСЛЕ
Workflow and arguments: **$ARGUMENTS**

Execute workflow:
```bash
.claude/scripts/workflows.sh $ARGUMENTS
```
```

2. **r2r-quick.md** - переменное число аргументов

```markdown
# ДО
Task: **$1**
Arguments: **$2**, **$3**, **$4**...

Execute quick task:
```bash
.claude/scripts/quick.sh "$1" "${@:2}"
```

# ПОСЛЕ
Task and arguments: **$ARGUMENTS**

Execute quick task:
```bash
.claude/scripts/quick.sh $ARGUMENTS
```
```

3. **r2r.md** - переменное число аргументов

```markdown
# ДО
Command: **$1**
Arguments: **$2**, **$3**, **$4**...

Execute R2R CLI:
```bash
.claude/scripts/r2r "$1" "${@:2}"
```

# ПОСЛЕ
Command and arguments: **$ARGUMENTS**

Execute R2R CLI:
```bash
.claude/scripts/r2r $ARGUMENTS
```
```

**Обоснование:** Эти команды принимают переменное число аргументов в зависимости от subcommand, $ARGUMENTS упрощает передачу всех параметров.

---

### Phase 3: Advanced Features (3-4 часа)

**Цель:** Добавить bash pre-execution и model specifications.

#### 3.1 Bash pre-execution

**Приоритет:** MEDIUM

**Кандидаты:**

1. **r2r-upload.md** - проверить файл перед загрузкой

```markdown
---
allowed-tools: Bash(ls:*), Bash(file:*), Bash(.claude/scripts/r2r:*)
argument-hint: "<file> [collection_id]"
description: Upload document to R2R with automatic processing
---

# R2R Document Upload

File to upload: **$1**
Collection ID: **$2** (optional)

## Pre-flight checks

- File exists: !`test -f "$1" && echo "✅ Found" || echo "❌ Not found"`
- File type: !`file -b "$1"`
- File size: !`du -h "$1" | cut -f1`

## Instructions

Upload the document to R2R...
```

2. **r2r-collections.md** - показать существующие коллекции при создании

```markdown
---
allowed-tools: Bash(.claude/scripts/r2r:*)
argument-hint: "[action]"
description: Manage R2R collections - list, create, delete, add/remove documents
---

# R2R Collections Management

## Current collections

!`.claude/scripts/r2r collections list -q`

## Instructions

Available actions:
- list - Show all collections
- create - Create new collection
...
```

3. **cc-hooks.md** - показать существующие hooks

```markdown
---
allowed-tools: Read, Glob, Bash(ls:*), Bash(find:*)
description: Claude Code hooks and lifecycle automation guide
---

# Claude Code Hooks Guide

## Existing hooks in this project

!`fd -t f . .claude/hooks/ 2>/dev/null || echo "No hooks configured"`

## Instructions

Read and explain hooks documentation...
```

**Результат:** Команды получают динамический контекст перед выполнением.

#### 3.2 Model specifications

**Приоритет:** LOW

**Применение:**

```yaml
# Documentation commands - используют haiku для скорости
# cc.md, cc-hooks.md, cc-commands.md, cc-mcp.md, cc-subagents.md, cc-setup.md
---
model: claude-3-5-haiku-20241022
description: ...
---

# Reasoning не нужен для документации, haiku быстрее и дешевле
```

**Обоснование:** Documentation commands - это read-only операции с простыми инструкциями, не требующие глубокого reasoning.

---

### Phase 4: Enhanced Markdown Structure (2-3 часа)

**Цель:** Улучшить форматирование для лучшего понимания Claude.

#### 4.1 Стандартизация структуры

**Рекомендуемая структура:**

```markdown
---
name: command-name
argument-hint: "<required> [optional]"
description: Clear one-line description
allowed-tools: Bash
model: claude-3-5-haiku-20241022  # если применимо
---

# Command Title

Brief introduction (1-2 sentences).

## Parameters

- **$1** - Parameter description
- **$2** - Optional parameter (default: value)

## Pre-flight Context (если bash pre-execution)

- Current state: !`command`
- Dynamic info: !`command`

## Instructions

Clear step-by-step instructions for Claude.

Execute the command:
```bash
.claude/scripts/script.sh "$1" "$2"
```

Present results as:
1. **Section 1:** Description
2. **Section 2:** Description

## Examples

```bash
# Example 1 - Basic usage
/command arg1

# Example 2 - With options
/command arg1 arg2 --flag
```

## Tips

- Tip 1
- Tip 2

## Related Commands

- `/other-command` - Description
```

#### 4.2 Применить структуру к высокоприоритетным командам

**Команды:**
- r2r-search.md
- r2r-rag.md
- r2r-agent.md
- r2r-upload.md
- r2r-workflows.md
- r2r-quick.md

---

## 📝 Implementation Checklist

### Phase 1: Quick Wins

- [ ] Добавить `argument-hint` ко всем 15 командам
- [ ] Улучшить descriptions (9 команд)
- [ ] Удалить избыточные `denied-tools` (7 команд)

### Phase 2: Standardization

- [ ] Документировать конвенцию параметров в CLAUDE.md
- [ ] Рефакторинг r2r-workflows.md на `$ARGUMENTS`
- [ ] Рефакторинг r2r-quick.md на `$ARGUMENTS`
- [ ] Рефакторинг r2r.md на `$ARGUMENTS`
- [ ] Тестирование всех 3 обновленных команд

### Phase 3: Advanced Features

- [ ] Добавить bash pre-execution в r2r-upload.md
- [ ] Добавить bash pre-execution в r2r-collections.md
- [ ] Добавить bash pre-execution в cc-hooks.md
- [ ] Добавить `model: claude-3-5-haiku-20241022` в 6 cc-* команд
- [ ] Тестирование bash pre-execution

### Phase 4: Enhanced Markdown

- [ ] Создать template.md с рекомендуемой структурой
- [ ] Применить структуру к r2r-search.md
- [ ] Применить структуру к r2r-rag.md
- [ ] Применить структуру к r2r-agent.md
- [ ] Применить структуру к r2r-upload.md
- [ ] Применить структуру к r2r-workflows.md
- [ ] Применить структуру к r2r-quick.md

### Phase 5: Documentation

- [ ] Обновить .claude/README.md с информацией о команде
- [ ] Добавить раздел "Custom Commands Best Practices" в CLAUDE.md
- [ ] Создать COMMANDS_REFERENCE.md с полным списком команд
- [ ] Обновить примеры использования в документации

---

## 🧪 Testing Plan

### Functional Testing

**Для каждой измененной команды:**

1. **Syntax test** - проверить `/help` показывает правильный `argument-hint`
2. **Execution test** - вызвать команду с различными параметрами
3. **Error test** - вызвать с некорректными параметрами
4. **Bash pre-execution test** - проверить динамический контекст

**Тестовые сценарии:**

```bash
# r2r-search.md
/help r2r-search  # Должен показать: <query> [limit]
/r2r-search "test query"  # Базовый вызов
/r2r-search "test query" 10  # С опциональным limit
/r2r-search  # Без параметров - должен запросить query

# r2r-workflows.md (ПОСЛЕ рефакторинга на $ARGUMENTS)
/r2r-workflows upload file.pdf
/r2r-workflows create-collection "Name" "Desc" file1.pdf file2.pdf
/r2r-workflows research "query" research

# r2r-upload.md (с bash pre-execution)
/r2r-upload existing.pdf  # Должен показать "✅ Found"
/r2r-upload nonexistent.pdf  # Должен показать "❌ Not found"
```

### Regression Testing

**Убедиться, что существующие workflows работают:**

```bash
# Основные R2R workflows
.claude/scripts/r2r search "test"
.claude/scripts/r2r rag "test"
.claude/scripts/workflows.sh upload test.pdf
.claude/scripts/quick.sh ask "test"

# Slash commands через Claude Code
/r2r-search "test"
/r2r-rag "test"
/r2r-agent "test"
/cc
```

---

## 📈 Success Metrics

### Quantitative

- ✅ **100% commands** имеют `argument-hint`
- ✅ **100% commands** имеют улучшенные descriptions
- ✅ **0 redundant** `denied-tools` entries
- ✅ **3 commands** используют `$ARGUMENTS` паттерн корректно
- ✅ **3 commands** используют bash pre-execution
- ✅ **6 commands** имеют `model` specification

### Qualitative

- ✅ Пользователи понимают синтаксис команды из `/help`
- ✅ Параметры используются последовательно (`$N` vs `$ARGUMENTS`)
- ✅ Bash pre-execution предоставляет полезный контекст
- ✅ Documentation commands работают быстрее (с haiku)
- ✅ Все команды следуют единой структуре markdown

---

## 🔄 Migration Strategy

### Backward Compatibility

**Гарантия:** Все изменения обратно совместимы.

- `argument-hint` - только metadata, не меняет поведение
- Улучшенные descriptions - только metadata
- Удаление `denied-tools` - не меняет permissions (allowed-tools остается)
- `$ARGUMENTS` рефакторинг - функционально эквивалентен `$1 $2 $3...`
- Bash pre-execution - добавляет контекст, не меняет логику
- `model` field - оптимизация, не breaking change

### Rollback Plan

**Если что-то сломается:**

1. Git revert к предыдущему состоянию `.claude/commands/`
2. Все команды в git, откат тривиален
3. Bash скрипты не меняются, только markdown команды

---

## 📚 Documentation Updates

### CLAUDE.md Updates

**Добавить секцию:**

```markdown
## 🔧 Custom Commands Best Practices

### Parameter Patterns

**Use $1, $2, $3 for:**
- Fixed number of required parameters
- Positional arguments with clear meaning
- Examples: `/r2r-search <query> [limit]`, `/r2r-upload <file> [collection_id]`

**Use $ARGUMENTS for:**
- Variable number of parameters
- Subcommands with different argument counts
- Examples: `/r2r-workflows <workflow> [args...]`, `/r2r-quick <task> [args...]`

### Frontmatter Fields

**Required:**
- `name` - Command name (matches filename)
- `description` - Clear one-line description
- `argument-hint` - Shows expected syntax in `/help`

**Optional:**
- `allowed-tools` - Restrict tool access (default: all denied)
- `model` - Specify model (e.g., haiku for docs, sonnet for analysis)

### Bash Pre-execution

Use `!command` to execute bash before prompt:
- Gather dynamic context (current git branch, file status)
- Pre-flight checks (file exists, service available)
- Show current state (list collections, hooks)

**Example:**
```markdown
---
allowed-tools: Bash(git status:*), Bash(git branch:*)
---

Current branch: !`git branch --show-current`
Recent commits: !`git log --oneline -5`
```

### Markdown Structure

Follow this structure for consistency:
1. **Title** - Clear command name
2. **Parameters** - Document $1, $2, or $ARGUMENTS
3. **Pre-flight Context** - Bash pre-execution if applicable
4. **Instructions** - Step-by-step guidance for Claude
5. **Examples** - Multiple usage examples
6. **Tips** - Pro tips and gotchas
7. **Related Commands** - Cross-references
```

### New File: COMMANDS_REFERENCE.md

**Create comprehensive reference:**

```markdown
# Claude Code Commands Reference

Complete reference for all custom slash commands in this project.

## Command Categories

### 🔍 R2R Search & Retrieval
- `/r2r-search` - Search knowledge base
- `/r2r-rag` - RAG with generation
- `/r2r-agent` - Multi-turn conversation

### 📁 R2R Data Management
- `/r2r-collections` - Collection CRUD
- `/r2r-upload` - Document upload

### ⚡ R2R Helpers
- `/r2r-quick` - Quick shortcuts
- `/r2r-workflows` - Automated workflows
- `/r2r-examples` - Interactive examples

### 📖 Claude Code Documentation
- `/cc` - Quick reference
- `/cc-hooks` - Hooks guide
- `/cc-commands` - Commands guide
- `/cc-mcp` - MCP integration
- `/cc-subagents` - Subagents guide
- `/cc-setup` - Setup guide

## Command Details

[Include full details for each command...]
```

---

## 🎯 Recommended Approach

**Approach: Gradual Enhancement (Phased)**

### Why Gradual?

1. **Low Risk** - Each phase is independently testable
2. **Quick Value** - Phase 1 delivers immediate UX improvement
3. **Data-Driven** - Can gather feedback before later phases
4. **Manageable** - 1-2 hours per phase, можно прерваться
5. **Reversible** - Easy git rollback at any phase

### Execution Order

1. **Week 1:** Phase 1 (Quick Wins) - 1-2 часа
2. **Week 2:** Phase 2 (Standardization) - 2-3 часа
3. **Week 3:** Phase 3 (Advanced Features) - 3-4 часа
4. **Week 4:** Phase 4 (Enhanced Markdown) - 2-3 часа
5. **Week 5:** Documentation updates и testing

**Total Time:** 10-15 часов распределенных на 5 недель.

### Alternative: Fast-Track (1 week intensive)

**Day 1:** Phase 1  
**Day 2:** Phase 2  
**Day 3:** Phase 3  
**Day 4:** Phase 4  
**Day 5:** Testing & Documentation

---

## 🚧 Risks & Mitigations

### Risk 1: Breaking existing workflows

**Mitigation:**
- Все изменения обратно совместимы
- Extensive testing plan
- Git rollback готов

**Likelihood:** Low  
**Impact:** Medium

### Risk 2: $ARGUMENTS рефакторинг нарушает edge cases

**Mitigation:**
- Тестировать с различным числом параметров
- Включая 0 параметров (should prompt)
- Документировать expected behavior

**Likelihood:** Medium  
**Impact:** Low

### Risk 3: Bash pre-execution замедляет команды

**Mitigation:**
- Использовать только для команд где контекст ценнее скорости
- Тестировать performance
- Можно disable через frontmatter

**Likelihood:** Low  
**Impact:** Low

### Risk 4: Model specification не поддерживается

**Mitigation:**
- Проверить Claude Code version (1.0.58+)
- Fallback: удалить model field если не работает
- Не критично для функциональности

**Likelihood:** Low  
**Impact:** Low

---

## 📋 Next Actions

### Immediate (Today)

1. ✅ Review this plan
2. ⏭️ Approve approach (Gradual Enhancement)
3. ⏭️ Start Phase 1: Add argument-hint to all commands

### This Week

1. ⏭️ Complete Phase 1
2. ⏭️ Test Phase 1 changes
3. ⏭️ Commit: `docs(commands): add argument-hint to all slash commands`

### This Month

1. ⏭️ Execute Phases 2-4
2. ⏭️ Update documentation
3. ⏭️ Final testing

---

## 📞 Questions for User

1. **Priority:** Which phase should we start with? (Recommend: Phase 1)
2. **Timeline:** Gradual (5 weeks) vs Fast-Track (1 week)?
3. **Scope:** All 15 commands or focus on high-priority (R2R commands)?
4. **Testing:** Manual testing OK or need automated tests?
5. **Documentation:** Update CLAUDE.md only or create COMMANDS_REFERENCE.md too?

---

**Author:** Claude Code  
**Date:** 2025-01-XX  
**Version:** 1.0  
**Status:** Proposal - Awaiting Approval
