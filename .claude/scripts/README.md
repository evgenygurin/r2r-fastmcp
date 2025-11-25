# R2R Bash Scripts

Прямой доступ к R2R API через bash скрипты вместо MCP серверов.

## Файлы

### r2r_client.sh - Основные операции запросов

**Команды:**
- `search <query> [limit]` - Гибридный поиск (semantic + fulltext)
- `rag <query> [max_tokens]` - RAG запрос с генерацией ответа
- `agent <query> [mode] [conv_id] [max_tokens]` - Агент с multi-turn разговорами

**Флаги:**
- `--json` - Вывод сырого JSON
- `--verbose` - Детальные метаданные (только для search)
- `--thinking` - Расширенное размышление (только для agent, 4096 токенов)

**Настройки по умолчанию:**
- Limit: 3 результата
- Max tokens: 8000
- Agent mode: research (reasoning, critique, python_executor)
- Search: hybrid (semantic + fulltext)

**Примеры:**
```bash
# Поиск
./r2r_client.sh search "машинное обучение" 5
./r2r_client.sh search "трансформеры" 10 --verbose
./r2r_client.sh search "нейронные сети" --json

# RAG
./r2r_client.sh rag "Объясни архитектуру трансформеров"
./r2r_client.sh rag "Что такое RAG?" 12000
./r2r_client.sh rag "FastMCP декораторы" --json

# Agent - research mode (по умолчанию)
./r2r_client.sh agent "Что такое DeepSeek R1?"
./r2r_client.sh agent "Проанализируй концепцию RAG" research "" "" --thinking

# Agent - rag mode
./r2r_client.sh agent "Простой вопрос о документе" rag

# Multi-turn conversation
response1=$(./r2r_client.sh agent "Что такое R2R?" --json)
conv_id=$(echo "$response1" | jq -r '.conversation_id')
./r2r_client.sh agent "Расскажи подробнее" research "$conv_id"
```

### r2r_advanced.sh - Расширенные операции управления

**30+ команд для полного управления R2R:**

#### Document Management
```bash
./r2r_advanced.sh docs list                    # Список документов
./r2r_advanced.sh docs get <doc_id>            # Получить документ
./r2r_advanced.sh docs delete <doc_id>         # Удалить документ
./r2r_advanced.sh docs export                  # Экспорт в CSV
./r2r_advanced.sh docs upload <file> [cols] [meta]  # Загрузить
./r2r_advanced.sh docs extract <doc_id>        # Извлечь граф знаний
```

#### Collections
```bash
./r2r_advanced.sh collections list
./r2r_advanced.sh collections create "Name" "Description"
./r2r_advanced.sh collections add-document <col_id> <doc_id>
./r2r_advanced.sh collections add-user <user_id> <col_id>
```

#### Knowledge Graphs
```bash
./r2r_advanced.sh graph entities <collection_id>
./r2r_advanced.sh graph relationships <collection_id>
./r2r_advanced.sh graph communities <collection_id>
./r2r_advanced.sh graph build-communities <collection_id>
./r2r_advanced.sh graph pull <collection_id>
./r2r_advanced.sh graph create-entity <col_id> "Name" "Desc" "Category"
./r2r_advanced.sh graph create-relationship <col_id> "Subj" <subj_id> "Pred" "Obj" <obj_id>
```

#### Advanced Search
```bash
./r2r_advanced.sh search filtered "query" '{"category":"tech"}'
./r2r_advanced.sh search strategy "query" vanilla|rag_fusion|hyde
./r2r_advanced.sh search graph "query" <collection_id>
```

#### Analytics
```bash
./r2r_advanced.sh analytics collection <collection_id>
./r2r_advanced.sh analytics document <document_id>
```

#### Demo Workflow
```bash
./r2r_advanced.sh demo  # Полный демонстрационный цикл
```

### R2R_EXAMPLES.md - Подробная документация

