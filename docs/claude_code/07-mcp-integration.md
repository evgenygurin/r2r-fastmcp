# 07: MCP Integration (Model Context Protocol)

## Обзор

Model Context Protocol (MCP) — это открытый протокол, который позволяет Claude Code взаимодействовать с внешними сервисами и инструментами. MCP расширяет возможности Claude, предоставляя доступ к базам данных, API, файловым системам и другим ресурсам через стандартизированный интерфейс.

## Что такое MCP?

### Ключевые концепции

MCP — это протокол для:
- **Расширения контекста** — доступ к внешним данным
- **Интеграции инструментов** — вызов внешних API
- **Унифицированного интерфейса** — стандартный способ взаимодействия
- **Безопасности** — контроль доступа и OAuth-аутентификация

### Архитектура

```
Claude Code (Client)
    ↓
MCP Protocol
    ↓
MCP Server (GitHub, Filesystem, Database, etc.)
    ↓
External Service/Resource
```

## Конфигурация MCP Servers

### Базовая структура

MCP servers конфигурируются в `settings.json`:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "executable",
      "args": ["arg1", "arg2"],
      "env": {
        "ENV_VAR": "value"
      }
    }
  }
}
```

### Пример: GitHub MCP Server

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"],
      "oauth": {
        "clientId": "your-github-client-id",
        "clientSecret": "your-github-client-secret",
        "scopes": ["repo", "issues", "pull_requests"]
      }
    }
  }
}
```

**Возможности GitHub MCP:**
- Чтение и создание issues
- Управление pull requests
- Доступ к репозиториям
- Работа с комментариями
- Поиск по коду

### Пример: Filesystem MCP Server

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/path/to/allowed/files"
      ]
    }
  }
}
```

**Возможности Filesystem MCP:**
- Чтение файлов вне проекта
- Запись в разрешенные директории
- Навигация по файловой системе
- Безопасный доступ с ограничениями

### Пример: Database MCP Server

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "postgresql://user:pass@localhost:5432/db"
      }
    }
  }
}
```

**Возможности Database MCP:**
- Выполнение SQL-запросов
- Чтение схемы базы данных
- Анализ данных
- Генерация отчетов

## OAuth-аутентификация

### Настройка OAuth

Для сервисов, требующих аутентификации:

```json
{
  "mcpServers": {
    "service-name": {
      "command": "npx",
      "args": ["-y", "@company/mcp-server"],
      "oauth": {
        "clientId": "oauth-client-id",
        "clientSecret": "oauth-client-secret",
        "scopes": ["scope1", "scope2", "scope3"]
      }
    }
  }
}
```

### Типичные scopes

**GitHub:**
```json
"scopes": ["repo", "issues", "pull_requests", "write:discussion"]
```

**Google:**
```json
"scopes": [
  "https://www.googleapis.com/auth/drive.readonly",
  "https://www.googleapis.com/auth/spreadsheets"
]
```

**Slack:**
```json
"scopes": ["channels:read", "chat:write", "files:read"]
```

### Процесс OAuth-авторизации

1. Пользователь упоминает MCP server: `@github`
2. Claude инициирует OAuth flow
3. Браузер открывается для авторизации
4. Пользователь предоставляет разрешения
5. Токен сохраняется в Claude Code
6. MCP server получает доступ к API

## Работа с MCP Servers

### Активация серверов

#### Через @-упоминания

```bash
# Автоматически активирует и включает сервер
@github help

@filesystem list /path/to/directory

@postgres show tables
```

#### Через /mcp команду

```bash
# Управление MCP серверами
/mcp

# Показывает:
# - Список доступных серверов
# - Статус (enabled/disabled)
# - Конфигурацию
# - Опции управления
```

### Включение/отключение

```bash
# В /mcp интерфейсе:
# ✓ github (enabled)
# ☐ filesystem (disabled)

# Переключение checkbox'ов для включения/отключения
```

### Проверка конфигурации

```bash
# Просмотр логов MCP
claude --debug

# Проверка подключения
claude /doctor

# Экспонирование MCP сервера
claude mcp serve
```

## Официальные MCP Servers

### @anthropic-ai/mcp-server-github

**Установка:**
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"]
    }
  }
}
```

**Функции:**
- `search_repositories` — поиск репозиториев
- `create_issue` — создание issues
- `get_pull_request` — получение информации о PR
- `list_commits` — список коммитов
- `create_comment` — комментирование

### @modelcontextprotocol/server-filesystem

**Установка:**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/allowed/path1",
        "/allowed/path2"
      ]
    }
  }
}
```

