# R2R Search Strategies - Troubleshooting

## Статус поддержки стратегий

Текущий R2R сервер (https://api.136-119-36-216.nip.io) поддерживает следующие search strategies:

| Стратегия | Статус | Описание |
|-----------|--------|----------|
| **vanilla** | ✅ Работает | Стандартный semantic search |
| **rag_fusion** | ❌ Ошибка | Multiple queries + RRF |
| **hyde** | ❌ Ошибка | Hypothetical Document Embeddings |

## Проблема с продвинутыми стратегиями

### Симптомы

При использовании `rag_fusion` или `hyde` стратегий как в `search`, так и в `rag` командах:
- **Search команда**: возвращает пустые результаты
- **RAG команда**: возвращает JSON с ошибкой вместо generated_answer
- Ошибка 500 в JSON ответе для обеих команд

### Полная ошибка

```json
{
  "detail": {
    "message": "An error '500: Internal RAG Error - litellm.BadRequestError: VertexAIException BadRequestError - {\n  \"error\": {\n    \"code\": 400,\n    \"message\": \"Unable to submit request because at least one contents field is required. Learn more: https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/gemini\",\n    \"status\": \"INVALID_ARGUMENT\"\n  }\n}\n' occurred during rag_app",
    "error": "500: Internal RAG Error - litellm.BadRequestError: VertexAIException BadRequestError",
    "error_type": "HTTPException"
  }
}
```

### Причина

R2R сервер пытается использовать VertexAI/Gemini модель для генерации hypothetical documents (HyDE) или alternative queries (RAG Fusion), но:

1. **Некорректная конфигурация модели** - Gemini API требует поле `contents`, которое не передается
2. **Проблема в litellm integration** - Middleware не формирует корректный запрос для VertexAI

### Workaround

В `.claude/scripts/lib/common.sh` используется `DEFAULT_SEARCH_STRATEGY="vanilla"` вместо продвинутых стратегий.

Это влияет на:
- `.claude/scripts/commands/search.sh` - hybrid search
- `.claude/scripts/commands/rag.sh` - RAG generation

Обе команды поддерживают явное указание стратегии через `--strategy <name>`, но рекомендуется использовать только `vanilla`.

## Тестирование стратегий

### Vanilla (работает)

```bash
curl -s -X POST "https://api.136-119-36-216.nip.io/v3/retrieval/rag" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{"query":"What is R2R?","search_settings":{"use_hybrid_search":true,"search_strategy":"vanilla"},"rag_generation_config":{"max_tokens":4000}}'
```

**Result:** ✅ Returns generated answer

### RAG Fusion (ошибка)

```bash
curl -s -X POST "https://api.136-119-36-216.nip.io/v3/retrieval/rag" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{"query":"What is R2R?","search_settings":{"use_hybrid_search":true,"search_strategy":"rag_fusion"},"rag_generation_config":{"max_tokens":4000}}'
```

**Result:** ❌ 500 Internal RAG Error - VertexAI BadRequestError

### HyDE (ошибка)

```bash
curl -s -X POST "https://api.136-119-36-216.nip.io/v3/retrieval/rag" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{"query":"What is R2R?","search_settings":{"use_hybrid_search":true,"search_strategy":"hyde"},"rag_generation_config":{"max_tokens":4000}}'
```

**Result:** ❌ 500 Internal RAG Error - VertexAI BadRequestError

## Рекомендации

1. **Использовать `vanilla` стратегию** для production queries
2. **Hybrid search (`use_hybrid_search: true`) всё ещё работает** с vanilla стратегией
3. **Обратиться к администратору R2R сервера** для исправления конфигурации VertexAI

## Конфигурация lib/common.sh

```bash
# Default settings
DEFAULT_LIMIT=3
DEFAULT_MAX_TOKENS=4000
DEFAULT_MODE="research"
DEFAULT_SEARCH_STRATEGY="vanilla"  # vanilla работает, rag_fusion и hyde - нет
```

## Примеры использования модульных команд

### Тестирование стратегий через CLI

```bash
# Search с разными стратегиями
.claude/scripts/r2r search "R2R" 3 --strategy vanilla      # ✅ Работает
.claude/scripts/r2r search "R2R" 3 --strategy rag_fusion   # ❌ Пустые результаты
.claude/scripts/r2r search "R2R" 3 --strategy hyde         # ❌ Пустые результаты

# RAG с разными стратегиями
.claude/scripts/r2r rag "What is R2R?" --strategy vanilla      # ✅ Работает
.claude/scripts/r2r rag "What is R2R?" --strategy rag_fusion   # ❌ VertexAI Error
.claude/scripts/r2r rag "What is R2R?" --strategy hyde         # ❌ VertexAI Error

# Проверка с JSON output
.claude/scripts/r2r rag "test" --strategy rag_fusion --json | jq '.detail.error'
```

## История изменений

- **2025-01-25**: Обнаружена проблема с `hyde` и `rag_fusion` стратегиями
- **2025-01-25**: Изменен DEFAULT_SEARCH_STRATEGY с `hyde` на `vanilla`
- **2025-01-25**: Протестированы все три стратегии, подтверждена работа только `vanilla`

## Ссылки

- [R2R Advanced RAG Documentation](https://r2r-docs.sciphi.ai/documentation/advanced-rag)
- [VertexAI Gemini API Reference](https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/gemini)
- [litellm VertexAI Integration](https://docs.litellm.ai/docs/providers/vertex)
