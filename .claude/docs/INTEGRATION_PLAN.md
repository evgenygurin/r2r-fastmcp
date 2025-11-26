# 🎯 План интеграции Claude Code с R2R

## Обзор

Комплексный план создания полной интеграции Claude Code CLI с R2R API. После анализа документации Claude Code и существующей инфраструктуры проекта определена оптимальная последовательность создания компонентов.

## 📊 Текущее состояние

### Что уже создано ✅

**Bash Scripts (scripts/):**
- ✅ Модульная CLI система (8 команд, 48 подкоманд)
- ✅ Главный dispatcher `r2r` с GNU-style флагами
- ✅ Helper scripts: examples.sh, workflows.sh, quick.sh, aliases.sh
- ✅ Унифицированный вывод (emoji/quiet/JSON)

**Commands (частично):**
- ✅ `/r2r` - Quick reference
- ⚠️ Остальные 8 команд требуют создания

**Agents:**
- ✅ 3 специализированных агента (research-assistant, doc-analyst, knowledge-explorer)

**Skills:**
- ✅ 3 описания возможностей (r2r-search, r2r-rag, r2r-graph)

**Hooks:**
- ✅ SessionStart/check-r2r.md
- ⚠️ Требуется расширение

**Configuration:**
- ✅ config/.env (R2R_BASE_URL, API_KEY)
- ✅ settings.json (пустой)

**Documentation:**
- ✅ docs/claude_code/ (6 разделов из 13)
- ✅ CLAUDE.md (основные правила)
- ✅ .claude/README.md (структура)

## 🎯 Что необходимо создать

### Приоритет 1: Slash Commands (9 команд) 🔴

**Цель:** Прямая интеграция с Claude Code CLI

**Commands to create:**

1. **`/r2r-search`** - Hybrid search
   - Аргументы: query, limit
   - Использует: `.claude/scripts/r2r search`
   - Формат вывода: ONE LINE

2. **`/r2r-rag`** - RAG generation
   - Аргументы: query, max_tokens
   - Использует: `.claude/scripts/r2r rag`
   - Показывает: answer + sources

3. **`/r2r-agent`** - Multi-turn agent
   - Аргументы: message, mode
   - Использует: `.claude/scripts/r2r agent`
   - Поддержка: research/rag modes

4. **`/r2r-collections`** - Collection management
   - Действия: list, create, add-doc, remove-doc
   - Использует: `.claude/scripts/r2r collections`

5. **`/r2r-upload`** - Document upload
   - Аргументы: file_path, collection_ids
   - Использует: `.claude/scripts/r2r docs upload`
   - Автоматически: extract entities

6. **`/r2r-examples`** - Interactive examples
   - Категории: search, rag, agent, docs, collections, graph
   - Использует: `.claude/scripts/examples.sh`

7. **`/r2r-workflows`** - Automated workflows
   - Workflows: upload, create-collection, research, analyze, batch-upload
   - Использует: `.claude/scripts/workflows.sh`

8. **`/r2r-quick`** - One-line shortcuts
   - Shortcuts: ask, status, up, col, continue, batch, cleanup
   - Использует: `.claude/scripts/quick.sh`

9. **`/cc`** - Claude Code documentation quick reference
   - Разделы: commands, hooks, subagents, skills, mcp
   - Читает: `docs/claude_code/`

**Дополнительные commands для Claude Code документации:**

10. **`/cc-hooks`** - Hooks documentation
11. **`/cc-commands`** - Custom commands guide
12. **`/cc-mcp`** - MCP integration
13. **`/cc-subagents`** - Subagents guide
14. **`/cc-setup`** - Installation guide
15. **`/cc-skills`** - Skills documentation

### Приоритет 2: Skills (3 уже есть, расширить до Claude Code Skills) 🟡

**Цель:** Научить Claude автоматически использовать R2R возможности

