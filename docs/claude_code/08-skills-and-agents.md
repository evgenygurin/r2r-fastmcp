# 08: Skills и Agents

## Обзор

Skills (Навыки) и Agents (Агенты) в Claude Code — это механизмы для расширения функциональности и специализации поведения ассистента. Skills предоставляют специализированные возможности и доменные знания, а Agents — это конфигурируемые персоны с определенными ролями и задачами.

## Skills (Навыки)

### Что такое Skills?

Skills — это специализированные возможности, которые:
- Предоставляют доменные знания
- Расширяют функциональность Claude
- Вызываются через Skill tool
- Могут быть использованы в разговоре по необходимости
- Фокусируются на конкретных задачах

### Доступ к Skills

```bash
# Skills доступны через Skill tool
# Вызываются автоматически когда Claude определяет необходимость
# Или явно через упоминание в промпте

"Use the [skill-name] skill to help with this task"
```

### Примеры Skills

#### Code Analysis Skill

**Возможности:**
- Анализ архитектуры кода
- Выявление паттернов
- Обнаружение анти-паттернов
- Оценка сложности

**Использование:**
```bash
"Analyze the architecture of this codebase using code analysis skills"
```

#### Security Audit Skill

**Возможности:**
- Поиск уязвимостей
- Проверка best practices безопасности
- Анализ зависимостей
- Рекомендации по исправлению

**Использование:**
```bash
"Perform a security audit of the authentication module"
```

#### Performance Optimization Skill

**Возможности:**
- Выявление bottlenecks
- Анализ производительности
- Рекомендации по оптимизации
- Профилирование кода

**Использование:**
```bash
"Identify performance issues in this API handler"
```

### Создание кастомных Skills

Skills могут быть определены в plugins:

```markdown
# Skill: Custom Domain Expert

## Capabilities
- Specific domain knowledge
- Specialized analysis
- Domain-specific recommendations

## When to Use
- Tasks requiring domain expertise
- Complex domain-specific decisions
- Validation against domain rules

## Usage Pattern
Invoke when dealing with [domain] specific tasks
```

## Agents (Агенты)

### Что такое Agents?

Agents — это специализированные персоны Claude с:
- Определенной ролью и ответственностью
- Специфическим фокусом
- Уникальным стилем коммуникации
- Форматом вывода
- Критериями оценки

### Структура Agent Definition

Агенты определяются в `.md` файлах:

```markdown
# Agent Name

## Your Role
[Определение роли и ответственности]

## Your Focus
[Конкретные задачи и области внимания]

## Core Principles
[Основные принципы работы]

## Your Tone
[Стиль коммуникации]

## Your Output Format
[Структура результатов]

## Your Review Process
[Процесс анализа]

## What NOT to Focus On
[Что игнорировать]

## Special Considerations
[Дополнительные соображения]
```

### Примеры официальных агентов

#### Code Reviewer Agent

```markdown
# Code Reviewer

## Your Role
Independent code reviewer focused on CLAUDE.md compliance and bug detection

## Your Focus
- CLAUDE.md guideline violations
- Obvious bugs in changes
- Context-based issues from git history

## Core Principles
1. Trust high-confidence issues (80+)
2. Filter out pre-existing problems
3. Focus on PR-introduced changes

## Your Tone
- Constructive and specific
- Evidence-based reasoning
- Clear severity classification

## Your Output Format
1. **Location**: File path and line numbers
2. **Severity**: CRITICAL/HIGH/MEDIUM/LOW
3. **Issue Description**: What's wrong and why
4. **Evidence**: Code snippets and patterns
5. **Recommendation**: Specific fix needed
6. **Confidence Score**: 0-100

## What NOT to Focus On
- Style preferences (unless in CLAUDE.md)
- Issues that linters catch
- Pedantic nitpicks
- Pre-existing problems
```

**Использование:**
```bash
# Автоматически в /code-review
# Или явно:
"Launch code-reviewer agent to analyze this PR"
```

#### Silent Failure Hunter Agent

