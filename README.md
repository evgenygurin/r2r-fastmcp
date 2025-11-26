# R2R FastMCP Documentation

> Полная русскоязычная документация по ключевым технологиям для AI-разработки: R2R, FastMCP и Claude Code

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Language: Russian](https://img.shields.io/badge/Language-Russian-blue.svg)](https://github.com/evgenygurin/r2r-fastmcp)

## 📚 О проекте

Этот репозиторий содержит детальную документацию на русском языке для трех технологий, которые вместе формируют мощный стек для AI-разработки:

### 🔷 [R2R](./docs/r2r/) - RAG to Riches
Production-ready система retrieval-augmented generation с:
- Vector Search (семантический поиск)
- Full-Text Search (полнотекстовый поиск)
- Knowledge Graphs (графы знаний)
- Agentic RAG (агентные системы)
- Multi-User Support (коллекции, аутентификация)

**Версия:** v3.x
**Документация:** [docs/r2r/README.md](./docs/r2r/README.md)

### 🔷 [FastMCP](./docs/fastmcp/) - Model Context Protocol Server
Pythonic фреймворк для создания серверов и клиентов MCP:
- Декораторы для быстрого создания tools, resources, prompts
- Context injection и dependency management
- HTTP и Stdio транспорты
- JWT и OAuth аутентификация
- Middleware и error handling
- FastAPI и OpenAPI интеграция

**Версия:** 2.x
**Документация:** [docs/fastmcp/README.md](./docs/fastmcp/README.md)

### 🔷 [Claude Code](./docs/claude_code/) - AI-Powered CLI
Официальный инструмент от Anthropic для агентного программирования:
- Субагенты для специализированных задач
- Hooks и кастомизация workflow
- MCP Integration для расширения возможностей
- Skills и Agents
- Plugins и Marketplaces
- GitHub Integration

**Версия:** 1.0.58+
**Документация:** [docs/claude_code/README.md](./docs/claude_code/README.md)

---

## ⚙️ R2R Integration

Репозиторий включает полную интеграцию с R2R v3 API:

### Modular CLI (8 команд, 48 подкоманд)
```bash
.claude/scripts/r2r search "query" --limit 5
.claude/scripts/r2r rag "question" --show-sources
.claude/scripts/r2r agent "query" --mode research --thinking
.claude/scripts/r2r docs list -l 10 -q
.claude/scripts/r2r collections create -n "Name"
.claude/scripts/r2r conversation list
.claude/scripts/r2r graph entities <id> -l 50
.claude/scripts/r2r analytics system
```

### Slash Commands (15)
- **R2R Core:** `/r2r-search`, `/r2r-rag`, `/r2r-agent`
- **R2R Management:** `/r2r-collections`, `/r2r-upload`, `/r2r`
- **R2R Helpers:** `/r2r-examples`, `/r2r-workflows`, `/r2r-quick`
- **Claude Code:** `/cc`, `/cc-hooks`, `/cc-commands`, `/cc-mcp`, `/cc-subagents`, `/cc-setup`

### Helper Scripts
- `examples.sh` - 50+ interactive examples
- `workflows.sh` - 5 automated workflows
- `quick.sh` - 10 quick tasks
- `aliases.sh` - shell shortcuts

### Agents & Skills
- 3 специализированных агента
- 3 skills для R2R

Подробнее: [.claude/README.md](.claude/README.md)

---

## 🤖 GitHub Workflows

Репозиторий включает автоматизацию через Claude Code GitHub Actions:

### Доступные workflows
- **claude-code-review.yml** - автоматический code review для Pull Requests с интеграцией @codegen
- **ci-failure-auto-fix.yml** - автоматическое исправление упавших CI тестов
- **issue-triage.yml** - автоматическая сортировка новых issues
- **issue-deduplication.yml** - поиск дубликатов issues
- **manual-code-analysis.yml** - ручной запуск анализа кода
- **test-failure-analysis.yml** - анализ упавших тестов

### Требования
- `CLAUDE_CODE_OAUTH_TOKEN` в GitHub repository secrets
- Доступ к `anthropics/claude-code-action@v1`
- Настроенный `@codegen` bot для автоматических исправлений

См. [docs/claude_code/11-github-integration.md](./docs/claude_code/11-github-integration.md) для деталей.

---

## 🚀 Быстрый старт

### Навигация по документации

```bash
# Полная документация R2R (8 разделов)
docs/r2r/README.md

# Полная документация FastMCP (8 разделов)
docs/fastmcp/README.md

# Полная документация Claude Code (13 разделов)
docs/claude_code/README.md
```

### R2R Quick Start

```bash
# Поиск в knowledge base
.claude/scripts/r2r search "R2R documentation" --limit 5

# RAG запрос
.claude/scripts/r2r rag "Как настроить hybrid search?"

# Agent conversation
.claude/scripts/r2r agent "Explain transformers" --thinking

# Через slash commands
/r2r-search "query" 5
/r2r-rag "question"
/r2r-agent "message" research
```

### Quick Reference

Для работы с репозиторием через Claude Code доступен **[CLAUDE.md](./CLAUDE.md)** - справочник с:
- Quick Reference для всех трех технологий
- API endpoints, SDK примеры, конфигурации
- Паттерны интеграции технологий
- Команды и workflow

---

## 📖 Содержание документации

### R2R Documentation (8 разделов)

1. **[Installation and Setup](./docs/r2r/01-installation-and-setup.md)** - Docker, Python/JS SDK, GCP deployment
2. **[Document Management](./docs/r2r/02-document-management.md)** - Ingestion, metadata, lifecycle
3. **[Search and RAG](./docs/r2r/03-search-and-rag.md)** - Vector, full-text, hybrid search, RAG queries
4. **[Knowledge Graphs](./docs/r2r/04-knowledge-graphs.md)** - Entities, relationships, communities
5. **[Collections](./docs/r2r/05-collections.md)** - Organization, access control, permissions
6. **[Authentication and Users](./docs/r2r/06-authentication-and-users.md)** - JWT, API keys, RBAC
7. **[Configuration](./docs/r2r/07-configuration.md)** - r2r.toml, environment variables, tuning
8. **[Agent](./docs/r2r/08-agent.md)** - RAG mode, Research mode, tools, conversations

### FastMCP Documentation (8 разделов)

1. **[Introduction](./docs/fastmcp/01-introduction.md)** - Что такое FastMCP, установка, quick start
2. **[Tools](./docs/fastmcp/02-tools.md)** - Создание и настройка инструментов
3. **[Resources & Prompts](./docs/fastmcp/03-resources-prompts.md)** - Ресурсы и промпты
4. **[Client & Connection](./docs/fastmcp/04-client-connection.md)** - Транспорты, подключение
5. **[Authentication](./docs/fastmcp/05-authentication.md)** - JWT, OAuth, security
6. **[Deployment & Configuration](./docs/fastmcp/06-deployment-configuration.md)** - Docker, K8s, Cloud
7. **[Middleware & Error Handling](./docs/fastmcp/07-middleware-error-handling.md)** - Middleware, exceptions
8. **[FastAPI & OpenAPI Integration](./docs/fastmcp/08-fastapi-openapi.md)** - Интеграция с API

### Claude Code Documentation (13 разделов)

1. **[Overview](./docs/claude_code/01-overview-and-getting-started.md)** - Что такое Claude Code, возможности
2. **[Installation](./docs/claude_code/02-installation-and-setup.md)** - Установка, аутентификация
3. **[Core Features](./docs/claude_code/03-core-features.md)** - Основные возможности, CLAUDE.md
4. **[Commands](./docs/claude_code/04-commands-and-usage.md)** - CLI, Slash Commands
5. **[Hooks](./docs/claude_code/05-hooks-and-customization.md)** - Кастомизация workflow
6. **[Subagents](./docs/claude_code/06-subagents.md)** - 9 типов субагентов
7. **[MCP Integration](./docs/claude_code/07-mcp-integration.md)** - Model Context Protocol
8. **[Skills & Agents](./docs/claude_code/08-skills-and-agents.md)** - Специализированные агенты
9. **[Plugins](./docs/claude_code/09-plugins-and-marketplaces.md)** - Расширения, Marketplaces
10. **[Settings](./docs/claude_code/10-settings-and-configuration.md)** - Конфигурация, permissions
11. **[GitHub Integration](./docs/claude_code/11-github-integration.md)** - Git, PR Review
12. **[Security](./docs/claude_code/12-security-and-permissions.md)** - Sandbox, Enterprise
13. **[Troubleshooting](./docs/claude_code/13-troubleshooting-and-debugging.md)** - Debug, Doctor

---

## 🔗 Интеграции

### R2R API Integration
Полная интеграция с R2R v3 через модульный bash CLI:
- GNU-style флаги (`--limit`, `-l`, `--quiet`, `-q`)
- Три режима вывода: default, quiet, JSON
- 8 команд с 48 подкомандами
- Slash commands для Claude Code

### Claude Code Integration
- 15 slash commands для быстрого доступа
- 3 специализированных агента
- Hooks для автоматизации
- CLAUDE.md для контекста проекта

Подробнее в [.claude/README.md](.claude/README.md)

---

## 🛠️ Для разработчиков

### Структура репозитория

```text
r2r-fastmcp/
├── docs/
│   ├── r2r/              # R2R v3 документация (8 разделов)
│   ├── fastmcp/          # FastMCP 2.x документация (8 разделов)
│   └── claude_code/      # Claude Code документация (13 разделов)
├── .claude/              # Claude Code интеграция
│   ├── commands/         # 15 slash commands
│   ├── scripts/          # Модульный R2R CLI (8 команд, 48 подкоманд)
│   ├── agents/           # 3 специализированных агента
│   ├── skills/           # 3 R2R skills
│   ├── hooks/            # Lifecycle hooks
│   └── config/           # .env конфигурация
├── CLAUDE.md             # Project memory для Claude Code
└── README.md             # Этот файл
```

### Работа с документацией

```bash
# Поиск по содержимому
rg "search term" docs/

# Поиск файлов
fd -e md . docs/

# Статистика
fd -e md . docs | wc -l  # Количество файлов
```

### Стандарты

- **Язык**: Русский (текст) + English (код, термины, API)
- **Формат**: Markdown (GitHub Flavored)
- **Стиль**: Эмодзи в заголовках, практические примеры
- **Коммиты**: `type(scope): description` (без подписей, одна строка)

---

## 📝 Вклад в проект

Если вы нашли ошибку или хотите улучшить документацию:

1. Fork репозитория
2. Создайте feature branch (`git checkout -b docs/improve-section`)
3. Внесите изменения
4. Commit (`git commit -m "docs(r2r): add search examples"`)
5. Push (`git push origin docs/improve-section`)
6. Создайте Pull Request

---

## 📚 Полезные ссылки

### Официальные ресурсы

**R2R:**
- [GitHub](https://github.com/sciphi-ai/r2r)
- [Documentation](https://r2r-docs.sciphi.ai)
- [Python SDK](https://github.com/sciphi-ai/r2r/tree/main/py/sdk)
- [JavaScript SDK](https://github.com/sciphi-ai/r2r/tree/main/js)

**FastMCP:**
- [GitHub](https://github.com/jlowin/fastmcp)
- [Documentation](https://gofastmcp.com)
- [FastMCP Cloud](https://fastmcp.cloud)

**Claude Code:**
- [Official Documentation](https://docs.claude.com/en/docs/claude-code/overview)
- [GitHub Repository](https://github.com/anthropics/claude-code)
- [SDK Documentation](https://docs.claude.com/en/docs/claude-code/sdk)

### Сообщества

- [MCP Protocol](https://modelcontextprotocol.io)
- [Anthropic Discord](https://discord.gg/anthropic)
- [LiteLLM Documentation](https://docs.litellm.ai/)

---

## 📄 Лицензия

MIT License - см. LICENSE для деталей.

Документация создана на основе официальных источников и дополнена практическими примерами.

---

## 🎯 Статус

- **R2R Documentation**: ✅ Полная (8/8 разделов)
- **FastMCP Documentation**: ✅ Полная (8/8 разделов)
- **Claude Code Documentation**: ✅ Полная (13/13 разделов)
- **CLAUDE.md Quick Reference**: ✅ Готов

**Последнее обновление:** Ноябрь 2025

---

**Автор:** [evgenygurin](https://github.com/evgenygurin)
**Репозиторий:** [github.com/evgenygurin/r2r-fastmcp](https://github.com/evgenygurin/r2r-fastmcp)
