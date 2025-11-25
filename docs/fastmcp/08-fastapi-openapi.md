# FastAPI и OpenAPI Integration

## Обзор

FastMCP предоставляет мощную интеграцию с существующими REST API через:
- **FastAPI** - автоматическая конвертация FastAPI приложений в MCP серверы
- **OpenAPI** - создание MCP серверов из OpenAPI спецификаций

Это позволяет LLM взаимодействовать с вашими API без написания нового кода.

## FastAPI Integration

### Базовая конвертация

Преобразуйте существующее FastAPI приложение в MCP сервер одной строкой:

```python
from fastapi import FastAPI
from fastmcp import FastMCP

# Существующее FastAPI приложение
app = FastAPI()

@app.get("/products/{product_id}")
def get_product(product_id: int) -> dict:
    return {"id": product_id, "name": "Product"}

# Конвертация в MCP сервер
mcp = FastMCP.from_fastapi(app=app)

if __name__ == "__main__":
    mcp.run()
```

**Что происходит автоматически:**
- Все FastAPI endpoints становятся MCP tools
- Pydantic модели конвертируются в JSON schemas
- Docstrings становятся описаниями tools
- Query/path/body параметры автоматически обрабатываются

### Добавление дополнительных компонентов

После конвертации можно добавить новые MCP компоненты:

```python
# Конвертация FastAPI в MCP
mcp = FastMCP.from_fastapi(app=app)

# Добавление нового tool
@mcp.tool
def get_product(product_id: int) -> dict:
    """Получает продукт по ID."""
    return products_db[product_id]

# Добавление resource
@mcp.resource("config://settings")
def get_settings() -> str:
    return "database_url=localhost"

# Запуск
if __name__ == "__main__":
    mcp.run()
```

### Комбинирование FastAPI и MCP маршрутов

Создайте единое приложение с обычными API endpoints и MCP interface:

```python
from fastapi import FastAPI
from fastmcp import FastMCP

# Существующее FastAPI приложение
app = FastAPI(title="E-commerce API")

@app.get("/products")
def list_products():
    return {"products": [...]}

@app.post("/products")
def create_product(product: Product):
    return {"created": True}

# 1. Генерация MCP сервера из API
mcp = FastMCP.from_fastapi(app=app, name="E-commerce MCP")

# 2. Создание MCP ASGI приложения
mcp_app = mcp.http_app(path='/mcp')

# 3. Объединение обоих наборов маршрутов
combined_app = FastAPI(
    title="E-commerce API with MCP",
    routes=[
        *mcp_app.routes,  # MCP маршруты
        *app.routes,      # Оригинальные API маршруты
    ],
    lifespan=mcp_app.lifespan,
)

# Теперь доступны:
# - Обычный API: http://localhost:8000/products
# - LLM-friendly MCP: http://localhost:8000/mcp
```

### Аутентификация в FastAPI для MCP

```python
from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastmcp import FastMCP

app = FastAPI()
security = HTTPBearer()

# Добавление аутентификации в FastAPI
def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    if credentials.credentials != "secret-token":
        raise HTTPException(status_code=401, detail="Invalid authentication")
    return credentials.credentials

# Защищенный endpoint
@app.get("/admin/stats", dependencies=[Depends(verify_token)])
def get_admin_stats():
    return {
        "total_products": len(products_db),
        "categories": list(set(p.category for p in products_db.values()))
    }

# Создание MCP сервера с authentication headers
mcp = FastMCP.from_fastapi(
    app=app,
    httpx_client_kwargs={
        "headers": {
            "Authorization": "Bearer secret-token",
        }
    }
)
```

### Интеграция с FastAPI Lifespan

Комбинирование FastMCP и FastAPI lifespan events:

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastmcp import FastMCP

@asynccontextmanager
async def app_lifespan(app: FastAPI):
    # Startup
    print("FastAPI starting up...")
    await init_database()
    yield
    # Shutdown
    print("FastAPI shutting down...")
    await close_database()

@asynccontextmanager
async def combined_lifespan(app: FastAPI):
    # Инициализация FastAPI
    async with app_lifespan(app):
        # Инициализация MCP session manager
        async with mcp_app.router.lifespan_context(app):
            yield

# Создание приложения с комбинированным lifespan
app = FastAPI(lifespan=combined_lifespan)
app.mount("/mcp", mcp_app)
```

## OpenAPI Integration

### Создание MCP сервера из OpenAPI спецификации

```python
import httpx
from fastmcp import FastMCP

