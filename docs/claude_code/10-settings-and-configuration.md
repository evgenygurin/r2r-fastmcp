# 10: Settings и Configuration

## Обзор

Claude Code предоставляет обширные возможности настройки через файл `settings.json`, переменные окружения и runtime параметры. Это позволяет адаптировать поведение инструмента под специфические требования проекта, команды или организации.

## Файл settings.json

### Расположение

```bash
# Глобальные настройки
~/.claude/settings.json

# Настройки проекта (приоритет выше)
.claude/settings.json

# Настройки команды/организации
/team/shared/.claude/settings.json
```

### Полная структура

```json
{
  "permissions": {
    "allowedTools": [
      "Read(**/*.{js,ts,json,md})",
      "Edit(**/*.{js,ts})",
      "Bash(git:*)",
      "Bash(npm:*)"
    ],
    "deniedTools": [
      "Edit(/config/secrets.json)",
      "Bash(rm -rf:*)"
    ]
  },
  "permissionMode": "acceptEdits",
  "spinnerTipsEnabled": true,
  "hooks": {
    "PreToolUse": [],
    "PostToolUse": [],
    "SessionStart": []
  },
  "statusLine": {
    "enabled": true,
    "format": "{{model}} | {{tokens}}"
  },
  "sandbox": {
    "allowUnsandboxedCommands": false
  },
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"],
      "oauth": {
        "clientId": "your-client-id",
        "clientSecret": "your-client-secret",
        "scopes": ["repo", "issues"]
      }
    }
  },
  "extraKnownMarketplaces": [
    {
      "name": "company-plugins",
      "url": "https://github.com/your-org/claude-plugins"
    }
  ],
  "companyAnnouncements": {
    "enabled": true,
    "message": "Welcome! Check our internal docs..."
  }
}
```

## Permissions (Разрешения)

### allowedTools

Разрешенные инструменты с glob patterns:

```json
{
  "permissions": {
    "allowedTools": [
      // Чтение файлов
      "Read(**/*.js)",
      "Read(**/*.ts)",
      "Read(**/*.json)",
      
      // Редактирование
      "Edit(**/*.js)",
      "Edit(**/*.ts)",
      
      // Bash команды
      "Bash(git:*)",
      "Bash(npm:*)",
      "Bash(node:*)",
      "Bash(python:*)",
      
      // Глобальные
      "Glob(**/*)",
      "Grep(**/*)"
    ]
  }
}
```

### deniedTools

Запрещенные инструменты (приоритет выше):

```json
{
  "permissions": {
    "deniedTools": [
      // Запрет редактирования критичных файлов
      "Edit(/config/production.json)",
      "Edit(**/.env)",
      "Edit(**/secrets.json)",
      
      // Запрет опасных команд
      "Bash(rm -rf:*)",
      "Bash(sudo:*)",
      "Bash(chmod:*)",
      
      // Запрет сетевых операций
      "Bash(curl:*)",
      "Bash(wget:*)"
    ]
  }
}
```

### permissionMode

Режимы работы с permissions:

```json
{
  "permissionMode": "acceptEdits"  // Значение по умолчанию
}
```

**Опции:**
- `"acceptEdits"` — автоматически принимать правки
- `"manual"` — спрашивать подтверждение каждый раз
- `"strict"` — разрешать только явно указанные в allowedTools

## Sandbox Mode

### Базовая конфигурация

```json
{
  "sandbox": {
    "allowUnsandboxedCommands": false
  }
}
```

**Возможности Sandbox:**
- Изоляция выполнения команд (Linux/Mac)
- Контроль доступа к файловой системе
- Ограничение сетевых операций
- Безопасное выполнение ненадежного кода

**Когда использовать:**
- Работа с ненадежным кодом
- Enterprise окружения
- Строгие security требования
- CI/CD pipelines

## Hooks Configuration

### Типы hooks

```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "echo 'Session started'"
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 /path/to/validator.py"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint"
          }
        ]
      }
    ]
  }
}
```

### Примеры hooks

**Валидация bash команд:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/bash-validator.py"
          }
        ]
      }
    ]
  }
}
```

**Автоматический линтинг:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "eslint --fix"
          }
        ]
      }
    ]
  }
}
```

