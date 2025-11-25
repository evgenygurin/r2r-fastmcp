# Tools (Инструменты)

## Что такое Tools?

Tools — это Python функции, которые LLM могут вызывать для выполнения действий: вычислений, API запросов, манипуляций с данными и других операций. FastMCP автоматически генерирует JSON схемы из type hints и docstring функций.

## Базовое создание Tool

### Простой инструмент

```python
from fastmcp import FastMCP

mcp = FastMCP(name="CalculatorServer")

@mcp.tool
def add(a: int, b: int) -> int:
    """Складывает два целых числа."""
    return a + b
```

FastMCP автоматически:
- Извлекает имя инструмента из имени функции (`add`)
- Использует docstring как описание
- Генерирует JSON схему из type hints

### Инструмент с умножением

```python
@mcp.tool
def multiply(a: float, b: float) -> float:
    """Умножает два числа."""
    return a * b
```

## Варианты регистрации Tools

### 1. "Голый" декоратор (рекомендуется)

```python
@mcp.tool
def my_tool(x: int) -> str:
    return str(x)
```

### 2. Декоратор с пользовательским именем

```python
@mcp.tool("custom_name")
def my_tool(x: int) -> str:
    return str(x)
```

### 3. Декоратор с именованным параметром

```python
@mcp.tool(name="custom_name")
def my_tool(x: int) -> str:
    return str(x)
```

### 4. Прямой вызов функции

```python
def my_function(x: int) -> str:
    return str(x)

mcp.tool(my_function, name="custom_name")
```

## Расширенная конфигурация Tools

### Tool с контекстом

```python
from fastmcp import Context

@mcp.tool
async def get_user_data(user_id: int, ctx: Context) -> dict:
    """Получает данные пользователя с доступом к контексту."""
    # Доступ к MCP возможностям через контекст
    resources = await ctx.list_resources()
    return {"user_id": user_id, "resources_count": len(resources)}
```

### Конфигурация через ToolAnnotations

```python
from fastmcp.server.decorators import ToolAnnotations

@mcp.tool(
    name="important_tool",
    description="Критически важный инструмент",
    annotations=ToolAnnotations(
        title="⚠️ LLM, используй этот инструмент первым!",
        readOnlyHint=True,      # Только для чтения
        destructiveHint=False,  # Не деструктивный
        idempotentHint=True,    # Идемпотентный
    )
)
def important_tool() -> str:
    return "Выполнен важный инструмент!"
```

### Исключение параметров из клиентских вызовов

```python
@mcp.tool(
    name="safe_operation",
    description="Безопасная операция",
    exclude_args=['delete_all']  # Клиенты не могут передать этот параметр
)
def safe_operation(data: str, delete_all: bool = False) -> str:
    if delete_all:
        return "Удаление запрещено через MCP"
    return f"Обработка: {data}"
```

### Отключение инструмента

```python
@mcp.tool(
    name="disabled_tool",
    description="Этот инструмент отключен",
    enabled=False  # Клиенты не смогут вызвать
)
def disabled_tool() -> str:
    return "Вы никогда не увидите это сообщение!"
```

### Добавление метаданных

```python
@mcp.tool(
    name="data_tool",
    description="Получает данные пользователя из базы данных",
    meta={
        "version": "2.0",
        "category": "database",
        "author": "dev-team"
    }
)
def data_tool(user_id: int) -> dict:
    return {"user_id": user_id, "data": "..."}
```

## Работа с типами данных

### Поддерживаемые типы

```python
from typing import List, Dict, Optional
from datetime import datetime

@mcp.tool
def complex_tool(
    number: int,
    text: str,
    flag: bool,
    items: List[str],
    mapping: Dict[str, int],
    optional_value: Optional[str] = None,
    timestamp: datetime = None
) -> Dict[str, any]:
    """Инструмент с различными типами данных."""
    return {
        "number": number,
        "text": text,
        "flag": flag,
        "items": items,
        "mapping": mapping,
        "optional": optional_value,
        "time": timestamp
    }
```

## Dependency Injection с Context

Context предоставляет доступ к MCP возможностям внутри инструмента.

### Ключевые особенности Context

