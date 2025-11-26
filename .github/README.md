# GitHub Workflows

Этот каталог содержит GitHub Actions workflows для автоматизации проверок в проекте.

## 📋 Доступные Workflows

### 1. CI - Documentation (`ci.yml`)

**Триггеры:** Push и Pull Request на ветки `main`, `develop`

**Проверки:**
- ✅ Структура документации (наличие docs/r2r, docs/fastmcp, docs/claude_code)
- ✅ README.md файлы в каждой секции
- ✅ Bash скрипты синтаксис (.claude/scripts/)
- ✅ Отсутствие .env файлов в репозитории
- ✅ Naming conventions (NN-name.md)
- ✅ Отсутствие package.json, requirements.txt

**Джобы:**
- `validate-docs` - проверка документации
- `validate-scripts` - проверка bash скриптов
- `check-formatting` - проверка форматирования
- `summary` - общий результат

### 2. Gemini Documentation Review (`gemini-docs-review.yml`)

**Триггеры:** Pull Request с изменениями в документации

**Файлы для ревью:**
- `docs/**/*.md`
- `.claude/**/*.md`
- `README.md`
- `CLAUDE.md`

**Проверки:**
- 🔍 Соответствие стандартам проекта
- 📚 Актуальность информации
- 🚫 Отсутствие противоречий
- ✍️ Грамотность и стиль
- 🏗️ Структура и навигация
- ⚠️ Специфичные требования

**Модель:** Gemini 1.5 Pro Latest

**Требует:** `GEMINI_API_KEY` secret в GitHub Settings

## 🚀 Quick Start

### Настройка CI (автоматически работает)

CI workflow не требует настройки - запускается автоматически при push/PR.

### Настройка Gemini Review

1. Получите API ключ: https://aistudio.google.com/apikey
2. Добавьте в GitHub: Settings → Secrets → Actions → New secret
   - Name: `GEMINI_API_KEY`
   - Value: ваш API ключ
3. Создайте PR с изменениями в документации
4. Gemini автоматически оставит review комментарии

**Подробная инструкция:** [GEMINI_SETUP.md](./GEMINI_SETUP.md)

## 📊 Статусы

### CI Badges

Добавьте в главный README.md:

```markdown
![CI](https://github.com/evgenygurin/r2r-fastmcp/workflows/CI%20-%20Documentation/badge.svg)
```

### Pull Request Checks

Оба workflow являются required checks для merge:
- ✅ CI - Documentation - должен пройти
- ℹ️ Gemini Review - информационный (не блокирует merge)

## 🔧 Настройка

### Изменение критериев CI

Отредактируйте `.github/workflows/ci.yml`:

```yaml
- name: Ваша новая проверка
  run: |
    # Ваши команды
```

### Изменение критериев Gemini Review

Отредактируйте `extra_prompt` в `.github/workflows/gemini-docs-review.yml`:

```yaml
extra_prompt: |
  Ты специализированный ревьюер...
  
  ДОПОЛНИТЕЛЬНЫЕ КРИТЕРИИ:
  - Ваш критерий
```

## 📚 Дополнительные ресурсы

- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **Gemini API:** https://ai.google.dev/docs
- **Project Documentation:** [../docs/](../docs/)
- **Project Guidelines:** [../CLAUDE.md](../CLAUDE.md)

## ⚠️ Troubleshooting

### CI workflow не запускается

**Решение:**
```bash
# Проверьте синтаксис YAML
yamllint .github/workflows/ci.yml

# Пересоздайте workflow
git add .github/workflows/ci.yml
git commit --amend
git push -f
```

### Gemini review не работает

**Причины:**
1. `GEMINI_API_KEY` не установлен
2. API квота исчерпана
3. Изменения не в документации

**Решение:** См. [GEMINI_SETUP.md](./GEMINI_SETUP.md#troubleshooting)

### Workflow timeout

**Для больших PR:**
```yaml
# Увеличьте timeout в workflow
timeout-minutes: 15  # было 10
```

## 🎯 Best Practices

1. **Запускайте локально перед push:**
   ```bash
   # Проверка bash скриптов
   bash -n .claude/scripts/*.sh
   
   # Проверка markdown
   find docs -name "*.md" | xargs grep -l "](/"
   ```

2. **Разбивайте большие PR** - легче для ревью и быстрее workflow

3. **Читайте комментарии Gemini** - AI может заметить неочевидные проблемы

4. **Обновляйте workflows** - при изменении структуры проекта

---

**Вопросы?** Создайте [Issue](https://github.com/evgenygurin/r2r-fastmcp/issues) или см. [CLAUDE.md](../CLAUDE.md)
