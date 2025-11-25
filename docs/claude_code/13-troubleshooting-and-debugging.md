# 13: Troubleshooting и Debugging

## Обзор

Этот раздел покрывает распространенные проблемы, методы диагностики и решения для Claude Code. Используйте его как справочник при возникновении проблем.

## Debug Mode

### Включение

```bash
# Запуск с debug логами
claude --debug

# Или через переменную окружения
export CLAUDE_DEBUG=1
claude
```

### Просмотр логов

```bash
# Tail debug лога
tail -f ~/.claude/debug.log

# Фильтрация по категориям
tail -f ~/.claude/debug.log | grep "MCP"
tail -f ~/.claude/debug.log | grep "Tool"
tail -f ~/.claude/debug.log | grep "Permission"
tail -f ~/.claude/debug.log | grep "Error"

# Поиск ошибок
grep "ERROR" ~/.claude/debug.log

# Последние 100 строк
tail -100 ~/.claude/debug.log
```

### Что логируется

- Tool вызовы и результаты
- Permission checks
- MCP server communication
- Hook execution
- API requests/responses
- File operations
- Errors и exceptions

## Doctor Command

### Использование

```bash
# Диагностика системы
claude /doctor

# Проверяет:
# - Версию Claude Code
# - API ключи
# - Настройки (settings.json)
# - MCP серверы
# - Permissions
# - Hooks
# - Доступ к файловой системе
```

### Типичный вывод

```
Claude Code Doctor Report
=========================

✓ Version: 1.5.0 (latest)
✓ API Key: Configured (sk-ant-...abc)
✓ Settings: ~/.claude/settings.json (valid JSON)

MCP Servers:
  ✓ github: Running (port 3001)
  ✗ postgres: Not responding
  ⚠ filesystem: Configured but not enabled

Permissions:
  ✓ allowedTools: 15 patterns defined
  ✓ deniedTools: 8 patterns defined
  ⚠ permissionMode: acceptEdits (consider manual for production)

Hooks:
  ✓ PreToolUse: 1 hook (bash-validator.py)
  ✓ PostToolUse: 2 hooks (linter, secrets-scanner)
  ✓ SessionStart: 0 hooks

Recommendations:
  1. Fix postgres MCP server connection
  2. Enable filesystem MCP server if needed
  3. Consider stricter permissionMode for production
```

## Распространенные проблемы

### 1. API Key проблемы

#### Симптомы
```
Error: Invalid API key
Error: API key not configured
Error: 401 Unauthorized
```

#### Диагностика
```bash
# Проверка наличия ключа
echo $ANTHROPIC_API_KEY

# Проверка формата (должен начинаться с sk-ant-)
echo $ANTHROPIC_API_KEY | grep "^sk-ant-"

# Тест API ключа
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-sonnet-4","max_tokens":10,"messages":[{"role":"user","content":"hi"}]}'
```

#### Решение
```bash
# Установка API key
export ANTHROPIC_API_KEY=sk-ant-your-actual-key

# Добавление в profile для постоянства
echo 'export ANTHROPIC_API_KEY=sk-ant-your-key' >> ~/.bashrc
source ~/.bashrc

# Или использование .env файла
echo 'ANTHROPIC_API_KEY=sk-ant-your-key' >> ~/.env
source ~/.env
```

### 2. Permission Denied

#### Симптомы
```
Error: Tool 'Edit' denied by permissions
Error: Command blocked by security policy
Permission denied: Cannot execute bash command
```

#### Диагностика
```bash
# Проверка текущих permissions
cat ~/.claude/settings.json | jq '.permissions'

# Проверка какой tool заблокирован
claude --debug
# Смотрим в логи: "Permission denied for tool: ..."
```

#### Решение
```bash
# Добавление разрешения в settings.json
{
  "permissions": {
    "allowedTools": [
      "Edit(path/to/your/file.js)",  // Добавить нужный паттерн
      "Bash(command:*)"               // Или команду
    ]
  }
}

# Или временно использовать более permissive mode
{
  "permissionMode": "manual"  // Будет спрашивать каждый раз
}
```

### 3. MCP Server не работает

#### Симптомы
```
Error: MCP server 'github' not responding
MCP connection timeout
Cannot connect to MCP server
```

