# R2R Search Skill

## Description

Skill для эффективного поиска информации в R2R knowledge base с использованием semantic search, hybrid search и advanced filtering.

## When to Use

Автоматически активируется при запросах типа:
- "Search for..."
- "Find information about..."
- "What does the knowledge base say about..."
- "Look up..."
- "Query the documents for..."

## Capabilities

### Core Competencies
- **Query Understanding** - интерпретация естественного языка в search запрос
- **Search Mode Selection** - выбор оптимального режима (basic/advanced/custom)
- **Filter Application** - применение фильтров по коллекциям, метаданным
- **Result Ranking** - сортировка по релевантности

### Search Strategies

#### 1. Semantic Search
Best for conceptual queries:
```text
"Find documents about neural network optimization"
"What papers discuss climate change effects?"
```

#### 2. Hybrid Search
Best for mixed concept + keyword queries:
```bash
"Papers about 'transformer' architecture published after 2020"
"Documents mentioning 'GPT-4' in research context"
```

#### 3. RAG Fusion
Best for complex multi-faceted queries:
```text
"Comprehensive overview of quantum computing applications"
"All aspects of transformer architecture design"
```

## Usage Parameters

### Search Settings

```python
{
    "use_semantic_search": True,   # Default
    "use_fulltext_search": False,  # Enable for keywords
    "use_hybrid_search": True,     # Best balance
    "search_strategy": "vanilla",  # or "rag_fusion", "hyde"
    "limit": 10,                   # Results count
    "filters": {}                  # Metadata filters
}
```

### Filters

| Filter Type | Example | Use Case |
|-------------|---------|----------|
| Collection | `{"collection_ids": {"$overlap": ["col_123"]}}` | Search in specific collections |
| Metadata | `{"metadata.category": {"$eq": "research"}}` | Filter by attributes |
| Date | `{"metadata.year": {"$gte": 2020}}` | Recent documents |
| Type | `{"document_type": {"$in": ["pdf", "md"]}}` | Specific formats |

## Invocation Examples

### Example 1: Simple Conceptual Search

**User Query:**
```text
"Find information about machine learning algorithms"
```

**Skill Actions:**
1. Identify query type → conceptual
2. Select strategy → semantic search
3. Execute search → use_semantic_search=True
4. Present results → ranked by relevance

**Expected Output:**
```markdown
Found 12 relevant documents about machine learning algorithms:

1. **Introduction to ML Algorithms** (score: 0.94)
   - Covers supervised, unsupervised, and reinforcement learning
   - Collection: ML Textbooks

2. **Deep Learning Architectures** (score: 0.89)
   - Focus on neural network algorithms
   - Collection: Research Papers
```

### Example 2: Keyword + Context (Hybrid)

**User Query:**
```bash
"Papers mentioning 'BERT' in NLP context"
```

**Skill Actions:**
1. Detect keywords → "BERT"
2. Detect context → "NLP"
3. Select strategy → hybrid search
4. Execute → fulltext for "BERT" + semantic for "NLP context"
5. Fuse results → reciprocal rank fusion

### Example 3: Filtered Search

**User Query:**
```text
"Recent research papers about quantum computing from the AI collection"
```

**Skill Actions:**
1. Parse constraints:
   - Topic: quantum computing
   - Type: research papers
   - Recency: recent
   - Collection: AI collection
2. Build filters:
   ```python
   {
       "collection_ids": {"$overlap": ["ai_collection_id"]},
       "metadata.type": {"$eq": "research_paper"},
       "metadata.year": {"$gte": 2023}
   }
   ```
3. Execute search with filters
4. Present results

## Query Optimization Tips

### 1. Specificity vs Recall

| Query Type | Strategy | Example |
|------------|----------|---------|
| Broad exploration | Semantic, low limit | "AI research" (limit: 20) |
| Specific fact | Hybrid, high precision | "GPT-4 parameter count" |
| Comprehensive | RAG fusion | "All transformer variants" |

### 2. Collection Scoping

**Good:**
```bash
"Search the research collection for papers on quantum entanglement"
```

**Better:**
```text
Filters: {"collection_ids": {"$overlap": ["research_col"]}}
Query: "quantum entanglement"
```

### 3. Temporal Filtering

For recent information:
```python
filters = {
    "metadata.publication_date": {
        "$gte": "2024-01-01"
    }
}
```

## Result Presentation Format

```markdown
### Search Results: [Query]

**Search Strategy:** Hybrid (semantic + fulltext)
**Collections Searched:** Research Papers, Technical Docs
**Results:** 15 documents found

#### Top 5 Results

**1. [Document Title]** (relevance: 0.95)
- **Collection:** Research Papers
- **Type:** PDF
- **Date:** 2024-03-15
- **Excerpt:** "Key content excerpt that matches the query..."
- **Entities:** [Entity1, Entity2]

**2. [Another Document]** (relevance: 0.89)
...

#### Search Refinement Suggestions
- Try: "narrow to specific aspect"
- Consider: searching in [related_collection]
- Filter by: publication_year >= 2023
```

## Performance Considerations

### Fast Searches (< 1s)
- Basic semantic search
- Small result sets (limit ≤ 10)
- Single collection

### Medium Searches (1-3s)
- Hybrid search
- Medium result sets (limit 10-50)
- Multiple collections

### Comprehensive Searches (3-10s)
- RAG fusion strategy
- Large result sets (limit > 50)
- Complex filters

## Error Handling

### No Results Found
```text
Action:
1. Suggest query reformulation
2. Try broader search
3. Check collection availability
4. Recommend related queries
```

### Too Many Results
```text
Action:
1. Apply stricter filters
2. Increase semantic precision
3. Narrow to specific collections
4. Use date range filters
```

### Ambiguous Query
```bash
Action:
1. Ask for clarification
2. Suggest specific interpretations
3. Execute multiple variants
4. Present options to user
```

## Integration with Other Skills

### Chain with RAG Skill
```text
1. R2R Search → find relevant documents
2. R2R RAG → generate answer from results
```

### Chain with Graph Skill
```bash
1. R2R Search → find documents
2. R2R Graph → explore entity relationships in results
```

## Quality Metrics

Track search effectiveness:
- **Precision** - relevant results / total results
- **Recall** - relevant results / all relevant docs
- **User satisfaction** - found what they needed?
- **Iteration count** - queries until satisfied

## Advanced Features

### 1. Query Expansion

Automatically expand queries:
```text
User: "Find ML papers"
Expanded: "Find machine learning papers OR artificial intelligence papers OR deep learning papers"
```

### 2. Semantic Similarity Threshold

Adjust based on use case:
```python
# High precision (research)
min_score = 0.75

# Balanced (exploration)
min_score = 0.60

# High recall (discovery)
min_score = 0.40
```

### 3. Multi-Query Search

For comprehensive results:
```python
queries = [
    "transformer architecture",
    "attention mechanism",
    "self-attention layers"
]
# Execute all, fuse results
```

## Related Documentation

- R2R Search API: `docs/r2r/03-search-rag.md`
- Search Command: `.claude/commands/r2r-search.md`
- Knowledge Explorer Agent: `.claude/agents/knowledge-explorer.md`
