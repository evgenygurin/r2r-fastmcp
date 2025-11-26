# 🎯 План интеграции Claude Code с R2R

## Обзор

Комплексный план создания полной интеграции Claude Code CLI с R2R API. После анализа документации Claude Code и существующей инфраструктуры проекта определена оптимальная последовательность создания компонентов.

> **Статус**: ✅ Gemini API успешно настроен и интегрирован с GitHub Actions.  
> **Проверка**: API ключ от Google AI Studio добавлен в секреты репозитория.

## 📊 Текущее состояние

### Что уже создано ✅

**Bash Scripts (scripts/):**
- ✅ Модульная CLI система (8 команд, 48 подкоманд)
  - `search.sh`, `rag.sh`, `agent.sh`, `docs.sh`
  - `collections.sh`, `conversation.sh`, `graph.sh`, `analytics.sh`
- ✅ Главный dispatcher `r2r` с GNU-style флагами
- ✅ Helper scripts: examples.sh (50+ examples), workflows.sh (5 workflows), quick.sh (10 tasks), aliases.sh
- ✅ Библиотека common.sh (43 строки, shared functions)
- ✅ Унифицированный вывод (emoji/quiet/JSON modes)

**Slash Commands (.claude/commands/):**
- ✅ **13/15 commands созданы** (87% готовности)
  - **R2R commands (9):** r2r.md, r2r-search.md, r2r-rag.md, r2r-agent.md, r2r-collections.md, r2r-upload.md, r2r-examples.md, r2r-workflows.md, r2r-quick.md
  - **Claude Code docs (4):** cc.md, cc-hooks.md, cc-commands.md, cc-mcp.md
  - ⚠️ **Missing (2):** cc-subagents.md, cc-setup.md
- ✅ TEMPLATE.md - шаблон для новых команд (95 строк)

**Agents (.claude/agents/):**
- ✅ **3 специализированных агента:**
  - `research-assistant.md` - Research mode с reasoning
  - `doc-analyst.md` - RAG-анализ документов
  - `knowledge-explorer.md` - Exploration + knowledge graph

**Skills (.claude/skills/):**
- ✅ **3 skill описания:**
  - `r2r-search.md` - Hybrid search capabilities
  - `r2r-rag.md` - RAG generation patterns
  - `r2r-graph.md` - Knowledge graph operations
- ⚠️ **Требуется:** Конвертация в правильный формат (SKILL.md + EXAMPLES.md)

**Hooks (.claude/hooks/):**
- ✅ SessionStart/check-r2r.md - проверка R2R API статуса
- ⚠️ **Требуется расширение:** PreToolUse, PostToolUse hooks

**Configuration:**
- ✅ config/.env (R2R_BASE_URL, API_KEY)
- ✅ settings.json структура определена

**Documentation:**
- ✅ **docs/claude_code/ (13/13 разделов - 100%)**
  - 01-overview через 13-troubleshooting
  - README.md + SUMMARY.md
  - ~150,000+ слов, 300+ code snippets
- ✅ CLAUDE.md (основные правила + troubleshooting)
- ✅ .claude/README.md (структура интеграции)
- ✅ .claude/docs/INTEGRATION_PLAN.md v2.0 (973 строки, comprehensive)
- ✅ .claude/docs/REFACTORING_SUMMARY.md (335 строк)
- ✅ .claude/docs/REFACTORING_PLAN.md (980 строк)

## 🎯 Что необходимо создать

### ✅ Завершено (87% готовности)

**Infrastructure:**
- ✅ Модульная CLI система (8 команд)
- ✅ Helper scripts (examples, workflows, quick, aliases)
- ✅ 13/15 slash commands
- ✅ 3 agents
- ✅ 3 skills (требуют рефакторинга)
- ✅ 1 hook (требуется расширение)
- ✅ Полная документация Claude Code (13 разделов)
- ✅ Comprehensive integration plan (v2.0)

### Приоритет 1: Завершить Commands (2 команды) 🟡

**Осталось создать:**

1. **`/cc-subagents`** - Subagents documentation
   - Источник: docs/claude_code/06-subagents.md
   - Описание: Explore, Plan, Code Explorer/Architect, Code Reviewer
   - Best practices для использования субагентов
   - Формат вывода: ONE LINE

