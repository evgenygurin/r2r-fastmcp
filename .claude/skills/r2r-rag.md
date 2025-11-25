# R2R RAG Skill

## Description

Skill для генерации ответов на основе документов из R2R knowledge base с использованием Retrieval-Augmented Generation (RAG).

## When to Use

Автоматически активируется при запросах типа:
- "Explain..."
- "What is..."
- "Describe..."
- "Summarize..."
- "Based on the documents..."
- "According to the knowledge base..."

## Capabilities

### Core Competencies
- **Context Retrieval** - поиск релевантных документов
- **Answer Generation** - синтез ответа на основе контекста
- **Citation Extraction** - предоставление ссылок на источники
- **Temperature Control** - управление determinism vs creativity

### Generation Modes

#### 1. Deterministic (temp: 0.0-0.2)
Best for factual questions:
```text
"What is the transformer architecture?"
"List the main components of BERT"
"Define quantum entanglement"
```

#### 2. Balanced (temp: 0.3-0.5)
Best for explanations:
```text
"Explain how attention mechanism works"
"Describe the differences between supervised and unsupervised learning"
```

#### 3. Creative (temp: 0.6-1.0)
Best for synthesis:
```text
"What are potential future applications of quantum computing?"
"Discuss the implications of AI alignment research"
```

## Usage Parameters

### RAG Generation Config

```python
{
    "model": "openai/gpt-4.1-mini",  # Fast & cost-effective
    "temperature": 0.1,               # Deterministic
    "max_tokens": 2000,              # Response length
    "stream": False                   # Set True for long responses
}
```

### Model Selection

| Model | Speed | Cost | Quality | Use Case |
|-------|-------|------|---------|----------|
| gpt-4.1-mini | Fast | Low | Good | Standard queries |
| gpt-4.1 | Medium | Medium | High | Important queries |
| claude-3-haiku | Fast | Low | Good | Quick answers |
| claude-3-opus | Slow | High | Excellent | Critical analysis |

### Search Integration

RAG автоматически выполняет search перед generation:
```python
search_settings = {
    "use_hybrid_search": True,
    "limit": 10,  # Context documents
    "filters": {}  # Optional
}
```

## Invocation Examples

### Example 1: Factual Question

**User Query:**
```text
"What is machine learning?"
```

**Skill Actions:**
1. Search knowledge base → find ML definitions
2. Retrieve context → top 5 documents
3. Generate answer → temperature=0.1
4. Extract citations → source documents
5. Present → answer + sources

**Expected Output:**
```markdown
Machine learning is a subset of artificial intelligence that enables
systems to learn and improve from experience without being explicitly
programmed [1]. It focuses on developing algorithms that can access
data and use it to learn for themselves [2].

Key characteristics:
- Automated learning from data [1]
- Pattern recognition and prediction [2]
- Improvement over time [3]

**Sources:**
[1] "Introduction to ML" (doc_abc123)
[2] "AI Fundamentals" (doc_def456)
[3] "ML Applications" (doc_ghi789)
```

### Example 2: Explanation Request

**User Query:**
```text
"Explain how neural networks learn"
```

**Skill Actions:**
1. Search → "neural network learning process"
2. Retrieve → detailed explanations
3. Generate → temperature=0.3 (balanced)
4. Structure → step-by-step explanation
5. Cite → multiple sources

### Example 3: Summarization

**User Query:**
```text
"Summarize the key findings from recent AI safety research"
```

**Skill Actions:**
1. Search → filter by recent + AI safety
2. Retrieve → multiple papers
3. Generate → temperature=0.4 (synthesis)
4. Summarize → structured bullet points
5. Cite → all sources

## Answer Quality Guidelines

### High-Quality Answers Include:

1. **Direct Response** - answer the actual question first
2. **Supporting Details** - elaboration with context
3. **Citations** - references to source documents
4. **Structure** - organized with headers/bullets
5. **Confidence** - note when uncertain

### Poor-Quality Answers:

- Generic information not from documents
- Missing citations
- Hallucinated facts
- Overly verbose without substance
- Ignoring the actual question

## Citation Formats

### Standard Citation
```markdown
Key fact from the document [1].

Sources:
[1] "Document Title" (collection/document_id)
```

### Detailed Citation
```markdown
According to Smith et al. (2024), "exact quote from paper" [1, p.42].

Sources:
[1] Smith, J. et al. (2024). "Paper Title" - AI Research Collection (doc_xyz789)
```

### Inline Citation
```markdown
The transformer architecture uses self-attention [1] with multi-head
mechanisms [2] to process sequences in parallel [1, 3].
```

## Temperature Guidelines

| Temperature | Behavior | Use Case | Example |
|-------------|----------|----------|---------|
| 0.0 | Deterministic | Factual queries | "Define X" |
| 0.1-0.2 | Very focused | Technical explanations | "How does X work?" |
| 0.3-0.4 | Balanced | General explanations | "Explain X" |
| 0.5-0.6 | Creative balance | Implications | "What could X lead to?" |
| 0.7-1.0 | Very creative | Speculation | "Imagine X in future" |

