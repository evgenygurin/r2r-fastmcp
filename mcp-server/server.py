#!/usr/bin/env python3
"""
R2R FastMCP Server
==================

MCP server providing tools for R2R API integration.
Maps 1-to-1 with slash commands in .claude/commands/

Tools:
- r2r_search: Hybrid search (semantic + fulltext)
- r2r_rag: RAG query with generation
- r2r_agent: Multi-turn agent conversation
- r2r_collections: Collection management
- r2r_upload: Document upload
- r2r_examples: Interactive examples
- r2r_workflows: Automated workflows
- r2r_quick: Quick one-line tasks
"""

import os
import httpx
from typing import Optional, Dict, Any, List
from fastmcp import FastMCP

# Initialize FastMCP server
mcp = FastMCP("R2R Integration Server")

# R2R Configuration from environment
R2R_BASE_URL = os.getenv("R2R_BASE_URL", "http://localhost:7272")
API_KEY = os.getenv("API_KEY", "")

def _get_headers() -> Dict[str, str]:
    """Get headers for R2R API requests."""
    return {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {API_KEY}"
    }

async def _make_request(
    method: str,
    endpoint: str,
    data: Optional[Dict[str, Any]] = None
) -> Dict[str, Any]:
    """Make HTTP request to R2R API."""
    url = f"{R2R_BASE_URL}{endpoint}"
    async with httpx.AsyncClient(timeout=120.0) as client:
        if method == "GET":
            response = await client.get(url, headers=_get_headers(), params=data)
        else:
            response = await client.post(url, headers=_get_headers(), json=data)
        response.raise_for_status()
        return response.json()


@mcp.tool()
async def r2r_search(
    query: str,
    limit: int = 3,
    strategy: str = "vanilla",
    collection_id: Optional[str] = None
) -> Dict[str, Any]:
    """
    Search R2R knowledge base with hybrid search (semantic + fulltext).

    Args:
        query: Search query text
        limit: Maximum number of results (default: 3)
        strategy: Search strategy - vanilla, hyde, or rag_fusion (default: vanilla)
        collection_id: Optional collection ID to filter results

    Returns:
        Search results with scores and metadata
    """
    search_settings = {
        "use_hybrid_search": True,
        "search_strategy": strategy,
        "filters": {}
    }

    if collection_id:
        search_settings["filters"]["collection_ids"] = {"$overlap": [collection_id]}

    payload = {
        "query": query,
        "limit": limit,
        "search_settings": search_settings
    }

    return await _make_request("POST", "/v3/retrieval/search", payload)


@mcp.tool()
async def r2r_rag(
    query: str,
    max_tokens: int = 4000,
    strategy: str = "vanilla",
    collection_id: Optional[str] = None
) -> Dict[str, Any]:
    """
    RAG query to R2R with answer generation.

    Args:
        query: Question or query text
        max_tokens: Maximum tokens for generation (default: 4000)
        strategy: Search strategy (default: vanilla)
        collection_id: Optional collection ID to filter context

    Returns:
        Generated answer with citations and search results
    """
    search_settings = {
        "use_hybrid_search": True,
        "search_strategy": strategy,
        "filters": {}
    }

    if collection_id:
        search_settings["filters"]["collection_ids"] = {"$overlap": [collection_id]}

    payload = {
        "query": query,
        "search_settings": search_settings,
        "rag_generation_config": {
            "max_tokens_to_sample": max_tokens
        }
    }

    return await _make_request("POST", "/v3/retrieval/rag", payload)


@mcp.tool()
async def r2r_agent(
    message: str,
    mode: str = "research",
    conversation_id: Optional[str] = None,
    max_tokens: int = 4000,
    enable_thinking: bool = False
) -> Dict[str, Any]:
    """
    Multi-turn conversation with R2R agent.

    Args:
        message: User message or instruction
        mode: Agent mode - 'research' or 'rag' (default: research)
        conversation_id: Optional conversation ID for multi-turn
        max_tokens: Maximum tokens for generation (default: 4000)
        enable_thinking: Enable extended thinking (4096 token budget)

    Returns:
        Agent response with conversation_id for follow-ups
    """
    payload: Dict[str, Any] = {
        "message": message,
        "rag_generation_config": {
            "max_tokens_to_sample": max_tokens
        }
    }

    if conversation_id:
        payload["conversation_id"] = conversation_id

    if enable_thinking:
        payload["rag_generation_config"]["extended_thinking"] = True
        payload["rag_generation_config"]["thinking_budget"] = 4096

    # Research mode provides better reasoning
    if mode == "research":
        payload["agent_mode"] = "research"

    return await _make_request("POST", "/v3/retrieval/agent", payload)


@mcp.tool()
async def r2r_collections_list(
    limit: int = 10,
    offset: int = 0
) -> Dict[str, Any]:
    """
    List R2R collections.

    Args:
        limit: Number of collections to return (default: 10)
        offset: Number of collections to skip (default: 0)

    Returns:
        List of collections with metadata
    """
    params = {
        "limit": limit,
        "offset": offset
    }

    return await _make_request("GET", "/v3/collections", params)


@mcp.tool()
async def r2r_collections_create(
    name: str,
    description: str
) -> Dict[str, Any]:
    """
    Create a new R2R collection.

    Args:
        name: Collection name
        description: Collection description

    Returns:
        Created collection with ID
    """
    payload = {
        "name": name,
        "description": description
    }

    return await _make_request("POST", "/v3/collections", payload)


@mcp.tool()
async def r2r_collections_get(
    collection_id: str
) -> Dict[str, Any]:
    """
    Get R2R collection details.

    Args:
        collection_id: Collection UUID

    Returns:
        Collection details with metadata
    """
    return await _make_request("GET", f"/v3/collections/{collection_id}", None)


