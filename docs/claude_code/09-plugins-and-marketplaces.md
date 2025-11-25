# 09: Plugins и Marketplaces

## Обзор

Система плагинов Claude Code позволяет расширять функциональность через кастомные команды, агенты, hooks и MCP серверы. Plugins могут быть расшарены через marketplaces и переиспользованы в разных проектах и командах.

## Что такое Claude Code Plugins?

### Определение

Plugins — это расширения, которые улучшают Claude Code через:
- **Slash команды** — кастомные команды типа `/feature-dev`
- **Специализированных агентов** — экспертные персоны для задач
- **Hooks** — перехват и обработка событий
- **MCP серверы** — интеграция с внешними сервисами
- **Output styles** — кастомизация стиля взаимодействия

### Преимущества

- **Переиспользование** — один раз написать, использовать везде
- **Шаринг** — делиться с командой через marketplaces
- **Консистентность** — единые процессы в разных проектах
- **Масштабирование** — enterprise-grade инструменты
- **Настройка** — адаптация под специфические нужды

## Установка Plugins

### Из официального репозитория

```bash
# Установка plugin
/plugin install pr-review-toolkit

# Установка из URL
/plugin install https://github.com/anthropics/claude-code/tree/main/plugins/code-review

# Установка из локальной директории
/plugin install /path/to/plugin
```

### Команды управления

```bash
# Просмотр доступных plugins
/plugin marketplace

# Включение plugin
/plugin enable security-guidance

# Отключение plugin
/plugin disable security-guidance

# Список установленных plugins
/plugin list

# Обновление plugin
/plugin update pr-review-toolkit

# Удаление plugin
/plugin uninstall code-review

# Валидация plugin структуры
/plugin validate /path/to/plugin
```

## Официальные Plugins

### PR Review Toolkit

**Назначение:** Комплексный review pull requests

**Включает 6 специализированных агентов:**
1. **code-reviewer** — general code review
2. **silent-failure-hunter** — error handling analysis
3. **pr-test-analyzer** — test coverage check
4. **comment-analyzer** — documentation accuracy
5. **type-design-reviewer** — type system design
6. **code-simplifier** — code polishing

**Установка:**
```bash
/plugin install pr-review-toolkit
```

**Использование:**
```bash
# Естественный язык
"Check if the tests cover all edge cases"
"Review the error handling in this PR"
"Is the documentation accurate?"
"Review type design for UserAccount"

# Комплексный review
"Before creating this PR, please:
1. Review test coverage
2. Check for silent failures
3. Verify comments are accurate
4. Review type design
5. General code review"
```

**Рабочий процесс:**
```bash
1. Написание кода → code-reviewer
2. Исправление проблем → silent-failure-hunter
3. Добавление тестов → pr-test-analyzer
4. Документирование → comment-analyzer
5. Прохождение проверок → code-simplifier
6. Создание PR
```

### Feature Development

**Назначение:** Структурированная разработка features

**7-фазный workflow:**
1. **Понимание требований** — анализ задачи
2. **Исследование кодовой базы** — code-explorer агенты
3. **Уточняющие вопросы** — идентификация неясностей
4. **Проектирование архитектуры** — code-architect агенты
5. **Реализация** — написание кода
6. **Code Review** — проверка качества
7. **Финализация** — полировка и PR

**Установка:**
```bash
/plugin install feature-dev
```

**Использование:**
```bash
/feature-dev

# Claude проведет через все 7 фаз
# С TodoWrite отслеживанием прогресса
```

**Core Principles:**
- Задавать уточняющие вопросы
- Понимать перед действием
- Читать файлы, идентифицированные агентами
- Простота и элегантность
- Использование TodoWrite для трекинга

### Code Review

**Назначение:** Автоматизация PR review

**Процесс:**
1. Проверка необходимости review (skip closed/draft/trivial)
2. Сбор CLAUDE.md guidelines
3. Суммаризация PR changes
4. Parallel запуск 4 агентов:
   - Agent #1 & #2: CLAUDE.md compliance
   - Agent #3: Obvious bugs scan
   - Agent #4: Git history context analysis
5. Оценка каждой проблемы 0-100
6. Фильтрация < 80 confidence
7. Публикация review comment

**Установка:**
```bash
/plugin install code-review
```

**Использование:**
```bash
# На PR ветке
/code-review

# Интеграция в CI/CD
# Trigger on PR creation or update
# Automatically posts review comments
# Skip if review already exists
```

**Best Practices:**
- Поддерживать чёткие CLAUDE.md файлы
- Доверять threshold 80+
- Запускать на всех non-trivial PRs
- Использовать как starting point для human review
- Обновлять CLAUDE.md на основе паттернов