2. **`/cc-setup`** - Installation and setup guide
   - Источник: docs/claude_code/02-installation-and-setup.md
   - Методы установки, authentication, configuration
   - Troubleshooting установки
   - Формат вывода: ONE LINE

**Already created (13 commands):**
- ✅ `/r2r` - R2R quick reference (main hub)
- ✅ `/r2r-search` - Hybrid search
- ✅ `/r2r-rag` - RAG generation
- ✅ `/r2r-agent` - Multi-turn agent (research/rag modes)
- ✅ `/r2r-collections` - Collection management
- ✅ `/r2r-upload` - Document upload with entity extraction
- ✅ `/r2r-examples` - Interactive examples (50+)
- ✅ `/r2r-workflows` - Automated workflows (5)
- ✅ `/r2r-quick` - One-line shortcuts (10 tasks)
- ✅ `/cc` - Claude Code documentation quick reference
- ✅ `/cc-hooks` - Hooks documentation
- ✅ `/cc-commands` - Custom commands guide
- ✅ `/cc-mcp` - MCP integration

### Приоритет 2: Refactor Skills (3 skills) 🟡

**Цель:** Конвертация в правильный формат Claude Code Skills

**Текущее состояние:**
Skills существуют как описательная документация (`.claude/skills/`):
- ✅ r2r-search.md (7,385 bytes) - Hybrid search patterns
- ✅ r2r-rag.md (9,971 bytes) - RAG generation examples  
- ✅ r2r-graph.md (11,091 bytes) - Knowledge graph operations

**Проблема:** Текущий формат - это markdown описания, а не функциональные Skills

**Требуется:** Конвертация в Claude Code Skills format (директория + SKILL.md + EXAMPLES.md)

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

### Приоритет 3: Verify Agents Format ✅

**Статус:** 3 агента созданы, требуется проверка формата

**Цель:** Убедиться что agents соответствуют Claude Code спецификации

Уже созданы (`.claude/agents/`):
- ✅ research-assistant.md
- ✅ doc-analyst.md
- ✅ knowledge-explorer.md

**Action items:**
1. Verify YAML frontmatter присутствует и соответствует спецификации
2. Check tool allowlists (должны включать Bash для R2R API calls)
3. Test natural language invocation (prompts должны активировать agents)
4. Validate bash commands используют correct R2R CLI paths

**Ожидаемый результат:** Agents готовы к production использованию без изменений

### Приоритет 4: Expand Hooks (4 recommended) 🟢

**Статус:** 1 hook создан, рекомендуется добавить 4 дополнительных

**Цель:** Полное покрытие lifecycle automation

**Existing:**
- ✅ SessionStart/check-r2r.md - R2R API health check при старте сессии

**Recommended additions:**

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

## 📋 Последовательность реализации (UPDATED)

### ✅ Этап 1: Commands (87% завершен)

**Статус:** 13/15 commands созданы

**Completed:**
- ✅ Все 9 R2R commands
- ✅ 4 из 6 Claude Code docs commands
- ✅ TEMPLATE.md для новых команд

**Remaining (13% работы):**
1. **Создать `/cc-subagents`** (источник: docs/claude_code/06-subagents.md)
2. **Создать `/cc-setup`** (источник: docs/claude_code/02-installation-and-setup.md)

**ETA:** 2-4 hours

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

### Этап 2: Skills Refactoring (0.5-1 день) 🟡

**Статус:** 3 skills существуют, требуется рефакторинг

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

### Этап 3: Agents Verification (0.5 дня) ✅

**Статус:** 3 agents созданы, требуется проверка

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

### Этап 4: Hooks Expansion (1 день - optional) 🟢

**Статус:** 1 core hook существует, расширение опционально

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

### Этап 5: Documentation Updates (0.5 день) 📚

**Статус:** Основная документация создана, требуются обновления

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

## 🚀 Продвинутые возможности интеграции

### Plan Mode Integration

**Концепция:** Использование Plan mode для сложных R2R workflows

**Примеры использования:**
```bash
# Автоматическое включение Plan mode для:
- Создание multi-document knowledge graphs
- Batch processing больших коллекций
- Complex research workflows с несколькими источниками
- Document analysis с entity extraction + community detection
```

**Реализация:**
- Plan subagent автоматически активируется для задач >3 шагов
- Использует Sonnet для планирования, Haiku для выполнения
- Визуализация процесса через Tab key
- TodoWrite integration для отслеживания прогресса

