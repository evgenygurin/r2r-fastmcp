#!/usr/bin/env python3
"""
Codegen Orchestration Manager - AI-powered code generation supervisor with R2R context.

This script transforms the repository from a documentation reviewer to a code generation
orchestrator, leveraging:
- Codegen.com agents for AI-powered code generation
- R2R knowledge base for project context and best practices
- GitHub Actions integration for CI/CD workflows

Based on Codegen documentation from R2R knowledge base:
- Codegen agents work with 100+ tools and integrations
- Support for GitHub, Slack, Linear, databases, and MCP servers
- Sandboxed execution environments for safe code generation
- SOC 2 Type I & II certified security
"""

import os
import sys
import json
import time
from typing import Dict, List, Optional, Any
from pathlib import Path

# Check required dependencies
try:
    from codegen import Agent
    CODEGEN_AVAILABLE = True
except ImportError:
    print("⚠️  Codegen SDK not installed. Install with: pip install codegen")
    print("   Falling back to API-only mode")
    CODEGEN_AVAILABLE = False

try:
    import requests
    REQUESTS_AVAILABLE = True
except ImportError:
    print("❌ Requests library required. Install with: pip install requests")
    sys.exit(1)


class R2RContextProvider:
    """
    Provides project context from R2R knowledge base via MCP integration.
    
    Uses R2R's hybrid search (semantic + full-text) to retrieve relevant
    documentation, best practices, and code examples.
    """
    
    def __init__(self, base_url: str, api_key: str):
        self.base_url = base_url.rstrip('/')
        self.api_key = api_key
        self.headers = {
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json'
        }
        self._verify_connection()
    
    def _verify_connection(self):
        """Verify R2R connection is working."""
        try:
            response = requests.get(
                f'{self.base_url}/v3/health',
                headers=self.headers,
                timeout=10
            )
            response.raise_for_status()
            print("✅ R2R connection verified")
        except Exception as e:
            print(f"⚠️  R2R connection warning: {e}")
    
    def search_knowledge_base(self, query: str, limit: int = 5) -> List[Dict[str, Any]]:
        """
        Search R2R knowledge base using hybrid search (semantic + full-text).
        
        Based on R2R best practices:
        - use_hybrid_search: true (combines vector + keyword search)
        - search_strategy: vanilla (most reliable)
        - limit: 3-5 for focused context
        """
        try:
            response = requests.post(
                f'{self.base_url}/v3/retrieval/search',
                headers=self.headers,
                json={
                    'query': query,
                    'search_settings': {
                        'use_hybrid_search': True,  # Semantic + full-text
                        'search_strategy': 'vanilla',  # Most reliable strategy
                        'limit': limit
                    }
                },
                timeout=30
            )
            response.raise_for_status()
            data = response.json()
            
            # Extract chunk_search_results
            results = data.get('results', {})
            if isinstance(results, dict):
                chunks = results.get('chunk_search_results', [])
            else:
                chunks = []
            
            print(f"📚 Found {len(chunks)} relevant context chunks from R2R")
            return chunks
            
        except Exception as e:
            print(f"⚠️  R2R search failed: {e}")
            return []
    
    def get_rag_answer(self, question: str, max_tokens: int = 4000) -> Optional[str]:
        """
        Get AI-generated answer with RAG (Retrieval-Augmented Generation).
        
        Uses R2R's RAG endpoint to retrieve relevant docs and generate
        a comprehensive answer with citations.
        """
        try:
            response = requests.post(
                f'{self.base_url}/v3/retrieval/rag',
                headers=self.headers,
                json={
                    'query': question,
                    'rag_generation_config': {
                        'max_tokens': max_tokens,
                        'temperature': 0.1,  # Low temp for factual accuracy
                        'stream': False
                    },
                    'search_settings': {
                        'use_hybrid_search': True,
                        'search_strategy': 'vanilla',
                        'limit': 5
                    }
                },
                timeout=60
            )
            response.raise_for_status()
            data = response.json()
            
            # Extract answer from nested structure
            results = data.get('results', {})
            completion = results.get('completion', {})
            choices = completion.get('choices', [])
            if choices:
                message = choices[0].get('message', {})
                content = message.get('content')
                if content:
                    print(f"💡 Got RAG answer from R2R ({len(content)} chars)")
                    return content
            
            return None
            
        except Exception as e:
            print(f"⚠️  R2R RAG query failed: {e}")
            return None
    
    def get_project_guidelines(self) -> str:
        """Load project guidelines from CLAUDE.md file."""
        try:
            claude_md = Path('CLAUDE.md')
            if claude_md.exists():
                content = claude_md.read_text(encoding='utf-8')
                print(f"📖 Loaded CLAUDE.md ({len(content)} chars)")
                return content
            return ""
        except Exception as e:
            print(f"⚠️  Could not read CLAUDE.md: {e}")
            return ""
    
    def store_generation_result(self, content: str, metadata: Dict[str, Any]) -> bool:
        """Store generated code/result back to R2R for future reference."""
        try:
            # Store as text document with metadata
            response = requests.post(
                f'{self.base_url}/v3/documents',
                headers=self.headers,
                files={
                    'file': ('codegen_result.txt', content.encode('utf-8'), 'text/plain')
                },
                data={
                    'metadata': json.dumps(metadata)
                },
                timeout=30
            )
            response.raise_for_status()
            print("✅ Stored generation result in R2R")
            return True
        except Exception as e:
            print(f"⚠️  Failed to store result in R2R: {e}")
            return False


