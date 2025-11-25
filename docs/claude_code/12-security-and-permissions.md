# 12: Security и Permissions

## Обзор

Claude Code предоставляет комплексную систему безопасности с fine-grained контролем доступа, sandbox режимом и enterprise-grade защитой. Это делает инструмент подходящим как для индивидуальной разработки, так и для строгих корпоративных сред.

## Система Permissions

### Концепция

Permissions контролируют какие инструменты Claude может использовать и к каким файлам/командам имеет доступ.

### Структура разрешений

```json
{
  "permissions": {
    "allowedTools": [
      "Read(**/*.{js,ts,json})",
      "Edit(**/*.{js,ts})",
      "Bash(git:*)",
      "Bash(npm:*)"
    ],
    "deniedTools": [
      "Edit(/config/secrets.json)",
      "Bash(rm -rf:*)"
    ]
  },
  "permissionMode": "acceptEdits"
}
```

### allowedTools

**Паттерны для инструментов:**

#### Read Tool
```json
{
  "allowedTools": [
    "Read(**/*.js)",           // Все JS файлы
    "Read(src/**/*)",          // Всё в src/
    "Read(**/*.{js,ts})",      // JS и TS файлы
    "Read(/config/app.json)"   // Конкретный файл
  ]
}
```

#### Edit Tool
```json
{
  "allowedTools": [
    "Edit(**/*.js)",           // Редактирование JS
    "Edit(src/**/*.ts)",       // TS в src/
    "Edit(**/test/*.spec.js)"  // Тестовые файлы
  ]
}
```

#### Bash Tool
```json
{
  "allowedTools": [
    "Bash(git:*)",            // Все git команды
    "Bash(npm:test)",         // Только npm test
    "Bash(npm:run build)",    // npm run build
    "Bash(node:scripts/*.js)" // Node скрипты
  ]
}
```

#### Другие Tools
```json
{
  "allowedTools": [
    "Glob(**/*.js)",          // Поиск файлов
    "Grep(src/**/*)",         // Поиск в src/
    "Write(/tmp/**/*)",       // Запись во временные
    "Task(*)"                 // Субагенты (осторожно!)
  ]
}
```

### deniedTools

Приоритет выше чем allowedTools:

```json
{
  "permissions": {
    "allowedTools": [
      "Edit(**/*.js)"  // Разрешены все JS
    ],
    "deniedTools": [
      "Edit(/config/*.js)",        // Но не конфиги
      "Edit(**/*.env)",            // И не .env файлы
      "Edit(**/secrets.json)"      // И не секреты
    ]
  }
}
```

**Опасные команды:**
```json
{
  "deniedTools": [
    "Bash(rm -rf:*)",           // Recursive delete
    "Bash(sudo:*)",             // Sudo команды
    "Bash(chmod:*)",            // Изменение прав
    "Bash(curl:*)",             // Сетевые запросы
    "Bash(wget:*)",             // Загрузка файлов
    "Bash(dd:*)",               // Низкоуровневые операции
    "Bash(mkfs:*)",             // Форматирование
    "Bash(> /dev/*)",           // Запись в devices
    "Edit(/etc/**/*)",          // Системные файлы
    "Edit(/usr/**/*)",          // Системные бинарники
    "Edit(/var/**/*)"           // Системные данные
  ]
}
```

### permissionMode

Режимы работы с разрешениями:

#### acceptEdits (по умолчанию)
```json
{
  "permissionMode": "acceptEdits"
}
```
- Автоматически применять правки
- Соблюдать allowedTools/deniedTools
- Не спрашивать подтверждения

**Когда использовать:**
- Доверенная среда
- Разработка features
- Быстрая итерация

#### manual
```json
{
  "permissionMode": "manual"
}
```
- Спрашивать подтверждение на каждый Edit
- Показывать diff перед применением
- Пользователь решает apply/reject

**Когда использовать:**
- Критичный код
- Production окружение
- Обучение Claude

#### strict
```json
{
  "permissionMode": "strict"
}
```
- Разрешать только явно указанные в allowedTools
- Блокировать всё остальное
- Максимальная безопасность

**Когда использовать:**
- Enterprise окружения
- Compliance требования
- Работа с чувствительными данными

## Sandbox Mode

### Что такое Sandbox?

Sandbox mode (Linux/Mac) изолирует выполнение Bash команд в защищенном окружении:

- Ограниченный доступ к файловой системе
- Контроль сетевых операций
- Изоляция процессов
- Предотвращение privilege escalation

### Конфигурация

```json
{
  "sandbox": {
    "allowUnsandboxedCommands": false
  }
}
```

**Опции:**
- `false` — все команды в sandbox (рекомендуется)
- `true` — разрешить escape из sandbox (осторожно!)

### Как работает

```bash
# С sandbox mode
# Bash команды выполняются через sandbox wrapper
# Ограничения на:
# - Доступ к /home/user/project только
# - Нет sudo
# - Нет изменения системных файлов
# - Контролируемые сетевые операции

# Без sandbox mode
# Прямое выполнение команд
# Полный доступ пользователя
# Больше рисков
```

### Escape из Sandbox

Иногда нужен полный доступ:

```json
{
  "sandbox": {
    "allowUnsandboxedCommands": true,
    "unsandboxedCommandPatterns": [
      "git:*",           // Git команды без sandbox
      "npm:install",     // npm install без ограничений
      "docker:*"         // Docker команды
    ]
  }
}
```

**⚠️ Используйте осторожно!**

## Best Practices

### 1. Principle of Least Privilege

```json
// ❌ Плохо: слишком широкие права
{
  "permissions": {
    "allowedTools": ["*"]
  }
}

// ✅ Хорошо: минимальные необходимые права
{
  "permissions": {
    "allowedTools": [
      "Read(src/**/*.{js,ts})",
      "Edit(src/**/*.{js,ts})",
      "Bash(git:status)",
      "Bash(git:add)",
      "Bash(git:commit)",
      "Bash(npm:test)"
    ]
  }
}
```

### 2. Защита секретов

```json
{
  "permissions": {
    "deniedTools": [
      "Read(**/.env*)",
      "Read(**/secrets.json)",
      "Read(**/credentials.json)",
      "Read(**/*.pem)",
      "Read(**/*.key)",
      "Edit(**/.env*)",
      "Edit(**/secrets.*)",
      "Bash(echo *password*)",
      "Bash(echo *secret*)"
    ]
  }
}
```

### 3. Sandbox для ненадежного кода

```json
{
  "sandbox": {
    "allowUnsandboxedCommands": false
  },
  "permissions": {
    "allowedTools": [
      "Read(**/*)",
      "Bash(node:test/*.js)",
      "Bash(npm:test)"
    ],
    "deniedTools": [
      "Edit(**/*)",      // Read-only
      "Write(**/*)",     // No writes
      "Bash(npm:install)"  // No package changes
    ]
  }
}
```

### 4. Разные профили для разных задач

**Development:**
```json
{
  "permissionMode": "acceptEdits",
  "permissions": {
    "allowedTools": [
      "Read(**/*)",
      "Edit(src/**/*)",
      "Edit(test/**/*)",
      "Bash(git:*)",
      "Bash(npm:*)"
    ]
  },
  "sandbox": {
    "allowUnsandboxedCommands": true
  }
}
```

**Code Review:**
```json
{
  "permissionMode": "manual",
  "permissions": {
    "allowedTools": [
      "Read(**/*)",
      "Bash(git:diff)",
      "Bash(git:log)",
      "Bash(git:blame)"
    ],
    "deniedTools": [
      "Edit(**/*)",
      "Bash(git:push)"
    ]
  },
  "sandbox": {
    "allowUnsandboxedCommands": false
  }
}
```

**Production:**
```json
{
  "permissionMode": "strict",
  "permissions": {
    "allowedTools": [
      "Read(src/**/*.{js,ts})",
      "Bash(git:status)"
    ],
    "deniedTools": [
      "Edit(**/*)",
      "Bash(git:push)",
      "Bash(npm:*)"
    ]
  },
  "sandbox": {
    "allowUnsandboxedCommands": false
  }
}
```

### 5. Логирование и Audit

```json
{
  "audit": {
    "enabled": true,
    "logFile": "~/.claude/audit.log",
    "logLevel": "info"
  }
}
```

```bash
# Просмотр audit лога
tail -f ~/.claude/audit.log

# Фильтрация по типу
grep "TOOL_DENIED" ~/.claude/audit.log

# Анализ активности
cat ~/.claude/audit.log | jq '.tool' | sort | uniq -c
```

## Hooks для Security

### PreToolUse Validation

Валидация перед выполнением:

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