Skills уже существуют как **описательная документация** (`.claude/skills/`):
- ✅ r2r-search.md (307 строк)
- ✅ r2r-rag.md (400 строк)
- ✅ r2r-graph.md (465 строк)

**Но нужны настоящие Claude Code Skills** (с YAML frontmatter):

**Skills to create:**

1. **`r2r-document-analyzer`** - Анализ документов
   ```yaml
   ---
   name: r2r-document-analyzer
   description: Analyze documents in R2R using RAG and knowledge graph. Use when analyzing uploaded documents or exploring document relationships.
   allowed-tools: Bash, Read
   ---
   ```
   - Использует: `/r2r-rag`, `/r2r-search`, graph queries
   - Автоматически: entities + relationships

2. **`r2r-knowledge-explorer`** - Исследование knowledge graph
   ```yaml
   ---
   name: r2r-knowledge-explorer
   description: Explore R2R knowledge graph for entity relationships and community insights. Use when investigating connections between concepts.
   allowed-tools: Bash, Read, Glob
   ---
   ```
   - Использует: graph entities, relationships, communities
   - Визуализация: связей и кластеров

3. **`r2r-research-assistant`** - Research mode помощник
   ```yaml
   ---
   name: r2r-research-assistant
   description: Deep research using R2R agent in research mode with reasoning and critique. Use for complex analytical queries requiring multi-step reasoning.
   allowed-tools: Bash
   ---
   ```
   - Использует: `/r2r-agent --mode research --thinking`
   - Включает: reasoning + critique tools

**Важно:** Skills должны иметь формат SKILL.md с YAML frontmatter для корректной работы в Claude Code.

### Приоритет 3: Specialized Agents (3 уже есть) 🟢

**Цель:** Субагенты для сложных задач

Уже созданы (`.claude/agents/`):
- ✅ research-assistant.md
- ✅ doc-analyst.md
- ✅ knowledge-explorer.md

**Требуется:** Проверить формат и обновить до актуальной спецификации Claude Code (с YAML frontmatter `name`, `description`, `tools`, `model`).

**Обновить агентов:**

1. **research-assistant** - конвертировать в правильный формат
2. **doc-analyst** - конвертировать в правильный формат
3. **knowledge-explorer** - конвертировать в правильный формат

### Приоритет 4: Hooks (расширить существующие) 🟡

**Цель:** Lifecycle automation

**Существующие:**
- ✅ SessionStart/check-r2r.md

**Hooks to add:**

1. **SessionStart/load-r2r-context** - Загружает R2R метаданные
   ```json
   {
     "hookSpecificOutput": {
       "hookEventName": "SessionStart",
       "additionalContext": "R2R collections: [...]\nRecent documents: [...]\nActive conversations: [...]"
     }
   }
   ```

2. **PreToolUse/validate-r2r-commands** - Валидация R2R команд
   ```json
   {
     "hooks": {
       "PreToolUse": [{
         "matcher": "Bash",
         "hooks": [{
           "type": "command",
           "command": "echo 'Running R2R command: $CLAUDE_TOOL_INPUT' >> ~/.claude/r2r-log.txt"
         }]
       }]
     }
   }
   ```

3. **PostToolUse/log-r2r-results** - Логирование результатов
   ```json
   {
     "hooks": {
       "PostToolUse": [{
         "matcher": "Bash",
         "hooks": [{
           "type": "command",
           "command": "jq -r '.tool_result' | tee -a ~/.claude/r2r-results.log"
         }]
       }]
     }
   }
   ```

### Приоритет 5: Documentation & README 📚

**Цель:** Полная документация интеграции

**Documentation to create/update:**

1. **.claude/README.md** - обновить с новыми commands
2. **.claude/commands/README.md** - описание всех slash commands
3. **.claude/agents/README.md** - обновить агентов
4. **.claude/skills/README.md** - создать (описание Skills)
5. **.claude/hooks/README.md** - обновить hooks
6. **INTEGRATION_GUIDE.md** - полное руководство пользователя