### Commit Commands

**Назначение:** Автоматизация git операций

**Команды:**
- `/commit` — stage, commit с автоматическим сообщением
- `/commit-push` — commit + push
- `/commit-push-pr` — commit + push + create PR

**Установка:**
```bash
/plugin install commit-commands
```

**Возможности:**
- Автогенерация commit messages в стиле репо
- Conventional commits
- Избегание коммита секретов (.env, credentials.json)
- Claude Code attribution в commit message

**Использование:**
```bash
# Быстрый commit
/commit

# Commit и push
/commit-push

# Полный workflow
/commit-push-pr
# → Создает ветку (если на main)
# → Stage и commit
# → Push
# → Создает PR
# → Возвращает PR URL
```

### Agent SDK Development

**Назначение:** Scaffold и верификация Agent SDK приложений

**Возможности:**
- Scaffold новых SDK проектов (TypeScript/Python)
- Установка latest SDK версий
- Создание примеров кода
- Автоматическая верификация setup

**Установка:**
```bash
/plugin install agent-sdk-dev
```

**Использование:**
```bash
/new-sdk-app

# Интерактивно спрашивает:
# 1. Язык (TypeScript или Python)
# 2. Название проекта
# 3. Тип агента (coding, business, custom)
# 4. Starting point (minimal, basic, example)
# 5. Tooling (npm/yarn/pnpm или pip/poetry)

# Затем:
# - Создает все файлы
# - Устанавливает зависимости
# - Запускает верификацию (agent-sdk-verifier-ts/py)
# - Проверяет type checking / syntax
```

**Верификация включает:**
- SDK installation and version
- Environment setup
- Correct SDK usage patterns
- Agent initialization
- Environment and security
- Error handling
- Documentation

### Explanatory Output Style

**Назначение:** Образовательные комментарии

**Возможности:**
- Brief explanations перед написанием кода
- Educational insights после кода
- Контекст о выбранных решениях

**Установка:**
```bash
/plugin install explanatory-output-style
```

**Как работает:**
- Использует SessionStart hook
- Инжектит контекст в каждую сессию
- Claude предоставляет объяснения перед/после кода

### Learning Output Style

**Назначение:** Интерактивное обучение

**Возможности:**
- Интерактивный teaching подход
- Активное участие в написании кода
- Комбинирует explanatory style

**Установка:**
```bash
/plugin install learning-output-style
```

**Пример взаимодействия:**
```
Claude: I've set up the authentication middleware. 
The session timeout behavior is a security vs. UX trade-off - 
should sessions auto-extend on activity, or have a hard timeout?

[User makes decision]

Claude: Great choice! Now, can you write the timeout logic 
in the middleware? I'll guide you on the structure.
```

## Структура Plugin

### Минимальная структура

```bash
my-plugin/
├── README.md           # Описание plugin
├── plugin.json         # Метаданные (опционально)
├── commands/           # Slash команды
│   └── my-command.md
├── agents/             # Специализированные агенты
│   └── my-agent.md
└── hooks/              # Event hooks
    └── session-start.md
```

### Полная структура

```bash
comprehensive-plugin/
├── README.md
├── plugin.json
├── commands/
│   ├── command1.md
│   ├── command2.md
│   └── command3.md
├── agents/
│   ├── agent1.md
│   ├── agent2.md
│   └── agent3.md
├── hooks/
│   ├── SessionStart/
│   │   └── setup-context.md
│   ├── PreToolUse/
│   │   └── validate-bash.md
│   └── PostToolUse/
│       └── lint-code.md
├── mcp-servers/
│   └── custom-server/
│       ├── package.json
│       └── index.js
└── examples/
    ├── basic-usage.md
    └── advanced-usage.md
```

### plugin.json

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Plugin description",
  "author": "Your Name",
  "repository": "https://github.com/you/my-plugin",
  "keywords": ["claude", "plugin", "code-review"],
  "requires": {
    "claudeCode": ">=1.0.0"
  },
  "commands": [
    {
      "name": "my-command",
      "description": "Command description",
      "file": "commands/my-command.md"
    }
  ],
  "agents": [
    {
      "name": "my-agent",
      "description": "Agent description",
      "file": "agents/my-agent.md"
    }
  ],
  "hooks": {
    "SessionStart": ["hooks/SessionStart/setup-context.md"],
    "PreToolUse": ["hooks/PreToolUse/validate-bash.md"],
    "PostToolUse": ["hooks/PostToolUse/lint-code.md"]
  }
}
```

### README.md template

```markdown
# Plugin Name

Brief description of what the plugin does.

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

