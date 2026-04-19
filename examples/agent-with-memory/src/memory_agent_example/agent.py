"""Strands Agent with memory support for AWS AgentCore runtime."""

import logging
import os

from strands import Agent
from strands.models import BedrockModel

from .tools import calculate, echo, get_current_time

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = """You are a helpful AI assistant running on AWS AgentCore with persistent memory.

You can remember context from previous conversations within a session.
Use this capability to provide personalized and context-aware responses.

You have access to the following tools:
- get_current_time: Get the current UTC time
- calculate: Evaluate mathematical expressions
- echo: Echo back messages for testing

Be concise and helpful in your responses. When using tools, explain what you're doing.
When you recall something from a prior exchange, mention it naturally.
"""


def create_agent() -> Agent:
    """Create and configure the Strands agent with memory support.

    Returns:
        Configured Strands Agent instance.
    """
    model_id = os.getenv("BEDROCK_MODEL_ID", "us.anthropic.claude-sonnet-4-20250514-v1:0")
    aws_region = os.getenv("AWS_REGION", "us-east-1")

    logger.info(f"Creating memory agent with model: {model_id} in region: {aws_region}")

    model = BedrockModel(
        model_id=model_id,
        region_name=aws_region,
    )

    agent = Agent(
        model=model,
        system_prompt=SYSTEM_PROMPT,
        tools=[get_current_time, calculate, echo],
    )

    return agent


_agent: Agent | None = None


def get_agent() -> Agent:
    """Get or create the global agent instance.

    Returns:
        The global Strands Agent instance.
    """
    global _agent
    if _agent is None:
        _agent = create_agent()
    return _agent