```python
from fastmcp import Context

@mcp.tool
async def advanced_tool(query: str, ctx: Context) -> dict:
    """Инструмент с полным доступом к контексту."""
    
    # Список доступных ресурсов
    resources = await ctx.list_resources()
    
    # Чтение конкретного ресурса
    content = await ctx.read_resource("resource://config")
    
    # Список инструментов
    tools = await ctx.list_tools()
    
    # Получение промптов
    prompts = await ctx.list_prompts()
    
    return {
        "query": query,
        "resources_count": len(resources),
        "tools_count": len(tools)
    }
```

### Важные моменты при использовании Context

1. **Имя параметра не важно** - важен только type hint `Context`
2. **Позиция параметра не важна** - может быть в любом месте сигнатуры
3. **Context опционален** - функции без Context работают нормально
4. **Методы Context асинхронны** - функция обычно должна быть `async`
5. **Context уникален для каждого запроса** - данные не сохраняются между запросами
6. **Context доступен только во время запроса** - использование вне запроса вызовет ошибки

### Опциональный Context для отладки

```python
@mcp.tool
async def flexible_tool(
    data: str,
    ctx: Context | None = None  # Опциональный для отладки
) -> str:
    if ctx:
        resources = await ctx.list_resources()
        return f"Обработка {data} с {len(resources)} ресурсами"
    return f"Обработка {data} без контекста"
```

## Вызов Tools из клиента

### Базовый вызов

```python
import asyncio
from fastmcp import Client

async def main():
    client = Client("http://localhost:8000/mcp")
    
    async with client:
        # Вызов инструмента
        result = await client.call_tool("add", {"a": 5, "b": 3})
        print(f"Результат: {result.content[0].text}")

asyncio.run(main())
```

### Список доступных инструментов

```python
async with client:
    tools = await client.list_tools()
    
    for tool in tools:
        print(f"Tool: {tool.name}")
        print(f"Description: {tool.description}")
        if hasattr(tool, 'inputSchema'):
            print(f"Input Schema: {tool.inputSchema}")
```

## Интеграция с FastAPI

FastMCP может автоматически создавать инструменты из FastAPI endpoints.

```python
from fastapi import FastAPI
from fastmcp import FastMCP

app = FastAPI()

@app.get("/products/{product_id}")
def get_product(product_id: int) -> dict:
    return {"id": product_id, "name": "Product"}

# Конвертация FastAPI в MCP
mcp = FastMCP.from_fastapi(app=app)

# Добавление дополнительных инструментов
@mcp.tool
def custom_tool(value: str) -> str:
    return f"Обработка: {value}"
```

## Лучшие практики

### 1. Используйте детальные docstrings

```python
@mcp.tool
def search_database(
    query: str,
    limit: int = 10,
    filter_category: Optional[str] = None
) -> List[dict]:
    """
    Поиск в базе данных по запросу.
    
    Args:
        query: Поисковый запрос для поиска записей
        limit: Максимальное количество возвращаемых результатов (по умолчанию 10)
        filter_category: Опциональный фильтр по категории
    
    Returns:
        Список словарей с результатами поиска
    """
    pass
```

### 2. Используйте строгую типизацию

```python
from typing import List, Dict, Optional
from pydantic import BaseModel

class SearchResult(BaseModel):
    id: int
    title: str
    score: float

@mcp.tool
def typed_search(query: str) -> List[SearchResult]:
    """Поиск с строгой типизацией результатов."""
    return [
        SearchResult(id=1, title="Result", score=0.95)
    ]
```

### 3. Обрабатывайте ошибки правильно

```python
from fastmcp.exceptions import ToolError

@mcp.tool
def safe_division(a: float, b: float) -> float:
    """Безопасное деление с обработкой ошибок."""
    if b == 0:
        raise ToolError("Деление на ноль невозможно")
    return a / b
```

### 4. Используйте async для I/O операций

```python
import httpx

@mcp.tool
async def fetch_data(url: str) -> dict:
    """Асинхронная загрузка данных из URL."""
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        return response.json()
```

## Отладка Tools

### Проверка регистрации

```python
# Получить все зарегистрированные инструменты
tools = mcp.get_tools()
for tool in tools:
    print(f"Registered: {tool.name}")
```

### Прямой вызов для тестирования

```python
# Можно вызвать функцию напрямую для тестирования
result = add(5, 3)
assert result == 8
```

## Следующие шаги

- [Resources and Prompts](./03-resources-prompts.md) - Работа с ресурсами и промптами
- [Middleware](./07-middleware-error-handling.md) - Добавление middleware для инструментов
- [Authentication](./05-authentication.md) - Защита инструментов