\`\`\`bash
/plugin install plugin-name
\`\`\`

## Commands

### /command-name

Description of what the command does.

**Usage:**
\`\`\`bash
/command-name [arguments]
\`\`\`

**Example:**
\`\`\`bash
/command-name --option value
\`\`\`

## Agents

### agent-name

Description of what the agent does.

**When to use:**
- Scenario 1
- Scenario 2

**Usage:**
\`\`\`bash
"Launch agent-name agent for this task"
\`\`\`

## Configuration

Optional configuration options.

\`\`\`json
{
  "myPlugin": {
    "option1": "value1",
    "option2": "value2"
  }
}
\`\`\`

## Best Practices

1. Best practice 1
2. Best practice 2
3. Best practice 3

## Troubleshooting

Common issues and solutions.

## License

License information.
\`\`\`

## Создание Plugin

### Шаг 1: Планирование

Определите:
- **Назначение** — какую проблему решает
- **Команды** — какие slash команды нужны
- **Агенты** — какие специализированные агенты
- **Hooks** — какие события перехватывать
- **MCP серверы** — нужны ли внешние интеграции

### Шаг 2: Создание структуры

```bash
mkdir my-plugin
cd my-plugin
mkdir commands agents hooks
touch README.md plugin.json
```

### Шаг 3: Определение команд

`commands/analyze-security.md`:
```markdown
# Command: /analyze-security

## What it does
Performs comprehensive security analysis of the codebase

## Process
1. Launch security-scanner agent to identify vulnerabilities
2. Launch dependency-checker agent for dependency analysis
3. Launch config-auditor agent for configuration review
4. Aggregate findings
5. Score by severity
6. Present report to user

## Implementation
[Detailed implementation instructions for Claude]

## Usage Examples
\`\`\`bash
/analyze-security
/analyze-security --deep
/analyze-security --fix
\`\`\`
\`\`\`

### Шаг 4: Определение агентов

`agents/security-scanner.md`:
```markdown
# Security Scanner Agent

## Your Role
Security expert scanning for vulnerabilities

## Your Focus
- SQL injection vulnerabilities
- XSS vulnerabilities
- CSRF protection
- Authentication issues
- Authorization flaws
- Secret exposure
- Insecure dependencies

## Your Output Format
1. **Vulnerability**: Type and description
2. **Location**: File:line
3. **Severity**: CRITICAL/HIGH/MEDIUM/LOW
4. **CWE**: CWE identifier
5. **Proof of Concept**: How to exploit
6. **Remediation**: How to fix
7. **References**: Links to documentation

## Core Principles
- Every finding must be exploitable
- Provide concrete proof of concepts
- Specific remediation steps
- OWASP Top 10 focus
\`\`\`

### Шаг 5: Добавление hooks (опционально)

`hooks/PreToolUse/security-check.md`:
```markdown
# Hook: Security Check (PreToolUse)

## When to Run
Before Bash tool executes potentially dangerous commands

## What to Check
- Commands containing `rm -rf`
- Commands accessing sensitive paths
- Commands with sudo
- Network operations to unknown hosts

## Action
- Block if dangerous
- Warn if suspicious
- Log all commands

## Implementation
[Hook implementation logic]
\`\`\`

### Шаг 6: Тестирование

```bash
# Установка локально
/plugin install /path/to/my-plugin

# Тестирование команд
/analyze-security

# Проверка агентов
"Launch security-scanner agent on this code"

# Валидация структуры
/plugin validate /path/to/my-plugin
```

### Шаг 7: Документирование

Создайте comprehensive README.md с:
- Четким описанием
- Примерами использования
- Best practices
- Troubleshooting guide
- License

### Шаг 8: Публикация

```bash
# Push to GitHub
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/you/my-plugin
git push -u origin main

# Create release
git tag v1.0.0
git push --tags
```

## Marketplaces

### Официальный Marketplace

**Anthropic's official plugins:**
- https://github.com/anthropics/claude-code/tree/main/plugins

**Установка:**
```bash
/plugin marketplace
# Показывает официальные plugins
# Можно установить напрямую
```

### Community Marketplaces

**Популярные репозитории:**
- awesome-claude-code
- claude-code-templates
- claude-code-cookbook

**Установка из URL:**
```bash
/plugin install https://github.com/user/plugin-repo
```

### Enterprise Marketplaces

**Настройка в settings.json:**
```json
{
  "extraKnownMarketplaces": [
    {
      "name": "company-plugins",
      "url": "https://github.com/your-org/claude-plugins"
    },
    {
      "name": "team-plugins",
      "url": "https://github.com/your-team/plugins"
    }
  ]
}
```

**Использование:**
```bash
/plugin marketplace
# Теперь показывает plugins из:
# - Official Anthropic
# - company-plugins
# - team-plugins

