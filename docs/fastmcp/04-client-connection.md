# Client и Connection

## Обзор FastMCP Client

FastMCP Client предоставляет асинхронный интерфейс для подключения к MCP серверам и взаимодействия с ними. Он поддерживает различные транспорты (stdio, HTTP, SSE) и обеспечивает единообразный API для работы с tools, resources и prompts.

## Создание клиента

### Подключение к серверу

```python
from fastmcp import Client

# HTTP сервер
client = Client("http://localhost:8000/mcp")

# Локальный Python скрипт (stdio)
client = Client("my_mcp_server.py")

# In-memory сервер (для тестирования)
from fastmcp import FastMCP
server = FastMCP("TestServer")
client = Client(server)
```

## Транспорты

FastMCP поддерживает различные способы подключения к серверам.

### 1. Streamable HTTP Transport (рекомендуется для продакшн)

```python
from fastmcp.client.transports import StreamableHttpTransport
from fastmcp import Client

# Базовое подключение
transport = StreamableHttpTransport(url="https://api.example.com/mcp")
client = Client(transport)

# С кастомными заголовками для аутентификации
transport = StreamableHttpTransport(
    url="https://api.example.com/mcp",
    headers={
        "Authorization": "Bearer your-token-here",
        "X-Custom-Header": "value"
    }
)
client = Client(transport)
```

**Преимущества HTTP Transport:**
- Эффективная двунаправленная потоковая передача
- Поддержка аутентификации через headers
- Подходит для production развертываний
- Работает через сеть

### 2. Stdio Transport (для локальных серверов)

```python
# Автоматически используется при передаче пути к файлу
client = Client("my_server.py")

# Или явное указание
from fastmcp.client.transports import StdioTransport

transport = StdioTransport(command=["python", "my_server.py"])
client = Client(transport)
```

**Преимущества Stdio Transport:**
- Простота использования для локальных серверов
- Не требует сетевой настройки
- Идеален для разработки и тестирования

### 3. SSE Transport (Server-Sent Events)

```python
client = Client("http://localhost:8000/sse")
```

## Управление соединением

### Контекстный менеджер (рекомендуется)

```python
import asyncio
from fastmcp import Client

async def main():
    client = Client("http://localhost:8000/mcp")
    
    async with client:
        # Клиент автоматически подключается
        result = await client.ping()
        print(f"Server responding: {result}")
        
        # Выполнение операций
        tools = await client.list_tools()
        
    # Клиент автоматически отключается при выходе из контекста

asyncio.run(main())
```

### Ручное управление соединением

```python
async def manual_connection():
    client = Client("http://localhost:8000/mcp")
    
    try:
        # Ручное подключение
        await client.connect()
        
        # Работа с клиентом
        result = await client.call_tool("my_tool", {"param": "value"})
        
    finally:
        # Ручное отключение
        await client.disconnect()
```

### Проверка состояния соединения

```python
async with client:
    # Проверка подключения
    if client.is_connected():
        print("Client is connected")
    
    # Ping сервера
    try:
        await client.ping()
        print("Server is responding")
    except Exception as e:
        print(f"Server not responding: {e}")
```

## Работа с Tools

### Список инструментов

```python
async with client:
    tools = await client.list_tools()
    
    for tool in tools:
        print(f"Tool: {tool.name}")
        print(f"Description: {tool.description}")
        
        if hasattr(tool, 'inputSchema'):
            print(f"Input Schema: {tool.inputSchema}")
```

### Вызов инструмента

```python
async with client:
    # Простой вызов
    result = await client.call_tool("add", {"a": 5, "b": 3})
    print(f"Result: {result.content[0].text}")
    
    # Вызов с обработкой ошибок
    try:
        result = await client.call_tool("divide", {"a": 10, "b": 0})
    except Exception as e:
        print(f"Error calling tool: {e}")
```

### Вызов асинхронного инструмента