# Создание HTTP клиента для вашего API
client = httpx.AsyncClient(base_url="https://api.example.com")

# Загрузка OpenAPI спецификации
openapi_spec = httpx.get("https://api.example.com/openapi.json").json()

# Создание MCP сервера
mcp = FastMCP.from_openapi(
    openapi_spec=openapi_spec,
    client=client,
    name="My API Server"
)

if __name__ == "__main__":
    mcp.run()
```

### Что конвертируется автоматически:

1. **Endpoints → Tools**
   - GET /users/{id} → get_users_by_id tool
   - POST /products → create_product tool

2. **Schemas → JSON Schemas**
   - OpenAPI schemas конвертируются в MCP tool schemas

3. **Descriptions → Docstrings**
   - OpenAPI descriptions становятся tool descriptions

### Структура FastMCPOpenAPI

```python
from fastmcp.server.openapi import FastMCPOpenAPI
import httpx

class FastMCPOpenAPI(FastMCP):
    def __init__(self, openapi_spec: dict, client: httpx.AsyncClient, **kwargs):
        # 1. Парсинг OpenAPI spec в HTTP routes
        self._routes = parse_openapi_to_http_routes(openapi_spec)
        
        # 2. Инициализация RequestDirector с openapi-core Spec
        self._spec = Spec.from_dict(openapi_spec)
        self._director = RequestDirector(self._spec)
        
        # 3. Создание компонентов через RequestDirector
        self._create_components()
```

**Преимущества stateless request building:**
- Схемы предварительно рассчитываются
- Быстрая валидация запросов
- Эффективная обработка

### Выполнение OpenAPI операций

```python
# OpenAPI tool автоматически выполняет HTTP запросы
async with client:
    # Вызов tool создает HTTP request по конфигурации route
    result = await client.call_tool("get_user_by_id", {"user_id": 123})
    print(result.content[0].text)
```

### Создание ресурсов из OpenAPI

```python
# OpenAPI resource templates с параметрами
resource = mcp.create_resource(
    uri="api://users/{user_id}/profile",
    params={"user_id": "123"},
    context=ctx
)
```

## Расширенные возможности

### Обработка ошибок HTTP

FastMCP автоматически обрабатывает:
- HTTP status codes → MCP errors
- Структурированные error responses
- Network timeouts и connection errors
- Сохранение error context

```python
from fastmcp.exceptions import ToolError

try:
    result = await client.call_tool("api_operation", {})
except ToolError as e:
    # HTTP ошибки конвертируются в ToolError
    print(f"API error: {e}")
```

### Настройка HTTP клиента

```python
import httpx
from fastmcp import FastMCP

# Кастомный HTTP клиент с расширенными настройками
client = httpx.AsyncClient(
    base_url="https://api.example.com",
    timeout=30.0,
    headers={
        "User-Agent": "FastMCP/2.0",
        "API-Key": "your-api-key"
    },
    verify=True,  # SSL verification
    follow_redirects=True
)

mcp = FastMCP.from_openapi(
    openapi_spec=spec,
    client=client
)
```

### Работа с аутентификацией

```python
# Bearer token authentication
client = httpx.AsyncClient(
    base_url="https://api.example.com",
    headers={
        "Authorization": "Bearer your-access-token"
    }
)

# API Key authentication
client = httpx.AsyncClient(
    base_url="https://api.example.com",
    headers={
        "X-API-Key": "your-api-key"
    }
)

# Basic authentication
import base64

auth_string = base64.b64encode(b"username:password").decode()
client = httpx.AsyncClient(
    base_url="https://api.example.com",
    headers={
        "Authorization": f"Basic {auth_string}"
    }
)

mcp = FastMCP.from_openapi(spec, client=client)
```

### Retry и timeout логика

```python
from httpx import AsyncClient, Timeout

# Настройка timeouts
timeout = Timeout(
    connect=5.0,  # Connection timeout
    read=10.0,    # Read timeout
    write=10.0,   # Write timeout
    pool=5.0      # Pool timeout
)

client = AsyncClient(
    base_url="https://api.example.com",
    timeout=timeout
)

# Retry logic (через httpx transport)
from httpx import HTTPTransport

transport = HTTPTransport(
    retries=3,
)

client = AsyncClient(
    base_url="https://api.example.com",
    transport=transport
)
```

## OpenAPI Experimental Features

FastMCP предоставляет экспериментальный OpenAPI parser с расширенными возможностями.

### Улучшенная обработка ошибок

```python
from fastmcp.experimental.server.openapi import FastMCPOpenAPI

