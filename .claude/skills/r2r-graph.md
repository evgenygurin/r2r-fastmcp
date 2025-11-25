# R2R Knowledge Graph Skill

## Description

Skill для работы с knowledge graph в R2R, включая поиск сущностей (entities), навигацию по relationships и анализ communities.

## When to Use

Автоматически активируется при запросах типа:
- "What entities..."
- "How is X related to Y..."
- "Show connections between..."
- "Find relationships..."
- "What's connected to [entity]..."
- "Entities in [collection]..."

## Capabilities

### Core Competencies
- **Entity Search** - поиск сущностей по имени/типу
- **Relationship Discovery** - поиск связей между сущностями
- **Community Detection** - идентификация кластеров связанных сущностей
- **Graph Traversal** - навигация по графу знаний

### Entity Types

Common entity types in R2R:
- **Person** - ученые, авторы, исторические фигуры
- **Organization** - компании, институты, лаборатории
- **Location** - места, города, страны
- **Concept** - идеи, теории, методы
- **Technology** - алгоритмы, системы, инструменты
- **Event** - конференции, публикации, эксперименты

### Relationship Types

Common relationships:
- **works_at** - Person → Organization
- **located_in** - Organization → Location
- **authored** - Person → Document
- **uses** - Technology → Technology
- **part_of** - Concept → Concept
- **influenced_by** - Concept → Concept

## Usage Parameters

### Entity Search Settings

```python
{
    "collection_id": "target_collection",
    "entity_name": "search_term",
    "entity_type": "Person",  # Optional filter
    "limit": 20
}
```

### Graph Search Settings

```python
graph_search_settings = {
    "use_graph_search": True,
    "kg_search_type": "local",  # or "global"
    "max_depth": 2,  # Relationship hops
    "entity_types": ["Person", "Organization"],
    "relation_types": ["works_at", "authored"]
}
```

## Invocation Examples

### Example 1: Entity Discovery

**User Query:**
```text
"What entities are related to neural networks?"
```

**Skill Actions:**
1. Search entities → "neural networks" in name/description
2. Get relationships → connected entities
3. Analyze → identify primary connections
4. Present → structured entity map

**Expected Output:**
```markdown
### Entities Related to "Neural Networks"

**Primary Entity:**
- **Neural Networks** (Concept)
  - Description: "Computational models inspired by biological neural networks"
  - Mentioned in: 45 documents

**Connected Entities:**

**People (5):**
- Geoffrey Hinton → pioneered_backpropagation
- Yann LeCun → developed_convolutional_networks
- Yoshua Bengio → contributed_to_deep_learning

**Technologies (8):**
- Backpropagation → training_algorithm_for
- Convolutional Neural Networks → type_of
- Recurrent Neural Networks → type_of
- Transformers → evolved_from

**Organizations (3):**
- Google DeepMind → researches
- OpenAI → applies
- MILA → studies

**Concepts (12):**
- Deep Learning → broader_category
- Artificial Intelligence → field_of
- Machine Learning → approach_in
```

### Example 2: Relationship Tracing

**User Query:**
```text
"How is transformer architecture connected to attention mechanism?"
```

**Skill Actions:**
1. Find entity: "Transformer Architecture"
2. Find entity: "Attention Mechanism"
3. Discover path → direct or indirect relationships
4. Present → relationship chain

**Expected Output:**
```markdown
### Connection Path

**Transformer Architecture** ←uses→ **Attention Mechanism**

**Direct Relationship:**
- Type: uses
- Description: "Transformers rely on self-attention mechanisms as core building block"
- Strength: Strong (mentioned in 23 documents)

**Shared Context:**
- Both appear in: 18 documents
- Common concepts: "Self-Attention", "Multi-Head Attention", "Query-Key-Value"
- Common authors: Vaswani et al., Dosovitskiy et al.

**Related Entities:**
- Self-Attention (intermediate concept)
- Multi-Head Attention (specific type)
- BERT (applies both)
- GPT (applies both)
```

### Example 3: Community Analysis

**User Query:**
```bash
"What are the main research communities in AI?"
```

**Skill Actions:**
1. Build communities → cluster related entities
2. Analyze → identify themes
3. Rank → by size and connectivity
4. Present → structured overview

## Graph Visualization Formats

### 1. Entity List Format

```markdown
## Entity: [Name]

**Type:** [Person/Organization/Concept/etc.]
**Description:** [Entity description]
**Source Documents:** 12
**Relationships:** 8

### Connected To:
- **[Entity1]** via [relationship_type]
- **[Entity2]** via [relationship_type]
- **[Entity3]** via [relationship_type]
```

### 2. Relationship Network Format

```markdown
## Relationship Network: [Central Entity]

```text
                     [Entity A]
                         ↓ works_at
    [Entity B] ← authored ← [Central Entity] → uses → [Entity C]
                         ↑ part_of
                     [Entity D]
```

**Legend:**
- → : directed relationship
- ↔ : bidirectional
- Thickness: relationship strength
```text

### 3. Community Clusters Format

```markdown
## Knowledge Graph Communities

### Community 1: Deep Learning Research (45 entities)
**Core Concepts:** Neural Networks, Deep Learning, Backpropagation
**Key People:** Hinton, LeCun, Bengio
**Organizations:** Google, Facebook AI, MILA
**Connectivity:** Very dense (0.78)

### Community 2: Natural Language Processing (38 entities)
**Core Concepts:** Transformers, Attention, Embeddings
**Key People:** Vaswani, Devlin, Radford
**Organizations:** Google, OpenAI, Hugging Face
**Connectivity:** Dense (0.65)

### Community 3: Computer Vision (29 entities)
...
```

