# 11: GitHub Integration

## Обзор

Claude Code предоставляет глубокую интеграцию с GitHub через встроенные инструменты, плагины и MCP серверы. Это позволяет автоматизировать работу с репозиториями, pull requests, issues и CI/CD прямо из командной строки.

## Встроенная Git интеграция

### Базовые git операции

Claude имеет прямой доступ к git через Bash tool:

```bash
# Все стандартные git команды доступны
git status
git add .
git commit -m "message"
git push
git pull
git branch
git checkout -b feature
```

### Автоматическое использование

Claude автоматически использует git для:
- Проверки текущего статуса перед изменениями
- Создания коммитов после правок
- Анализа истории изменений (git blame)
- Понимания контекста через git log
- Работы с ветками

## GitHub CLI (gh)

### Использование gh

Claude может использовать GitHub CLI для всех GitHub операций:

```bash
# Pull Requests
gh pr create
gh pr list
gh pr view 123
gh pr comment 123
gh pr merge 123
gh pr checks 123

# Issues
gh issue create
gh issue list
gh issue view 456
gh issue comment 456
gh issue close 456

# Repositories
gh repo view
gh repo clone user/repo
gh repo fork

# Workflows
gh workflow list
gh workflow run
gh run list
gh run view 789
```

### Настройка gh

```bash
# Аутентификация
gh auth login

# Конфигурация
gh config set prompt enabled
gh config set editor vim

# Проверка
gh auth status
```

## Commit Commands Plugin

### Установка

```bash
/plugin install commit-commands
```

### Команды

#### /commit

Автоматический commit с умным сообщением:

```bash
/commit

# Claude:
# 1. Запускает git status
# 2. Анализирует изменения
# 3. Генерирует commit message в стиле репо
# 4. Создает commit
# 5. Добавляет Claude Code attribution
```

**Возможности:**
- Следует стилю коммитов репо
- Conventional commits
- Избегает коммита секретов (.env, credentials)
- Информативные сообщения

**Пример commit message:**
```
feat: Add user authentication with JWT

- Implement JWT token generation
- Add login/logout endpoints
- Create auth middleware
- Add tests for auth flow

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

#### /commit-push

Commit + push в одной команде:

```bash
/commit-push

# Выполняет:
# 1. git add (relevant files)
# 2. git commit -m "message"
# 3. git push
```

#### /commit-push-pr

Полный workflow от кода до PR:

```bash
/commit-push-pr

# Выполняет:
# 1. Создает новую ветку (если на main)
# 2. Stage и commit
# 3. Push с -u flag
# 4. Создает PR через gh
# 5. Возвращает PR URL
```

**Генерация PR:**
```markdown
## Summary
- Added user authentication
- Implemented JWT tokens
- Added comprehensive tests

## Test plan
- [x] Unit tests pass
- [x] Integration tests pass
- [ ] Manual testing required

