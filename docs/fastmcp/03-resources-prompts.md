# Resources и Prompts

## Resources (Ресурсы)

Resources — это данные, которые LLM могут читать для получения контекста. Они представляют файлы, API ответы, динамические данные или любую другую информацию, которая может понадобиться LLM.

### Типы Resources

FastMCP поддерживает несколько типов ресурсов:

- **TextResource** - Текстовые данные
- **FileResource** - Файлы с диска
- **DirectoryResource** - Содержимое директорий
- **Динамические ресурсы** - Генерируемые функциями

## Статические Resources

### 1. TextResource - Простые текстовые данные

```python
from fastmcp import FastMCP
from fastmcp.resources import TextResource

mcp = FastMCP(name="DataServer")

# Создание текстового ресурса
notice_resource = TextResource(
    uri="resource://notice",
    name="Important Notice",
    text="Техническое обслуживание запланировано на воскресенье.",
    tags={"notification"}
)
mcp.add_resource(notice_resource)
```

### 2. FileResource - Файлы с диска

```python
from pathlib import Path
from fastmcp.resources import FileResource

readme_path = Path("./README.md").resolve()

if readme_path.exists():
    readme_resource = FileResource(
        uri=f"file://{readme_path.as_posix()}",
        path=readme_path,
        name="README File",
        description="README проекта",
        mime_type="text/markdown",
        tags={"documentation"}
    )
    mcp.add_resource(readme_resource)
```

### 3. DirectoryResource - Листинг директорий

```python
from fastmcp.resources import DirectoryResource

data_dir_path = Path("./app_data").resolve()

if data_dir_path.is_dir():
    data_listing_resource = DirectoryResource(
        uri="resource://data-files",
        path=data_dir_path,
        name="Data Directory Listing",
        description="Список файлов в директории данных",
        recursive=False  # True для рекурсивного обхода
    )
    mcp.add_resource(data_listing_resource)
```

### Пользовательский ключ хранения

```python
special_resource = TextResource(
    uri="resource://common-notice",
    name="Special Notice",
    text="Специальное уведомление с пользовательским ключом.",
)
mcp.add_resource(special_resource, key="resource://custom-key")
```

## Динамические Resources

Динамические ресурсы создаются функциями и могут генерировать контент на лету.

### Базовый динамический ресурс

```python
from fastmcp import FastMCP

mcp = FastMCP(name="ConfigServer")

@mcp.resource("config://settings")
def get_settings() -> str:
    """Возвращает текущие настройки приложения."""
    return "database_url=localhost:5432\napi_key=secret"
```

### Ресурс с параметрами (шаблон URI)

```python
@mcp.resource("users://{user_id}/profile")
def get_user_profile(user_id: str) -> str:
    """Получает профиль пользователя по ID."""
    # user_id извлекается из URI автоматически
    return f"Profile for user {user_id}"
```

### Асинхронный ресурс с HTTP запросами

```python
import httpx

@mcp.resource("api://weather/{city}")
async def get_weather(city: str) -> str:
    """Получает погоду для города."""
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"https://api.weather.com/v1/{city}"
        )
        return response.text
```

### Ресурс с метаданными

```python
@mcp.resource(
    "data://analytics/report",
    name="Analytics Report",
    description="Ежедневный отчет по аналитике",
    mime_type="application/json",
    tags={"analytics", "reports"}
)
def get_analytics() -> str:
    """Генерирует JSON отчет."""
    import json
    return json.dumps({
        "users": 1000,
        "revenue": 50000,
        "date": "2024-01-15"
    })
```

## Работа с Resources из клиента

### Список всех ресурсов

```python
from fastmcp import Client

async with Client("http://localhost:8000/mcp") as client:
    resources = await client.list_resources()
    
    for resource in resources:
        print(f"Resource: {resource.name}")
        print(f"URI: {resource.uri}")
        print(f"Description: {resource.description}")
        
        # Доступ к метаданным
        if hasattr(resource, '_meta') and resource._meta:
            fastmcp_meta = resource._meta.get('_fastmcp', {})
            print(f"Tags: {fastmcp_meta.get('tags', [])}")
```