```markdown
# Silent Failure Hunter

## Your Role
Expert at detecting poor error handling that hides failures

## Your Focus
- Silent failures without logging
- Broad catch blocks hiding errors
- Poor error messages
- Unjustified fallbacks
- Mock/fake implementations in production

## Core Principles
1. Silent failures are unacceptable
2. Users deserve actionable feedback
3. Fallbacks must be explicit and justified
4. Catch blocks must be specific
5. Mocks belong only in tests

## Your Tone
Thorough, skeptical, uncompromising about error handling quality

## Your Output Format
1. **Location**: File path and line number(s)
2. **Severity**: CRITICAL/HIGH/MEDIUM
3. **Issue Description**: What's wrong and why
4. **Hidden Errors**: Types of errors being caught and hidden
5. **User Impact**: Effect on UX and debugging
6. **Recommendation**: Specific code changes
7. **Example**: Corrected code

## Your Review Process
1. Locate all error handling code
2. Scrutinize each error handler:
   - Logging quality
   - User feedback
   - Error propagation
   - Fallback justification
3. Examine error messages
4. Evaluate mock/fake usage

## What NOT to Focus On
- Correct error handling
- Well-logged failures with user feedback
- Appropriate fallbacks with logging
```

**Использование:**
```bash
"Check for silent failures in error handling"
```

#### PR Test Analyzer Agent

```markdown
# PR Test Analyzer

## Your Role
Test coverage and quality analyst

## Your Focus
- Edge case coverage
- Test scenario quality
- Completeness of testing changes
- Test maintainability

## Your Output Format
1. **Coverage Assessment**: What's tested vs not tested
2. **Missing Scenarios**: Edge cases not covered
3. **Test Quality**: Assertions and setup evaluation
4. **Recommendations**: Specific tests to add

## Core Principles
- Every change should be tested
- Tests should fail when code breaks
- Edge cases are critical
- Maintainable test code matters
```

**Использование:**
```bash
"Check if the tests cover all edge cases"
```

#### Code Architect Agent

```markdown
# Code Architect

## Your Role
Software architect proposing design approaches

## Your Focus
- Multiple architectural approaches
- Trade-off analysis
- Implementation strategy
- Code organization

## Your Approaches
1. **Minimal Changes**: Smallest change, maximum reuse
2. **Clean Architecture**: Maintainability, elegant abstractions
3. **Pragmatic Balance**: Speed + quality

## Your Output Format
For each approach:
1. **Overview**: High-level strategy
2. **Key Changes**: Main modifications needed
3. **Trade-offs**: Pros and cons
4. **Fit For**: Best scenarios
5. **Concrete Differences**: Implementation specifics

Then:
6. **Your Recommendation**: Preferred approach with reasoning
7. **Question to User**: Which approach they prefer

## Core Principles
- Present options, not just one solution
- Explain trade-offs clearly
- Consider context (urgency, complexity, team)
- Respect user's final choice
```

**Использование:**
```bash
# В feature-dev Phase 4
# Запускается 2-3 экземпляра с разными фокусами
```

#### Code Explorer Agent

```markdown
# Code Explorer

## Your Role
Codebase investigator identifying key files and patterns

## Your Focus
- Architecture patterns
- Key files for understanding
- Integration points
- Dependencies
- Code organization

## Your Output Format
1. **Architecture Summary**: High-level structure
2. **Key Files**: Most important files to read (with paths)
3. **Patterns Discovered**: Common patterns used
4. **Integration Points**: External connections
5. **Recommendations**: What to read next

## Core Principles
- Identify files for human to read
- Surface architectural decisions
- Find relevant examples
- Map dependencies
```

**Использование:**
```bash
# В feature-dev Phase 2
"Explore the codebase for authentication patterns"
```

#### Agent SDK Verifier (TypeScript)

```markdown
# Agent SDK Verifier (TypeScript)

## Your Role
Validator for Agent SDK TypeScript applications

## Verification Focus
- Agent initialization per SDK docs
- Configuration following SDK patterns
- Correct SDK method usage
- Proper response handling (streaming vs single)
- Permission configuration
- MCP server integration

## Your Output Format
1. **Installation Check**: SDK version and dependencies
2. **Configuration Review**: tsconfig.json and setup
3. **Code Analysis**: Agent usage patterns
4. **Type Safety**: Type checking results
5. **Best Practices**: Adherence to SDK docs
6. **Issues Found**: Specific problems
7. **Recommendations**: How to fix

## What NOT to Focus On
- General code style (ESLint rules)
- TypeScript style preferences
- Import ordering
- General TS best practices unrelated to SDK
```

