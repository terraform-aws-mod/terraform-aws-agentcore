# Strands Agent for AWS AgentCore Runtime
# Multi-stage build for smaller image size

FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS builder

WORKDIR /app

# Copy dependency files and README (required by pyproject.toml)
COPY pyproject.toml uv.lock README.md ./

# Install dependencies into a virtual environment
RUN uv sync --frozen --no-dev --no-install-project

# Copy source code
COPY src/ ./src/

# Install the project
RUN uv sync --frozen --no-dev


# Production image
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS runtime

WORKDIR /app

# Create non-root user for security (least-privilege)
RUN groupadd --gid 1000 appgroup && \
    useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home appuser

# Copy the virtual environment from builder
COPY --from=builder --chown=appuser:appgroup /app/.venv /app/.venv

# Copy source code
COPY --from=builder --chown=appuser:appgroup /app/src /app/src

# Set environment variables
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONPATH="/app/src"
ENV PYTHONUNBUFFERED=1

# AWS region (can be overridden)
ENV AWS_REGION=us-east-1

# Bedrock model ID (can be overridden)
ENV BEDROCK_MODEL_ID=us.anthropic.claude-sonnet-4-20250514-v1:0

# Log level
ENV LOG_LEVEL=INFO

# Switch to non-root user
USER appuser

# Run the AgentCore runtime server
CMD ["python", "-m", "strands_agent_example.server"]