**Session initialization:**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "git fetch origin"
      },
      {
        "type": "command",
        "command": "npm install"
      }
    ]
  }
}
```

## Status Line

### Конфигурация

```json
{
  "statusLine": {
    "enabled": true,
    "format": "{{model}} | {{tokens}} | {{cost}}"
  }
}
```

**Доступные переменные:**
- `{{model}}` — текущая модель
- `{{tokens}}` — использованные токены
- `{{cost}}` — стоимость запроса
- `{{time}}` — время выполнения
- `{{files}}` — количество файлов в контексте

**Примеры:**
```json
// Минималистичный
{"format": "{{model}}"}

// Детальный
{"format": "Model: {{model}} | Tokens: {{tokens}} | Cost: ${{cost}} | Time: {{time}}s"}

// С Unicode
{"format": "🤖 {{model}} | 📊 {{tokens}} | 💰 ${{cost}}"}
```

## MCP Servers Configuration

### Базовая структура

```json
{
  "mcpServers": {
    "server-name": {
      "command": "executable",
      "args": ["arg1", "arg2"],
      "env": {
        "ENV_VAR": "value"
      },
      "oauth": {
        "clientId": "id",
        "clientSecret": "secret",
        "scopes": ["scope1"]
      }
    }
  }
}
```

### Примеры конфигураций

**GitHub:**
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"],
      "oauth": {
        "clientId": "${GITHUB_CLIENT_ID}",
        "clientSecret": "${GITHUB_CLIENT_SECRET}",
        "scopes": ["repo", "issues"]
      }
    }
  }
}
```

**Filesystem:**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/home/user/documents",
        "/home/user/projects"
      ]
    }
  }
}
```

**Database:**
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "${DATABASE_URL}"
      }
    }
  }
}
```

## Plugin Marketplaces

### Конфигурация

```json
{
  "extraKnownMarketplaces": [
    {
      "name": "company-plugins",
      "url": "https://github.com/company/claude-plugins",
      "description": "Internal company plugins"
    },
    {
      "name": "team-plugins",
      "url": "https://github.com/team/plugins",
      "auth": {
        "type": "token",
        "token": "${PLUGIN_REPO_TOKEN}"
      }
    }
  ]
}
```

## Company Announcements

### Конфигурация

```json
{
  "companyAnnouncements": {
    "enabled": true,
    "message": "Welcome to Company Claude Code!\n\nImportant links:\n- Docs: https://docs.company.com/claude\n- Support: #claude-support\n- Guidelines: CLAUDE.md in each repo",
    "showOnStartup": true
  }
}
```

## Environment Variables

### API Keys

```bash
# Anthropic
export ANTHROPIC_API_KEY=sk-ant-...

# OpenAI (альтернатива)
export OPENAI_API_KEY=sk-...

# AWS Bedrock
export AWS_REGION=us-west-2
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...

# Google Vertex
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
export GOOGLE_CLOUD_PROJECT=project-id
export GOOGLE_CLOUD_LOCATION=us-central1
```

### Claude Code Settings

```bash
# Модель по умолчанию
export ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-5

# Bash настройки
export CLAUDE_BASH_NO_LOGIN=1

# Proxy
export NO_PROXY=localhost,127.0.0.1
export HTTP_PROXY=http://proxy:8080
export HTTPS_PROXY=http://proxy:8080

# Отключение фоновых операций
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
export DISABLE_AUTOUPDATER=1

# SDK mode
export CLAUDE_CODE_EXIT_AFTER_STOP_DELAY=5000
```

### Использование в командной строке

```bash
# Запуск с определенным API key
ANTHROPIC_API_KEY=sk-ant-... claude

# Запуск с бюджетом
claude --max-budget-usd 10.00

# Запуск с определенной моделью
claude --model claude-opus-4

# Debug режим
claude --debug
```

## Runtime Configuration

### Командная строка

```bash
# Выбор модели
claude --model claude-sonnet-4-5

# Установка бюджета
claude --max-budget-usd 50.00

# Debug режим
claude --debug

# Headless режим (без интерактивности)
claude --headless "Task description"

# SDK mode
claude --sdk-mode
```

### В сессии

```bash
# Переключение модели
/model

# Просмотр контекста
/context

# Управление памятью
/memory

# MCP серверы
/mcp

# Plugins
/plugin list
```

## Профили конфигурации

### Создание профилей

```bash
~/.claude/
├── settings.json              # Default
├── settings.production.json   # Production
├── settings.development.json  # Development
└── settings.strict.json       # Strict security
```

### Использование профилей