## Graph Query Types

### 1. Direct Entity Lookup

```text
User: "Tell me about Geoffrey Hinton"

Action: Direct entity search → return entity details + relationships
```

### 2. Relationship Query

```text
User: "Who works at OpenAI?"

Action: Filter by relationship_type="works_at" + target="OpenAI"
```

### 3. Path Finding

```text
User: "How is X connected to Y?"

Action: Find shortest path between entities
```

### 4. Neighborhood Exploration

```text
User: "What's connected to neural networks?"

Action: Get all entities within N hops
```

### 5. Community Discovery

```text
User: "What are the research clusters?"

Action: Run community detection algorithm
```

## Integration with Search & RAG

### Pattern 1: Entity-Guided Search

```bash
1. R2R Graph → identify key entities in topic
2. R2R Search → use entities as filters
3. R2R RAG → generate answer with entity context
```

Example:
```text
User: "Explain transformers"

Flow:
1. Graph: Find "Transformer" entity
2. Get related: "Self-Attention", "BERT", "GPT"
3. Search: Documents mentioning these entities
4. RAG: Generate comprehensive explanation
```

### Pattern 2: Relationship-Based Research

```text
1. R2R Graph → discover relationships
2. R2R RAG → explain each relationship
3. Synthesize → comprehensive overview
```

Example:
```text
User: "How did transformers influence modern NLP?"

Flow:
1. Graph: Transformers → influenced → [BERT, GPT, T5, ...]
2. RAG: Explain each influence
3. Synthesize: Comprehensive impact analysis
```

## Graph Quality Metrics

### Entity Coverage
```text
- Total entities: 1,245
- Entity types: 6 (Person, Organization, Concept, Technology, Location, Event)
- Entities with relationships: 98%
- Orphaned entities: 2%
```

### Relationship Density
```text
- Total relationships: 3,678
- Relationships per entity (avg): 2.95
- Bidirectional: 45%
- Unidirectional: 55%
```

### Community Structure
```text
- Communities detected: 12
- Modularity score: 0.72 (high)
- Largest community: 245 entities
- Smallest community: 8 entities
```

## Advanced Graph Operations

### 1. Temporal Analysis

Track entity evolution over time:
```markdown
## Entity Timeline: "Transformer Architecture"

**2017:** Introduced in "Attention is All You Need"
- Related entities: Attention Mechanism (5 docs)

**2018-2019:** Rapid adoption
- New entities: BERT (12 docs), GPT (8 docs)
- Relationships: 23 new "applies" links

**2020-2024:** Dominance
- New entities: GPT-3, T5, CLIP, Vision Transformers (45 docs)
- Relationships: 156 "influenced_by" links
```

### 2. Centrality Analysis

Identify most important entities:
```markdown
## Most Central Entities (by degree centrality)

1. **Neural Networks** (degree: 89)
   - Hub connecting deep learning, ML, AI

2. **Attention Mechanism** (degree: 67)
   - Key concept in modern architectures

3. **Geoffrey Hinton** (degree: 54)
   - Influential researcher across multiple areas
```

### 3. Bridging Entities

Find entities connecting communities:
```markdown
## Bridge Entities (connecting multiple communities)

**Transfer Learning** bridges:
- Computer Vision community
- Natural Language Processing community
- Deep Learning community

Appears in: 45 documents across all three areas
```

## Error Handling

### Entity Not Found
```text
Action:
1. Suggest similar entities (fuzzy match)
2. Recommend building knowledge graph from documents
3. Offer to search documents instead
```

### No Relationships
```text
Action:
1. Entity exists but isolated
2. Suggest extracting relationships from documents
3. Show entity details without connections
```

### Graph Not Built
```bash
Action:
1. Check if documents have been processed
2. Suggest running knowledge graph extraction
3. Provide command: /r2r-upload with graph extraction
```

## Building Knowledge Graphs

### From Existing Documents

```python
# Extract entities and relationships
client.graphs.pull(collection_id)

# Build communities
client.graphs.build_communities(collection_id)

# Configure entity/relationship types
graph_settings = {
    "entity_types": ["Person", "Organization", "Concept"],
    "relation_types": ["works_at", "authored", "related_to"],
    "max_knowledge_relationships": 100
}
```

### Quality Guidelines

**Good Entities:**
- Specific and unambiguous
- Consistently named
- Well-described
- Connected to relevant entities

**Poor Entities:**
- Too generic ("thing", "item")
- Inconsistent names ("ML" vs "Machine Learning")
- No description
- Isolated (no relationships)

## Related Documentation

- R2R Knowledge Graphs: `docs/r2r/04-knowledge-graphs.md`
- Knowledge Explorer Agent: `.claude/agents/knowledge-explorer.md`
- Entity Search Command: `.claude/commands/r2r-search.md`

## Graph Maintenance

### Regular Tasks

1. **Entity Deduplication** - merge similar entities
2. **Relationship Validation** - verify connections
3. **Community Recomputation** - update clusters
4. **Orphan Cleanup** - connect isolated entities

### Growth Monitoring

```text
Track over time:
- Entity count growth rate
- Relationship density
- Community structure stability
- Query performance
```
