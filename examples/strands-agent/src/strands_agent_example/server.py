"""Server for AWS AgentCore runtime using BedrockAgentCoreApp."""

import logging
import os
from typing import Any

from bedrock_agentcore.runtime import BedrockAgentCoreApp
from bedrock_agentcore.runtime.context import BedrockAgentCoreContext

from .agent import get_agent

logging.basicConfig(
    level=getattr(logging, os.getenv("LOG_LEVEL", "INFO")),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

# Create the AgentCore application
app = BedrockAgentCoreApp()


@app.entrypoint
def handle_message(payload: dict[str, Any]) -> str:
    """Handle incoming messages from AgentCore runtime.

    The entrypoint receives the full JSON payload from AgentCore.
    Expected payload format: {"message": "user message here"}

    Args:
        payload: The full request payload as a dictionary.

    Returns:
        Agent response as a string.
    """
    # Extract message from payload
    message = payload.get("message", "")
    if not message:
        # Try alternative payload formats
        message = payload.get("input", {}).get("prompt", "") if isinstance(payload.get("input"), dict) else ""
        if not message:
            message = payload.get("prompt", "")
    
    if not message:
        logger.warning(f"No message found in payload: {payload}")
        return "Error: No message provided in payload. Expected format: {'message': 'your message'}"

    session_id = BedrockAgentCoreContext.get_session_id()
    logger.info(f"Processing message: {message[:50]}... (session: {session_id})")

    try:
        agent = get_agent()
        result = agent(message)
        response = str(result)
        logger.info(f"Agent response: {response[:100]}...")
        return response
    except Exception as e:
        logger.exception(f"Error processing message: {e}")
        return f"Error: {e}"


def main() -> None:
    """Run the AgentCore runtime server."""
    logger.info("Starting Strands Agent on AgentCore runtime...")
    app.run()


if __name__ == "__main__":
    main()
