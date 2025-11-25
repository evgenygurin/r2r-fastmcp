#!/usr/bin/env python3
"""
R2R Knowledge Bridge - FastMCP Server

Предоставляет доступ к R2R (search, rag, agent) через MCP Protocol
для интеграции с Claude Code.
"""

from r2r import R2RClient
from fastmcp import FastMCP, Context
from fastmcp.exceptions import ToolError, ResourceError
import os
import json
import logging

# Настройка логирования
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s: %(message)s'
)
logger = logging.getLogger(__name__)

# Инициализация
mcp = FastMCP("R2R Knowledge Bridge")

# R2R Client
R2R_BASE_URL = os.getenv("R2R_BASE_URL", "http://localhost:7272")
R2R_API_KEY = os.getenv("R2R_API_KEY")

try:
    if R2R_API_KEY:
        r2r_client = R2RClient(base_url=R2R_BASE_URL, api_key=R2R_API_KEY)
    else:
        r2r_client = R2RClient(base_url=R2R_BASE_URL)
    logger.info(f"R2R client initialized: {R2R_BASE_URL}")
except Exception as e:
    logger.error(f"Failed to initialize R2R client: {e}")
    r2r_client = None


# ========== TOOLS ==========

@mcp.tool
async def search_knowledge(
    query: str,
    limit: int = 5,
    use_hybrid: bool = True
) -> str:
    """
    Поиск в R2R knowledge base.

    Args:
        query: Поисковый запрос
        limit: Максимальное количество результатов (default: 5)
        use_hybrid: Использовать hybrid search (semantic + fulltext)

    Returns:
        JSON string с результатами поиска
    """
    if not r2r_client:
        raise ToolError("R2R client not initialized")

    try:
        logger.info(f"Search: '{query}' (limit={limit}, hybrid={use_hybrid})")

        results = r2r_client.retrieval.search(
            query=query,
            search_settings={
                "limit": limit,
                "use_hybrid_search": use_hybrid
            }
        )

        return json.dumps(results, ensure_ascii=False, indent=2)

    except ConnectionError as e:
        raise ToolError(f"R2R server unavailable: {e}")
    except Exception as e:
        logger.error(f"Search failed: {e}")
        raise ToolError(f"Search failed: {str(e)}")


@mcp.tool
async def rag_query(
    question: str,
    temperature: float = 0.1,
    model: str = "openai/gpt-4.1-mini"
) -> str:
    """
    RAG запрос к R2R с генерацией ответа.

    Args:
        question: Вопрос для RAG системы
        temperature: Температура генерации (0.0-1.0)
        model: LLM модель для генерации

    Returns:
        Сгенерированный ответ с контекстом
    """
    if not r2r_client:
        raise ToolError("R2R client not initialized")

    try:
        logger.info(f"RAG: '{question}' (temp={temperature}, model={model})")

        response = r2r_client.retrieval.rag(
            query=question,
            rag_generation_config={
                "model": model,
                "temperature": temperature
            }
        )

        # Извлекаем сгенерированный текст
        if isinstance(response, dict):
            completion = response.get("results", {}).get("completion", {})
            if isinstance(completion, dict):
                choices = completion.get("choices", [])
                if choices:
                    message = choices[0].get("message", {})
                    return message.get("content", str(response))

        return json.dumps(response, ensure_ascii=False, indent=2)

    except ConnectionError as e:
        raise ToolError(f"R2R server unavailable: {e}")
    except Exception as e:
        logger.error(f"RAG query failed: {e}")
        raise ToolError(f"RAG query failed: {str(e)}")


@mcp.tool
async def agent_chat(
    message: str,
    conversation_id: str = None,
    mode: str = "rag"
) -> str:
    """
    Multi-turn conversation с R2R agent.

    Args:
        message: Сообщение пользователя
        conversation_id: ID беседы для продолжения (optional)
        mode: Режим агента - 'rag' или 'research' (default: rag)

    Returns:
        Ответ агента с conversation_id для follow-ups
    """
    if not r2r_client:
        raise ToolError("R2R client not initialized")

    try:
        logger.info(
            f"Agent: '{message[:50]}...' "
            f"(mode={mode}, conv_id={conversation_id})"
        )

        kwargs = {
            "message": {"role": "user", "content": message},
            "mode": mode
        }

        if conversation_id:
            kwargs["conversation_id"] = conversation_id

        response = r2r_client.retrieval.agent(**kwargs)

        return json.dumps(response, ensure_ascii=False, indent=2)

    except ConnectionError as e:
        raise ToolError(f"R2R server unavailable: {e}")
    except Exception as e:
        logger.error(f"Agent chat failed: {e}")
        raise ToolError(f"Agent chat failed: {str(e)}")