**Функции:**
- `read_file` — чтение файлов
- `write_file` — запись файлов
- `list_directory` — список файлов в директории
- `get_file_info` — метаданные файла

### @modelcontextprotocol/server-postgres

**Установка:**
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "postgresql://..."
      }
    }
  }
}
```

**Функции:**
- `query` — выполнение SQL
- `list_tables` — список таблиц
- `describe_table` — схема таблицы
- `list_databases` — список БД

## Создание кастомного MCP Server

### Структура проекта

```
my-mcp-server/
├── package.json
├── index.js (или index.ts)
└── README.md
```

### package.json

```json
{
  "name": "@company/mcp-server-custom",
  "version": "1.0.0",
  "main": "index.js",
  "bin": {
    "mcp-server-custom": "./index.js"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.0.0"
  }
}
```

### Базовая реализация

```javascript
#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

// Создание сервера
const server = new Server(
  {
    name: 'custom-server',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
      resources: {},
    },
  }
);

// Регистрация инструментов
server.setRequestHandler('tools/list', async () => {
  return {
    tools: [
      {
        name: 'my_tool',
        description: 'Description of what this tool does',
        inputSchema: {
          type: 'object',
          properties: {
            param1: {
              type: 'string',
              description: 'First parameter',
            },
          },
          required: ['param1'],
        },
      },
    ],
  };
});

// Обработка вызовов инструментов
server.setRequestHandler('tools/call', async (request) => {
  if (request.params.name === 'my_tool') {
    const { param1 } = request.params.arguments;
    
    // Ваша логика
    const result = await doSomething(param1);
    
    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify(result, null, 2),
        },
      ],
    };
  }
  
  throw new Error(`Unknown tool: ${request.params.name}`);
});

// Запуск сервера
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Custom MCP server running on stdio');
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
```

### Регистрация ресурсов

```javascript
// Список ресурсов
server.setRequestHandler('resources/list', async () => {
  return {
    resources: [
      {
        uri: 'custom://resource/1',
        name: 'Resource Name',
        description: 'Resource description',
        mimeType: 'application/json',
      },
    ],
  };
});

// Чтение ресурса
server.setRequestHandler('resources/read', async (request) => {
  const { uri } = request.params;
  
  if (uri === 'custom://resource/1') {
    const data = await fetchResourceData();
    
    return {
      contents: [
        {
          uri,
          mimeType: 'application/json',
          text: JSON.stringify(data, null, 2),
        },
      ],
    };
  }
  
  throw new Error(`Unknown resource: ${uri}`);
});
```

### Использование в Claude Code

```json
{
  "mcpServers": {
    "custom": {
      "command": "npx",
      "args": ["-y", "@company/mcp-server-custom"]
    }
  }
}
```

## Интеграция с популярными сервисами

### Slack MCP Server

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-your-token",
        "SLACK_TEAM_ID": "T1234567"
      }
    }
  }
}
```

**Возможности:**
- Отправка сообщений в каналы
- Чтение истории сообщений
- Управление каналами
- Работа с файлами

### Jira MCP Server

```json
{
  "mcpServers": {
    "jira": {
      "command": "npx",
      "args": ["-y", "@company/mcp-server-jira"],
      "env": {
        "JIRA_URL": "https://your-domain.atlassian.net",
        "JIRA_EMAIL": "your-email@company.com",
        "JIRA_API_TOKEN": "your-api-token"
      }
    }
  }
}
```

**Возможности:**
- Создание и обновление issues
- Поиск по JQL
- Управление спринтами
- Комментирование

### Google Drive MCP Server

```json
{
  "mcpServers": {
    "gdrive": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-gdrive"],
      "oauth": {
        "clientId": "google-client-id",
        "clientSecret": "google-client-secret",
        "scopes": [
          "https://www.googleapis.com/auth/drive.readonly"
        ]
      }
    }
  }
}
```

**Возможности:**
- Чтение документов
- Поиск файлов
- Доступ к shared drives
- Экспорт в различные форматы

## Безопасность MCP

### Enterprise Allowlists

Организации могут ограничить доступные MCP servers:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"]
    }
  },
  "allowedMcpServers": ["github"],
  "blockAllOtherMcpServers": true
}
```

### Ограничение permissions

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/safe/path/only"
      ]
    }
  },
  "permissions": {
    "mcpServers": {
      "filesystem": {
        "allowedPaths": ["/safe/path/only"],
        "deniedPaths": ["/safe/path/only/secrets"]
      }
    }
  }
}
```

### Sandbox mode

```json
{
  "sandbox": {
    "allowUnsandboxedCommands": false
  },
  "mcpServers": {
    "bash": {
      "command": "docker",
      "args": ["run", "--rm", "-i", "mcp-sandbox"]
    }
  }
}
```