## 📋 Последовательность реализации

### Этап 1: Commands (1-2 дня) 🔴

**Приоритет:** ВЫСОКИЙ - основа интеграции

**Шаги:**
1. Создать директории для commands:
   ```bash
   mkdir -p .claude/commands/cc
   ```

2. Создать R2R команды (9 файлов):
   - r2r-search.md
   - r2r-rag.md
   - r2r-agent.md
   - r2r-collections.md
   - r2r-upload.md
   - r2r-examples.md
   - r2r-workflows.md
   - r2r-quick.md
   - r2r.md (уже есть)

3. Создать Claude Code documentation commands (6 файлов):
   - cc.md
   - cc-hooks.md
   - cc-commands.md
   - cc-mcp.md
   - cc-subagents.md
   - cc-setup.md

**Формат каждого command:**
```markdown
---
name: command-name
description: Brief description of what this command does
allowed-tools: Bash, Read
denied-tools: Write, Edit
---

# Command Name

Full description and usage instructions.

## Examples

\`\`\`bash
/command-name arg1 arg2
\`\`\`

## Output Format

Description of expected output.
```

**Тестирование:**
```bash
# Test each command
/r2r-search "test query"
/r2r-rag "What is R2R?"
/r2r-agent "Hello"
/cc
```

### Этап 2: Skills (1 день) 🟡

**Приоритет:** СРЕДНИЙ - автоматизация

**Шаги:**
1. Создать директорию:
   ```bash
   mkdir -p .claude/skills
   ```

2. Конвертировать существующие описания в Claude Code Skills:
   - r2r-document-analyzer/SKILL.md
   - r2r-knowledge-explorer/SKILL.md
   - r2r-research-assistant/SKILL.md

3. Добавить дополнительные файлы для каждого skill:
   - EXAMPLES.md (примеры использования)
   - REFERENCE.md (справочная информация)
   - scripts/ (при необходимости)

**Формат SKILL.md:**
```markdown
---
name: skill-name
description: When to use this skill (specific, with keywords)
allowed-tools: Bash, Read, Grep
---

# Skill Name

## Instructions

Step-by-step instructions for Claude.

## Best Practices

- Practice 1
- Practice 2

## Examples

Examples of usage.
```

**Тестирование:**
```bash
# List skills
/skills

# Test skill activation
"Analyze the document about transformers" # Should trigger r2r-document-analyzer
"Show me entity relationships for AI concepts" # Should trigger r2r-knowledge-explorer
```

### Этап 3: Agents (0.5 дня) 🟢

**Приоритет:** НИЗКИЙ - уже существуют

**Шаги:**
1. Проверить существующие агенты в `.claude/agents/`
2. Обновить формат до актуальной спецификации
3. Добавить YAML frontmatter:
   ```yaml
   ---
   name: agent-name
   description: When to invoke this agent (proactive usage)
   tools: Read, Bash, Grep, Glob
   model: sonnet
   ---
   ```

**Тестирование:**
```bash
# List agents
/agents

# Test explicit invocation
"Use research-assistant to analyze DeepSeek-R1"
```

### Этап 4: Hooks (1 день) 🟡

**Приоритет:** СРЕДНИЙ - automation

**Шаги:**
1. Создать hook directories:
   ```bash
   mkdir -p .claude/hooks/{SessionStart,PreToolUse,PostToolUse}
   ```

2. Создать hooks:
   - SessionStart/load-r2r-context.md
   - PreToolUse/validate-r2r-commands.md
   - PostToolUse/log-r2r-results.md

3. Обновить settings.json:
   ```json
   {
     "hooks": {
       "SessionStart": [...],
       "PreToolUse": [...],
       "PostToolUse": [...]
     }
   }
   ```

**Формат hook файла:**
```markdown
---
event: SessionStart
description: Brief description of hook purpose
---

# Hook Name

Instructions for the hook command or LLM prompt.

## Output Format

JSON structure for hookSpecificOutput.
```

