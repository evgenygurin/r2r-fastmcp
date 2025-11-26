# Документация Claude Code

Полное руководство по использованию Claude Code — официального инструмента командной строки от Anthropic для агентного программирования.

## Содержание

### Начало работы

1. **[Обзор и Быстрый Старт](./01-overview-and-getting-started.md)**
   - Что такое Claude Code
   - Ключевые возможности
   - Быстрый старт за 30 секунд
   - Системные требования

2. **[Установка и Настройка](./02-installation-and-setup.md)**
   - Системные требования
   - Методы установки (curl, NPM, специфичные версии)
   - Первоначальная настройка и аутентификация
   - Настройка окружения
   - Обновление и удаление

3. **[Основные Возможности](./03-core-features.md)**
   - Создание функций из описаний
   - Отладка и исправление ошибок
   - Навигация по кодовой базе
   - Автоматизация рутинных задач
   - Работа с файлами и командами
   - MCP интеграция
   - Best practices

### Использование

4. **[Команды и Использование](./04-commands-and-usage.md)**
   - Основные CLI команды
   - Встроенные Slash Commands
   - Создание кастомных команд
   - Управление разрешениями
   - Workflow примеры

5. **[Hooks и Кастомизация](./05-hooks-and-customization.md)**
   - Что такое hooks
   - Типы hooks (SessionStart, PreToolUse, PostToolUse и т.д.)
   - Создание custom hooks
   - Примеры hooks
   - Security considerations

6. **[Субагенты](./06-subagents.md)**
   - Концепция субагентов и их типы
   - Explore, Plan, Code Explorer, Code Architect
   - Code Reviewer, Silent Failure Hunter, PR Test Analyzer
   - Параллельное выполнение субагентов
   - Создание кастомных агентов
   - Workflow-примеры и Best practices

### Интеграции

7. **[MCP Integration](./07-mcp-integration.md)**
   - Что такое Model Context Protocol
   - Конфигурация MCP серверов (settings.json)
   - OAuth-аутентификация
   - Официальные MCP серверы (GitHub, Filesystem, Database)
   - Создание кастомных MCP серверов
   - Enterprise security (allowlists)
   - Примеры использования и best practices

8. **[Skills и Agents](./08-skills-and-agents.md)**
   - Что такое Skills и Agents
   - Структура agent definitions
   - Официальные агенты (Code Reviewer, Silent Failure Hunter, и др.)
   - Создание кастомных агентов
   - Agent vs Subagent vs Skill
   - Integration с plugins
   - Примеры и best practices

9. **[Plugins и Marketplaces](./09-plugins-and-marketplaces.md)**
   - Что такое Claude Code Plugins
   - Официальные plugins (PR Review Toolkit, Feature Dev, Code Review)
   - Установка и управление plugins
   - Структура и создание собственных plugins
   - Marketplaces (официальный, community, enterprise, приватные)
   - Best practices и troubleshooting

### Конфигурация

10. **[Settings и Configuration](./10-settings-and-configuration.md)**
    - Файл settings.json (расположение и структура)
    - Permissions (allowedTools, deniedTools, permissionMode)
    - Sandbox mode конфигурация
    - Hooks configuration
    - Status Line и MCP servers settings
    - Environment variables
    - Профили конфигурации
    - Best practices

11. **[GitHub Integration](./11-github-integration.md)**
    - Встроенная Git интеграция
    - GitHub CLI (gh) использование
    - Commit Commands Plugin (/commit, /commit-push, /commit-push-pr)
    - Code Review Plugin (автоматический PR review)
    - GitHub MCP Server с OAuth
    - Claude Code Action для GitHub
    - PR Review Toolkit (6 специализированных агентов)
    - Best practices и troubleshooting

### Безопасность и Troubleshooting

12. **[Security и Permissions](./12-security-and-permissions.md)**
    - Система permissions (allowedTools, deniedTools)
    - Sandbox mode (изоляция команд)
    - permissionMode (acceptEdits, manual, strict)
    - Best practices (Principle of Least Privilege)
    - Hooks для security валидации
    - Enterprise security (централизованные политики)
    - Compliance reporting
    - Security checklist

13. **[Troubleshooting и Debugging](./13-troubleshooting-and-debugging.md)**
    - Debug mode и просмотр логов
    - Doctor command для диагностики
    - 10+ распространенных проблем и их решений
    - Debug workflow (систематический подход)
    - Reporting bugs (/bug команда, GitHub issues)
    - Performance issues и их решение
    - Best practices для debugging