## Примеры использования

### Работа с GitHub

```bash
# Создание issue
@github create issue in repo/name with title "Bug: Login fails" and body "Steps to reproduce..."

# Поиск PR
@github show pull request #123 in repo/name

# Комментирование
@github comment on issue #456 with "Fixed in PR #789"
```

### Работа с базой данных

```bash
# Запрос данных
@postgres query "SELECT * FROM users WHERE active = true LIMIT 10"

# Анализ схемы
@postgres describe table users

# Статистика
@postgres show table sizes
```

### Работа с файлами

```bash
# Чтение конфига
@filesystem read /etc/app/config.json

# Запись лога
@filesystem write /var/log/app.log with "Log entry..."

# Список файлов
@filesystem list /home/user/documents
```

## Отладка MCP

### Debug режим

```bash
# Запуск с отладкой
claude --debug

# Просмотр MCP логов
tail -f ~/.claude/debug.log | grep MCP
```

### Тестирование сервера

```bash
# Запуск MCP сервера отдельно
npx @anthropic-ai/mcp-server-github

# Тест подключения
echo '{"jsonrpc":"2.0","method":"initialize","params":{},"id":1}' | npx @anthropic-ai/mcp-server-github
```

### Проверка конфигурации

```bash
# Валидация settings.json
claude /doctor

# Список активных серверов
/mcp
```

## Best Practices

### 1. Минимальные разрешения

```json
// ❌ Плохо: слишком широкие разрешения
{
  "filesystem": {
    "args": ["-y", "@modelcontextprotocol/server-filesystem", "/"]
  }
}

// ✅ Хорошо: конкретные пути
{
  "filesystem": {
    "args": [
      "-y",
      "@modelcontextprotocol/server-filesystem",
      "/home/user/project",
      "/home/user/data"
    ]
  }
}
```

### 2. Безопасное хранение секретов

```bash
# ❌ Плохо: секреты в settings.json
{
  "env": {
    "API_KEY": "secret-key-12345"
  }
}

# ✅ Хорошо: переменные окружения
{
  "env": {
    "API_KEY": "${API_KEY}"
  }
}

# В .env или системных переменных:
export API_KEY=secret-key-12345
```

### 3. OAuth вместо токенов

```json
// ✅ Предпочитайте OAuth для сервисов, которые его поддерживают
{
  "github": {
    "oauth": {
      "clientId": "...",
      "clientSecret": "...",
      "scopes": ["repo"]
    }
  }
}
```

### 4. Версионирование

```json
// Фиксируйте версии для стабильности
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@anthropic-ai/mcp-server-github@1.2.3"
      ]
    }
  }
}
```

### 5. Документирование

```json
{
  "mcpServers": {
    "internal-api": {
      "command": "npx",
      "args": ["-y", "@company/mcp-server"],
      "description": "Internal API for product data",
      "documentation": "https://docs.company.com/mcp",
      "contact": "team@company.com"
    }
  }
}
```

## Продвинутые возможности

### Кастомные протоколы

```javascript
// Регистрация кастомного протокола
server.setRequestHandler('custom/action', async (request) => {
  // Ваша логика
  return { result: 'success' };
});
```

### Streaming responses

```javascript
server.setRequestHandler('tools/call', async (request, { signal }) => {
  const stream = createReadableStream();
  
  return {
    content: [
      {
        type: 'text',
        text: stream,
      },
    ],
  };
});
```

### Error handling

```javascript
server.setRequestHandler('tools/call', async (request) => {
  try {
    const result = await riskyOperation();
    return { content: [{ type: 'text', text: result }] };
  } catch (error) {
    return {
      error: {
        code: 'OPERATION_FAILED',
        message: error.message,
      },
    };
  }
});
```

## Заключение

MCP Integration в Claude Code:
- **Расширяет возможности** через внешние сервисы
- **Стандартизирует интеграции** через единый протокол
- **Обеспечивает безопасность** через OAuth и permissions
- **Упрощает разработку** через готовые серверы
- **Масштабируется** для enterprise-сценариев

MCP превращает Claude Code в универсальный интерфейс к вашей инфраструктуре.

## Дополнительные ресурсы

- [MCP Protocol Specification](https://spec.modelcontextprotocol.io/)
- [MCP SDK Documentation](https://github.com/modelcontextprotocol/sdk)
- [Official MCP Servers](https://github.com/modelcontextprotocol/servers)
- [Claude Code MCP Guide](https://docs.claude.com/en/docs/claude-code/mcp)