#### Диагностика
```bash
# Проверка конфигурации
cat ~/.claude/settings.json | jq '.mcpServers'

# Тест MCP сервера отдельно
npx @anthropic-ai/mcp-server-github

# Проверка процессов
ps aux | grep mcp

# Проверка портов
lsof -i :3001  # Замените на порт вашего MCP сервера
```

#### Решение
```bash
# 1. Проверка установки пакета
npm list -g @anthropic-ai/mcp-server-github

# 2. Переустановка если нужно
npm install -g @anthropic-ai/mcp-server-github

# 3. Проверка OAuth credentials (если нужны)
echo $GITHUB_CLIENT_ID
echo $GITHUB_CLIENT_SECRET

# 4. Перезапуск Claude
# Exit и снова запустить claude
```

### 4. Plugin не загружается

#### Симптомы
```
Error: Plugin 'my-plugin' not found
Plugin validation failed
Command /my-command not recognized
```

#### Диагностика
```bash
# Список установленных plugins
/plugin list

# Валидация plugin
/plugin validate /path/to/plugin

# Проверка структуры
ls -la /path/to/plugin/
# Должны быть: README.md, commands/, agents/, etc.

# Debug логи
claude --debug
tail -f ~/.claude/debug.log | grep plugin
```

#### Решение
```bash
# 1. Переустановка plugin
/plugin uninstall plugin-name
/plugin install plugin-name

# 2. Проверка что plugin включен
/plugin enable plugin-name

# 3. Для локальных plugins - проверка пути
/plugin install /absolute/path/to/plugin

# 4. Проверка plugin.json (если есть)
cat /path/to/plugin/plugin.json
jq . /path/to/plugin/plugin.json  # Валидация JSON
```

### 5. File Access проблемы

#### Симптомы
```
Error: Cannot read file
Error: File not found
Permission denied: /path/to/file
```

#### Диагностика
```bash
# Проверка существования файла
ls -la /path/to/file

# Проверка прав доступа
stat /path/to/file

# Проверка permissions в Claude
cat ~/.claude/settings.json | jq '.permissions.allowedTools'

# Проверка sandbox settings
cat ~/.claude/settings.json | jq '.sandbox'
```

#### Решение
```bash
# 1. Проверка прав файла
chmod 644 /path/to/file  # Для чтения
chmod 644 /path/to/file  # Для записи

# 2. Добавление в allowedTools
{
  "permissions": {
    "allowedTools": [
      "Read(/path/to/file)"
    ]
  }
}

# 3. Если sandbox блокирует - добавить в unsandboxed
{
  "sandbox": {
    "allowUnsandboxedCommands": true,
    "unsandboxedCommandPatterns": [
      "cat:/path/to/file"
    ]
  }
}
```

### 6. Model не отвечает / Timeout

#### Симптомы
```
Error: Request timeout
Model taking too long to respond
Connection reset
```

#### Диагностика
```bash
# Проверка сети
ping api.anthropic.com

# Проверка proxy settings
echo $HTTP_PROXY
echo $HTTPS_PROXY

# Test API напрямую
curl -I https://api.anthropic.com

# Проверка rate limits
# В debug логах смотреть "429 Too Many Requests"
```

#### Решение
```bash
# 1. Проверка proxy (если используется)
export NO_PROXY=localhost,127.0.0.1
unset HTTP_PROXY
unset HTTPS_PROXY

# 2. Установка timeout (если нужно)
# Пока не конфигурируется, но можно попробовать retry

# 3. Проверка rate limits
# Подождать несколько минут
# Или переключиться на другую модель
/model
# Выбрать менее загруженную модель

# 4. Проверка budget (если установлен)
claude --max-budget-usd 100  # Увеличить лимит
```

### 7. Hook не выполняется

#### Симптомы
```
Hook не срабатывает
PostToolUse hook пропущен
PreToolUse validation не работает
```

#### Диагностика
```bash
# Проверка конфигурации hooks
cat ~/.claude/settings.json | jq '.hooks'

# Проверка существования hook скрипта
ls -la ~/.claude/hooks/

# Проверка прав на выполнение
ls -la ~/.claude/hooks/bash-validator.py

# Тест hook вручную
echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | \
  python3 ~/.claude/hooks/bash-validator.py

# Debug логи
claude --debug
tail -f ~/.claude/debug.log | grep hook
```

