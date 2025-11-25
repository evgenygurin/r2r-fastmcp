# Deployment и Configuration

## Обзор конфигурации

FastMCP поддерживает декларативную конфигурацию через файлы `fastmcp.json`. Это **каноничный и предпочтительный** способ настройки проектов, обеспечивающий единый источник правды для настроек сервера, зависимостей и опций развертывания.

## Концептуальная модель конфигурации

Файл `fastmcp.json` отвечает на три фундаментальных вопроса:

1. **Source** (ГДЕ) - Где находится код вашего сервера?
2. **Environment** (ЧТО) - Какое окружение требуется?
3. **Deployment** (КАК) - Как должен работать сервер?

```
┌─────────────────────────────────────────┐
│         fastmcp.json                    │
├─────────────────────────────────────────┤
│  Source: WHERE is the code?             │
│  ├─ entrypoint: "server.py:mcp"         │
│  └─ path: "./src"                       │
├─────────────────────────────────────────┤
│  Environment: WHAT setup is needed?     │
│  ├─ python: "3.11"                      │
│  └─ dependencies: "requirements.txt"    │
├─────────────────────────────────────────┤
│  Deployment: HOW should it run?         │
│  ├─ host: "0.0.0.0"                     │
│  ├─ port: 8000                          │
│  └─ env: {"API_KEY": "..."}            │
└─────────────────────────────────────────┘
```

## Структура fastmcp.json

### Базовая конфигурация

```json
{
  "source": {
    "entrypoint": "server.py:mcp"
  }
}
```

### Полная конфигурация

```json
{
  "source": {
    "entrypoint": "server.py:mcp",
    "path": "./src",
    "watch": ["*.py", "config/*.json"]
  },
  "environment": {
    "python": "3.11",
    "dependencies": "requirements.txt",
    "system_packages": ["git", "curl"]
  },
  "deployment": {
    "transport": "http",
    "host": "0.0.0.0",
    "port": 8000,
    "env": {
      "API_KEY": "${API_KEY}",
      "DATABASE_URL": "postgresql://localhost/db",
      "ENVIRONMENT": "${ENVIRONMENT}"
    },
    "working_directory": "./app"
  }
}
```

## Source Configuration (ГДЕ)

Source определяет **где** находится код вашего сервера.

### Параметры

```json
{
  "source": {
    "entrypoint": "server.py:mcp",  // Обязательно: файл:объект
    "path": "./src",                // Опционально: путь к коду
    "watch": ["*.py"]               // Опционально: файлы для hot reload
  }
}
```

### Примеры entrypoint

```json
// Простой случай - объект называется 'mcp'
{"entrypoint": "server.py"}

// Специфический объект
{"entrypoint": "server.py:my_server"}

// Вложенная структура
{"entrypoint": "app/main.py:mcp"}
```

## Environment Configuration (ЧТО)

Environment определяет **какое** окружение требуется для работы сервера.

### Python версия

```json
{
  "environment": {
    "python": "3.11"  // Точная версия Python
  }
}
```

### Зависимости

```json
{
  "environment": {
    // Из requirements.txt
    "dependencies": "requirements.txt",
    
    // Или из pyproject.toml
    "dependencies": "pyproject.toml",
    
    // Или напрямую
    "dependencies": ["fastmcp>=2.0", "httpx", "pydantic"]
  }
}
```

### Системные пакеты

```json
{
  "environment": {
    "system_packages": ["git", "curl", "postgresql-client"]
  }
}
```

### Полный пример

```json
{
  "environment": {
    "python": "3.11",
    "dependencies": "requirements.txt",
    "system_packages": ["git"],
    "pip_index_url": "https://pypi.org/simple"
  }
}
```

## Deployment Configuration (КАК)

Deployment определяет **как** ваш сервер должен работать.

### Транспорт

```json
{
  "deployment": {
    "transport": "http"  // или "stdio"
  }
}
```

### Сеть

```json
{
  "deployment": {
    "host": "0.0.0.0",  // Слушать на всех интерфейсах
    "port": 8000,       // Порт для HTTP сервера
    "path": "/mcp"      // URL путь для HTTP endpoint
  }
}
```

### Environment Variables

```json
{
  "deployment": {
    "env": {
      "API_KEY": "secret-key",
      "DATABASE_URL": "postgresql://localhost/mydb",
      "DEBUG": "true"
    }
  }
}
```

### Интерполяция переменных окружения

FastMCP поддерживает интерполяцию переменных через синтаксис `${VAR_NAME}`:

```json
{
  "deployment": {
    "env": {
      "API_URL": "https://api.${ENVIRONMENT}.example.com",
      "DB_HOST": "${DB_HOST}",
      "DB_USER": "${DB_USER}",
      "DB_PASSWORD": "${DB_PASSWORD}"
    }
  }
}
```

**Преимущества интерполяции:**
- Одна конфигурация для dev/staging/production
- Чувствительные данные вне файлов
- Динамические URL и connection strings
- Environment-специфичные префиксы

### Рабочая директория

```json
{
  "deployment": {
    "working_directory": "./app"
  }
}
```

## Запуск с fastmcp.json

### Основная команда

```bash
fastmcp run fastmcp.json
```

### Переопределение параметров через CLI

```bash
# Переопределение порта
fastmcp run fastmcp.json --port 9000

# Переопределение host
fastmcp run fastmcp.json --host 127.0.0.1

# Переопределение transport
fastmcp run fastmcp.json --transport stdio
```

### С переменными окружения

```bash
# Установка переменных для интерполяции
export ENVIRONMENT=production
export DB_HOST=prod-db.example.com
export API_KEY=prod-secret-key

fastmcp run fastmcp.json
```

## FastMCP Cloud

