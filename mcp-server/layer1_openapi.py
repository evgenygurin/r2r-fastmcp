#!/usr/bin/env python3
"""
Layer 1: R2R OpenAPI FastMCP Server
====================================

Automatically generates MCP tools from R2R OpenAPI specification.
Provides direct 1-to-1 mapping of all R2R API endpoints.

Base layer for smart composite tools (Layer 2).
"""

import httpx
import os
from typing import Any, Dict, Optional
from fastmcp import FastMCP

# R2R API Configuration
R2R_BASE_URL = os.getenv("R2R_BASE_URL", "http://136.119.36.216:7272")
API_KEY = os.getenv("API_KEY", "")

# Initialize FastMCP server (Layer 1)
mcp = FastMCP("R2R OpenAPI Layer 1")


async def fetch_openapi_spec() -> Dict[str, Any]:
    """Fetch OpenAPI specification from R2R server."""
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{R2R_BASE_URL}/openapi.json")
        response.raise_for_status()
        return response.json()


def _get_headers() -> Dict[str, str]:
    """Get authentication headers for R2R API."""
    return {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {API_KEY}"
    }


async def call_r2r_endpoint(
    method: str,
    path: str,
    body: Optional[Dict[str, Any]] = None,
    params: Optional[Dict[str, Any]] = None
) -> Dict[str, Any]:
    """
    Generic R2R API caller.

    Args:
        method: HTTP method (GET, POST, PUT, DELETE)
        path: API endpoint path
        body: Request body for POST/PUT
        params: Query parameters for GET

    Returns:
        API response as dict
    """
    url = f"{R2R_BASE_URL}{path}"

    async with httpx.AsyncClient(timeout=120.0) as client:
        if method == "GET":
            response = await client.get(
                url,
                headers=_get_headers(),
                params=params or {}
            )
        elif method == "POST":
            response = await client.post(
                url,
                headers=_get_headers(),
                json=body or {}
            )
        elif method == "PUT":
            response = await client.put(
                url,
                headers=_get_headers(),
                json=body or {}
            )
        elif method == "DELETE":
            response = await client.delete(
                url,
                headers=_get_headers()
            )
        else:
            raise ValueError(f"Unsupported HTTP method: {method}")

        response.raise_for_status()
        return response.json()


# ========================================
# Core Retrieval Tools (v3)
# ========================================

@mcp.tool()
async def r2r_search(
    query: str,
    limit: int = 3,
    search_strategy: str = "vanilla",
    use_hybrid_search: bool = True
) -> Dict[str, Any]:
    """
    POST /v3/retrieval/search
    Hybrid search (semantic + fulltext)
    """
    return await call_r2r_endpoint(
        "POST",
        "/v3/retrieval/search",
        body={
            "query": query,
            "limit": limit,
            "search_settings": {
                "use_hybrid_search": use_hybrid_search,
                "search_strategy": search_strategy
            }
        }
    )


@mcp.tool()
async def r2r_rag(
    query: str,
    max_tokens: int = 4000,
    search_strategy: str = "vanilla"
) -> Dict[str, Any]:
    """
    POST /v3/retrieval/rag
    RAG query with generation
    """
    return await call_r2r_endpoint(
        "POST",
        "/v3/retrieval/rag",
        body={
            "query": query,
            "search_settings": {
                "use_hybrid_search": True,
                "search_strategy": search_strategy
            },
            "rag_generation_config": {
                "max_tokens_to_sample": max_tokens
            }
        }
    )


@mcp.tool()
async def r2r_agent(
    message: str,
    conversation_id: Optional[str] = None,
    max_tokens: int = 4000
) -> Dict[str, Any]:
    """
    POST /v3/retrieval/agent
    Multi-turn agent conversation
    """
    payload = {
        "message": message,
        "rag_generation_config": {
            "max_tokens_to_sample": max_tokens
        }
    }

    if conversation_id:
        payload["conversation_id"] = conversation_id

    return await call_r2r_endpoint("POST", "/v3/retrieval/agent", body=payload)


# ========================================
# Collections Management (v3)
# ========================================

