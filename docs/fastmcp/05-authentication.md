# Authentication и Security

## Обзор аутентификации в FastMCP

FastMCP поддерживает корпоративную аутентификацию с **нулевой конфигурацией** для популярных провайдеров. Аутентификация **крайне рекомендуется** для удаленных MCP серверов, а некоторые LLM клиенты требуют её обязательно.

## Зачем нужна аутентификация?

- **Безопасность**: Защита от несанкционированного доступа
- **Контроль доступа**: Управление тем, кто может вызывать tools и читать resources
- **Аудит**: Отслеживание, кто и когда использовал сервер
- **Требования клиентов**: Некоторые LLM клиенты отказываются подключаться без аутентификации

## JWT Token Verification

FastMCP поддерживает проверку JWT токенов от внешних identity провайдеров.

### Что такое JWT?

JWT (JSON Web Token) — это стандарт для безопасной передачи информации между сторонами в виде JSON объекта. Токен содержит:
- **Header**: Тип токена и алгоритм подписи
- **Payload**: Claims (утверждения) о пользователе
- **Signature**: Цифровая подпись для проверки подлинности

### Асимметричная верификация (RSA/ECDSA)

Используется для токенов от внешних сервисов (Auth0, Okta, Azure AD).

#### Через JWKS endpoint

```python
from fastmcp import FastMCP
from fastmcp.server.auth.providers import JWTVerifier

# Создание JWT верификатора с JWKS
auth_provider = JWTVerifier(
    jwks_url="https://your-domain.auth0.com/.well-known/jwks.json",
    issuer="https://your-domain.auth0.com/",
    audience="your-api-identifier",
    algorithms=["RS256"],  # Поддержка RSA алгоритмов
    required_scopes=["read:data", "write:data"]  # Опционально
)

# Создание аутентифицированного сервера
mcp = FastMCP("Secure Server", auth_provider=auth_provider)
```

**Преимущества JWKS:**
- Автоматическая ротация ключей
- Не нужно хранить публичные ключи в коде
- Работает с большинством OAuth провайдеров
- Подходит для production

#### С явным публичным ключом

```python
PUBLIC_KEY = """-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
-----END PUBLIC KEY-----"""

auth_provider = JWTVerifier(
    public_key=PUBLIC_KEY,
    issuer="https://your-domain.auth0.com/",
    audience="your-api-identifier",
    algorithms=["RS256"]
)

mcp = FastMCP("Secure Server", auth_provider=auth_provider)
```

### Симметричная верификация (HMAC)

Используется для внутренних микросервисов, где секрет может быть безопасно распределен.

```python
from fastmcp.server.auth.providers import JWTVerifier

# HMAC верификация с общим секретом
auth_provider = JWTVerifier(
    public_key="your-shared-secret-key-min-32-chars",  # Параметр назван public_key для обратной совместимости
    algorithms=["HS256"],  # или HS384, HS512
    issuer="your-service",
    audience="internal-services"
)

mcp = FastMCP("Internal Service", auth_provider=auth_provider)
```

**Важно для HMAC:**
- Используйте сильный секрет (минимум 32 символа)
- Никогда не публикуйте секрет в логах или version control
- Реализуйте безопасную ротацию ключей
- Рассмотрите асимметричные ключи для внешних API

**Преимущества HMAC:**
- Простота управления
- Быстрее RSA
- Хорошо подходит для микросервисной аутентификации

## Конфигурация через переменные окружения

FastMCP поддерживает конфигурацию аутентификации через environment variables.

### JWT через переменные окружения

```bash
# Асимметричная верификация (JWKS)
export FASTMCP_AUTH_ENABLED=true
export FASTMCP_AUTH_JWKS_URL=https://your-domain.auth0.com/.well-known/jwks.json
export FASTMCP_AUTH_ISSUER=https://your-domain.auth0.com/
export FASTMCP_AUTH_AUDIENCE=your-api-identifier
export FASTMCP_AUTH_ALGORITHMS=RS256,RS384
export FASTMCP_AUTH_REQUIRED_SCOPES=read:data,write:data

# Симметричная верификация (HMAC)
export FASTMCP_AUTH_ENABLED=true
export FASTMCP_AUTH_SECRET_KEY=your-shared-secret-key-min-32-chars
export FASTMCP_AUTH_ALGORITHMS=HS256
export FASTMCP_AUTH_ISSUER=your-service
export FASTMCP_AUTH_AUDIENCE=internal-services
```

Затем просто создайте сервер:

