# R2R Agents - Обновлено для Bash Scripts

## ⚠️ Важно

Agents в этой директории ранее ссылались на **MCP сервер**, который был заменен на **bash скрипты**.

## Текущий статус

### Все agents обновлены для работы с модульным CLI:

- ✅ **research-assistant.md** - использует `/r2r-agent` и `.claude/scripts/r2r agent`
- ✅ **knowledge-explorer.md** - использует `/r2r-search` и `.claude/scripts/r2r search`
- ✅ **doc-analyst.md** - использует `/r2r-rag` и `.claude/scripts/r2r rag`

## Использование Agents

### Research Assistant

**Триггеры:**
- "Research [topic]"
- "Analyze the implications of [X]"
- "Deep dive into [complex question]"

**Команды:**
```bash
# Через slash command
/r2r-agent "Research AI safety" research "" --thinking

# Прямо через модульный CLI
.claude/scripts/r2r agent "Research AI safety" --mode research --thinking
```

### Knowledge Explorer

**Триггеры:**
- "Find information about [X]"
- "Search for [topic]"
- "What does the knowledge base say about [Y]?"

**Команды:**
```bash
# Через slash command
/r2r-search "machine learning" 10 --verbose

# Прямо через модульный CLI
.claude/scripts/r2r search "machine learning" --limit 10 --verbose
```

### Doc Analyst

**Триггеры:**
- "Explain [concept]"
- "What is [term]?"
- "Summarize [topic]"

**Команды:**
```bash
# Через slash command
/r2r-rag "Explain transformers"

# Прямо через модульный CLI
.claude/scripts/r2r rag "Explain transformers" --max-tokens 12000
```

## Доступные инструменты

### Agents НЕ используют MCP tools

Вместо этого:
1. Agents вызываются естественным языком
2. Claude Code интерпретирует intent
3. Выполняется соответствующая **slash command** (`/r2r-search`, `/r2r-rag`, `/r2r-agent`)
4. Slash command вызывает **bash скрипт**
5. Bash скрипт делает curl к R2R API

## Обновленная архитектура

```text
User Query
    ↓
Agent Recognizes Pattern
    ↓
Slash Command (/r2r-search, /r2r-rag, /r2r-agent)
    ↓
Modular CLI (.claude/scripts/r2r)
    ↓
Command Module (commands/*.sh)
    ↓
R2R API (curl + jq)
```

## Доступные команды для Agents

| Agent | Основная команда | Дополнительные |
|-------|------------------|----------------|
| **Research Assistant** | `/r2r-agent` | `/r2r-search`, `/r2r-rag` |
| **Knowledge Explorer** | `/r2r-search` | `/r2r-collections` |
| **Doc Analyst** | `/r2r-rag` | `/r2r-search` |

## Skills vs Agents

- **Skills** (`.claude/skills/`) - описательные гайды о возможностях R2R
- **Agents** (`.claude/agents/`) - паттерны использования для complex workflows

Оба используют одни и те же bash скрипты и slash команды.
