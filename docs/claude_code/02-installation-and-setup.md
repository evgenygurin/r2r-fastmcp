# Установка и настройка Claude Code

## Системные требования

Перед установкой убедитесь, что ваша система соответствует минимальным требованиям:

### Операционные системы
- **macOS:** версия 10.15 или выше
- **Linux:** Ubuntu 20.04+, Debian 10+ или совместимые дистрибутивы
- **Windows:** Windows 10+ с одним из:
  - WSL 1 (Windows Subsystem for Linux)
  - WSL 2 (рекомендуется)
  - Git for Windows

### Аппаратные требования
- **RAM:** минимум 4GB (рекомендуется 8GB+)
- **Дисковое пространство:** минимум 500MB свободного места
- **Процессор:** любой современный процессор (x64, ARM64)

### Программное обеспечение
- **Интернет:** стабильное подключение для аутентификации и AI-обработки
- **Shell:** Bash, Zsh или Fish (рекомендуется)
- **Node.js:** версия 18+ (при установке через NPM)

## Методы установки

### Метод 1: Рекомендуемая установка (curl)

#### macOS и Linux

```bash
curl -fsSL https://claude.ai/install.sh | sh
```

Этот скрипт:
1. Определяет вашу операционную систему и архитектуру
2. Скачивает соответствующий бинарный файл
3. Устанавливает Claude Code
4. Создает симлинк в `~/.local/bin/claude`
5. Добавляет путь в переменную PATH (если необходимо)

**Что делает установщик:**
- Устанавливает бинарник в `~/.claude/bin/`
- Создает конфигурационные директории
- Настраивает переменные окружения
- НЕ требует прав `sudo`

#### Windows (PowerShell)

```powershell
& ([scriptblock]::Create((irm https://claude.ai/install.ps1)))
```

**Альтернативный метод для Windows (batch):**
```batch
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

### Метод 2: Установка через NPM

```bash
npm install -g claude-code
```

> ⚠️ **ВАЖНОЕ ПРЕДУПРЕЖДЕНИЕ:** 
> НЕ используйте `sudo npm install -g`! Это может привести к:
> - Проблемам с правами доступа
> - Рискам безопасности
> - Сложностям при обновлении

**Если возникают проблемы с правами:**

Вместо использования `sudo`, настройте NPM для установки глобальных пакетов без root-прав:

```bash
# Создайте директорию для глобальных пакетов
mkdir -p ~/.npm-global

# Настройте NPM использовать эту директорию
npm config set prefix '~/.npm-global'

# Добавьте в PATH (добавьте в ~/.bashrc или ~/.zshrc)
export PATH=~/.npm-global/bin:$PATH

