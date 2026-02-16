# ADR-0002: AI Assistcraft Architecture

## Status

Accepted

## Date

2025-01-27

## Context

PACE requires AI capabilities for:
- Conversation analysis and transcription
- Intelligent agent assistance
- Natural language queries against CRM data

We need to decide on the AI platform architecture and how it integrates with the core PACE system.

## Decision

We will use **AI Assistcraft** as a dedicated, isolated subsystem with the following architecture:

### 1. Separate Database
AI Assistcraft will have its own PostgreSQL database (on a separate Google Cloud SQL instance) to:
- Store conversation history and transcripts
- Cache AI analysis results
- Maintain AI-specific data without polluting the main PACE DB

### 2. Backend Service
A dedicated Python/FastAPI backend (`assistcraftBackend`) that:
- Orchestrates AI workflows
- Fetches database schema from PACE Web to build SQL queries
- Schema is cached and refreshed per deploy or on-demand

### 3. MCP Servers (Model Context Protocol)
Modular MCP servers created as needed to:
- Provide structured tool access for AI agents
- Interact with PACE Web APIs
- Enable future extensibility without core changes

### 4. Communication Pattern
- **Inbound**: REST API calls from PACE Web
- **Outbound**: Server-Sent Events (SSE) for streaming AI responses
- Real-time conversation stream from Call Center via WebSocket

## Consequences

### Positive
- AI system can scale independently
- Database isolation prevents AI workloads from impacting CRM performance
- MCP architecture allows flexible agent tooling
- SSE enables responsive AI interactions

### Negative
- Two databases to manage and backup
- Additional infrastructure complexity
- Schema synchronization needed between PACE Web and Assistcraft

### Risks
- MCP server proliferation if not managed
- Schema drift between PACE Web and cached schema in Assistcraft

## Affected Elements

LikeC4 elements affected by this decision:

- `pace.aiAssistcraft` - Main AI container
- `pace.aiAssistcraft.assistcraftBackend` - Backend service
- `pace.aiAssistcraft.mcpServers` - MCP servers (L3 component)
- `pace.assistcraftDb` - Dedicated AI database
- `pace.paceWeb` - Provides schema and data APIs

## Related Diagrams

- [AI Assistcraft Components (L3)](../exports/aiComponents.png)
- [PACE Containers (L2)](../exports/containers.png)

## References

- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- AI Assistcraft internal documentation