## Быстрые ссылки

### Для новичков
- [Быстрый старт](./01-overview-and-getting-started.md#быстрый-старт-за-30-секунд)
- [Установка](./02-installation-and-setup.md#методы-установки)
- [Первые команды](./04-commands-and-usage.md#основные-команды-cli)

### Для разработчиков
- [Основные возможности](./03-core-features.md)
- [Кастомные команды](./04-commands-and-usage.md#кастомные-slash-commands)
- [Hooks](./05-hooks-and-customization.md)
- [Skills](./08-skills-and-agents.md)

### Для команд
- [CLAUDE.md best practices](./03-core-features.md#claudemd-файл)
- [Settings management](./10-settings-and-configuration.md)
- [Permissions control](./12-security-and-permissions.md)
- [GitHub Actions](./11-github-integration.md)

### Для Enterprise
- [Enterprise MCP configuration](./07-mcp-integration.md#enterprise-mcp-configuration)
- [Managed settings](./10-settings-and-configuration.md#enterprise-managed-policy-settings)
- [Security considerations](./12-security-and-permissions.md)

## Полезные ресурсы

### Официальные ресурсы
- [Официальная документация](https://docs.claude.com/en/docs/claude-code/overview)
- [GitHub репозиторий](https://github.com/anthropics/claude-code)
- [Примеры использования](https://github.com/anthropics/claude-code/tree/main/examples)
- [SDK документация](https://docs.claude.com/en/docs/claude-code/sdk)

### Сообщество
- [Discord сообщество](https://discord.gg/anthropic)
- [GitHub Discussions](https://github.com/anthropics/claude-code/discussions)
- [Stack Overflow (тег: claude-code)](https://stackoverflow.com/questions/tagged/claude-code)

### Дополнительные ресурсы
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code) - curated список ресурсов
- [Claude Code Templates](https://github.com/davila7/claude-code-templates) - готовые конфигурации
- [Claude Code Cookbook](https://github.com/wasabeef/claude-code-cookbook) - рецепты и примеры

## Структура документации

Каждый раздел документации построен следующим образом:

1. **Введение** - краткий обзор темы
2. **Основные концепции** - key concepts и терминология
3. **Практические примеры** - hands-on примеры
4. **Best Practices** - рекомендации и паттерны
5. **Advanced Topics** - продвинутые техники
6. **Troubleshooting** - решение проблем
7. **Следующие шаги** - ссылки на связанные темы

## Как читать эту документацию

### Если вы новичок
1. Начните с [Обзора](./01-overview-and-getting-started.md)
2. Следуйте [Установке](./02-installation-and-setup.md)
3. Изучите [Основные возможности](./03-core-features.md)
4. Практикуйтесь с [Командами](./04-commands-and-usage.md)

### Если вы опытный пользователь
- Изучите [Hooks](./05-hooks-and-customization.md) для кастомизации
- Настройте [MCP интеграции](./07-mcp-integration.md)
- Создайте [Skills](./08-skills-and-agents.md) для специализации
- Разработайте [Plugins](./09-plugins-and-marketplaces.md) для расширения

### Если вы настраиваете для команды
- Настройте [Settings management](./10-settings-and-configuration.md)
- Внедрите [GitHub Integration](./11-github-integration.md)
- Установите [Security policies](./12-security-and-permissions.md)
- Документируйте в [CLAUDE.md](./03-core-features.md#claudemd-файл)

## Вклад в документацию

Эта документация создана на основе официальной документации Claude Code и дополнена практическими примерами.

### Источники
- [Official Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)
- [Claude Code SDK](https://docs.claude.com/en/docs/claude-code/sdk)
- [MCP Protocol](https://modelcontextprotocol.io)
- Community contributions

### Обновления
Документация регулярно обновляется в соответствии с новыми версиями Claude Code.

## Версионирование

Эта документация соответствует:
- **Claude Code версия:** 1.0.58+
- **Дата последнего обновления:** Январь 2025
- **API версия:** v3

> **Примечание:** Некоторые возможности могут отличаться в зависимости от вашей версии Claude Code. Всегда проверяйте официальную документацию для последних обновлений.

## Обратная связь

Нашли ошибку или хотите улучшить документацию? Создайте issue или pull request в репозитории проекта.

## Лицензия

Эта документация предоставляется "как есть" для образовательных целей. Claude Code и связанные торговые марки принадлежат Anthropic.

---

**Начните с:** [Обзор и Быстрый Старт →](./01-overview-and-getting-started.md)

<!-- Test update: 16:03:50 -->