@mcp.tool()
async def collections_list(
    limit: int = 10,
    offset: int = 0
) -> Dict[str, Any]:
    """GET /v3/collections - List collections"""
    return await call_r2r_endpoint(
        "GET",
        "/v3/collections",
        params={"limit": limit, "offset": offset}
    )


@mcp.tool()
async def collections_create(
    name: str,
    description: str
) -> Dict[str, Any]:
    """POST /v3/collections - Create collection"""
    return await call_r2r_endpoint(
        "POST",
        "/v3/collections",
        body={"name": name, "description": description}
    )


@mcp.tool()
async def collections_get(collection_id: str) -> Dict[str, Any]:
    """GET /v3/collections/{id} - Get collection details"""
    return await call_r2r_endpoint("GET", f"/v3/collections/{collection_id}")


@mcp.tool()
async def collections_update(
    collection_id: str,
    name: Optional[str] = None,
    description: Optional[str] = None
) -> Dict[str, Any]:
    """POST /v3/collections/{id} - Update collection"""
    body = {}
    if name:
        body["name"] = name
    if description:
        body["description"] = description

    return await call_r2r_endpoint(
        "POST",
        f"/v3/collections/{collection_id}",
        body=body
    )


@mcp.tool()
async def collections_delete(collection_id: str) -> Dict[str, Any]:
    """DELETE /v3/collections/{id} - Delete collection"""
    return await call_r2r_endpoint("DELETE", f"/v3/collections/{collection_id}")


# ========================================
# Documents Management (v3)
# ========================================

@mcp.tool()
async def documents_list(
    limit: int = 10,
    offset: int = 0
) -> Dict[str, Any]:
    """GET /v3/documents - List documents"""
    return await call_r2r_endpoint(
        "GET",
        "/v3/documents",
        params={"limit": limit, "offset": offset}
    )


@mcp.tool()
async def documents_get(document_id: str) -> Dict[str, Any]:
    """GET /v3/documents/{id} - Get document details"""
    return await call_r2r_endpoint("GET", f"/v3/documents/{document_id}")


@mcp.tool()
async def documents_delete(document_id: str) -> Dict[str, Any]:
    """DELETE /v3/documents/{id} - Delete document"""
    return await call_r2r_endpoint("DELETE", f"/v3/documents/{document_id}")


# ========================================
# Knowledge Graph Operations (v3)
# ========================================

@mcp.tool()
async def graphs_list(
    limit: int = 10,
    offset: int = 0
) -> Dict[str, Any]:
    """GET /v3/graphs - List graphs"""
    return await call_r2r_endpoint(
        "GET",
        "/v3/graphs",
        params={"limit": limit, "offset": offset}
    )


@mcp.tool()
async def graph_entities(
    collection_id: str,
    limit: int = 50,
    offset: int = 0
) -> Dict[str, Any]:
    """GET /v3/graphs/{collection_id}/entities - List entities"""
    return await call_r2r_endpoint(
        "GET",
        f"/v3/graphs/{collection_id}/entities",
        params={"limit": limit, "offset": offset}
    )


@mcp.tool()
async def graph_relationships(
    collection_id: str,
    limit: int = 50,
    offset: int = 0
) -> Dict[str, Any]:
    """GET /v3/graphs/{collection_id}/relationships - List relationships"""
    return await call_r2r_endpoint(
        "GET",
        f"/v3/graphs/{collection_id}/relationships",
        params={"limit": limit, "offset": offset}
    )


@mcp.tool()
async def graph_communities(
    collection_id: str,
    limit: int = 50,
    offset: int = 0
) -> Dict[str, Any]:
    """GET /v3/graphs/{collection_id}/communities - List communities"""
    return await call_r2r_endpoint(
        "GET",
        f"/v3/graphs/{collection_id}/communities",
        params={"limit": limit, "offset": offset}
    )


# ========================================
# Resources (Exposed via MCP)
# ========================================

@mcp.resource("r2r://openapi/spec")
async def get_openapi_spec() -> str:
    """Expose R2R OpenAPI specification as MCP resource"""
    spec = await fetch_openapi_spec()
    return str(spec)


@mcp.resource("r2r://config/base_url")
async def get_base_url() -> str:
    """Expose R2R base URL as MCP resource"""
    return R2R_BASE_URL


if __name__ == "__main__":
    mcp.run()
