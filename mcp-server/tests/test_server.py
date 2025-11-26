"""Tests for R2R FastMCP Server"""
import pytest
from unittest.mock import AsyncMock, patch
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from server import (
    r2r_search,
    r2r_rag,
    r2r_agent,
    r2r_collections_list,
    r2r_collections_create,
    r2r_examples,
    r2r_workflows,
    r2r_quick,
)


@pytest.fixture
def mock_make_request():
    """Mock _make_request function"""
    with patch("server._make_request", new_callable=AsyncMock) as mock:
        yield mock


@pytest.mark.asyncio
async def test_r2r_search(mock_make_request):
    """Test r2r_search tool"""
    mock_make_request.return_value = {
        "results": {
            "chunk_search_results": [
                {"id": "test123", "score": 0.95, "text": "Test result"}
            ]
        }
    }

    result = await r2r_search("test query", limit=3)

    assert "results" in result
    mock_make_request.assert_called_once()
    args = mock_make_request.call_args
    assert args[0][1] == "/v3/retrieval/search"
    assert args[1]["data"]["query"] == "test query"
    assert args[1]["data"]["limit"] == 3


@pytest.mark.asyncio
async def test_r2r_rag(mock_make_request):
    """Test r2r_rag tool"""
    mock_make_request.return_value = {
        "results": {
            "generated_answer": "Test answer",
            "citations": []
        }
    }

    result = await r2r_rag("What is FastMCP?", max_tokens=4000)

    assert "results" in result
    mock_make_request.assert_called_once()
    args = mock_make_request.call_args
    assert args[0][1] == "/v3/retrieval/rag"
    assert args[1]["data"]["query"] == "What is FastMCP?"


@pytest.mark.asyncio
async def test_r2r_agent(mock_make_request):
    """Test r2r_agent tool"""
    mock_make_request.return_value = {
        "results": {
            "response": "Agent response",
            "conversation_id": "conv_abc123"
        }
    }

    result = await r2r_agent("Research question", mode="research")

    assert "results" in result
    mock_make_request.assert_called_once()
    args = mock_make_request.call_args
    assert args[0][1] == "/v3/retrieval/agent"


@pytest.mark.asyncio
async def test_r2r_collections_list(mock_make_request):
    """Test r2r_collections_list tool"""
    mock_make_request.return_value = {
        "results": [
            {"id": "col1", "name": "Test Collection"}
        ]
    }

    result = await r2r_collections_list(limit=10)

    assert "results" in result
    mock_make_request.assert_called_once()
    args = mock_make_request.call_args
    assert args[0][1] == "/v3/collections"


@pytest.mark.asyncio
async def test_r2r_collections_create(mock_make_request):
    """Test r2r_collections_create tool"""
    mock_make_request.return_value = {
        "results": {"id": "col_new", "name": "New Collection"}
    }

    result = await r2r_collections_create("New Collection", "Description")

    assert "results" in result
    mock_make_request.assert_called_once()
    args = mock_make_request.call_args
    assert args[1]["data"]["name"] == "New Collection"


@pytest.mark.asyncio
async def test_r2r_examples():
    """Test r2r_examples tool"""
    result = await r2r_examples(category="search")

    assert "category" in result
    assert result["category"] == "search"
    assert "examples" in result
    assert len(result["examples"]) > 0


@pytest.mark.asyncio
async def test_r2r_workflows():
    """Test r2r_workflows tool"""
    result = await r2r_workflows("invalid_workflow")

    assert "available_workflows" in result
    assert "status" in result


@pytest.mark.asyncio
async def test_r2r_quick():
    """Test r2r_quick tool"""
    result = await r2r_quick("status")

    assert "task" in result
    assert result["task"] == "status"
    assert "r2r_url" in result
