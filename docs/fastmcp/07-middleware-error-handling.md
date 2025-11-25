# Middleware и Error Handling

## Что такое Middleware?

Middleware в FastMCP — это компоненты, которые обрабатывают запросы до и после их выполнения. Они позволяют добавить:
- Аутентификацию и авторизацию
- Логирование и мониторинг
- Обработку ошибок
- Валидацию данных
- Rate limiting
- Кеширование

## Как работает Middleware?

FastMCP middleware работает по модели pipeline:

```
Request
   ↓
Middleware 1 → before
   ↓
Middleware 2 → before
   ↓
Middleware 3 → before
   ↓
Handler (Tool/Resource/Prompt)
   ↓
Middleware 3 → after
   ↓
Middleware 2 → after
   ↓
Middleware 1 → after
   ↓
Response
```

## Создание базового Middleware

### Структура Middleware

```python
from fastmcp.server.middleware import Middleware, MiddlewareContext

class MyMiddleware(Middleware):
    async def on_request(self, context: MiddlewareContext, call_next):
        # Код до обработки запроса
        print("Before request")
        
        # Вызов следующего middleware/handler
        result = await call_next(context)
        
        # Код после обработки запроса
        print("After request")
        
        return result
```

### Добавление Middleware к серверу

```python
from fastmcp import FastMCP

mcp = FastMCP("My Server")

# Добавление middleware
mcp.add_middleware(MyMiddleware())
```

## Middleware Hooks

FastMCP предоставляет специализированные hooks для разных типов операций.

### Доступные Hooks

```python
class FullMiddleware(Middleware):
    async def on_request(self, context: MiddlewareContext, call_next):
        """Вызывается для всех запросов."""
        return await call_next(context)
    
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        """Вызывается при вызове tool."""
        return await call_next(context)
    
    async def on_read_resource(self, context: MiddlewareContext, call_next):
        """Вызывается при чтении resource."""
        return await call_next(context)
    
    async def on_get_prompt(self, context: MiddlewareContext, call_next):
        """Вызывается при получении prompt."""
        return await call_next(context)
```

## Управление потоком выполнения

### 1. Продолжение обработки

```python
class ContinueMiddleware(Middleware):
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        print("Processing tool call...")
        # Продолжаем обработку
        return await call_next(context)
```

### 2. Модификация контекста перед обработкой

```python
class ModifyContextMiddleware(Middleware):
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        # Модификация контекста перед вызовом
        context.metadata['timestamp'] = datetime.now()
        
        result = await call_next(context)
        return result
```

### 3. Модификация результата после обработки

```python
class ModifyResponseMiddleware(Middleware):
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        result = await call_next(context)
        
        # Модификация результата
        if hasattr(result, 'content'):
            result.content[0].text = f"Modified: {result.content[0].text}"
        
        return result
```

### 4. Остановка цепочки (редко используется)

```python
class StopMiddleware(Middleware):
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        # Проверка условия
        if should_stop(context):
            # Возврат результата без вызова call_next
            return create_error_response("Access denied")
        
        return await call_next(context)
```

### 5. Обработка ошибок

```python
class ErrorCatchMiddleware(Middleware):
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        try:
            return await call_next(context)
        except Exception as e:
            # Обработка ошибки
            logging.error(f"Tool call failed: {e}")
            raise
```

## Примеры Middleware

### Логирование

```python
import logging
from datetime import datetime

class LoggingMiddleware(Middleware):
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        start_time = datetime.now()
        tool_name = context.message.name if hasattr(context.message, 'name') else 'unknown'
        
        logging.info(f"Tool call started: {tool_name}")
        
        try:
            result = await call_next(context)
            duration = (datetime.now() - start_time).total_seconds()
            logging.info(f"Tool call completed: {tool_name} ({duration:.2f}s)")
            return result
        except Exception as e:
            duration = (datetime.now() - start_time).total_seconds()
            logging.error(f"Tool call failed: {tool_name} ({duration:.2f}s) - {e}")
            raise

mcp.add_middleware(LoggingMiddleware())
```

### Аутентификация и авторизация

```python
from fastmcp.exceptions import ToolError

class AuthorizationMiddleware(Middleware):
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        if context.fastmcp_context and context.fastmcp_context.request_context:
            access_token = context.fastmcp_context.request_context.access_token
            
            # Проверка аутентификации
            if not access_token:
                raise ToolError("Authentication required")
            
            # Проверка авторизации по scope
            tool_name = context.message.name
            if tool_name.startswith("admin_") and "admin" not in access_token.scopes:
                raise ToolError(f"Admin scope required for {tool_name}")
        
        return await call_next(context)

mcp.add_middleware(AuthorizationMiddleware())
```

### Валидация параметров

```python
class ValidationMiddleware(Middleware):
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        if hasattr(context.message, 'arguments'):
            args = context.message.arguments
            
            # Пример валидации
            if 'email' in args:
                email = args['email']
                if '@' not in email:
                    raise ToolError(f"Invalid email format: {email}")
        
        return await call_next(context)

mcp.add_middleware(ValidationMiddleware())
```