#### Решение
```bash
# 1. Сделать hook executable
chmod +x ~/.claude/hooks/bash-validator.py

# 2. Проверка shebang в скрипте
head -1 ~/.claude/hooks/bash-validator.py
# Должно быть: #!/usr/bin/env python3

# 3. Проверка зависимостей
python3 ~/.claude/hooks/bash-validator.py  # Должно запуститься

# 4. Проверка JSON конфигурации
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",  // Правильный tool name
        "hooks": [
          {
            "type": "command",
            "command": "/absolute/path/to/hook.py"  // Абсолютный путь
          }
        ]
      }
    ]
  }
}
```

### 8. Context Window заполнен

#### Симптомы
```
Error: Context window exceeded
Too many tokens in context
Cannot add more files to context
```

#### Диагностика
```bash
# Проверка текущего использования
/context

# Просмотр файлов в контексте
# Claude покажет список в /context
```

#### Решение
```bash
# 1. Очистка контекста
/clear

# 2. Использование /compact
/compact
# Сжимает conversation, сохраняя важное

# 3. Использование Explore subagent
# Вместо добавления всех файлов, спросите:
"What files implement authentication?"
# Explore subagent найдет без добавления в контекст

# 4. Selective file reading
# Читайте только нужные части файлов
# Claude может читать по частям через offset/limit
```

### 9. Git конфликты

#### Симптомы
```
Error: Merge conflict
Cannot commit: conflicts present
Git operation failed
```

#### Диагностика
```bash
# Проверка статуса
git status

# Просмотр конфликтов
git diff

# Файлы с конфликтами
git diff --name-only --diff-filter=U
```

#### Решение
```bash
# Попросите Claude разрешить
"Resolve the merge conflicts in [file]"

# Claude может:
# 1. Прочитать файл с conflict markers
# 2. Понять обе версии
# 3. Предложить resolution
# 4. Применить fix

# Или вручную
git checkout --ours file.js   # Оставить вашу версию
git checkout --theirs file.js  # Взять их версию
git add file.js
git commit
```

### 10. Thinking Mode проблемы

#### Симптомы
```
Thinking mode not showing
Tab key not toggling thinking
Extended thinking not working
```

#### Диагностика
```bash
# Проверка модели
/model
# Thinking доступен не на всех моделях

# Проверка в IDE extension
# Настройки → Claude Code → Thinking Mode
```

#### Решение
```bash
# 1. Toggle через Tab key
# Нажмите Tab для включения/выключения

# 2. Temporary disable через /t
"Your prompt /t"

# 3. Для extended thinking (Anthropic providers)
# Убедитесь что модель поддерживает
# Sonnet 4.5, Opus 4 - поддерживают
# Haiku 4.5 - использует Sonnet для planning

# 4. В IDE extension
# Кнопка toggle thinking mode в UI
```

## Debug Workflow

### Систематический подход

1. **Воспроизведение проблемы**
```bash
# Запустить с debug
claude --debug

# Повторить действия, вызывающие проблему
# Сохранить вывод и логи
```

2. **Сбор информации**
```bash
# Version
claude --version

# Doctor check
claude /doctor > doctor-report.txt

# Settings
cat ~/.claude/settings.json > settings-backup.json

# Logs
tail -200 ~/.claude/debug.log > debug-output.txt

# Environment
env | grep CLAUDE > env-vars.txt
env | grep ANTHROPIC >> env-vars.txt
```

3. **Изоляция проблемы**
```bash
# Minimal settings
mv ~/.claude/settings.json ~/.claude/settings.json.bak
echo '{}' > ~/.claude/settings.json

# Попробовать снова
# Если работает - проблема в settings

# Постепенно добавлять настройки обратно
# Определить проблемную секцию
```

4. **Тестирование решения**
```bash
# Применить fix
# Протестировать
# Проверить что не сломалось другое

# Документировать решение
echo "Problem: ..." >> ~/.claude/troubleshooting-notes.md
echo "Solution: ..." >> ~/.claude/troubleshooting-notes.md
```