class CodegenOrchestrator:
    """
    Orchestrates Codegen agents with R2R context integration.
    
    Based on Codegen capabilities from R2R documentation:
    - Analyze requirements and implement features
    - Fix bugs and write tests
    - Improve documentation
    - Create PRs and manage repositories
    - Chat in Slack and update tickets
    """
    
    def __init__(self, org_id: str, api_token: str, r2r_provider: R2RContextProvider):
        self.org_id = org_id
        self.api_token = api_token
        self.r2r = r2r_provider
        
        if CODEGEN_AVAILABLE:
            self.agent = Agent(org_id=org_id, token=api_token)
            print("✅ Codegen SDK initialized")
        else:
            self.agent = None
            print("⚠️  Running without Codegen SDK (API calls only)")
    
    def _extract_key_guidelines(self, guidelines: str) -> str:
        """Extract key sections from CLAUDE.md for prompt."""
        sections = []
        
        # Extract project overview
        if '## 🎯 Обзор проекта' in guidelines:
            start = guidelines.find('## 🎯 Обзор проекта')
            end = guidelines.find('## 📁', start)
            if end > start:
                sections.append(guidelines[start:end])
        
        # Extract coding practices
        if '## ✅ Обязательные практики' in guidelines:
            start = guidelines.find('## ✅ Обязательные практики')
            end = guidelines.find('##', start + 10)
            if end > start:
                sections.append(guidelines[start:end])
        
        return '\n\n'.join(sections)
    
    def build_enriched_prompt(self, task_description: str, files: List[str]) -> str:
        """
        Build enriched prompt with R2R context following Codegen Agent Rules best practices.
        
        Based on R2R documentation:
        - Agent rules provide coding standards and conventions
        - Rules are text prompts injected into agent context
        - Preference order: User > Repository > Organization rules
        """
        prompt_parts = [
            "# CODEGEN TASK\n",
            f"{task_description}\n",
            "\n## PROJECT CONTEXT & AGENT RULES\n"
        ]
        
        # 1. Load project guidelines (Repository-level rules)
        guidelines = self.r2r.get_project_guidelines()
        if guidelines:
            key_sections = self._extract_key_guidelines(guidelines)
            if key_sections:
                prompt_parts.append("### Repository Rules (from CLAUDE.md)\n")
                prompt_parts.append(key_sections[:2000])  # Limit to 2000 chars
                prompt_parts.append("\n")
        
        # 2. Search R2R for relevant best practices
        print(f"🔍 Searching R2R for: '{task_description[:100]}...'")
        
        # Get best practices from R2R
        best_practices_query = f"best practices for {task_description}"
        rag_answer = self.r2r.get_rag_answer(best_practices_query, max_tokens=2000)
        
        if rag_answer:
            prompt_parts.append("\n### Best Practices from Knowledge Base\n")
            prompt_parts.append(rag_answer[:1500])
            prompt_parts.append("\n")
        
        # 3. Add relevant code examples from R2R
        search_results = self.r2r.search_knowledge_base(task_description, limit=3)
        
        if search_results:
            prompt_parts.append("\n### Relevant Documentation & Examples\n")
            for idx, result in enumerate(search_results, 1):
                text = result.get('text', '')
                metadata = result.get('metadata', {})
                score = result.get('score', 0)
                
                prompt_parts.append(f"\n#### Context {idx} (relevance: {score:.3f})\n")
                
                # Add source info
                title = metadata.get('title', 'Unknown')
                doc_type = metadata.get('document_type', '')
                prompt_parts.append(f"**Source:** {title} ({doc_type})\n\n")
                
                # Add content preview (limit to 400 chars per chunk)
                content_preview = text[:400]
                if len(text) > 400:
                    content_preview += "..."
                prompt_parts.append(f"```\n{content_preview}\n```\n")
        
        # 4. Add changed files context
        if files:
            prompt_parts.append("\n## CHANGED FILES\n")
            prompt_parts.append(f"Total files: {len(files)}\n\n")
            
            for filepath in files[:5]:  # Limit to first 5 files
                try:
                    file_path = Path(filepath)
                    if file_path.exists():
                        content = file_path.read_text(encoding='utf-8')
                        ext = file_path.suffix[1:] if file_path.suffix else 'txt'
                        
                        prompt_parts.append(f"### {filepath}\n")
                        
                        # Add file preview (limit to 800 chars per file)
                        content_preview = content[:800]
                        if len(content) > 800:
                            content_preview += "\n... (truncated)"
                        
                        prompt_parts.append(f"```{ext}\n{content_preview}\n```\n\n")
                except Exception as e:
                    print(f"⚠️  Could not read {filepath}: {e}")
        
        # 5. Add task-specific instructions
        prompt_parts.append("\n## INSTRUCTIONS\n")
        prompt_parts.append("""
Please follow these guidelines:
1. Follow the repository rules and coding standards from CLAUDE.md
2. Apply best practices from the knowledge base
3. Reference relevant documentation and examples
4. Ensure code quality, readability, and maintainability
5. Include proper error handling and comments
6. Write tests for new functionality where appropriate
""")
        
        final_prompt = "\n".join(prompt_parts)
        print(f"📝 Built enriched prompt ({len(final_prompt)} chars)")
        return final_prompt
    
    def run_codegen_task(self, task_description: str, files: List[str] = None,
                         wait_for_completion: bool = True, max_wait_time: int = 300) -> Dict[str, Any]:
        """
        Run a Codegen agent task with R2R context enrichment.
        
        Returns:
            Dict with task_id, status, result, and execution_time
        """
        files = files or []
        
        print(f"\n🚀 Starting Codegen orchestration...")
        print(f"   Task: {task_description}")
        print(f"   Files: {len(files)} files")
        
        # Build enriched prompt with R2R context
        enriched_prompt = self.build_enriched_prompt(task_description, files)
        
        # Run Codegen agent
        if not self.agent:
            print("❌ Codegen agent not available (SDK not installed)")
            return {
                'task_id': None,
                'status': 'error',
                'result': None,
                'error': 'Codegen SDK not available'
            }
        
        try:
            task = self.agent.run(prompt=enriched_prompt)
            task_id = task.id if hasattr(task, 'id') else 'unknown'
            
            print(f"✅ Task created: {task_id}")
            print(f"   Initial status: {task.status}")
            
            if not wait_for_completion:
                return {
                    'task_id': task_id,
                    'status': task.status,
                    'result': None,
                    'execution_time': 0
                }
            
            # Poll for completion
            start_time = time.time()
            last_status = task.status
            poll_count = 0
            
            while task.status not in ['completed', 'failed', 'cancelled']:
                elapsed = time.time() - start_time
                
                if elapsed > max_wait_time:
                    print(f"⏱️  Task timeout after {max_wait_time}s")
                    break
                
                time.sleep(5)  # Poll every 5 seconds
                poll_count += 1
                
                try:
                    task.refresh()
                except Exception as e:
                    print(f"⚠️  Error refreshing task: {e}")
                    break
                
                if task.status != last_status:
                    print(f"   Status update [{poll_count}]: {task.status}")
                    last_status = task.status
            
            execution_time = time.time() - start_time
            result_data = task.result if hasattr(task, 'result') else None
            
            result = {
                'task_id': task_id,
                'status': task.status,
                'result': result_data,
                'execution_time': execution_time,
                'poll_count': poll_count
            }
            
            # Log completion
            if task.status == 'completed':
                print(f"✅ Task completed in {execution_time:.1f}s ({poll_count} polls)")
                
                # Store result in R2R for future reference
                if result_data:
                    self.r2r.store_generation_result(
                        content=str(result_data),
                        metadata={
                            'task_description': task_description,
                            'files': files,
                            'codegen_task_id': task_id,
                            'execution_time': execution_time,
                            'timestamp': time.time()
                        }
                    )
            elif task.status == 'failed':
                print(f"❌ Task failed after {execution_time:.1f}s")
            elif task.status == 'cancelled':
                print(f"⚠️  Task cancelled after {execution_time:.1f}s")
            
            return result
            
        except Exception as e:
            print(f"❌ Task execution failed: {e}")
            return {
                'task_id': None,
                'status': 'error',
                'result': None,
                'error': str(e),
                'execution_time': 0
            }
    
    # High-level task methods
    
    def improve_documentation(self, doc_files: List[str]) -> Dict[str, Any]:
        """Improve documentation quality and clarity."""
        return self.run_codegen_task(
            "Improve documentation: enhance clarity, fix errors, add examples",
            files=doc_files
        )
    
    def generate_code(self, description: str, reference_files: List[str] = None) -> Dict[str, Any]:
        """Generate code based on description and reference files."""
        return self.run_codegen_task(
            f"Generate code: {description}",
            files=reference_files or []
        )
    
    def fix_bugs(self, bug_description: str, affected_files: List[str] = None) -> Dict[str, Any]:
        """Fix bugs in code."""
        return self.run_codegen_task(
            f"Fix bug: {bug_description}",
            files=affected_files or []
        )
    
    def review_code(self, files: List[str]) -> Dict[str, Any]:
        """Review code for quality, security, and best practices."""
        return self.run_codegen_task(
            "Review code: check quality, security, performance, and adherence to best practices",
            files=files
        )
    
    def analyze_pr(self, pr_number: int, action: str = "review") -> Dict[str, Any]:
        """Analyze PR and generate code/review."""
        # Get best practices for PR review from R2R
        pr_context = self.r2r.get_rag_answer(
            f"What are the best practices for {action} in pull requests?"
        )
        
        task_desc = f"{action.capitalize()} PR #{pr_number}"
        if pr_context:
            task_desc += f"\n\nBest Practices:\n{pr_context[:1000]}"
        
        return self.run_codegen_task(task_desc)