**bash-validator.py:**
```python
#!/usr/bin/env python3
import json
import re
import sys

DANGEROUS_PATTERNS = [
    (r"rm -rf", "Recursive delete blocked"),
    (r"sudo", "Sudo commands blocked"),
    (r"curl.*\|.*bash", "Pipe to bash blocked"),
    (r"wget.*\|.*bash", "Pipe to bash blocked"),
    (r">(.*)/dev/", "Writing to devices blocked")
]

def validate_command(command: str) -> list[str]:
    issues = []
    for pattern, message in DANGEROUS_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            issues.append(message)
    return issues

def main():
    input_data = json.load(sys.stdin)
    
    if input_data.get("tool_name") != "Bash":
        sys.exit(0)
    
    command = input_data.get("tool_input", {}).get("command", "")
    issues = validate_command(command)
    
    if issues:
        for message in issues:
            print(f"🚫 {message}", file=sys.stderr)
        sys.exit(2)  # Block execution
    
    sys.exit(0)  # Allow

if __name__ == "__main__":
    main()
```

### PostToolUse Verification

Проверка после выполнения:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.claude/hooks/secrets-scanner.py"
          }
        ]
      }
    ]
  }
}
```

**secrets-scanner.py:**
```python
#!/usr/bin/env python3
import json
import re
import sys

SECRET_PATTERNS = [
    r"password\s*=\s*['\"][\w\W]{8,}['\"]",
    r"api[_-]?key\s*=\s*['\"][\w\W]{20,}['\"]",
    r"secret\s*=\s*['\"][\w\W]{20,}['\"]",
    r"token\s*=\s*['\"][\w\W]{20,}['\"]",
    r"sk-[a-zA-Z0-9]{20,}",  # Anthropic API key
    r"ghp_[a-zA-Z0-9]{36}",  # GitHub token
    r"-----BEGIN [\w\s]+ PRIVATE KEY-----"
]

def scan_for_secrets(content: str) -> list[str]:
    found = []
    for pattern in SECRET_PATTERNS:
        matches = re.finditer(pattern, content, re.IGNORECASE)
        for match in matches:
            found.append(f"Potential secret: {match.group()[:30]}...")
    return found

def main():
    input_data = json.load(sys.stdin)
    
    if input_data.get("tool_name") != "Edit":
        sys.exit(0)
    
    content = input_data.get("tool_input", {}).get("new_string", "")
    secrets = scan_for_secrets(content)
    
    if secrets:
        print("⚠️  WARNING: Potential secrets detected!", file=sys.stderr)
        for secret in secrets:
            print(f"  - {secret}", file=sys.stderr)
        sys.exit(1)  # Warning (не блокирует, но уведомляет)
    
    sys.exit(0)

if __name__ == "__main__":
    main()
```

## Enterprise Security

### Centralized Policy

```json
// /company/claude-policy.json
{
  "permissions": {
    "allowedTools": [
      "Read(**/*.{js,ts,jsx,tsx,json,md})",
      "Edit(src/**/*.{js,ts,jsx,tsx})",
      "Edit(test/**/*.{js,ts,jsx,tsx})",
      "Bash(git:status)",
      "Bash(git:diff)",
      "Bash(git:log)",
      "Bash(git:add)",
      "Bash(git:commit)",
      "Bash(npm:test)",
      "Bash(npm:run build)"
    ],
    "deniedTools": [
      "Edit(**/.env*)",
      "Edit(**/secrets.*)",
      "Edit(/config/production.*)",
      "Bash(rm:*)",
      "Bash(sudo:*)",
      "Bash(curl:*)",
      "Bash(wget:*)",
      "Bash(git:push)",
      "Bash(npm:publish)"
    ]
  },
  "permissionMode": "acceptEdits",
  "sandbox": {
    "allowUnsandboxedCommands": false
  },
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"],
      "oauth": {
        "clientId": "${COMPANY_GITHUB_CLIENT_ID}",
        "clientSecret": "${COMPANY_GITHUB_CLIENT_SECRET}",
        "scopes": ["repo"]
      }
    }
  },
  "allowedMcpServers": ["github"],
  "blockAllOtherMcpServers": true,
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 /company/claude/validators/bash.py"
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
            "command": "python3 /company/claude/validators/secrets.py"
          }
        ]
      }
    ]
  },
  "audit": {
    "enabled": true,
    "logFile": "/var/log/claude/audit.log",
    "remoteLogging": {
      "enabled": true,
      "endpoint": "https://logs.company.com/claude"
    }
  }
}
```

### Распространение политики

```bash
# В .bashrc или .zshrc
export CLAUDE_CONFIG=/company/claude-policy.json