@mcp.tool
async def search_entities(
    entity_name: str,
    collection_id: str
) -> str:
    """
    Поиск сущностей в R2R knowledge graph.

    Args:
        entity_name: Имя сущности для поиска
        collection_id: ID коллекции

    Returns:
        JSON со списком найденных сущностей
    """
    if not r2r_client:
        raise ToolError("R2R client not initialized")

    try:
        logger.info(
            f"Entity search: '{entity_name}' "
            f"in collection {collection_id}"
        )

        entities = r2r_client.graphs.list_entities(
            collection_id=collection_id,
            entity_name=entity_name
        )

        return json.dumps(entities, ensure_ascii=False, indent=2)

    except ConnectionError as e:
        raise ToolError(f"R2R server unavailable: {e}")
    except Exception as e:
        logger.error(f"Entity search failed: {e}")
        raise ToolError(f"Entity search failed: {str(e)}")


@mcp.tool
async def upload_document(
    file_path: str,
    collection_id: str = None,
    metadata: dict = None
) -> str:
    """
    Загрузка документа в R2R.

    Args:
        file_path: Путь к файлу
        collection_id: ID коллекции (optional)
        metadata: Метаданные документа (optional)

    Returns:
        Информация о созданном документе
    """
    if not r2r_client:
        raise ToolError("R2R client not initialized")

    try:
        logger.info(f"Upload: {file_path} to collection {collection_id}")

        kwargs = {"file_path": file_path}

        if collection_id:
            kwargs["collection_ids"] = [collection_id]
        if metadata:
            kwargs["metadata"] = metadata

        result = r2r_client.documents.create(**kwargs)

        return json.dumps(result, ensure_ascii=False, indent=2)

    except FileNotFoundError:
        raise ToolError(f"File not found: {file_path}")
    except ConnectionError as e:
        raise ToolError(f"R2R server unavailable: {e}")
    except Exception as e:
        logger.error(f"Document upload failed: {e}")
        raise ToolError(f"Upload failed: {str(e)}")


@mcp.tool
async def list_collections() -> str:
    """
    Список всех коллекций в R2R.

    Returns:
        JSON со списком коллекций
    """
    if not r2r_client:
        raise ToolError("R2R client not initialized")

    try:
        logger.info("Listing collections")

        collections = r2r_client.collections.list()

        return json.dumps(collections, ensure_ascii=False, indent=2)

    except ConnectionError as e:
        raise ToolError(f"R2R server unavailable: {e}")
    except Exception as e:
        logger.error(f"List collections failed: {e}")
        raise ToolError(f"Failed to list collections: {str(e)}")


# ========== RESOURCES ==========

@mcp.resource("knowledge://collections")
def get_collections_resource() -> str:
    """Список доступных коллекций в R2R."""
    if not r2r_client:
        return json.dumps({"error": "R2R client not initialized"})

    try:
        collections = r2r_client.collections.list()
        return json.dumps(collections, ensure_ascii=False, indent=2)
    except Exception as e:
        logger.error(f"Resource error: {e}")
        return json.dumps({"error": str(e)})


@mcp.resource("knowledge://collections/{collection_id}/documents")
def get_collection_documents(collection_id: str) -> str:
    """Список документов в коллекции."""
    if not r2r_client:
        return json.dumps({"error": "R2R client not initialized"})

    try:
        docs = r2r_client.documents.list(
            filters={"collection_ids": {"$overlap": [collection_id]}}
        )
        return json.dumps(docs, ensure_ascii=False, indent=2)
    except Exception as e:
        logger.error(f"Resource error: {e}")
        return json.dumps({"error": str(e)})


@mcp.resource("config://r2r")
def get_r2r_config() -> str:
    """Конфигурация R2R подключения."""
    config = {
        "base_url": R2R_BASE_URL,
        "auth_enabled": R2R_API_KEY is not None,
        "client_initialized": r2r_client is not None
    }
    return json.dumps(config, ensure_ascii=False, indent=2)


# ========== ENTRY POINT ==========

if __name__ == "__main__":
    logger.info("Starting R2R Knowledge Bridge MCP Server")
    logger.info(f"R2R Base URL: {R2R_BASE_URL}")

    mcp.run(transport="stdio")