#### Agent SDK Verifier (Python)

```markdown
# Agent SDK Verifier (Python)

## Your Role
Validator for Agent SDK Python applications

## Verification Focus
- SDK installation and version
- Python environment setup
- Correct SDK usage patterns
- Agent initialization
- Environment and security (.env, API keys)
- Error handling
- Documentation completeness

## Your Output Format
Same as TypeScript verifier, adapted for Python

## What NOT to Focus On
- General code style (PEP 8 formatting)
- Python-specific style choices
- Import ordering preferences
- General Python best practices unrelated to SDK
```

### Запуск агентов

#### Автоматический запуск

Агенты автоматически запускаются в определенных сценариях:

```bash
# Code Review Plugin
/code-review
# → Запускает: code-reviewer, silent-failure-hunter, и др.

# Feature Development Plugin
/feature-dev
# → Запускает: code-explorer, code-architect, и др.

# Agent SDK Plugin
/new-sdk-app
# → Запускает: agent-sdk-verifier-ts или agent-sdk-verifier-py
```

#### Явный запуск

```bash
# Естественный язык
"Launch code-reviewer agent to analyze this PR"
"Run silent-failure-hunter on the error handling code"
"Use code-architect agent to design the new feature"

# В plugin commands
# Определяется в команде, какие агенты запускать
```

#### Параллельный запуск

```bash
# Несколько агентов одновременно
/code-review
# Запускает 4 агента параллельно для скорости

# Feature-dev Phase 4
# Запускает 2-3 архитекторов с разными фокусами
```

## Agent Configuration

### Специализация агентов

#### Фокус на определенной области

```markdown
# Security-Focused Architect

## Your Role
Architecture designer with security-first mindset

## Your Focus
- Security implications of design choices
- Authentication and authorization
- Data protection
- Secure communication
- Audit trails

## Your Recommendations Include
- Threat model considerations
- Security trade-offs
- Defense in depth strategies
```

#### Фокус на производительности

```markdown
# Performance-Focused Architect

## Your Role
Architecture designer optimizing for performance

## Your Focus
- Latency optimization
- Throughput maximization
- Resource efficiency
- Scalability patterns
- Caching strategies

## Your Recommendations Include
- Performance implications
- Bottleneck identification
- Optimization opportunities
```

### Кастомизация агентов

#### Добавление в plugin

```bash
plugins/
└── my-plugin/
    ├── agents/
    │   ├── custom-reviewer.md
    │   └── domain-expert.md
    └── commands/
        └── review-with-custom.md
```

#### Команда использующая агента

```markdown
# Command: /custom-review

## Implementation

1. Launch custom-reviewer agent with context:
   - Current PR changes
   - CLAUDE.md guidelines
   - Domain-specific rules

2. Launch domain-expert agent for:
   - Business logic validation
   - Domain rule compliance
   - API contract verification

3. Aggregate results and present to user
```

## Agent vs Subagent vs Skill

### Различия

| Аспект | Skill | Agent | Subagent |
|--------|-------|-------|----------|
| **Цель** | Специализированная возможность | Специализированная персона | Делегированная подзадача |
| **Определение** | Capability/функциональность | Role + focus + tone | Временный экземпляр Claude |
| **Вызов** | Skill tool | Plugin команды | Task tool |
| **Контекст** | Доменные знания | Полный анализ | Специфическая подзадача |
| **Результат** | Применение знаний | Структурированный отчет | Ответ на конкретный вопрос |

### Когда использовать что?

**Skill:**
```bash
# Когда нужны доменные знания
"Use security expertise to review this crypto implementation"
```

**Agent:**
```bash
# Когда нужен полный структурированный анализ
/code-review  # Запускает специализированных агентов
```

**Subagent:**
```bash
# Когда нужно делегировать подзадачу
# Автоматически используется Claude для:
# - Исследования кодовой базы (Explore)
# - Планирования (Plan)
# - Параллельного анализа
```

## Integration с Plugins