## Result Presentation Format

```markdown
## Answer: [Question]

[Direct answer in 1-2 paragraphs]

### Detailed Explanation

[Structured breakdown with headers]

#### Key Points

- **Point 1:** Explanation [1]
- **Point 2:** Explanation [2]
- **Point 3:** Explanation [1, 3]

### Additional Context

[Relevant background information]

### Sources & Citations

1. **[Document Title]** (collection_id/document_id)
   - Key contribution: [What this source provided]
   - Relevance score: 0.92

2. **[Another Document]** (collection_id/document_id)
   - Key contribution: [What this provided]
   - Relevance score: 0.87

### Related Questions

- [Suggested follow-up 1]
- [Suggested follow-up 2]

### Confidence Assessment

- **High:** [Claims supported by multiple sources]
- **Medium:** [Claims from single source]
- **Low:** [Inferences or extrapolations]
```

## Streaming for Long Responses

For queries requiring lengthy answers:

```python
{
    "stream": True,
    "max_tokens": 4000
}
```

Benefits:
- Progressive display (better UX)
- Early cancellation if off-track
- Lower perceived latency

## Error Handling

### Insufficient Context
```bash
Issue: Not enough relevant documents found

Action:
1. Acknowledge limitation
2. Provide partial answer if possible
3. Suggest query refinement
4. Recommend adding more documents to KB
```

### Contradictory Information
```text
Issue: Sources disagree on facts

Action:
1. Present multiple perspectives
2. Cite each source
3. Note the contradiction
4. Provide confidence levels
```

### No Answer Possible
```bash
Issue: Question outside KB scope

Action:
1. State clearly "not found in knowledge base"
2. Suggest related topics that ARE covered
3. Recommend alternative resources
```

## Integration with Other Skills

### Chain with Search Skill
```text
1. R2R Search → find relevant docs
2. R2R RAG → generate comprehensive answer
```

### Pre-filter with Graph Skill
```text
1. R2R Graph → identify key entities
2. R2R RAG → generate answer using entity context
```

## Quality Metrics

Track RAG effectiveness:
- **Factual Accuracy** - claims match sources
- **Citation Quality** - proper source attribution
- **Answer Relevance** - addresses the question
- **Coherence** - logical flow and structure
- **User Satisfaction** - met information need

## Advanced Features

### 1. Multi-Document Synthesis

Combine information from multiple sources:
```python
# RAG automatically searches multiple docs
# and synthesizes a unified answer

User: "What's the consensus on X?"
RAG: [searches 10+ papers, synthesizes common themes]
```

### 2. Confidence Scoring

Indicate certainty levels:
```markdown
**High Confidence (supported by 5+ sources):**
- Fact A
- Fact B

**Medium Confidence (supported by 2-3 sources):**
- Claim C

**Low Confidence (single source or inferred):**
- Hypothesis D
```

### 3. Structured Output

Generate formatted responses:
```markdown
## Summary (3 sentences)

## Detailed Explanation (5 paragraphs)

## Key Takeaways (bullet points)

## Further Reading (citations)
```

### 4. Task-Specific Prompts

Customize for different question types:
```python
# Definition query
task_prompt = "Provide a clear, concise definition based on the documents."

# Comparison query
task_prompt = "Compare and contrast based on the sources, noting similarities and differences."

# How-to query
task_prompt = "Provide step-by-step explanation based on the documentation."
```

## Best Practices

### For Users

1. **Be Specific** - "Explain transformer self-attention" > "Tell me about transformers"
2. **Request Citations** - Add "with sources" to get detailed citations
3. **Specify Depth** - "Brief overview" vs "Comprehensive explanation"
4. **Follow Up** - Ask clarifying questions to refine answer

### For Claude Code Integration

1. **Always provide sources** - Never omit citations
2. **Note confidence** - Distinguish facts from inferences
3. **Structure answers** - Use headers and bullets
4. **Handle errors gracefully** - Be transparent about limitations
5. **Suggest next steps** - Related questions or topics

## Comparison: RAG vs Agent Chat

| Feature | RAG Skill | Agent Chat |
|---------|-----------|------------|
| **Use Case** | Direct Q&A | Multi-turn research |
| **Context** | Single query | Conversation history |
| **Speed** | Fast | Slower (extended thinking) |
| **Depth** | Focused answer | Comprehensive analysis |
| **Best For** | Facts, definitions | Complex reasoning |

## Related Documentation

- R2R RAG API: `docs/r2r/03-search-rag.md`
- RAG Command: `.claude/commands/r2r-rag.md`
- Doc Analyst Agent: `.claude/agents/doc-analyst.md`
- Research Assistant Agent: `.claude/agents/research-assistant.md`