# Перезагрузите конфигурацию shell
source ~/.bashrc  # или source ~/.zshrc
```

Теперь можно устанавливать без sudo:
```bash
npm install -g claude-code
```

### Метод 3: Установка конкретной версии

Если вам нужна специфическая версия Claude Code:

**С помощью curl (macOS/Linux):**
```bash
curl -fsSL https://claude.ai/install.sh | sh -s 1.0.58
```

**С помощью PowerShell (Windows):**
```powershell
& ([scriptblock]::Create((irm https://claude.ai/install.ps1))) 1.0.58
```

**С помощью NPM:**
```bash
npm install -g claude-code@1.0.58
```

## Миграция к локальной установке

Если вы ранее устанавливали с `sudo`, рекомендуется мигрировать на локальную установку:

```bash
# Запустите Claude Code и выполните миграцию
claude migrate-to-local
```

Это переместит Claude Code в `~/.claude/local/` и настроит alias в конфигурации вашего shell. Больше не потребуется `sudo` для обновлений.

## Первоначальная настройка

### Шаг 1: Запуск и аутентификация

После установки запустите:

```bash
claude
```

При первом запуске вы увидите приглашение войти в систему.

**Процесс аутентификации:**

1. **Выберите метод аутентификации:**
   - Claude API (прямой доступ)
   - AWS Bedrock
   - Google Vertex AI

2. **Для Claude API:**
   ```
   Откроется браузер для входа в аккаунт Anthropic
   После входа токен автоматически сохранится
   ```

3. **Для AWS Bedrock:**
   - Настройте AWS credentials
   - Установите переменные окружения:
     ```bash
     export AWS_REGION=us-east-1
     export AWS_PROFILE=your-profile
     ```
   - См. [подробную документацию Bedrock](https://docs.claude.com/en/docs/claude-code/amazon-bedrock)

4. **Для Google Vertex AI:**
   - Настройте Google Cloud credentials
   - Установите переменные окружения:
     ```bash
     export GOOGLE_APPLICATION_CREDENTIALS=/path/to/credentials.json
     export GOOGLE_CLOUD_PROJECT=your-project-id
     ```
   - См. [подробную документацию Vertex](https://docs.claude.com/en/docs/claude-code/google-vertex-ai)

### Шаг 2: Управление учетными данными

После аутентификации учетные данные хранятся в:
- **macOS/Linux:** `~/.claude/credentials`
- **Windows:** `%USERPROFILE%\.claude\credentials`

**Безопасность учетных данных:**
- Файлы защищены правами доступа только для владельца (600)
- Токены зашифрованы
- Никогда не передавайте файлы credentials третьим лицам

**Проверка статуса аутентификации:**
```bash
claude auth status
```

**Выход из системы:**
```bash
claude auth logout
```

### Шаг 3: Проверка установки

Проверьте, что установка прошла успешно:

```bash
# Проверка версии
claude --version

# Получение справки
claude --help

# Проверка конфигурации
claude config status
```

## Настройка окружения

### Переменные окружения

Claude Code поддерживает настройку через переменные окружения:

```bash
# Модель по умолчанию
export CLAUDE_DEFAULT_MODEL=claude-3-7-sonnet

# Отключение prompt caching
export DISABLE_PROMPT_CACHING=true

# Логирование
export CLAUDE_LOG_LEVEL=debug

# Прокси настройки
export HTTP_PROXY=http://proxy.example.com:8080
export HTTPS_PROXY=http://proxy.example.com:8080
```

**Постоянная установка переменных:**

Добавьте в `~/.bashrc`, `~/.zshrc` или `~/.config/fish/config.fish`:

```bash
# Для Bash/Zsh
echo 'export CLAUDE_DEFAULT_MODEL=claude-3-7-sonnet' >> ~/.bashrc

# Для Fish
echo 'set -gx CLAUDE_DEFAULT_MODEL claude-3-7-sonnet' >> ~/.config/fish/config.fish
```

### Shell интеграция

Claude Code лучше всего работает с современными shell:

**Рекомендуемые настройки для Bash:**
```bash
# ~/.bashrc
eval "$(claude completion bash)"
```

**Для Zsh:**
```bash
# ~/.zshrc
eval "$(claude completion zsh)"
```

**Для Fish:**
```fish
# ~/.config/fish/config.fish
claude completion fish | source
```

Это добавит автодополнение для команд Claude Code.

## Настройка для конкретных сценариев

### WSL (Windows Subsystem for Linux)

Если вы используете WSL:

**WSL 1:**
- Работает из коробки
- Использует сетевой стек хоста напрямую

**WSL 2:**
- Может потребоваться дополнительная настройка сети
- Для интеграции с IDE см. раздел [Troubleshooting](./13-troubleshooting-and-debugging.md)

**Установка в WSL:**
```bash
# В WSL терминале
curl -fsSL https://claude.ai/install.sh | sh

# Добавьте в ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"
```

### Development Containers

Claude Code поддерживает работу в контейнерах разработки:

**Основные возможности:**
- Production-ready Node.js 20
- Встроенные инструменты разработки (git, ZSH, fzf)
- Кастомный firewall для безопасности
- Интеграция с VS Code
- Сохранение сессий между перезапусками

См. [подробную документацию по devcontainers](https://docs.claude.com/en/docs/claude-code/devcontainer).

### CI/CD окружения

Для использования в CI/CD (GitHub Actions, GitLab CI и т.д.):

**GitHub Actions пример:**
```yaml
- name: Install Claude Code
  run: curl -fsSL https://claude.ai/install.sh | sh

- name: Run Claude Code
  run: claude "Generate unit tests for all functions in src/"
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

См. [GitHub Actions документацию](./11-github-integration.md) для подробностей.

## Обновление Claude Code

### Автоматическое обновление

Claude Code проверяет наличие обновлений при запуске:

```bash
# Claude уведомит о доступных обновлениях
claude
# "A new version (1.0.60) is available. Run 'claude update' to install."
```

### Ручное обновление

**Для установки через curl:**
```bash
curl -fsSL https://claude.ai/install.sh | sh
```

**Для установки через NPM:**
```bash
npm update -g claude-code
```

**Проверка текущей версии:**
```bash
claude --version
```

### Откат к предыдущей версии

Если обновление вызвало проблемы:

```bash
# Установка конкретной версии
curl -fsSL https://claude.ai/install.sh | sh -s 1.0.58
```

## Удаление Claude Code

Если необходимо удалить Claude Code:

**Полное удаление:**
```bash
# Удаление бинарника
rm -rf ~/.claude

# Удаление конфигурации (опционально - сохранит ваши настройки)
# rm -rf ~/.config/claude

# Удаление учетных данных
rm -rf ~/.claude/credentials
```

**Для NPM установки:**
```bash
npm uninstall -g claude-code
rm -rf ~/.claude
```

## Проверка установки

После установки и настройки выполните проверочный тест:

```bash
# Запустите Claude Code
claude

# В интерактивном режиме введите:
"Hello Claude, what can you do?"

# Claude должен ответить описанием своих возможностей
```

## Следующие шаги

После успешной установки:
1. Изучите [Основные возможности](./03-core-features.md)
2. Ознакомьтесь с [Командами](./04-commands-and-usage.md)
3. Настройте [Разрешения](./12-security-and-permissions.md)
4. Кастомизируйте через [Настройки](./10-settings-and-configuration.md)

## Часто встречающиеся проблемы

### Проблемы с PATH

Если команда `claude` не найдена после установки:

```bash
# Проверьте, где установлен claude
which claude

# Если не найден, добавьте в PATH
export PATH="$HOME/.local/bin:$PATH"

# Сделайте постоянным (добавьте в ~/.bashrc или ~/.zshrc)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

### Проблемы с правами доступа

См. детальный раздел [Troubleshooting](./13-troubleshooting-and-debugging.md#linux-permission-issues).

### Проблемы с сетью

Если у вас есть корпоративный прокси или файрвол, настройте прокси переменные окружения.