```python
async with client:
    # Инструмент, который выполняет долгую операцию
    result = await client.call_tool(
        "process_large_dataset",
        {"dataset_id": "123", "operation": "analyze"}
    )
    print(result.content[0].text)
```

## Работа с Resources

### Список ресурсов

```python
async with client:
    resources = await client.list_resources()
    
    for resource in resources:
        print(f"Resource: {resource.name}")
        print(f"URI: {resource.uri}")
        print(f"Description: {resource.description}")
        
        # Доступ к метаданным FastMCP
        if hasattr(resource, '_meta') and resource._meta:
            fastmcp_meta = resource._meta.get('_fastmcp', {})
            print(f"Tags: {fastmcp_meta.get('tags', [])}")
            print(f"MIME Type: {fastmcp_meta.get('mime_type')}")
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
        elif hasattr(item, 'blob'):
            print(f"Binary content length: {len(item.blob)}")
```

### Чтение ресурса с параметрами

```python
async with client:
    # URI с параметрами (шаблонные URI)
    user_profile = await client.read_resource("users://alice/profile")
    weather = await client.read_resource("api://weather/london")
```

## Работа с Prompts

### Список промптов

```python
async with client:
    prompts = await client.list_prompts()
    
    for prompt in prompts:
        print(f"Prompt: {prompt.name}")
        print(f"Description: {prompt.description}")
        
        if prompt.arguments:
            arg_names = [arg.name for arg in prompt.arguments]
            print(f"Arguments: {arg_names}")
```

### Получение отрендеренного промпта

```python
async with client:
    # Промпт с аргументами
    result = await client.get_prompt("analyze_data", {
        "data": [1, 2, 3],
        "analysis_type": "statistical"
    })
    
    # Доступ к сгенерированным сообщениям
    for message in result.messages:
        print(f"Role: {message.role}")
        print(f"Content: {message.content}")
```

## Получение информации о сервере

### Server Info

```python
async with client:
    # Получение информации о сервере
    info = await client.get_server_info()
    print(f"Server name: {info.name}")
    print(f"Version: {info.version}")
```

### Capabilities

```python
async with client:
    # Получение capabilities
    caps = await client.get_server_capabilities()
    print(f"Supports tools: {caps.tools}")
    print(f"Supports resources: {caps.resources}")
```

## Получение Session

```python
async with client:
    # Получение текущей сессии
    session = client.session
    print(f"Session ID: {session.id}")
    print(f"Status: {session.status}")
```

**Важно**: Метод `session` вызовет `RuntimeError`, если клиент не подключен.

## Обработка ошибок

### Базовая обработка ошибок

```python
async with client:
    try:
        result = await client.call_tool("risky_operation", {})
    except RuntimeError as e:
        print(f"Runtime error: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")
```

### Обработка ошибок соединения

```python
from fastmcp import Client

async def robust_connection():
    client = Client("http://localhost:8000/mcp")
    
    try:
        async with client:
            await client.ping()
    except ConnectionError:
        print("Failed to connect to server")
    except TimeoutError:
        print("Connection timeout")
    except Exception as e:
        print(f"Unexpected error: {e}")
```

## CORS для браузерных клиентов

Если вы подключаетесь из браузера, настройте CORS на сервере:

```python
from fastmcp import FastMCP
from starlette.middleware import Middleware
from starlette.middleware.cors import CORSMiddleware

mcp = FastMCP("MyServer")

# Настройка CORS
middleware = [
    Middleware(
        CORSMiddleware,
        allow_origins=["*"],  # Используйте конкретные origins в продакшн
        allow_methods=["GET", "POST", "DELETE", "OPTIONS"],
        allow_headers=[
            "mcp-protocol-version",
            "mcp-session-id",
            "Authorization",
            "Content-Type",
        ],
        expose_headers=["mcp-session-id"],
    )
]

app = mcp.http_app(middleware=middleware)
```

## Тестирование с клиентом

### Unit тесты с in-memory сервером