Comprehensive guide с:
- 26 примеров кода с ожидаемыми результатами
- Production workflows
- Performance benchmarks
- Best practices
- Troubleshooting guide

## Конфигурация

**Environment Variables:**
Скрипты загружают переменные из `.claude/config/.env`:
```bash
R2R_BASE_URL=https://api.136-119-36-216.nip.io
API_KEY=your_api_key_here
```

**Расположение:**
- `.claude/config/.env` - конфигурация для bash скриптов

## Интеграция с Claude Code

### Slash Commands

Команды в `.claude/commands/` автоматически используют эти скрипты:

- `/r2r-search "query"` → `r2r_client.sh search`
- `/r2r-rag "query"` → `r2r_client.sh rag`
- `/r2r-agent "message"` → `r2r_client.sh agent`
- `/r2r-collections` → `r2r_advanced.sh collections`
- `/r2r-upload <file>` → `r2r_advanced.sh docs upload`

### Настройки

`settings.json` обновлен для использования bash скриптов вместо MCP сервера:
```json
{
  "mcpServers": {
    "_comment": "MCP servers disabled - using bash scripts instead",
    "_disabled_r2r-bridge": { ... }
  }
}
```

## Agent Modes

### RAG Mode
**Tools:** search_file_knowledge, search_file_descriptions, get_file_content, web_search, web_scrape
**Best for:** Direct questions, fact retrieval

### Research Mode (DEFAULT)
**Tools:** rag, reasoning, critique, python_executor
**Best for:** Complex analysis, multi-step reasoning, deep exploration

### Extended Thinking
**Flag:** `--thinking`
**Budget:** 4096 tokens
**Temperature:** 1.0
**Best for:** Philosophical questions, deep analysis, multi-step reasoning

## Search Features

### Hybrid Search
Combines:
- **Semantic search** - Понимание концептуального смысла
- **Fulltext search** - Точное совпадение ключевых слов
- **Reciprocal Rank Fusion** - Объединение результатов

### Search Strategies
- `vanilla` - Стандартный semantic search
- `rag_fusion` - Множественные запросы + RRF
- `hyde` - Hypothetical Document Embeddings

## Характеристики производительности

**Search:**
- Latency: ~200-500ms
- Results: 3-10 (оптимально)
- Hybrid search: 30-50% лучшая релевантность

**RAG:**
- Latency: ~2-5s (в зависимости от max_tokens)
- Quality: Высокая (hybrid search + GPT-4)
- Token limit: до 16K

**Agent:**
- Latency: ~3-10s (research mode), ~2-4s (rag mode)
- Extended thinking: +2-5s overhead
- Context preservation: Да (multi-turn)

## Best Practices

1. **Используй research mode по умолчанию** для лучшего reasoning
2. **Extended thinking** для сложных аналитических задач
3. **Hybrid search** для баланса semantic и keyword matching
4. **Multi-turn conversations** для сохранения контекста
5. **Verbose flag** для debugging и анализа релевантности
6. **JSON output** для автоматизации и обработки

## Troubleshooting

**Ошибка аутентификации:**
```bash
# Проверь .env файл
cat r2r_fastapi/.env | grep API_KEY
```

**Пустые результаты:**
```bash
# Проверь подключение
curl -s "${R2R_BASE_URL}/v3/system/settings" -H "Authorization: Bearer ${API_KEY}"
```

**Extended thinking не работает:**
```bash
# Убедись, что модель поддерживает extended thinking
# anthropic/claude-3-7-sonnet-20250219 - рекомендуется
```

**Conversation ID потерян:**
```bash
# Используй --json и jq для извлечения
response=$(./r2r_client.sh agent "query" --json)
conv_id=$(echo "$response" | jq -r '.conversation_id')
```

## Дополнительная информация

- **R2R Documentation:** `docs/r2r/`
- **Examples:** `R2R_EXAMPLES.md`
- **CLAUDE.md:** R2R Quick Reference section
- **Slash Commands:** `.claude/commands/r2r-*.md`