```bash
# Через symlink
ln -sf ~/.claude/settings.production.json ~/.claude/settings.json

# Через переменную окружения
export CLAUDE_CONFIG=~/.claude/settings.production.json
claude

# Через аргумент
claude --config ~/.claude/settings.production.json
```

### Пример: Development Profile

```json
{
  "permissions": {
    "allowedTools": ["*"]
  },
  "permissionMode": "acceptEdits",
  "sandbox": {
    "allowUnsandboxedCommands": true
  }
}
```

### Пример: Production Profile

```json
{
  "permissions": {
    "allowedTools": [
      "Read(**/*.{js,ts})",
      "Bash(git:status)",
      "Bash(git:log)"
    ],
    "deniedTools": [
      "Edit(**/*)",
      "Bash(rm:*)",
      "Bash(sudo:*)"
    ]
  },
  "permissionMode": "manual",
  "sandbox": {
    "allowUnsandboxedCommands": false
  }
}
```

### Пример: Strict Security Profile

```json
{
  "permissions": {
    "allowedTools": [
      "Read(src/**/*.{js,ts})"
    ],
    "deniedTools": [
      "Edit(**/*)",
      "Bash(*)"
    ]
  },
  "permissionMode": "strict",
  "sandbox": {
    "allowUnsandboxedCommands": false
  },
  "mcpServers": {},
  "spinnerTipsEnabled": false
}
```

## Best Practices

### 1. Используйте переменные окружения для секретов

```json
// ❌ Плохо
{
  "mcpServers": {
    "github": {
      "oauth": {
        "clientSecret": "actual-secret-here"
      }
    }
  }
}

// ✅ Хорошо
{
  "mcpServers": {
    "github": {
      "oauth": {
        "clientSecret": "${GITHUB_CLIENT_SECRET}"
      }
    }
  }
}
```

### 2. Специфичные permissions

```json
// ❌ Плохо: слишком широко
{
  "permissions": {
    "allowedTools": ["*"]
  }
}

// ✅ Хорошо: конкретно
{
  "permissions": {
    "allowedTools": [
      "Read(src/**/*.{js,ts})",
      "Edit(src/**/*.{js,ts})",
      "Bash(npm:test)",
      "Bash(git:*)"
    ]
  }
}
```

### 3. Используйте hooks для автоматизации

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {"type": "command", "command": "npm run lint:fix"},
          {"type": "command", "command": "npm run format"}
        ]
      }
    ]
  }
}
```

### 4. Документируйте настройки

```json
{
  "_comment": "Company Claude Code Configuration",
  "_author": "DevOps Team",
  "_lastUpdated": "2025-01-15",
  "_documentation": "https://docs.company.com/claude-config",
  
  "permissions": {
    "_comment": "Restricted to source code only",
    "allowedTools": ["Read(src/**/*.{js,ts})"]
  }
}
```

### 5. Version control для команды

```bash
# В репозитории проекта
.claude/
├── settings.json          # Настройки проекта
├── README.md             # Документация настроек
└── .gitignore            # Исключить локальные override'ы

# .gitignore
.claude/settings.local.json
.claude/.env
```

## Troubleshooting

### Настройки не применяются

```bash
# Проверка какой конфиг используется
claude --debug
# Смотрите в логах "Loading config from..."

# Валидация JSON
jq . ~/.claude/settings.json

# Проверка прав доступа
ls -la ~/.claude/settings.json
```

### Permission errors

```bash
# Проверка текущих permissions
# В Claude session:
"What are my current permissions?"

# Проверка в settings
cat ~/.claude/settings.json | jq '.permissions'
```

### MCP servers не работают

```bash
# Тест MCP сервера
npx @anthropic-ai/mcp-server-github

# Проверка конфигурации
cat ~/.claude/settings.json | jq '.mcpServers'

# Debug режим
claude --debug
# Смотрите MCP-related логи
```

## Заключение

Правильная конфигурация Claude Code:
- **Повышает безопасность** через permissions
- **Автоматизирует workflow** через hooks
- **Интегрирует с инфраструктурой** через MCP
- **Масштабируется** от личного до enterprise
- **Адаптируется** под специфические требования

## Дополнительные ресурсы

- [Configuration Guide](https://docs.claude.com/en/docs/claude-code/configuration)
- [Permissions Reference](https://docs.claude.com/en/docs/claude-code/permissions)
- [Hooks Documentation](https://docs.claude.com/en/docs/claude-code/hooks)
- [MCP Configuration](https://docs.claude.com/en/docs/claude-code/mcp)