/plugin install plugin-name --marketplace company-plugins
```

### Приватные Marketplaces

**С authentication:**
```json
{
  "extraKnownMarketplaces": [
    {
      "name": "private-plugins",
      "url": "https://private-repo.company.com/plugins",
      "auth": {
        "type": "token",
        "token": "${PLUGIN_REPO_TOKEN}"
      }
    }
  ]
}
```

```bash
# В environment
export PLUGIN_REPO_TOKEN=ghp_xxxxx

# Теперь Claude может устанавливать приватные plugins
/plugin install internal-tool --marketplace private-plugins
```

## Best Practices

### Разработка Plugins

**1. Модульность**
```bash
# ✅ Хорошо: специализированные агенты
agents/
├── sql-scanner.md
├── xss-scanner.md
└── csrf-scanner.md

# ❌ Плохо: один универсальный агент
agents/
└── security-agent.md  # Делает всё
```

**2. Документация**
```markdown
# ✅ Хорошо: детальные примеры
## Usage Examples

### Basic Security Scan
\`\`\`bash
/analyze-security
\`\`\`

### Deep Scan with Auto-fix
\`\`\`bash
/analyze-security --deep --fix
\`\`\`

### Scan Specific Directory
\`\`\`bash
/analyze-security --path src/auth
\`\`\`

# ❌ Плохо: без примеров
## Usage
Use /analyze-security command
```

**3. Именование**
```bash
# ✅ Хорошо: описательные имена
/security-audit
/feature-scaffold
/pr-comprehensive-review

# ❌ Плохо: непонятные имена
/sa
/fs
/pcr
```

**4. Конфигурируемость**
```json
// ✅ Хорошо: настраиваемые опции
{
  "myPlugin": {
    "severity": "high",
    "autoFix": false,
    "ignorePatterns": ["test/**", "*.test.js"]
  }
}

// ❌ Плохо: жёстко зашитые значения
```

**5. Error Handling**
```markdown
## Error Handling

### If scan fails
- Logs detailed error
- Shows user-friendly message
- Suggests troubleshooting steps
- Provides fallback options

### Common issues
1. **Permission denied**: Ensure file access
2. **Timeout**: Try --quick mode
3. **Memory**: Reduce scan scope
```

### Использование Plugins

**1. Выбор правильного plugin**
```bash
# Для security → security-audit plugin
# Для features → feature-dev plugin
# Для PR review → pr-review-toolkit plugin
```

**2. Комбинирование plugins**
```bash
# Workflow с несколькими plugins
/feature-dev          # Разработка feature
/analyze-security     # Security check
/pr-review-toolkit    # Comprehensive review
/commit-push-pr       # Create PR
```

**3. Периодическое обновление**
```bash
# Проверка обновлений
/plugin list --updates

# Обновление всех
/plugin update --all

# Обновление конкретного
/plugin update pr-review-toolkit
```

## Troubleshooting

### Plugin не устанавливается

```bash
# Проверка структуры
/plugin validate /path/to/plugin

# Проверка логов
claude --debug
tail -f ~/.claude/debug.log | grep plugin

# Проверка permissions
ls -la /path/to/plugin
```

### Команда не работает

```bash
# Проверка, что plugin включён
/plugin list
# ✓ plugin-name (enabled)

# Включение если отключён
/plugin enable plugin-name

# Перезапуск Claude
# Exit и снова запустить
```

### Agent не запускается

```bash
# Проверка определения agent
cat plugins/my-plugin/agents/my-agent.md

# Проверка, что файл читается Claude
"Read the agent definition in plugins/my-plugin/agents/my-agent.md"

# Debug режим
claude --debug
```

## Заключение

Система Plugins в Claude Code:
- **Расширяет функциональность** через модульные компоненты
- **Обеспечивает шаринг** через marketplaces
- **Унифицирует процессы** в командах и проектах
- **Масштабируется** от личного использования до enterprise
- **Открыта для кастомизации** под любые нужды

Plugins превращают Claude Code в платформу, которая адаптируется к вашим уникальным workflow и требованиям.

## Дополнительные ресурсы

- [Official Plugins Repository](https://github.com/anthropics/claude-code/tree/main/plugins)
- [Plugin Development Guide](https://docs.claude.com/en/docs/claude-code/plugins)
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code)
- [Claude Code Templates](https://github.com/davila7/claude-code-templates)
- [Claude Code Cookbook](https://github.com/wasabeef/claude-code-cookbook)