@mcp.tool()
async def r2r_upload(
    file_path: str,
    collection_ids: Optional[List[str]] = None,
    title: Optional[str] = None,
    mode: str = "hi-res"
) -> Dict[str, Any]:
    """
    Upload document to R2R knowledge base.

    Args:
        file_path: Path to document file
        collection_ids: Optional list of collection IDs
        title: Optional document title
        mode: Ingestion mode - 'hi-res' or 'fast' (default: hi-res)

    Returns:
        Document ID and ingestion status
    """
    # Note: This is a simplified implementation
    # Actual file upload requires multipart/form-data
    payload = {
        "file_path": file_path,
        "metadata": {}
    }

    if title:
        payload["metadata"]["title"] = title

    if collection_ids:
        payload["collection_ids"] = collection_ids

    if mode:
        payload["ingestion_mode"] = mode

    return await _make_request("POST", "/v3/documents/create", payload)


@mcp.tool()
async def r2r_examples(
    category: Optional[str] = None
) -> Dict[str, Any]:
    """
    Get R2R interactive examples and tutorials.

    Args:
        category: Optional category filter (search, rag, agent, docs, collections, graph)

    Returns:
        List of examples with code snippets and descriptions
    """
    examples = {
        "search": [
            {
                "name": "Basic Search",
                "description": "Simple search with 3 results",
                "code": "r2r_search('machine learning', limit=3)"
            },
            {
                "name": "Collection-specific Search",
                "description": "Search within specific collection",
                "code": "r2r_search('neural networks', limit=5, collection_id='col_id')"
            }
        ],
        "rag": [
            {
                "name": "Basic RAG Query",
                "description": "Simple question answering",
                "code": "r2r_rag('What is FastMCP?', max_tokens=1000)"
            },
            {
                "name": "Extended RAG Response",
                "description": "Detailed answer with more context",
                "code": "r2r_rag('Explain transformer architecture in detail', max_tokens=8000)"
            }
        ],
        "agent": [
            {
                "name": "Research Query",
                "description": "Complex analysis with reasoning",
                "code": "r2r_agent('Research AI safety implications', mode='research')"
            },
            {
                "name": "Multi-turn Conversation",
                "description": "Continue conversation with context",
                "code": "r2r_agent('Tell me more', conversation_id='conv_id')"
            }
        ],
        "collections": [
            {
                "name": "List Collections",
                "description": "Get all collections",
                "code": "r2r_collections_list(limit=10)"
            },
            {
                "name": "Create Collection",
                "description": "Create new collection",
                "code": "r2r_collections_create('AI Research', 'Papers about AI')"
            }
        ]
    }

    if category and category in examples:
        return {"category": category, "examples": examples[category]}

    return {"all_categories": list(examples.keys()), "examples": examples}


@mcp.tool()
async def r2r_workflows(
    workflow: str,
    **kwargs
) -> Dict[str, Any]:
    """
    Execute automated R2R workflows for common multi-step tasks.

    Args:
        workflow: Workflow name - upload, create-collection, research, analyze, batch-upload
        **kwargs: Workflow-specific arguments

    Returns:
        Workflow execution result
    """
    workflows_info = {
        "upload": "Upload document and optionally add to collection",
        "create-collection": "Create collection and add multiple documents",
        "research": "Deep research query with multi-step reasoning",
        "analyze": "Analyze specific document with RAG",
        "batch-upload": "Upload multiple documents from directory"
    }

    if workflow == "research":
        query = kwargs.get("query", "")
        mode = kwargs.get("mode", "research")
        return await r2r_agent(query, mode=mode, enable_thinking=True)

    elif workflow == "create-collection":
        name = kwargs.get("name", "")
        description = kwargs.get("description", "")
        collection = await r2r_collections_create(name, description)
        return {
            "workflow": "create-collection",
            "result": collection,
            "next_steps": ["Upload documents using r2r_upload with collection_id"]
        }

    return {
        "available_workflows": workflows_info,
        "selected": workflow,
        "status": "not_implemented" if workflow not in workflows_info else "info"
    }


@mcp.tool()
async def r2r_quick(
    task: str,
    **kwargs
) -> Dict[str, Any]:
    """
    Quick one-line R2R tasks and shortcuts.

    Args:
        task: Task name - ask, status, up, col, col-search, continue, graph, batch, find, cleanup
        **kwargs: Task-specific arguments

    Returns:
        Task execution result
    """
    if task == "ask":
        # Quick search + RAG answer
        query = kwargs.get("query", "")
        search_result = await r2r_search(query, limit=3)
        rag_result = await r2r_rag(query, max_tokens=2000)
        return {
            "task": "ask",
            "query": query,
            "search": search_result,
            "answer": rag_result
        }

    elif task == "status":
        # System status check
        return {
            "task": "status",
            "r2r_url": R2R_BASE_URL,
            "api_configured": bool(API_KEY),
            "status": "configured"
        }

    elif task == "col":
        # Quick collection create
        name = kwargs.get("name", "")
        description = kwargs.get("description", "")
        return await r2r_collections_create(name, description)

    elif task == "col-search":
        # Quick collection search
        query = kwargs.get("query", "")
        collections = await r2r_collections_list(limit=20)
        return {
            "task": "col-search",
            "query": query,
            "collections": collections
        }

    return {
        "available_tasks": [
            "ask", "status", "up", "col", "col-search",
            "continue", "graph", "batch", "find", "cleanup"
        ],
        "selected": task,
        "kwargs": kwargs
    }


if __name__ == "__main__":
    # Run MCP server with stdio transport
    mcp.run()