### Чтение ресурса

```python
async with client:
    # Чтение текстового ресурса
    content = await client.read_resource("resource://config/settings.json")
    
    for item in content:
        if hasattr(item, 'text'):
            print(f"Text content: {item.text}")
            print(f"MIME type: {item.mimeType}")
```

### Чтение ресурса с параметрами

```python
async with client:
    # URI с параметрами
    profile = await client.read_resource("users://123/profile")
    print(profile)
```

## Prompts (Промпты)

Prompts — это переиспользуемые шаблоны сообщений для LLM. Они позволяют стандартизировать взаимодействие и параметризовать запросы.

### Простой промпт

```python
from fastmcp import FastMCP

mcp = FastMCP(name="AssistantServer")

@mcp.prompt
def greeting_prompt(name: str, role: str = "user") -> str:
    """Генерирует персонализированное приветствие."""
    return f"Hello {name}! You are logged in as {role}."
```

### Промпт с множественными сообщениями

```python
from typing import List

@mcp.prompt
def analysis_prompt(topic: str, depth: str = "basic") -> List[dict]:
    """Генерирует промпт для анализа темы."""
    messages = [
        {
            "role": "system",
            "content": f"You are an expert analyst specializing in {topic}."
        },
        {
            "role": "user",
            "content": f"Please provide a {depth} analysis of {topic}."
        }
    ]
    return messages
```

### Промпт с контекстом

```python
from fastmcp import Context

@mcp.prompt
async def contextual_prompt(query: str, ctx: Context) -> str:
    """Промпт с доступом к ресурсам через контекст."""
    # Получаем доступные ресурсы
    resources = await ctx.list_resources()
    resource_list = ", ".join([r.name for r in resources])
    
    return f"""Analyze the following query: {query}
    
Available resources: {resource_list}
Please use these resources to provide context in your response."""
```

### Промпт с тегами

```python
@mcp.prompt(
    name="data_analysis",
    description="Промпт для анализа данных",
    tags={"analysis", "data"}
)
def data_analysis_prompt(dataset_name: str) -> str:
    """Анализирует указанный датасет."""
    return f"Perform comprehensive analysis on {dataset_name} dataset."
```

## Работа с Prompts из клиента

### Список всех промптов

```python
async with client:
    prompts = await client.list_prompts()
    
    for prompt in prompts:
        print(f"Prompt: {prompt.name}")
        print(f"Description: {prompt.description}")
        
        if prompt.arguments:
            print(f"Arguments: {[arg.name for arg in prompt.arguments]}")
        
        # Доступ к тегам
        if hasattr(prompt, '_meta') and prompt._meta:
            fastmcp_meta = prompt._meta.get('_fastmcp', {})
            print(f"Tags: {fastmcp_meta.get('tags', [])}")
```

### Получение отрендеренного промпта

```python
async with client:
    # Промпт с простыми аргументами
    result = await client.get_prompt("user_greeting", {
        "name": "Alice",
        "role": "administrator"
    })
    
    # Доступ к сгенерированным сообщениям
    for message in result.messages:
        print(f"Generated message: {message.content}")
```

### Фильтрация промптов по тегам

```python
async with client:
    prompts = await client.list_prompts()
    
    # Фильтрация по тегу
    analysis_prompts = [
        prompt for prompt in prompts 
        if hasattr(prompt, '_meta') and prompt._meta and
           prompt._meta.get('_fastmcp', {}) and
           'analysis' in prompt._meta.get('_fastmcp', {}).get('tags', [])
    ]
    
    print(f"Found {len(analysis_prompts)} analysis prompts")
```

## Управление Resources через PromptManager