### Context Optimization Strategies

**Проблема:** Large document collections могут превышать context limits

**Решения:**

1. **Explore Subagent для поиска релевантных документов**
   ```bash
   # Автоматическая активация при:
   "Find all documents about machine learning in my collection"
   "Where are the references to transformers architecture?"
   ```

2. **Compact command для сжатия контекста**
   ```bash
   /compact  # Shrinks conversation size
   ```

3. **Selective file reading через agents**
   - Code Explorer идентифицирует ключевые документы
   - Читаем только релевантные части
   - Используем document summaries из R2R

### Enterprise Features

**Централизованные политики безопасности:**

**settings.json (enterprise-managed):**
```json
{
  "permissions": {
    "allowedTools": [
      "Read(**/*.{md,txt,json})",
      "Bash(r2r:*)",
      "Bash(git:*)"
    ],
    "deniedTools": [
      "Bash(rm:*)",
      "Bash(curl:*)",
      "Edit(/config/*)",
      "Write(/secrets/*)"
    ]
  },
  "permissionMode": "manual",
  "sandbox": {
    "allowUnsandboxedCommands": false
  },
  "companyAnnouncements": {
    "enabled": true,
    "message": "R2R Integration: Use /r2r-* commands for document operations. Check CLAUDE.md for guidelines."
  }
}
```

**Compliance & Auditing:**
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash(r2r:*)",
      "hooks": [{
        "type": "command",
        "command": "echo \"$(date -Iseconds) USER=${USER} COMMAND=${CLAUDE_TOOL_INPUT}\" >> /var/log/claude-r2r-audit.log"
      }]
    }],
    "PostToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "jq -r '{timestamp: now | todate, user: env.USER, result: .tool_result}' | tee -a ~/.claude/compliance.jsonl"
      }]
    }]
  }
}
```

### Plugin Development для R2R

**Идея:** Создать официальный R2R plugin для marketplace

**Структура plugin:**
```
claude-plugins/
└── r2r-integration/
    ├── plugin.json
    ├── README.md
    ├── commands/
    │   ├── r2r-search.md
    │   ├── r2r-rag.md
    │   └── r2r-agent.md
    ├── agents/
    │   ├── research-assistant.md
    │   └── doc-analyst.md
    ├── skills/
    │   └── r2r-document-analyzer/
    │       ├── SKILL.md
    │       └── EXAMPLES.md
    └── hooks/
        └── SessionStart/
            └── check-r2r-status.md
```

**plugin.json:**
```json
{
  "name": "r2r-integration",
  "version": "1.0.0",
  "description": "Full R2R v3 integration for document management, RAG, and knowledge graphs",
  "author": "R2R Team",
  "homepage": "https://github.com/your-org/claude-r2r-plugin",
  "commands": ["r2r-search", "r2r-rag", "r2r-agent", "r2r-collections", "r2r-upload"],
  "agents": ["research-assistant", "doc-analyst", "knowledge-explorer"],
  "skills": ["r2r-document-analyzer", "r2r-knowledge-explorer"],
  "hooks": ["SessionStart/check-r2r-status"],
  "dependencies": {
    "bash": ">=5.0",
    "jq": ">=1.6",
    "curl": ">=7.68"
  },
  "config": {
    "requiredEnvVars": ["R2R_BASE_URL", "API_KEY"]
  }
}
```

### Interactive Question Tool Integration

**Концепция:** Использование interactive questions для улучшения R2R workflows

**Примеры:**

1. **Document Upload Clarification:**
   ```markdown
   Claude: "Before uploading this document, I need clarification:
   
   1. Which collection should I use?
      - Existing: 'research-papers' (15 docs)
      - Existing: 'technical-docs' (42 docs)  
      - Create new collection?
   
   2. Should I extract entities and relationships immediately?
      - Yes (takes 2-3 min, enables graph queries)
      - No (faster, can extract later)
   
   3. Ingestion mode:
      - hi-res (thorough, slower, with summaries)
      - fast (quick, minimal enrichment)
   "
   ```

2. **Research Query Optimization:**
   ```markdown
   Claude: "For this research query, I can use:
   
   1. RAG mode (fast, straightforward answers)
   2. Research mode (deeper analysis with reasoning)
   
   The query seems complex - would you prefer research mode?
   Also, should I include web search for up-to-date information?"
   ```

### Model Selection Strategy

**Рекомендации по выбору моделей для R2R операций:**

| Операция | Модель | Обоснование |
|----------|--------|-------------|
| Document upload | Haiku 4.5 | Быстрая обработка метаданных |
| Simple search | Haiku 4.5 | Достаточно для форматирования результатов |
| RAG generation | Sonnet 4.5 | Качественные ответы с citations |
| Research mode | Sonnet 4.5 | Reasoning требует мощной модели |
| Graph exploration | Haiku 4.5 + Sonnet | Haiku для queries, Sonnet для анализа |
| Batch processing | Haiku 4.5 | Cost-effective для множества операций |
| Planning workflows | Sonnet 4.5 | Сложное планирование multi-step tasks |

**Конфигурация в commands:**
```yaml
---
name: r2r-research
model: sonnet  # Force Sonnet for research mode
---
```

### Workflow Templates

**Шаблоны для типичных задач:**

#### 1. Academic Research Workflow
```bash
# Phase 1: Upload papers
/r2r-upload paper1.pdf --collection research-papers
/r2r-upload paper2.pdf --collection research-papers