🤖 Generated with [Claude Code](https://claude.ai/code)
```

## Code Review Plugin

### Установка

```bash
/plugin install code-review
```

### Автоматический PR Review

#### Процесс

```bash
# На PR ветке
/code-review

# Claude выполняет:
# 1. Проверяет необходимость review
#    - Пропускает closed/draft/trivial PRs
#    - Пропускает если review уже есть
#
# 2. Собирает контекст
#    - CLAUDE.md guidelines
#    - PR changes
#    - Git history
#
# 3. Запускает 4 агента параллельно
#    - Agent #1 & #2: CLAUDE.md compliance
#    - Agent #3: Obvious bugs
#    - Agent #4: Git history context
#
# 4. Оценивает проблемы (0-100 confidence)
#
# 5. Фильтрует < 80 confidence
#
# 6. Постит comment если есть проблемы
```

#### Система оценки

**Confidence Scoring:**
- **91-100**: Critical bug или явное нарушение
- **76-90**: Важная проблема
- **51-75**: Валидная но low-impact
- **26-50**: Minor nitpick
- **0-25**: Вероятно ложное срабатывание

**Что фильтруется:**
- Pre-existing проблемы
- Код похожий на баг, но корректный
- Педантичные придирки
- Что поймает линтер
- Общие вопросы качества (если не в CLAUDE.md)

#### Пример review comment

```markdown
## Code Review

### High Priority Issues

#### Issue #1 (Confidence: 95)
**Location:** `src/auth.js:45-50`
**Severity:** HIGH

SQL injection vulnerability in login function.

**Evidence:**
```javascript
const query = `SELECT * FROM users WHERE email = '${email}'`;
```

**Recommendation:**
Use parameterized queries:
```javascript
const query = 'SELECT * FROM users WHERE email = ?';
db.query(query, [email]);
```

---

#### Issue #2 (Confidence: 87)
**Location:** `src/api.js:120`
**Severity:** MEDIUM

Error swallowed without logging.

**Evidence:**
```javascript
try {
  await processData();
} catch (e) {
  return null; // Silent failure
}
```

**Recommendation:**
Log error before returning:
```javascript
try {
  await processData();
} catch (e) {
  logger.error('Failed to process data:', e);
  return null;
}
```

---

🤖 Automated review by [Claude Code](https://claude.ai/code)
Review Agent: code-reviewer v1.0
```

### Best Practices

**1. Поддерживайте CLAUDE.md:**
```markdown
# CLAUDE.md

## Code Guidelines

### Security
- Always use parameterized queries
- Validate all user input
- Never expose secrets in logs

### Error Handling
- Log all errors with context
- Provide user-friendly messages
- Never swallow exceptions silently

### Testing
- Write tests for all new features
- Maintain >80% coverage
- Test edge cases
```

**2. Интеграция в workflow:**
```bash
# После разработки
/code-review

# Исправление проблем
[make fixes]

# Финальная проверка
/code-review

# Создание PR
/commit-push-pr
```

**3. CI/CD интеграция:**
```yaml
# .github/workflows/claude-review.yml
name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Claude Review
        run: |
          claude --headless "/code-review"
        env:
          ANTHROPIC_API_KEY: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
```

## GitHub MCP Server

### Установка и настройка

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"],
      "oauth": {
        "clientId": "${GITHUB_CLIENT_ID}",
        "clientSecret": "${GITHUB_CLIENT_SECRET}",
        "scopes": ["repo", "issues", "pull_requests"]
      }
    }
  }
}
```

### Получение OAuth credentials

```bash
# 1. Создать GitHub OAuth App
# https://github.com/settings/developers

# 2. Настроить:
# - Application name: Claude Code
# - Homepage URL: https://claude.ai/code
# - Authorization callback URL: http://localhost:3000/callback

# 3. Получить Client ID и Client Secret

# 4. Добавить в environment
export GITHUB_CLIENT_ID=your_client_id
export GITHUB_CLIENT_SECRET=your_client_secret
```

### Использование

```bash
# Активация через @-mention
@github help

# Создание issue
@github create issue in user/repo with title "Bug: Login fails" and body "Steps to reproduce..."

# Просмотр PR
@github show pull request #123 in user/repo

# Комментирование
@github comment on issue #456 with "Fixed in PR #789"

# Поиск
@github search issues in user/repo with "bug login"

# Список PRs
@github list pull requests in user/repo

# Merge PR
@github merge pull request #123 in user/repo
```

## Claude Code Action

### Что это?

GitHub Action, который позволяет Claude отвечать на вопросы и делать изменения в PRs и issues через комментарии.

### Установка

```yaml
# .github/workflows/claude-code.yml
name: Claude Code Action

on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]

jobs:
  claude:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Claude Code Action
        uses: anthropics/claude-code-action@v1
        with:
          anthropic_api_key: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Trigger phrases

```markdown
<!-- В комментарии PR или issue -->

@claude explain this code

@claude fix the linting errors

@claude add tests for this function

@claude implement the feature described in #123

@claude review this PR
```

### Пример взаимодействия

**User comment:**
```
@claude add input validation to the login function
```

**Claude response:**
```markdown
I've added input validation to the login function. Changes:

1. **Email validation**
   - Check for valid email format
   - Sanitize input

2. **Password validation**
   - Minimum 8 characters
   - Require alphanumeric + special chars

3. **Error handling**
   - Clear error messages
   - Logging for security events

Committed as: abc123f

Would you like me to add rate limiting as well?
```

## PR Review Toolkit

### Установка

```bash
/plugin install pr-review-toolkit
```

### Агенты

Toolkit включает 6 специализированных агентов:

#### 1. code-reviewer
General purpose code review

#### 2. silent-failure-hunter
Поиск проблем с error handling

#### 3. pr-test-analyzer
Анализ тестового покрытия

#### 4. comment-analyzer
Проверка accuracy документации

#### 5. type-design-reviewer
Review типов и интерфейсов

#### 6. code-simplifier
Упрощение и полировка кода

### Workflow

```bash
# 1. Разработка
[write code]

# 2. Code review
"Review this code for bugs and CLAUDE.md compliance"
# → Запускается code-reviewer

# 3. Error handling check
"Check for silent failures"
# → Запускается silent-failure-hunter

# 4. Test coverage
"Are the tests comprehensive?"
# → Запускается pr-test-analyzer

# 5. Documentation
"Is the documentation accurate?"
# → Запускается comment-analyzer

# 6. Type design
"Review the type design"
# → Запускается type-design-reviewer

# 7. Polish
"Simplify and polish the code"
# → Запускается code-simplifier

# 8. Create PR
/commit-push-pr
```

### Комплексный review

```bash
"Before creating this PR, please:
1. Review test coverage
2. Check for silent failures
3. Verify comments are accurate
4. Review type design
5. General code review
6. Simplify and polish"

# Claude последовательно запустит всех агентов
```

## Интеграция с GitHub Projects

### Через GitHub CLI

```bash
# Создание issue
gh issue create --title "Feature: Add auth" --body "Description" --project "Project Name"

# Добавление в project
gh project item-add PROJECT_ID --issue ISSUE_NUMBER

# Обновление статуса
gh project item-edit --field "Status" --value "In Progress"
```

### Через MCP

```bash
@github create issue in user/repo with title "Task" and add to project "Sprint 1"
```

## Best Practices

### 1. Используйте conventional commits

```bash
# Claude автоматически следует этому в /commit
feat: Add new feature
fix: Fix bug
docs: Update documentation
style: Format code
refactor: Refactor component
test: Add tests
chore: Update dependencies
```

### 2. Автоматизируйте PR workflow

```bash
# Полный цикл в одной команде
/commit-push-pr

# Claude:
# - Создаст правильную ветку
# - Сделает информативный commit
# - Push с tracking
# - Создаст PR с контекстом
```

### 3. Регулярный code review

```bash
# Перед каждым PR
/code-review

# В CI/CD pipeline
# - Автоматический review на каждый PR
# - Блокирование merge при high severity issues
```

### 4. Используйте CLAUDE.md

```markdown
# Создайте .claude/CLAUDE.md в репозитории

## Project Guidelines

### Architecture
[Your architecture decisions]

### Code Style
[Your style preferences]

### Security
[Security requirements]

### Testing
[Testing requirements]
```

### 5. Интегрируйте с существующими tools

```bash
# Claude работает с:
# - GitHub Actions
# - gh CLI
# - git hooks
# - pre-commit
# - ESLint/Prettier
# - Jest/Vitest
```

## Troubleshooting

### gh не найден

```bash
# Установка GitHub CLI
# macOS
brew install gh

# Linux
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Аутентификация
gh auth login
```

### MCP GitHub не работает

```bash
# Проверка конфигурации
cat ~/.claude/settings.json | jq '.mcpServers.github'

# Тест OAuth
@github help
# Должен открыть браузер для авторизации

# Debug
claude --debug
tail -f ~/.claude/debug.log | grep github
```

### /code-review не находит проблем

```bash
# 1. Проверьте CLAUDE.md
cat .claude/CLAUDE.md

# 2. Убедитесь что изменения существенные
git diff main

# 3. Проверьте threshold
# По умолчанию 80+ confidence
# Ниже - не показывается

# 4. Запустите с явным промптом
"Review this PR for security issues and bugs"
```

## Заключение

GitHub Integration в Claude Code:
- **Автоматизирует workflow** от кода до PR
- **Повышает качество** через автоматический review
- **Ускоряет разработку** через умные команды
- **Интегрируется** с существующими процессами
- **Масштабируется** для команд любого размера

## Дополнительные ресурсы

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Claude Code Action](https://github.com/anthropics/claude-code-action)
- [MCP GitHub Server](https://github.com/anthropics/mcp-server-github)
- [Commit Commands Plugin](https://github.com/anthropics/claude-code/tree/main/plugins/commit-commands)
- [Code Review Plugin](https://github.com/anthropics/claude-code/tree/main/plugins/code-review)