```python
from fastmcp import FastMCP

# Аутентификация автоматически настраивается из environment variables
mcp = FastMCP("Auto-Auth Server")
```

**Преимущества environment configuration:**
- Разделение настроек от кода
- Следование twelve-factor app принципам
- Упрощение deployment pipelines
- Один код для разных окружений

## OAuth 2.0 провайдеры

FastMCP предоставляет готовые интеграции с популярными OAuth провайдерами.

### AWS Cognito

```python
from fastmcp import FastMCP
from fastmcp.server.auth.providers import AWSCognitoProvider

# Настройка AWS Cognito
auth_provider = AWSCognitoProvider(
    user_pool_id="us-east-1_XXXXXXXXX",
    region="us-east-1",
    client_id="your-app-client-id",
    client_secret="your-app-client-secret",  # Опционально
    redirect_uri="http://localhost:8000/callback"  # Для OAuth flow
)

mcp = FastMCP("Cognito Protected Server", auth_provider=auth_provider)
```

### Google OAuth

```python
from fastmcp.server.auth.providers import GoogleOAuthProvider

auth_provider = GoogleOAuthProvider(
    client_id="your-google-client-id.apps.googleusercontent.com",
    client_secret="your-google-client-secret",
    redirect_uri="http://localhost:8000/callback"
)

mcp = FastMCP("Google Auth Server", auth_provider=auth_provider)
```

### GitHub OAuth

```python
from fastmcp.server.auth.providers import GitHubOAuthProvider

auth_provider = GitHubOAuthProvider(
    client_id="your-github-client-id",
    client_secret="your-github-client-secret",
    redirect_uri="http://localhost:8000/callback"
)

mcp = FastMCP("GitHub Auth Server", auth_provider=auth_provider)
```

### Другие провайдеры

FastMCP также поддерживает:
- **WorkOS**
- **Azure AD** (Microsoft)
- **Auth0**
- **Scalekit**
- Любой OAuth 2.0 совместимый провайдер

## OAuth Proxy Pattern

Для провайдеров, не поддерживающих Dynamic Client Registration, используйте OAuth Proxy.

```python
from fastmcp import FastMCP
from fastmcp.server.auth import OAuthProxy

# Настройка OAuth Proxy для AWS Cognito
oauth_proxy = OAuthProxy(
    authorization_endpoint="https://your-domain.auth.us-east-1.amazoncognito.com/oauth2/authorize",
    token_endpoint="https://your-domain.auth.us-east-1.amazoncognito.com/oauth2/token",
    client_id="your-cognito-app-client-id",
    client_secret="your-cognito-app-client-secret",
    scopes=["openid", "profile", "email"]
)

# JWT верификатор для валидации токенов
jwt_verifier = JWTVerifier(
    jwks_url="https://cognito-idp.us-east-1.amazonaws.com/us-east-1_XXXXX/.well-known/jwks.json",
    issuer="https://cognito-idp.us-east-1.amazonaws.com/us-east-1_XXXXX",
    audience="your-cognito-app-client-id"
)

mcp = FastMCP(
    "Cognito with OAuth Proxy",
    auth_provider=jwt_verifier,
    oauth_proxy=oauth_proxy
)
```

## AccessToken и Claims

### Доступ к токену в tools

```python
from fastmcp import Context
from fastmcp.server.auth import AccessToken

@mcp.tool
async def protected_tool(data: str, ctx: Context) -> str:
    """Инструмент с доступом к токену пользователя."""
    
    # Получение access token
    token: AccessToken = ctx.access_token
    
    if token:
        print(f"User ID: {token.sub}")
        print(f"Scopes: {token.scopes}")
        print(f"Email: {token.get('email')}")
        print(f"Name: {token.get('name')}")
    
    return f"Processing {data} for user {token.sub if token else 'anonymous'}"
```

### Структура AccessToken

```python
class AccessToken:
    # Стандартные JWT claims
    sub: str          # Subject (user ID)
    iss: str          # Issuer
    aud: str          # Audience
    exp: int          # Expiration time
    iat: int          # Issued at
    scopes: List[str] # OAuth scopes
    
    # Метод для доступа к custom claims
    def get(self, key: str, default=None):
        pass
```

## Middleware для аутентификации

Вы можете добавить дополнительные проверки через middleware.