### Rate Limiting

```python
from collections import defaultdict
from datetime import datetime, timedelta

class RateLimitMiddleware(Middleware):
    def __init__(self, max_requests=100, window_seconds=60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self.requests = defaultdict(list)
    
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        if context.fastmcp_context and context.fastmcp_context.request_context:
            access_token = context.fastmcp_context.request_context.access_token
            user_id = access_token.sub if access_token else 'anonymous'
            
            now = datetime.now()
            window_start = now - timedelta(seconds=self.window_seconds)
            
            # Очистка старых запросов
            self.requests[user_id] = [
                req_time for req_time in self.requests[user_id]
                if req_time > window_start
            ]
            
            # Проверка лимита
            if len(self.requests[user_id]) >= self.max_requests:
                raise ToolError(
                    f"Rate limit exceeded: {self.max_requests} requests per "
                    f"{self.window_seconds} seconds"
                )
            
            # Добавление текущего запроса
            self.requests[user_id].append(now)
        
        return await call_next(context)

mcp.add_middleware(RateLimitMiddleware(max_requests=10, window_seconds=60))
```

### Кеширование

```python
from functools import lru_cache
import hashlib
import json

class CachingMiddleware(Middleware):
    def __init__(self):
        self.cache = {}
    
    def _get_cache_key(self, context: MiddlewareContext) -> str:
        """Генерирует ключ кеша из контекста."""
        if hasattr(context.message, 'name') and hasattr(context.message, 'arguments'):
            data = {
                'name': context.message.name,
                'arguments': context.message.arguments
            }
            return hashlib.md5(json.dumps(data, sort_keys=True).encode()).hexdigest()
        return None
    
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        cache_key = self._get_cache_key(context)
        
        # Проверка кеша
        if cache_key and cache_key in self.cache:
            logging.info(f"Cache hit for {context.message.name}")
            return self.cache[cache_key]
        
        # Выполнение и кеширование
        result = await call_next(context)
        
        if cache_key:
            self.cache[cache_key] = result
            logging.info(f"Cached result for {context.message.name}")
        
        return result

mcp.add_middleware(CachingMiddleware())
```

### Метрики и мониторинг

```python
from prometheus_client import Counter, Histogram

class MetricsMiddleware(Middleware):
    def __init__(self):
        self.tool_calls = Counter(
            'mcp_tool_calls_total',
            'Total tool calls',
            ['tool_name', 'status']
        )
        self.tool_duration = Histogram(
            'mcp_tool_duration_seconds',
            'Tool execution time',
            ['tool_name']
        )
    
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        tool_name = context.message.name if hasattr(context.message, 'name') else 'unknown'
        
        with self.tool_duration.labels(tool_name=tool_name).time():
            try:
                result = await call_next(context)
                self.tool_calls.labels(tool_name=tool_name, status='success').inc()
                return result
            except Exception as e:
                self.tool_calls.labels(tool_name=tool_name, status='error').inc()
                raise

mcp.add_middleware(MetricsMiddleware())
```

## MiddlewareContext

### Доступ к контексту запроса

```python
class ContextAwareMiddleware(Middleware):
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        # Доступ к MCP context
        if context.fastmcp_context:
            # FastMCP инстанс
            fastmcp = context.fastmcp_context.fastmcp
            
            # Request context с access token
            if context.fastmcp_context.request_context:
                access_token = context.fastmcp_context.request_context.access_token
                print(f"User: {access_token.sub if access_token else 'anonymous'}")
        
        # Доступ к сообщению
        if hasattr(context.message, 'name'):
            print(f"Tool name: {context.message.name}")
        
        if hasattr(context.message, 'arguments'):
            print(f"Arguments: {context.message.arguments}")
        
        return await call_next(context)
```

### MCP Session доступность

**Важно**: MCP session может быть недоступна во время инициализации.

```python
class SafeContextMiddleware(Middleware):
    async def on_request(self, context: MiddlewareContext, call_next):
        # Проверка доступности request context
        if context.fastmcp_context and context.fastmcp_context.request_context:
            # Request context доступен
            access_token = context.fastmcp_context.request_context.access_token
            print(f"Authenticated user: {access_token.sub if access_token else None}")
        else:
            # Возможно, handshake еще не завершен
            print("MCP request context not available yet")
        
        return await call_next(context)
```

### HTTP Request данные

Для HTTP транспортов можно получить HTTP-специфичные данные:

```python
from fastmcp.server.dependencies import get_http_request, get_http_headers

class HttpAwareMiddleware(Middleware):
    async def on_request(self, context: MiddlewareContext, call_next):
        # Получение HTTP request (если доступен)
        http_request = get_http_request()
        
        if http_request:
            # Доступ к HTTP headers
            user_agent = http_request.headers.get('user-agent')
            client_ip = http_request.client.host
            
            print(f"User-Agent: {user_agent}")
            print(f"Client IP: {client_ip}")
        
        return await call_next(context)
```

## Error Handling

### Встроенный Error Handling Middleware

FastMCP предоставляет готовые middleware для обработки ошибок.

