# R2R Knowledge Bridge - FastMCP Server

FastMCP сервер для интеграции R2R (RAG to Riches) с Claude Code через MCP Protocol.

## Возможности

### Tools (6 штук)

1. **search_knowledge** - Semantic/hybrid search в knowledge base
2. **rag_query** - RAG запросы с генерацией ответов
3. **agent_chat** - Multi-turn conversations (rag/research modes)
4. **search_entities** - Поиск сущностей в Knowledge Graph
5. **upload_document** - Загрузка документов в R2R
6. **list_collections** - Список коллекций

### Resources (3 штуки)

1. **knowledge://collections** - Список всех коллекций
2. **knowledge://collections/{id}/documents** - Документы в коллекции
3. **config://r2r** - Конфигурация подключения

## Установка

```bash
# 1. Установить зависимости
cd .claude/mcp-servers/r2r-bridge
pip install -r requirements.txt

# 2. Скопировать и настроить environment variables
cp .env.example .env
# Отредактировать .env с вашими настройками

# 3. Запустить R2R сервер (если локально)
docker compose up -d

# 4. Настроить в Claude Code settings.json (уже добавлено)
```

## Конфигурация в Claude Code

Добавлено в `.claude/settings.json`:

```json
{
  "mcpServers": {
    "r2r-bridge": {
      "command": "python",
      "args": [".claude/mcp-servers/r2r-bridge/server.py"],
      "env": {
        "R2R_BASE_URL": "${R2R_BASE_URL:-http://localhost:7272}",
        "OPENAI_API_KEY": "${OPENAI_API_KEY}"
      }
    }
  }
}
```

## Использование

### Через Commands

```bash
/r2r-search "machine learning"
/r2r-rag "What is transformer architecture?"
/r2r-agent "Research DeepSeek R1" research
/r2r-collections
```

### Через Natural Language

```bash
"Search the knowledge base for neural networks"
"Use R2R to explain quantum computing"
"Start a research conversation about AI safety"
```

### Прямое использование MCP Tools

```bash
@r2r-bridge search_knowledge "query" 10 true
@r2r-bridge rag_query "question" 0.1
@r2r-bridge agent_chat "message" null rag
```

## Environment Variables

| Переменная | Обязательна | По умолчанию | Описание |
|------------|-------------|--------------|----------|
| `R2R_BASE_URL` | Нет | `http://localhost:7272` | URL R2R сервера |
| `R2R_API_KEY` | Нет | - | API ключ для аутентификации |
| `OPENAI_API_KEY` | Да | - | OpenAI API key для генерации |

## Troubleshooting

### R2R server not available

```bash
# Проверить доступность R2R
curl http://localhost:7272/v3/system/settings

# Запустить R2R локально
cd ~/R2R
docker compose up -d
```

### ModuleNotFoundError

```bash
# Переустановить зависимости
pip install -r requirements.txt
```

### Permission denied

```bash
# Сделать server.py исполняемым
chmod +x server.py
```

## Логи

Логи MCP сервера пишутся в stdout:

```bash
# Просмотр логов (через Claude Code)
tail -f /tmp/r2r-usage.log
```

## Архитектура

```text
┌─────────────────────┐
│   Claude Code CLI   │
└──────────┬──────────┘
           │ MCP Protocol (stdio)
           │
┌──────────▼──────────┐
│  FastMCP Bridge     │
│  (этот сервер)      │
│  • 6 Tools          │
│  • 3 Resources      │
└──────────┬──────────┘
           │ Python SDK / REST API
           │
┌──────────▼──────────┐
│    R2R Server       │
│  (localhost:7272)   │
└─────────────────────┘
```

## Дополнительная информация

- **R2R Documentation:** `docs/r2r/README.md`
- **FastMCP Documentation:** `docs/fastmcp/README.md`
- **Integration Patterns:** `CLAUDE.md` (секция "Интеграции")