## Reporting Bugs

### Использование /bug

```bash
/bug

# Claude поможет:
# 1. Собрать системную информацию
# 2. Воспроизвести проблему
# 3. Сгенерировать детальный отчет
# 4. Создать GitHub issue (опционально)
```

### GitHub Issues

**URL:** https://github.com/anthropics/claude-code/issues

**Что включить:**
1. Описание проблемы
2. Шаги воспроизведения
3. Ожидаемое поведение
4. Актуальное поведение
5. Версия Claude Code
6. Операционная система
7. Relevant логи (без секретов!)
8. Settings (без секретов!)

**Template:**
```markdown
## Description
Brief description of the issue

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- Claude Code version: 1.5.0
- OS: macOS 14.0
- Shell: zsh 5.9

## Logs
```
[Relevant log output]
```

## Settings (redacted)
```json
{
  "permissions": {...},
  "sandbox": {...}
}
```

## Additional Context
Any other relevant information
```

## Performance Issues

### Slow response

```bash
# 1. Проверка модели
/model
# Переключиться на более быструю (Haiku)

# 2. Уменьшение контекста
/compact
/context  # Проверить usage

# 3. Disable non-essential traffic
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# 4. Проверка сети
ping api.anthropic.com
traceroute api.anthropic.com
```

### High memory usage

```bash
# Проверка использования памяти
ps aux | grep claude

# Restart Claude
# Exit и снова запустить

# Уменьшение context window
/clear
# Или /compact

# Disable caching (если проблема)
# В settings.json:
{
  "caching": {
    "enabled": false
  }
}
```

## Best Practices для Debugging

### 1. Всегда используйте version control

```bash
# Перед экспериментами
git status
git stash  # Если есть изменения

# После успешного fix
git commit -m "Fix: [description]"
```

### 2. Backup configurations

```bash
# Перед изменением settings
cp ~/.claude/settings.json ~/.claude/settings.json.bak

# Или version control
cd ~/.claude
git init
git add settings.json
git commit -m "Initial settings"
```

### 3. Incremental changes

```bash
# ❌ Не меняйте всё сразу
# ✅ Меняйте по одной настройке
# Тестируйте после каждого изменения
```

### 4. Document solutions

```bash
# Создайте troubleshooting log
mkdir -p ~/.claude/docs
echo "# Troubleshooting Log" > ~/.claude/docs/troubleshooting.md

# Добавляйте решения
echo "## [Date] Problem with X" >> ~/.claude/docs/troubleshooting.md
echo "Solution: Y" >> ~/.claude/docs/troubleshooting.md
```

### 5. Test in isolation

```bash
# Минимальный test case
claude --config /tmp/minimal-settings.json

# Или в clean environment
unset ANTHROPIC_API_KEY
export ANTHROPIC_API_KEY=sk-ant-test
claude
```

## Получение помощи

### Community

- **GitHub Issues**: https://github.com/anthropics/claude-code/issues
- **Discussions**: https://github.com/anthropics/claude-code/discussions
- **Discord**: Anthropic Discord server

### Official

- **Documentation**: https://docs.claude.com/en/docs/claude-code
- **Support**: support@anthropic.com
- **Security**: https://hackerone.com/anthropic-vdp

### В Claude

```bash
# Попросите Claude помочь с troubleshooting
"I'm having an issue with [description]. Can you help debug?"

# Claude может:
# - Анализировать логи
# - Проверять настройки
# - Предлагать решения
# - Генерировать bug report
```

## Заключение

Эффективное troubleshooting требует:
- **Систематического подхода** — воспроизведение, изоляция, решение
- **Хороших инструментов** — debug mode, /doctor, логи
- **Документации** — запись решений для будущего
- **Community support** — использование ресурсов сообщества

С правильным подходом большинство проблем решаются быстро и эффективно.

## Дополнительные ресурсы

- [Debug Mode Guide](https://docs.claude.com/en/docs/claude-code/debugging)
- [Common Issues FAQ](https://docs.claude.com/en/docs/claude-code/faq)
- [GitHub Issues](https://github.com/anthropics/claude-code/issues)
- [Community Discord](https://discord.gg/anthropic)