```python
from fastmcp.server.middleware.error_handling import ErrorHandlingMiddleware

# Добавление error handling middleware
mcp.add_middleware(ErrorHandlingMiddleware())
```

**Возможности:**
- Ловит исключения во время обработки
- Логирует ошибки
- Конвертирует исключения в стандартные MCP error responses
- Отслеживает паттерны ошибок

### Retry Middleware

```python
from fastmcp.server.middleware.error_handling import RetryMiddleware

# Автоматический retry для временных ошибок
mcp.add_middleware(RetryMiddleware(
    max_retries=3,
    backoff_factor=2  # Exponential backoff
))
```

### Пользовательская обработка ошибок

```python
from fastmcp.exceptions import ToolError, ResourceError

class CustomErrorMiddleware(Middleware):
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        try:
            return await call_next(context)
        except ValueError as e:
            # Конвертация ValueError в ToolError
            raise ToolError(f"Invalid value: {e}")
        except KeyError as e:
            # Конвертация KeyError в ToolError
            raise ToolError(f"Missing key: {e}")
        except Exception as e:
            # Логирование неожиданных ошибок
            logging.exception(f"Unexpected error in tool call")
            raise ToolError(f"Internal error: {str(e)}")

mcp.add_middleware(CustomErrorMiddleware())
```

## Доступ к Resources и Prompts из Middleware

### Проверка доступа к Resources

```python
from fastmcp.exceptions import ResourceError

class ResourceAccessMiddleware(Middleware):
    async def on_read_resource(self, context: MiddlewareContext, call_next):
        if context.fastmcp_context:
            try:
                # Получение ресурса для проверки метаданных
                resource = await context.fastmcp_context.fastmcp.get_resource(
                    context.message.uri
                )
                
                # Проверка тегов
                if "restricted" in resource.tags:
                    raise ResourceError("Access denied: restricted resource")
            except Exception:
                pass
        
        return await call_next(context)

mcp.add_middleware(ResourceAccessMiddleware())
```

### Проверка доступа к Prompts

```python
from fastmcp.exceptions import PromptError

class PromptAccessMiddleware(Middleware):
    async def on_get_prompt(self, context: MiddlewareContext, call_next):
        if context.fastmcp_context:
            try:
                # Получение промпта для проверки
                prompt = await context.fastmcp_context.fastmcp.get_prompt(
                    context.message.name
                )
                
                # Проверка статуса
                if not prompt.enabled:
                    raise PromptError("Prompt is currently disabled")
            except Exception:
                pass
        
        return await call_next(context)

mcp.add_middleware(PromptAccessMiddleware())
```

## Порядок Middleware

Middleware выполняются в порядке добавления:

```python
mcp.add_middleware(LoggingMiddleware())      # 1. Логирование
mcp.add_middleware(AuthenticationMiddleware()) # 2. Аутентификация
mcp.add_middleware(ValidationMiddleware())   # 3. Валидация
mcp.add_middleware(RateLimitMiddleware())    # 4. Rate limiting
mcp.add_middleware(CachingMiddleware())      # 5. Кеширование
```

**Важно**: Порядок имеет значение! Аутентификация должна быть перед авторизацией, логирование обычно первым или последним.

## Комбинирование Middleware

```python
class CombinedMiddleware(Middleware):
    """Middleware с множественными проверками."""
    
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        # 1. Логирование
        logging.info(f"Tool call: {context.message.name}")
        
        # 2. Аутентификация
        if not self._is_authenticated(context):
            raise ToolError("Authentication required")
        
        # 3. Валидация
        self._validate_arguments(context)
        
        # 4. Выполнение
        start_time = datetime.now()
        try:
            result = await call_next(context)
            duration = (datetime.now() - start_time).total_seconds()
            logging.info(f"Tool completed in {duration:.2f}s")
            return result
        except Exception as e:
            logging.error(f"Tool failed: {e}")
            raise
```

## Лучшие практики

### 1. Держите middleware простыми

```python
# Хорошо - одна ответственность
class LoggingMiddleware(Middleware):
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        logging.info(f"Tool: {context.message.name}")
        return await call_next(context)

# Плохо - слишком много ответственности
class EverythingMiddleware(Middleware):
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        # Логирование, аутентификация, валидация, кеширование...
        pass
```

### 2. Обрабатывайте ошибки правильно

```python
class SafeMiddleware(Middleware):
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        try:
            return await call_next(context)
        except ToolError:
            # Пропускаем ToolError дальше
            raise
        except Exception as e:
            # Логируем неожиданные ошибки
            logging.exception("Unexpected error")
            raise ToolError(f"Internal error: {str(e)}")
```

### 3. Используйте типизацию

```python
from typing import Optional

class TypedMiddleware(Middleware):
    async def on_call_tool(
        self,
        context: MiddlewareContext,
        call_next
    ) -> Optional[any]:
        return await call_next(context)
```

## Следующие шаги

- [Authentication](./05-authentication.md) - Middleware для аутентификации
- [Tools](./02-tools.md) - Защита инструментов через middleware
- [Deployment](./06-deployment-configuration.md) - Middleware в продакшн