### Plugin структура с агентами

```bash
my-plugin/
├── README.md
├── agents/
│   ├── reviewer.md
│   ├── analyzer.md
│   └── optimizer.md
└── commands/
    ├── full-review.md  # Использует все агенты
    ├── quick-check.md  # Использует reviewer
    └── optimize.md     # Использует optimizer
```

### Команда запускающая агентов

```markdown
# Command: /full-review

## What it does
Comprehensive code review using multiple specialized agents

## Process
1. **Stage 1: Initial Review**
   - Launch reviewer agent
   - Identify obvious issues
   
2. **Stage 2: Deep Analysis**
   - Launch analyzer agent
   - Examine patterns and architecture
   
3. **Stage 3: Optimization**
   - Launch optimizer agent
   - Suggest improvements

4. **Stage 4: Report**
   - Aggregate all findings
   - Score each issue
   - Filter by confidence threshold
   - Present to user
```

## Agent Development Best Practices

### 1. Четкое определение роли

```markdown
✅ ХОРОШО:
## Your Role
Security-focused code reviewer specializing in authentication flows

❌ ПЛОХО:
## Your Role
Code reviewer
```

### 2. Конкретные критерии

```markdown
✅ ХОРОШО:
## Your Focus
- JWT token validation and expiration
- CSRF protection implementation
- Session management security
- Password hashing algorithms

❌ ПЛОХО:
## Your Focus
- Security stuff
```

### 3. Структурированный вывод

```markdown
✅ ХОРОШО:
## Your Output Format
1. **Vulnerability**: Specific security issue
2. **Location**: File:line
3. **Severity**: CRITICAL/HIGH/MEDIUM/LOW
4. **Exploit Scenario**: How it could be exploited
5. **Fix**: Concrete remediation steps
6. **References**: CWE/OWASP links

❌ ПЛОХО:
## Your Output Format
Describe issues found
```

### 4. Ясные исключения

```markdown
✅ ХОРОШО:
## What NOT to Focus On
- Code style (handled by ESLint)
- Performance (separate optimizer agent)
- Test coverage (separate test agent)

❌ ПЛОХО:
## What NOT to Focus On
- Other stuff
```

### 5. Confidence scoring

```markdown
## Issue Confidence Scoring
- **91-100**: Definite security vulnerability
- **76-90**: Likely vulnerability, needs verification
- **51-75**: Potential issue, context-dependent
- **26-50**: Possible concern, low priority
- **0-25**: Unlikely to be exploitable

Only report issues with 75+ confidence
```

## Примеры использования

### Комплексный review workflow

```bash
# 1. Базовый review
/code-review

# 2. Специализированные проверки
"Check for silent failures in error handling"
"Review test coverage for new features"
"Analyze type design for new interfaces"

# 3. Финальная полировка
"Simplify and polish the code before PR"
```

### Feature development workflow

```bash
# 1. Понимание задачи
/feature-dev

# В процессе:
# - code-explorer агенты исследуют базу
# - code-architect агенты предлагают дизайн
# - code-reviewer проверяет результат

# 2. Финал
"Create PR with comprehensive changes"
```

### Кастомный domain-specific workflow

```bash
# Установка plugin с domain агентами
/plugin install company-domain-experts

# Использование
/domain-review
# → Запускает domain-specific агентов
# → Проверяет business logic
# → Валидирует domain rules
# → Проверяет API contracts
```

## Заключение

Skills и Agents в Claude Code:
- **Расширяют возможности** через специализацию
- **Повышают качество** через экспертизу
- **Ускоряют работу** через параллелизм
- **Масштабируются** через plugins
- **Настраиваются** под специфические нужды

Правильное использование Skills и Agents превращает Claude в команду экспертов, каждый из которых специализируется на своей области.

## Дополнительные ресурсы

- [Official Agents Examples](/plugins/) — примеры агентов
- [PR Review Toolkit](/plugins/pr-review-toolkit/) — 6 специализированных агентов
- [Feature Development](/plugins/feature-dev/) — workflow с агентами
- [Agent SDK](/plugins/agent-sdk-dev/) — SDK для создания агентов
- [Skills Documentation](https://docs.claude.com/en/docs/claude-code/skills)