# Или symlink
ln -sf /company/claude-policy.json ~/.claude/settings.json

# Или в Docker
COPY /company/claude-policy.json /root/.claude/settings.json
```

### Compliance Reporting

```python
#!/usr/bin/env python3
# /company/claude/reports/compliance.py

import json
from datetime import datetime, timedelta
from collections import defaultdict

def analyze_audit_log(log_file: str, days: int = 30):
    cutoff = datetime.now() - timedelta(days=days)
    
    stats = {
        "total_operations": 0,
        "denied_operations": 0,
        "tools_used": defaultdict(int),
        "users": set(),
        "violations": []
    }
    
    with open(log_file) as f:
        for line in f:
            entry = json.loads(line)
            timestamp = datetime.fromisoformat(entry["timestamp"])
            
            if timestamp < cutoff:
                continue
            
            stats["total_operations"] += 1
            stats["users"].add(entry.get("user", "unknown"))
            stats["tools_used"][entry["tool"]] += 1
            
            if entry.get("denied"):
                stats["denied_operations"] += 1
                stats["violations"].append({
                    "user": entry.get("user"),
                    "tool": entry["tool"],
                    "reason": entry.get("deny_reason"),
                    "timestamp": entry["timestamp"]
                })
    
    return {
        **stats,
        "users": list(stats["users"]),
        "tools_used": dict(stats["tools_used"])
    }

# Запуск
report = analyze_audit_log("/var/log/claude/audit.log")
print(json.dumps(report, indent=2))
```

## Security Checklist

### Перед использованием

- [ ] Настроены allowedTools с минимальными правами
- [ ] Настроены deniedTools для критичных файлов и команд
- [ ] Выбран подходящий permissionMode
- [ ] Включен sandbox mode (если Linux/Mac)
- [ ] Секреты в переменных окружения, не в коде
- [ ] Hooks настроены для валидации
- [ ] Audit logging включен

### Для teams

- [ ] Централизованная политика безопасности
- [ ] MCP servers ограничены allowlist'ом
- [ ] Обязательный code review
- [ ] Регулярный анализ audit логов
- [ ] Документация security guidelines
- [ ] Обучение команды best practices

### Для enterprise

- [ ] Compliance с регуляциями (GDPR, SOC2, etc.)
- [ ] Централизованное управление политиками
- [ ] Интеграция с SIEM системами
- [ ] Regular security audits
- [ ] Incident response процедуры
- [ ] Backup и disaster recovery

## Troubleshooting

### Tool заблокирован

```bash
# Проверка permissions
cat ~/.claude/settings.json | jq '.permissions'

# Добавление разрешения
# В settings.json:
{
  "permissions": {
    "allowedTools": [
      "Read(path/to/file.js)"  # Добавить этот паттерн
    ]
  }
}
```

### Sandbox блокирует команду

```bash
# Временно: escape из sandbox для одной команды
# Не рекомендуется!

# Лучше: добавить паттерн в unsandboxed
{
  "sandbox": {
    "allowUnsandboxedCommands": true,
    "unsandboxedCommandPatterns": [
      "git:*"  # Только git команды
    ]
  }
}
```

### Hook блокирует операцию

```bash
# Просмотр логов hook
claude --debug
tail -f ~/.claude/debug.log | grep hook

# Тестирование hook отдельно
echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | \
  python3 ~/.claude/hooks/bash-validator.py
```

## Заключение

Security в Claude Code:
- **Гибкий контроль** через permissions
- **Изоляция** через sandbox mode
- **Валидация** через hooks
- **Audit** для compliance
- **Масштабируемость** от личного до enterprise

Правильная настройка безопасности позволяет использовать Claude Code в любых окружениях с необходимым уровнем защиты.

## Дополнительные ресурсы

- [Security Policy](https://github.com/anthropics/claude-code/security/policy)
- [Permissions Documentation](https://docs.claude.com/en/docs/claude-code/permissions)
- [Sandbox Mode Guide](https://docs.claude.com/en/docs/claude-code/sandbox)
- [Enterprise Security](https://docs.claude.com/en/docs/claude-code/enterprise-security)
- [Report Security Issues](https://hackerone.com/anthropic-vdp)