# Phase 2: Extract knowledge graph
/r2r-agent "Extract entities and relationships from all papers about transformers"

# Phase 3: Research synthesis
/r2r-agent --mode research "Synthesize findings about transformer architectures, include reasoning steps"

# Phase 4: Community detection
.claude/scripts/r2r graph communities build <collection_id>

# Phase 5: Insight generation
/r2r-agent "What are the main research clusters in transformer papers?"
```

#### 2. Code Documentation Analysis
```bash
# Phase 1: Upload documentation
/r2r-workflows upload-batch docs/*.md --collection code-docs

# Phase 2: Create knowledge graph
/r2r-agent "Build knowledge graph of API relationships"

# Phase 3: Interactive exploration
/r2r-agent "I'm implementing authentication, show me related docs and examples"
```

#### 3. Compliance & Audit Trail
```bash
# Phase 1: Upload compliance documents
/r2r-upload compliance-policy.pdf --collection compliance

# Phase 2: Hybrid search with audit
/r2r-search "data retention policies" --audit

# Phase 3: Generate compliance report
/r2r-rag "Summarize all data retention policies with citations" --format report
```

### Performance Optimization

**Best Practices для больших коллекций:**

1. **Batch Operations:**
   ```bash
   # Bad: Individual uploads
   for file in *.pdf; do
     /r2r-upload "$file"
   done
   
   # Good: Batch workflow
   /r2r-workflows batch-upload *.pdf --collection my-docs --parallel 5
   ```

2. **Index Management:**
   ```bash
   # Create HNSW index для fast search
   .claude/scripts/r2r analytics create-index \
     --table chunks \
     --method hnsw \
     --measure cosine_distance \
     --m 16 \
     --ef-construction 64
   ```

3. **Query Optimization:**
   ```bash
   # Use vanilla strategy (hyde/rag_fusion не работают)
   /r2r-search "query" --strategy vanilla --limit 10
   
   # Hybrid search для лучших результатов
   /r2r-search "query" --hybrid --full-text-weight 1 --semantic-weight 5
   ```

### Integration with GitHub Actions

**Automated document processing:**

**.github/workflows/r2r-sync.yml:**
```yaml
name: Sync Docs to R2R

on:
  push:
    paths:
      - 'docs/**'

jobs:
  sync-r2r:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Claude Code
        run: |
          curl -fsSL https://claude.ai/install.sh | bash
          claude --version
      
      - name: Upload changed docs
        env:
          R2R_BASE_URL: ${{ secrets.R2R_BASE_URL }}
          API_KEY: ${{ secrets.R2R_API_KEY }}
        run: |
          # Get changed files
          git diff --name-only HEAD~1 HEAD | grep '^docs/' > changed.txt
          
          # Upload via workflow
          cat changed.txt | xargs .claude/scripts/workflows.sh batch-upload \
            --collection github-docs \
            --ingestion-mode fast
      
      - name: Extract entities
        run: |
          .claude/scripts/r2r collections extract <collection-id>
```

### Security Best Practices

**Checklist для production deployment:**

- [ ] **Environment Variables:** API_KEY в .env, НЕ в settings.json
- [ ] **Permissions:** Minimal necessary tools в allowedTools
- [ ] **Sandbox Mode:** Enabled на production
- [ ] **Audit Logging:** PreToolUse/PostToolUse hooks configured
- [ ] **Rate Limiting:** Implement в bash scripts
- [ ] **Input Validation:** Sanitize user inputs перед API calls
- [ ] **Secret Scanning:** Pre-commit hook для обнаружения API keys
- [ ] **Network Isolation:** R2R API доступен только через VPN
- [ ] **Backup Strategy:** Regular exports коллекций
- [ ] **Monitoring:** Alert на failed R2R operations

**Pre-commit hook example:**
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check for exposed API keys
if git diff --cached --name-only | grep -E '\.(sh|md|json)$' | \
   xargs grep -E 'API_KEY=sk-|R2R.*=http://.*:[0-9]+'; then
  echo "Error: Potential API key or URL exposure detected!"
  exit 1
fi
```

### Troubleshooting Guide

**Типичные проблемы и решения:**

#### Problem: "API_KEY not set"
```bash
# Solution:
source .claude/config/.env
echo $API_KEY  # Verify

# Alternative: Set globally
export API_KEY=sk-ant-...
```

#### Problem: "Search strategies hyde/rag_fusion not working"
```bash
# Solution: Use vanilla only
/r2r-search "query" --strategy vanilla

# See: .claude/docs/SEARCH_STRATEGIES.md
```

#### Problem: "Context limit exceeded"
```bash
# Solutions:
1. Use Explore subagent: "Find relevant docs about X"
2. Use /compact command
3. Use document summaries: /r2r-search --summary-only
4. Filter by collection: --collection-ids <id>
```

#### Problem: "Hooks not triggering"
```bash
# Debug:
claude --debug  # Enable debug mode
tail -f ~/.claude/debug.log  # Monitor hooks

# Verify hooks config:
jq .hooks ~/.claude/settings.json

# Test hook manually:
bash .claude/hooks/SessionStart/check-r2r.md
```

## 📝 Следующие шаги

### Immediate (Next 48 hours)
1. **✅ Commands:** Создать все 15 slash commands
2. **✅ Testing:** Тестировать каждую команду отдельно
3. **✅ Documentation:** Обновить .claude/README.md

### Short-term (Week 1)
1. **Skills:** Конвертировать в правильный YAML формат
2. **Agents:** Обновить до актуальной спецификации
3. **Hooks:** Расширить для полного lifecycle coverage

### Medium-term (Week 2)
1. **Plugin:** Собрать все компоненты в official R2R plugin
2. **Marketplace:** Publish в community marketplace
3. **CI/CD:** GitHub Actions workflows

### Long-term (Month 1)
1. **Advanced Features:** Plan mode integration, context optimization
2. **Enterprise:** Centralized policies, compliance reporting
3. **Performance:** Batch processing, index optimization
4. **Community:** Documentation, tutorials, examples

## 🎓 Learning Resources

### For Beginners
- `docs/claude_code/01-overview-and-getting-started.md` - Start here
- `.claude/commands/r2r-quick.md` - One-line shortcuts
- `.claude/scripts/examples.sh` - Interactive examples

### For Developers
- `docs/claude_code/04-commands-and-usage.md` - Custom commands
- `docs/claude_code/05-hooks-and-customization.md` - Hooks guide
- `.claude/agents/` - Agent examples

### For Teams
- `docs/claude_code/10-settings-and-configuration.md` - Settings management
- `docs/claude_code/12-security-and-permissions.md` - Security policies
- `.claude/docs/INTEGRATION_PLAN.md` - This document

### Advanced Topics
- `docs/claude_code/06-subagents.md` - Subagent system
- `docs/claude_code/07-mcp-integration.md` - MCP servers
- `docs/claude_code/09-plugins-and-marketplaces.md` - Plugin development

---

**План составлен:** 2025-01-19
**Версия:** 2.0 (Comprehensive Edition)
**Статус:** Ready for Implementation 🚀

**Авторы:**
- Initial plan: Integration team
- Comprehensive edition: Based on full Claude Code documentation analysis + Context7 research

**Changelog:**
- v1.0: Basic integration plan
- v2.0: Added advanced features, enterprise setup, workflows, troubleshooting