FastMCP Cloud — бесплатный хостинг для персональных серверов от команды Prefect.

### Шаг 1: Создание проекта

1. Посетите [fastmcp.cloud](https://fastmcp.cloud)
2. Войдите через GitHub
3. Создайте проект из вашего репозитория

### Шаг 2: Конфигурация

На экране конфигурации укажите:

- **Name**: Имя проекта (используется в URL)
  ```
  Пример: my-awesome-server
  URL: https://my-awesome-server.fastmcp.app/mcp
  ```

- **Entrypoint**: Python файл с сервером
  ```
  Примеры:
  - server.py
  - server.py:my_mcp
  - app/main.py:mcp
  ```

- **Authentication**: 
  - **Disabled**: Публичный доступ
  - **Enabled**: Только члены вашей организации

### Шаг 3: Развертывание

FastMCP Cloud автоматически:
- Определяет зависимости из `requirements.txt` или `pyproject.toml`
- Создает изолированное Python окружение
- Развертывает ваш сервер
- Генерирует HTTPS URL

### Шаг 4: Подключение

```python
from fastmcp import Client

client = Client("https://my-awesome-server.fastmcp.app/mcp")

async with client:
    result = await client.call_tool("my_tool", {})
```

### Настройка CI/CD

FastMCP Cloud интегрируется с GitHub:

```yaml
# .github/workflows/deploy.yml
name: Deploy to FastMCP Cloud

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy
        run: |
          # FastMCP Cloud автоматически подхватит изменения
          echo "Deployed to FastMCP Cloud"
```

## HTTP Deployment

### Базовый HTTP сервер

```python
from fastmcp import FastMCP

mcp = FastMCP("My Server")

if __name__ == "__main__":
    mcp.run(transport="http", host="0.0.0.0", port=8000)
```

### HTTP с HTTPS (SSL)

```python
import ssl

# Создание SSL context
ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ssl_context.load_cert_chain('cert.pem', 'key.pem')

mcp.run(
    transport="http",
    host="0.0.0.0",
    port=443,
    ssl_context=ssl_context
)
```

### HTTP с path prefix

```python
# Сервер будет доступен по http://localhost:8000/api/mcp
mcp.run(
    transport="http",
    host="0.0.0.0",
    port=8000,
    path="/api/mcp"
)
```

### HTTP с CORS

```python
from starlette.middleware import Middleware
from starlette.middleware.cors import CORSMiddleware

middleware = [
    Middleware(
        CORSMiddleware,
        allow_origins=["https://myapp.com"],
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

## Stdio Deployment

Stdio - традиционный способ для локальных MCP серверов.

```python
from fastmcp import FastMCP

mcp = FastMCP("Local Server")

if __name__ == "__main__":
    mcp.run(transport="stdio")
```

### Использование в MCP конфигурации клиента

```json
{
  "mcpServers": {
    "my-server": {
      "command": "python",
      "args": ["path/to/server.py"]
    }
  }
}
```

## Docker Deployment

### Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Копирование зависимостей
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование кода
COPY . .

# Expose порт
EXPOSE 8000

# Запуск сервера
CMD ["python", "server.py"]
```

### docker-compose.yml

```yaml
version: '3.8'

services:
  fastmcp-server:
    build: .
    ports:
      - "8000:8000"
    environment:
      - API_KEY=${API_KEY}
      - DATABASE_URL=${DATABASE_URL}
    volumes:
      - ./data:/app/data
    restart: unless-stopped
```

### Запуск

```bash
docker-compose up -d
```

## Kubernetes Deployment

### deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastmcp-server
spec:
  replicas: 3
  selector:
    matchLabels:
      app: fastmcp-server
  template:
    metadata:
      labels:
        app: fastmcp-server
    spec:
      containers:
      - name: fastmcp
        image: myregistry/fastmcp-server:latest
        ports:
        - containerPort: 8000
        env:
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: fastmcp-secrets
              key: api-key
---
apiVersion: v1
kind: Service
metadata:
  name: fastmcp-service
spec:
  selector:
    app: fastmcp-server
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
  type: LoadBalancer
```

## Production Best Practices

### 1. Используйте переменные окружения

```json
{
  "deployment": {
    "env": {
      "DATABASE_URL": "${DATABASE_URL}",
      "SECRET_KEY": "${SECRET_KEY}",
      "ENVIRONMENT": "${ENVIRONMENT}"
    }
  }
}
```

### 2. Логирование

```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

mcp = FastMCP("Production Server")
```

### 3. Health checks

```python
@mcp.tool
async def health_check() -> dict:
    """Health check endpoint."""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat()
    }
```

### 4. Мониторинг

```python
from prometheus_client import Counter, Histogram

tool_calls = Counter('mcp_tool_calls_total', 'Total tool calls')
tool_duration = Histogram('mcp_tool_duration_seconds', 'Tool execution time')

@mcp.tool
async def monitored_tool(data: str) -> str:
    tool_calls.inc()
    with tool_duration.time():
        return process_data(data)
```

### 5. Graceful shutdown

```python
import signal
import sys

def signal_handler(sig, frame):
    print('Shutting down gracefully...')
    # Cleanup code
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)
```

## Масштабирование

### Горизонтальное масштабирование

```yaml
# kubernetes
spec:
  replicas: 5  # Множественные инстансы
  
  # Load balancer распределяет запросы
```

### Вертикальное масштабирование

```python
# Увеличение ресурсов для инстанса
# CPU, Memory limits в Kubernetes/Docker
```

## Следующие шаги

- [Middleware](./07-middleware-error-handling.md) - Обработка запросов
- [Authentication](./05-authentication.md) - Защита production серверов
- [FastAPI Integration](./08-fastapi-openapi.md) - Интеграция с существующими API
