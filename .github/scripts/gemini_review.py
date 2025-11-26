#!/usr/bin/env python3
"""Gemini-based documentation review script for GitHub Actions."""

import os
import sys
from google import genai
from google.genai import types, errors

def main():
    api_key = os.environ.get('GEMINI_API_KEY')
    if not api_key:
        print("❌ GEMINI_API_KEY secret not configured")
        sys.exit(1)

    # Use new Google Gen AI SDK (not deprecated google-generativeai)
    try:
        client = genai.Client(api_key=api_key)
    except errors.APIError as e:
        print(f"❌ Failed to initialize Gemini client: {e.code} - {e.message}")
        sys.exit(1)
    
    # Read project context from CLAUDE.md
    project_context = ""
    try:
        with open('CLAUDE.md', 'r', encoding='utf-8') as f:
            # Read key sections for context
            content = f.read()
            # Extract project overview and key guidelines
            if '## 🎯 Обзор проекта' in content:
                start = content.find('## 🎯 Обзор проекта')
                end = content.find('## 📁 Структура проекта')
                if end > start:
                    project_context = content[start:end]
            
            # Add style guidelines
            if '## ✅ Обязательные практики' in content:
                start = content.find('## ✅ Обязательные практики')
                end = content.find('##', start + 10)
                if end > start:
                    project_context += "\n\n" + content[start:end if end != -1 else len(content)]
    except Exception as e:
        print(f"⚠️  Could not read CLAUDE.md: {e}")
    
    # Read changed files
    with open('changed_files.txt', 'r') as f:
        changed_files = [line.strip() for line in f if line.strip()]
    
    if not changed_files:
        print("✅ No documentation files to review")
        sys.exit(0)
    
    print(f"📝 Reviewing {len(changed_files)} files...")
    
    # Prepare comprehensive review for each file
    reviews = []
    all_contents = {}  # Store all file contents for cross-reference check
    
    # First pass: read all files
    for filepath in changed_files:
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                all_contents[filepath] = f.read()
        except Exception as e:
            print(f"❌ Error reading {filepath}: {e}")
    
    # Second pass: review each file with full context
    for filepath, content in all_contents.items():
        try:
            # Determine file category for context-specific checks
            file_category = "general"
            if "/r2r/" in filepath:
                file_category = "R2R v3 documentation"
            elif "/fastmcp/" in filepath:
                file_category = "FastMCP 2.x documentation"
            elif "/claude_code/" in filepath:
                file_category = "Claude Code 1.0.58+ documentation"
            elif "/.claude/" in filepath:
                file_category = "R2R integration (commands/skills/agents)"
            
            # Build prompt with project context
            prompt_parts = ["Вы - технический рецензент русскоязычной документации для AI-проектов.\n"]
            if project_context:
                prompt_parts.append(f"КОНТЕКСТ ПРОЕКТА:\n{project_context}\n")
            prompt_parts.append(f"""
ВАЖНО: Это документация-only репозиторий. Никакого кода для компиляции/тестирования.

Файл: {filepath}
Категория: {file_category}

ПРОВЕРЬТЕ ДОКУМЕНТАЦИЮ НА:

1. **Техническая точность**:
   - Корректность API endpoints и параметров
   - Соответствие версиям (R2R v3, FastMCP 2.x, Claude Code 1.0.58+)
   - Актуальность примеров кода (работают ли они?)
   - Правильность технических терминов

2. **Консистентность терминологии**:
   - Русский текст + английские термины (RAG, agent, collection, etc)
   - Единообразие названий (не "коллекция" и "collection" вперемешку)
   - Согласованность с другими разделами документации

3. **Структура и форматирование**:
   - Эмодзи в заголовках H2 (обязательно: 🎯, 📁, 🔍, ⚙️, 📚, 🔗, ⚠️, ✅, ❌)
   - Нумерация файлов: NN-section-name.md (01, 02, 03...)
   - Корректность внутренних ссылок (относительные пути)
   - Наличие примеров кода с правильным форматированием

4. **Полнота и ясность**:
   - Достаточно ли примеров?
   - Понятны ли объяснения?
   - Есть ли важные пропущенные темы?
   - Нужны ли дополнительные пояснения?

5. **Грамматика и стиль**:
   - Орфографические и грамматические ошибки
   - Читабельность текста
   - Профессиональный тон

6. **Соответствие CLAUDE.md**:
   - Следует ли файл установленным конвенциям?
   - Нет ли запрещенных действий (build scripts, package.json, etc)?
   - Используются ли современные инструменты (rg вместо grep)?

ФОРМАТ ОТВЕТА:

### ✅ Что хорошо
 - [2-3 конкретных положительных момента]

### ⚠️  Предупреждения (не критичные, но стоит улучшить)
 - [Список предупреждений с указанием строк/разделов]

### ❌ Критические ошибки (требуют обязательного исправления)
 - [Список ошибок с указанием строк и как исправить]

### 💡 Рекомендации по улучшению
 - [2-3 конкретных предложения]

### 📊 Оценка качества: X/10
 - [Краткое обоснование оценки]

Будьте конкретны: указывайте номера строк, примеры ошибок, конкретные исправления.
Если все отлично - так и напишите.

---
СОДЕРЖИМОЕ ФАЙЛА:
""")
            prompt_parts.append(content)
            prompt = "\n".join(prompt_parts)
            
            try:
                # Use new SDK method
                response = client.models.generate_content(
                    model='gemini-2.5-flash',
                    contents=prompt
                )
                if response.text:
                    reviews.append(f"## 📄 {filepath}\n\n{response.text}\n\n---\n")
                else:
                    reviews.append(f"## 📄 {filepath}\n\n⚠️ **Предупреждение**: Gemini API не вернул ответ. Возможно, превышены лимиты или проблема с настройкой.\n\n**Краткий обзор вручную:**\n- Файл содержит {len(content.split())} слов\n- Проверьте техническую точность API endpoints\n- Убедитесь в консистентности терминологии\n- Проверьте форматирование и эмодзи в заголовках\n\n---\n")
            except errors.APIError as api_error:
                print(f"⚠️ API Error: {api_error.code} - {api_error.message}")
                if api_error.code == 400:
                    reviews.append(f"## 📄 {filepath}\n\n❌ **Ошибка API (400 - Invalid API Key)**: {api_error.message}\n\n**Решение:** Проверьте правильность GEMINI_API_KEY в GitHub Secrets\n\n**Автоматическая проверка:**\n- ✅ Файл читается корректно ({len(content.split())} слов)\n- 📝 Требуется ручная проверка технической точности\n- 🔍 Проверьте внутренние ссылки и форматирование\n- 🎯 Убедитесь в наличии эмодзи в H2 заголовках\n\n---\n")
                elif api_error.code == 429:
                    reviews.append(f"## 📄 {filepath}\n\n⚠️ **Rate Limit (429)**: {api_error.message}\n\n**Автоматическая проверка:**\n- ✅ Файл читается корректно ({len(content.split())} слов)\n\n---\n")
                else:
                    reviews.append(f"## 📄 {filepath}\n\n❌ **Ошибка API ({api_error.code})**: {api_error.message}\n\n---\n")
            except Exception as api_error:
                reviews.append(f"## 📄 {filepath}\n\n❌ **Неожиданная ошибка**: {str(api_error)}\n\n---\n")
            
        except Exception as e:
            reviews.append(f"## 📄 {filepath}\n\n❌ **Ошибка при обработке файла**: {str(e)}\n\n---\n")
    
    # Third pass: check consistency across files (if multiple docs files changed)
    if len(changed_files) > 1:
        try:
            docs_files = [f for f in changed_files if f.startswith('docs/')]
            if len(docs_files) > 1:
                combined_content = "\n\n".join([
                    f"=== {filepath} ===\n{all_contents[filepath][:2000]}"
                    for filepath in docs_files[:3]  # Limit to 3 files for context window
                ])
                
                consistency_prompt = f"""Проверьте КОНСИСТЕНТНОСТЬ между файлами документации:

{combined_content}

ПРОВЕРЬТЕ:
1. Используются ли одинаковые термины для одних и тех же концепций?
2. Нет ли противоречий в описании API или функциональности?
3. Согласованы ли примеры кода?
4. Единообразен ли стиль изложения?

ФОРМАТ ОТВЕТА:
- ✅ Если консистентность соблюдена
- ⚠️  Найденные несоответствия с конкретными примерами
- 💡 Рекомендации по улучшению консистентности
"""
                
                try:
                    consistency_response = client.models.generate_content(
                        model='gemini-2.5-flash',
                        contents=consistency_prompt
                    )
                    if consistency_response.text:
                        reviews.insert(0, f"## 🔗 Проверка консистентности между файлами\n\n{consistency_response.text}\n\n---\n")
                    else:
                        reviews.insert(0, f"## 🔗 Проверка консистентности между файлами\n\n⚠️ **Gemini API недоступен для проверки консистентности**\n\nПроверьте вручную:\n- Единообразие терминологии между файлами\n- Отсутствие противоречий в описаниях API\n- Согласованность примеров кода\n\n---\n")
                except errors.APIError as api_error:
                    reviews.insert(0, f"## 🔗 Проверка консистентности между файлами\n\n❌ **Ошибка API ({api_error.code})**: {api_error.message}\n\n---\n")
                except Exception as api_error:
                    reviews.insert(0, f"## 🔗 Проверка консистентности между файлами\n\n❌ **Неожиданная ошибка**: {str(api_error)}\n\n---\n")
        except Exception as e:
            print(f"⚠️  Could not perform consistency check: {e}")
    
    # Write review to file
    with open('review_output.md', 'w', encoding='utf-8') as f:
        f.write("# 🤖 Gemini Documentation Review\n\n")
        f.write(f"**Проверено файлов:** {len(changed_files)}\n\n")
        f.write("**Контекст проекта:** Документация-only репозиторий для R2R v3, FastMCP 2.x, Claude Code 1.0.58+\n\n")
        f.write("---\n\n")
        f.write('\n'.join(reviews))
        f.write("\n---\n\n")
        f.write("*Этот обзор сгенерирован автоматически. Финальное решение за человеком-рецензентом.*\n")
    
    # Print summary
    print("\n📊 Review Summary:")
    with open('review_output.md', 'r', encoding='utf-8') as f:
        print(f.read())

if __name__ == '__main__':
    main()