**Тестирование:**
```bash
# Start new session (trigger SessionStart)
claude

# Run R2R command (trigger PreToolUse + PostToolUse)
/r2r-search "test"

# Check logs
cat ~/.claude/r2r-log.txt
```

### Этап 5: Documentation (1 день) 📚

**Приоритет:** ВЫСОКИЙ - для пользователей

**Шаги:**
1. Обновить `.claude/README.md` с новыми компонентами
2. Создать `.claude/commands/README.md`
3. Создать `.claude/skills/README.md`
4. Обновить `.claude/agents/README.md`
5. Обновить `.claude/hooks/README.md`
6. Создать `INTEGRATION_GUIDE.md` (полное руководство)
7. Обновить основной `CLAUDE.md`

**INTEGRATION_GUIDE.md структура:**
```markdown
# R2R + Claude Code Integration Guide

## Quick Start
## Commands Reference
## Skills Usage
## Agents Guide
## Hooks Configuration
## Troubleshooting
## Examples
```

### Этап 6: Testing & PR (0.5 дня) ✅

**Шаги:**
1. Полное тестирование всех компонентов
2. Проверка совместимости
3. Создание changelog
4. Git commit + PR

**Тестовый checklist:**
- [ ] Все 15 commands работают
- [ ] Skills активируются автоматически
- [ ] Agents вызываются корректно
- [ ] Hooks выполняются на events
- [ ] Документация актуальна
- [ ] Нет конфликтов конфигурации

## 📊 Общая оценка времени

| Этап | Приоритет | Время | Статус |
|------|-----------|-------|--------|
| Commands | 🔴 HIGH | 1-2 дня | Pending |
| Skills | 🟡 MEDIUM | 1 день | Pending |
| Agents | 🟢 LOW | 0.5 дня | Exists |
| Hooks | 🟡 MEDIUM | 1 день | Partial |
| Documentation | 🔴 HIGH | 1 день | Pending |
| Testing & PR | ✅ REQUIRED | 0.5 дня | Pending |
| **TOTAL** | | **4.5-5.5 дней** | |

## 🎯 Критерии успеха

### Функциональные
- ✅ Все 15 slash commands работают без ошибок
- ✅ Skills активируются автоматически при релевантных запросах
- ✅ Agents корректно вызываются и выполняют задачи
- ✅ Hooks срабатывают на lifecycle events
- ✅ Bash scripts интегрированы с commands

### Качественные
- ✅ Документация полная и актуальная
- ✅ Примеры использования для всех компонентов
- ✅ Troubleshooting guide создан
- ✅ Consistent naming и форматирование
- ✅ Git history чистая (одна строка коммитов)

### Пользовательские
- ✅ Quick start < 5 минут
- ✅ Интуитивно понятные команды
- ✅ Полезные error messages
- ✅ Comprehensive examples

## 🔗 Ссылки

### Официальная документация
- [Claude Code](https://docs.claude.com/en/docs/claude-code)
- [R2R v3 API](https://r2r-docs.sciphi.ai)
- [MCP Protocol](https://modelcontextprotocol.io)

### Внутренняя документация
- `CLAUDE.md` - основные правила проекта
- `.claude/README.md` - структура интеграции
- `docs/claude_code/` - полная документация Claude Code
- `docs/r2r/` - полная документация R2R

### Примеры
- `.claude/scripts/` - bash CLI примеры
- `.claude/agents/` - существующие агенты
- `.claude/skills/` - существующие skills описания

## 📝 Следующие шаги

1. **Сейчас:** Создать все 15 commands
2. **Затем:** Конвертировать skills в правильный формат
3. **После:** Обновить agents и hooks
4. **В конце:** Полная документация + PR

---

**План составлен:** 2025-01-XX
**Версия:** 1.0
**Статус:** Ready for Implementation 🚀