def main():
    """Main entry point for GitHub Actions."""
    
    print("=" * 70)
    print("🤖 Codegen Orchestration Manager")
    print("   AI-powered code generation with R2R context integration")
    print("=" * 70)
    print()
    
    # Load environment variables
    codegen_org_id = os.environ.get('CODEGEN_ORG_ID')
    codegen_token = os.environ.get('CODEGEN_API_TOKEN')
    r2r_base_url = os.environ.get('R2R_BASE_URL')
    r2r_api_key = os.environ.get('R2R_API_KEY')
    
    # Validate configuration
    missing_vars = []
    if not codegen_org_id:
        missing_vars.append('CODEGEN_ORG_ID')
    if not codegen_token:
        missing_vars.append('CODEGEN_API_TOKEN')
    if not r2r_base_url:
        missing_vars.append('R2R_BASE_URL')
    if not r2r_api_key:
        missing_vars.append('R2R_API_KEY')
    
    if missing_vars:
        print(f"❌ Missing required environment variables: {', '.join(missing_vars)}")
        print("\n📋 Configuration Guide:")
        print("   Add these secrets to your GitHub repository:")
        print("   1. CODEGEN_ORG_ID: Your Codegen organization ID")
        print("   2. CODEGEN_API_TOKEN: Your Codegen API token")
        print("   3. R2R_BASE_URL: R2R API endpoint")
        print("   4. R2R_API_KEY: R2R API key")
        print("\n   Get Codegen token at: https://codegen.sh/token")
        sys.exit(1)
    
    # Initialize R2R context provider
    print("🔧 Initializing R2R context provider...")
    r2r_provider = R2RContextProvider(r2r_base_url, r2r_api_key)
    
    # Initialize Codegen orchestrator
    print("🔧 Initializing Codegen orchestrator...")
    orchestrator = CodegenOrchestrator(codegen_org_id, codegen_token, r2r_provider)
    
    print()
    
    # Read task configuration
    task_file = Path('codegen_task.json')
    
    if not task_file.exists():
        # Default: analyze changed files
        print("📝 No task configuration found, analyzing changed files...")
        
        changed_files = []
        changed_files_path = Path('changed_files.txt')
        if changed_files_path.exists():
            with open(changed_files_path, 'r') as f:
                changed_files = [line.strip() for line in f if line.strip()]
        
        if not changed_files:
            print("✅ No files to analyze")
            sys.exit(0)
        
        # Determine task type based on files
        if any(f.endswith('.md') for f in changed_files):
            task_type = "improve_docs"
            description = f'Improve documentation: enhance clarity, fix errors, add examples for {len(changed_files)} files'
        elif any(f.endswith('.py') for f in changed_files):
            task_type = "review_code"
            description = f'Review {len(changed_files)} Python files for quality and best practices'
        else:
            task_type = "analyze_changes"
            description = f'Analyze {len(changed_files)} changed files and provide recommendations'
        
        task_config = {
            'type': task_type,
            'description': description,
            'files': changed_files
        }
    else:
        # Load custom task
        print("📝 Loading task configuration from codegen_task.json...")
        with open(task_file, 'r') as f:
            task_config = json.load(f)
    
    print()
    print(f"🎯 Task Configuration:")
    print(f"   Type: {task_config['type']}")
    print(f"   Description: {task_config['description']}")
    print(f"   Files: {len(task_config.get('files', []))}")
    print()
    
    # Execute task
    result = None
    task_type = task_config['type']
    
    try:
        if task_type == 'improve_docs':
            result = orchestrator.improve_documentation(task_config.get('files', []))
        elif task_type == 'generate_code':
            result = orchestrator.generate_code(
                task_config['description'],
                task_config.get('files', [])
            )
        elif task_type == 'fix_bugs':
            result = orchestrator.fix_bugs(
                task_config['description'],
                task_config.get('files', [])
            )
        elif task_type == 'review_code':
            result = orchestrator.review_code(task_config.get('files', []))
        elif task_type == 'analyze_pr':
            pr_number = task_config.get('pr_number')
            if not pr_number:
                print("❌ PR number required for analyze_pr task")
                sys.exit(1)
            result = orchestrator.analyze_pr(pr_number, task_config.get('action', 'review'))
        else:
            result = orchestrator.run_codegen_task(
                task_config['description'],
                task_config.get('files', [])
            )
    except KeyboardInterrupt:
        print("\n\n⚠️  Task interrupted by user")
        sys.exit(130)
    except Exception as e:
        print(f"\n❌ Task execution error: {e}")
        sys.exit(1)
    
    # Write output
    output_file = Path('codegen_output.json')
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2, ensure_ascii=False, default=str)
    
    print()
    print("=" * 70)
    print("📊 Codegen Task Summary")
    print("=" * 70)
    print(f"Task ID:        {result.get('task_id', 'N/A')}")
    print(f"Status:         {result.get('status', 'unknown')}")
    if result.get('execution_time'):
        print(f"Execution Time: {result['execution_time']:.1f}s")
    if result.get('poll_count'):
        print(f"Poll Count:     {result['poll_count']}")
    print()
    
    if result.get('result'):
        print("📝 Result Preview:")
        print("-" * 70)
        result_text = str(result['result'])
        print(result_text[:800] + ('...' if len(result_text) > 800 else ''))
        print("-" * 70)
        print()
        
        # Write detailed result to markdown
        result_md = Path('codegen_result.md')
        with open(result_md, 'w', encoding='utf-8') as f:
            f.write("# 🤖 Codegen Generation Result\n\n")
            f.write(f"**Task:** {task_config['description']}\n\n")
            f.write(f"**Status:** {result['status']}\n\n")
            f.write(f"**Task ID:** {result.get('task_id', 'N/A')}\n\n")
            if result.get('execution_time'):
                f.write(f"**Execution Time:** {result['execution_time']:.1f}s\n\n")
            f.write(f"---\n\n")
            f.write("## Generated Output\n\n")
            f.write(result_text)
            f.write(f"\n\n---\n\n")
            f.write("*Generated by Codegen with R2R context integration*\n")
        
        print(f"✅ Full result saved to: {result_md}")
    
    print()
    print("=" * 70)
    
    # Exit code based on status
    if result.get('status') == 'completed':
        print("✅ Task completed successfully")
        sys.exit(0)
    elif result.get('status') in ['failed', 'error']:
        print("❌ Task failed")
        sys.exit(1)
    else:
        print("⚠️  Task finished with unknown status")
        sys.exit(0)


if __name__ == '__main__':
    main()