```python
from fastmcp.server.middleware import Middleware, MiddlewareContext
from fastmcp.exceptions import ToolError

class ScopeCheckMiddleware(Middleware):
    async def on_call_tool(self, context: MiddlewareContext, call_next):
        if context.fastmcp_context and context.fastmcp_context.request_context:
            access_token = context.fastmcp_context.request_context.access_token
            
            if access_token:
                # Проверка наличия требуемого scope
                if "admin" not in access_token.scopes:
                    raise ToolError("Admin scope required for this tool")
        
        return await call_next(context)

mcp.add_middleware(ScopeCheckMiddleware())
```

## Подключение с аутентификацией из клиента

### Bearer Token

```python
from fastmcp import Client
from fastmcp.client.transports import StreamableHttpTransport

# Подключение с Bearer токеном
transport = StreamableHttpTransport(
    url="https://api.example.com/mcp",
    headers={
        "Authorization": "Bearer your-jwt-token-here"
    }
)

client = Client(transport)

async with client:
    result = await client.call_tool("protected_tool", {})
```

### OAuth Flow

```python
# Для OAuth провайдеров клиенты обычно получают токен через OAuth flow
# и затем используют его в headers

# 1. Пользователь проходит OAuth авторизацию
# 2. Получает access_token
# 3. Использует токен для подключения

transport = StreamableHttpTransport(
    url="https://api.example.com/mcp",
    headers={
        "Authorization": f"Bearer {access_token}"
    }
)
```

## Лучшие практики безопасности

### 1. Используйте HTTPS в продакшн

```python
# Хорошо
mcp.run(transport="http", host="0.0.0.0", port=443, ssl_context=ssl_context)

# Плохо для продакшн
mcp.run(transport="http", host="0.0.0.0", port=8000)
```

### 2. Ротация секретов

```python
# Периодически меняйте секреты
# Используйте secrets management системы (AWS Secrets Manager, HashiCorp Vault)

import os
from datetime import datetime, timedelta

def get_current_secret():
    # Загрузка секрета из защищенного хранилища
    return os.environ.get("CURRENT_SECRET_KEY")
```

### 3. Минимальные permissions

```python
# Требуйте только необходимые scopes
auth_provider = JWTVerifier(
    jwks_url="...",
    required_scopes=["read:data"]  # Только чтение, не write
)
```

### 4. Валидация на уровне инструментов

```python
@mcp.tool
async def admin_operation(ctx: Context) -> str:
    """Административная операция."""
    token = ctx.access_token
    
    if not token or "admin" not in token.scopes:
        raise ToolError("Admin access required")
    
    # Выполнение операции
    return "Admin operation completed"
```

### 5. Логирование и мониторинг

```python
import logging

@mcp.tool
async def sensitive_operation(data: str, ctx: Context) -> str:
    """Чувствительная операция с логированием."""
    token = ctx.access_token
    
    logging.info(
        f"User {token.sub if token else 'anonymous'} "
        f"called sensitive_operation"
    )
    
    # Операция
    return "Done"
```

## Обработка ошибок аутентификации

### Сетевые проблемы с identity provider

```python
from fastmcp.server.auth.providers import JWTVerifier
import httpx

auth_provider = JWTVerifier(
    jwks_url="https://your-idp.com/.well-known/jwks.json",
    issuer="https://your-idp.com/",
    # Добавление timeout и retry логики
    http_client=httpx.AsyncClient(timeout=5.0)
)
```

### Graceful degradation

```python
@mcp.tool
async def flexible_tool(ctx: Context) -> str:
    """Инструмент с graceful degradation."""
    token = ctx.access_token
    
    if token:
        # Полная функциональность для аутентифицированных
        return await get_full_data(token.sub)
    else:
        # Ограниченная функциональность для анонимных
        return await get_public_data()
```

## Тестирование аутентификации

### Mock токены для тестов

```python
import pytest
from fastmcp import FastMCP, Client
from fastmcp.server.auth import AccessToken

@pytest.fixture
def mock_auth_server():
    # Создание сервера с mock аутентификацией
    mcp = FastMCP("Test Server")
    
    @mcp.tool
    async def protected_tool(ctx: Context) -> str:
        token = ctx.access_token
        return f"User: {token.sub if token else 'anonymous'}"
    
    return mcp

@pytest.mark.asyncio
async def test_with_mock_token(mock_auth_server):
    # Тестирование с mock токеном
    client = Client(mock_auth_server)
    
    async with client:
        result = await client.call_tool("protected_tool", {})
        assert "User:" in result.content[0].text
```

## Следующие шаги

- [Deployment](./06-deployment-configuration.md) - Развертывание с аутентификацией
- [Middleware](./07-middleware-error-handling.md) - Дополнительные проверки
- [Client](./04-client-connection.md) - Подключение с токенами