### Получение ресурса по URI

```python
from fastmcp.resources import ResourceManager

# Внутри сервера
resource_manager = mcp.resource_manager
resource = await resource_manager.get_resource("resource://config")
```

### Проверка существования ресурса

```python
if resource_manager.has_resource("resource://config"):
    resource = await resource_manager.get_resource("resource://config")
```

## Управление Prompts через PromptManager

### Методы PromptManager

```python
# Проверка существования промпта
if mcp.prompt_manager.has_prompt("greeting"):
    prompt = mcp.prompt_manager.get_prompt("greeting")

# Получение всех промптов
all_prompts = mcp.prompt_manager.get_prompts()

# Рендеринг промпта с аргументами
result = mcp.prompt_manager.render_prompt(
    "analysis",
    arguments={"topic": "AI", "depth": "advanced"}
)
```

### Добавление промпта программно

```python
from fastmcp.prompts import FunctionPrompt

def custom_prompt_fn(name: str) -> str:
    return f"Hello, {name}!"

prompt = mcp.prompt_manager.add_prompt_from_fn(
    fn=custom_prompt_fn,
    name="custom_greeting",
    description="Custom greeting prompt",
    tags={"greeting"}
)
```

## Middleware для Resources и Prompts

Вы можете добавить проверки доступа для ресурсов и промптов.

```python
from fastmcp.server.middleware import Middleware, MiddlewareContext
from fastmcp.exceptions import ResourceError, PromptError

class ComponentAccessMiddleware(Middleware):
    async def on_read_resource(self, context: MiddlewareContext, call_next):
        if context.fastmcp_context:
            try:
                resource = await context.fastmcp_context.fastmcp.get_resource(
                    context.message.uri
                )
                if "restricted" in resource.tags:
                    raise ResourceError("Доступ запрещен: ограниченный ресурс")
            except Exception:
                pass
        return await call_next(context)
    
    async def on_get_prompt(self, context: MiddlewareContext, call_next):
        if context.fastmcp_context:
            try:
                prompt = await context.fastmcp_context.fastmcp.get_prompt(
                    context.message.name
                )
                if not prompt.enabled:
                    raise PromptError("Промпт в данный момент отключен")
            except Exception:
                pass
        return await call_next(context)

# Добавление middleware
mcp.add_middleware(ComponentAccessMiddleware())
```

## Лучшие практики

### 1. Используйте семантичные URI

```python
# Хорошо
@mcp.resource("users://{user_id}/profile")
@mcp.resource("config://database/settings")
@mcp.resource("api://external/{endpoint}")

# Плохо
@mcp.resource("res1")
@mcp.resource("data")
```

### 2. Добавляйте описательные метаданные

```python
@mcp.resource(
    "reports://sales/monthly",
    name="Monthly Sales Report",
    description="Detailed monthly sales analysis with trends",
    mime_type="application/json",
    tags={"reports", "sales", "analytics"}
)
def monthly_sales() -> str:
    return generate_report()
```

### 3. Обрабатывайте ошибки

```python
from fastmcp.exceptions import ResourceError

@mcp.resource("data://{dataset_id}")
async def get_dataset(dataset_id: str) -> str:
    if not dataset_exists(dataset_id):
        raise ResourceError(f"Dataset {dataset_id} not found")
    return load_dataset(dataset_id)
```

### 4. Кешируйте дорогие операции

```python
from functools import lru_cache

@lru_cache(maxsize=128)
def expensive_computation(param: str) -> str:
    # Дорогая операция
    return result

@mcp.resource("cache://data/{param}")
def cached_resource(param: str) -> str:
    return expensive_computation(param)
```

## Следующие шаги

- [Client and Connection](./04-client-connection.md) - Подключение к серверам
- [Tools](./02-tools.md) - Работа с инструментами
- [Middleware](./07-middleware-error-handling.md) - Обработка ресурсов через middleware