mcp = FastMCPOpenAPI(
    openapi_spec=spec,
    client=client,
    # Расширенная обработка ошибок
    handle_errors=True,
    error_mapping={
        404: "Resource not found",
        401: "Authentication required",
        403: "Access denied"
    }
)
```

### Оптимизация payload handling

- Предварительная валидация параметров
- Эффективная сериализация/десериализация
- Минимальные накладные расходы

### JWT Claims поддержка

```python
# Автоматическая обработка JWT claims из OpenAPI security schemes
mcp = FastMCPOpenAPI(
    openapi_spec=spec,
    client=client,
    jwt_claims_support=True
)
```

## Пример: Полная интеграция

### 1. Существующий REST API

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Task Management API")

class Task(BaseModel):
    id: int
    title: str
    completed: bool = False

tasks_db = {}

@app.get("/tasks")
def list_tasks():
    """Список всех задач."""
    return {"tasks": list(tasks_db.values())}

@app.get("/tasks/{task_id}")
def get_task(task_id: int):
    """Получить задачу по ID."""
    if task_id not in tasks_db:
        raise HTTPException(status_code=404, detail="Task not found")
    return tasks_db[task_id]

@app.post("/tasks")
def create_task(task: Task):
    """Создать новую задачу."""
    tasks_db[task.id] = task
    return task

@app.put("/tasks/{task_id}")
def update_task(task_id: int, task: Task):
    """Обновить существующую задачу."""
    if task_id not in tasks_db:
        raise HTTPException(status_code=404, detail="Task not found")
    tasks_db[task_id] = task
    return task

@app.delete("/tasks/{task_id}")
def delete_task(task_id: int):
    """Удалить задачу."""
    if task_id not in tasks_db:
        raise HTTPException(status_code=404, detail="Task not found")
    del tasks_db[task_id]
    return {"deleted": True}
```

### 2. Конвертация в MCP

```python
from fastmcp import FastMCP

# Конвертация FastAPI в MCP
mcp = FastMCP.from_fastapi(app=app, name="Task Management MCP")

# Добавление дополнительных MCP tools
@mcp.tool
def summarize_tasks() -> dict:
    """Статистика по задачам."""
    total = len(tasks_db)
    completed = sum(1 for t in tasks_db.values() if t.completed)
    return {
        "total": total,
        "completed": completed,
        "pending": total - completed
    }

if __name__ == "__main__":
    mcp.run(transport="http", port=8000)
```

### 3. Использование из LLM

```python
from fastmcp import Client

async def use_task_api():
    client = Client("http://localhost:8000/mcp")
    
    async with client:
        # Список tools
        tools = await client.list_tools()
        print(f"Available: {[t.name for t in tools]}")
        
        # Создание задачи через LLM
        result = await client.call_tool("create_task", {
            "task": {
                "id": 1,
                "title": "Learn FastMCP",
                "completed": False
            }
        })
        
        # Получение статистики
        stats = await client.call_tool("summarize_tasks", {})
        print(stats)
```

## Лучшие практики

### 1. Используйте async clients

```python
# Хорошо
client = httpx.AsyncClient()

# Плохо для FastMCP
client = httpx.Client()  # Синхронный клиент
```

### 2. Управляйте lifecycle клиента

```python
# Хорошо - клиент закрывается автоматически
async with httpx.AsyncClient() as client:
    mcp = FastMCP.from_openapi(spec, client)
    # ...

# Или явное закрытие
client = httpx.AsyncClient()
try:
    mcp = FastMCP.from_openapi(spec, client)
    # ...
finally:
    await client.aclose()
```

### 3. Обрабатывайте ошибки

```python
from fastmcp.exceptions import ToolError

@app.get("/api/data")
def get_data():
    try:
        return fetch_data()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

### 4. Документируйте API

```python
@app.get("/users/{user_id}", 
         summary="Get user by ID",
         description="Retrieves user information by unique identifier",
         response_description="User object with all details")
def get_user(user_id: int):
    """
    Подробное описание endpoint.
    
    - **user_id**: Уникальный идентификатор пользователя
    """
    return user_db[user_id]
```

## Следующие шаги

- [Deployment](./06-deployment-configuration.md) - Развертывание интегрированных API
- [Authentication](./05-authentication.md) - Защита API endpoints
- [Tools](./02-tools.md) - Дополнительные MCP tools