```python
import pytest
from fastmcp import FastMCP, Client

@pytest.fixture
def test_server():
    mcp = FastMCP("TestServer")
    
    @mcp.tool
    def add(a: int, b: int) -> int:
        return a + b
    
    return mcp

@pytest.mark.asyncio
async def test_tool_call(test_server):
    client = Client(test_server)
    
    async with client:
        result = await client.call_tool("add", {"a": 2, "b": 3})
        assert result.content[0].text == "5"
```

### Интеграционные тесты с HTTP

```python
import pytest
from fastmcp import Client
from fastmcp.client.transports import StreamableHttpTransport

@pytest.mark.asyncio
async def test_http_connection():
    transport = StreamableHttpTransport(url="http://localhost:8000/mcp")
    client = Client(transport)
    
    async with client:
        # Тест ping
        result = await client.ping()
        assert result is not None
        
        # Тест list tools
        tools = await client.list_tools()
        assert len(tools) > 0
```

### Тестирование только сетевых функций

```python
from fastmcp import Client
from fastmcp.client.transports import StreamableHttpTransport

# Для тестирования HTTP-специфичных функций
async def test_network_features():
    server_url = "http://localhost:8000/mcp"
    transport = StreamableHttpTransport(server_url)
    
    async with Client(transport=transport) as client:
        result = await client.ping()
        assert result is not None
```

## Продвинутые техники

### Множественные подключения

```python
async def multiple_clients():
    server1 = Client("http://server1.com/mcp")
    server2 = Client("http://server2.com/mcp")
    
    async with server1, server2:
        # Параллельные запросы к разным серверам
        results = await asyncio.gather(
            server1.call_tool("tool1", {}),
            server2.call_tool("tool2", {})
        )
        
        print(f"Results from both servers: {results}")
```

### Retry logic

```python
import asyncio
from fastmcp import Client

async def call_with_retry(client, tool_name, args, max_retries=3):
    for attempt in range(max_retries):
        try:
            result = await client.call_tool(tool_name, args)
            return result
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            await asyncio.sleep(2 ** attempt)  # Exponential backoff
```

### Timeout handling

```python
import asyncio
from fastmcp import Client

async def call_with_timeout(client, tool_name, args, timeout=10):
    try:
        result = await asyncio.wait_for(
            client.call_tool(tool_name, args),
            timeout=timeout
        )
        return result
    except asyncio.TimeoutError:
        print(f"Tool call timed out after {timeout} seconds")
        raise
```

## Лучшие практики

### 1. Всегда используйте контекстный менеджер

```python
# Хорошо
async with client:
    result = await client.call_tool("my_tool", {})

# Плохо - нужно вручную управлять соединением
await client.connect()
result = await client.call_tool("my_tool", {})
await client.disconnect()
```

### 2. Обрабатывайте ошибки

```python
async with client:
    try:
        result = await client.call_tool("risky_operation", {})
    except Exception as e:
        logger.error(f"Tool call failed: {e}")
        # Fallback logic
```

### 3. Переиспользуйте клиентов в одном контексте

```python
# Хорошо - один контекст для множества операций
async with client:
    tools = await client.list_tools()
    result1 = await client.call_tool("tool1", {})
    result2 = await client.call_tool("tool2", {})

# Плохо - создание нового контекста для каждой операции
async with client:
    tools = await client.list_tools()

async with client:
    result = await client.call_tool("tool1", {})
```

### 4. Используйте типизацию

```python
from fastmcp import Client
from typing import Dict, Any

async def typed_client_call(client: Client, tool_name: str, args: Dict[str, Any]) -> str:
    async with client:
        result = await client.call_tool(tool_name, args)
        return result.content[0].text
```

## Следующие шаги

- [Authentication](./05-authentication.md) - Настройка аутентификации
- [Resources and Prompts](./03-resources-prompts.md) - Работа с ресурсами
- [Deployment](./06-deployment-configuration.md) - Развертывание серверов
