# PACE Container Architecture

## Overview

PACE is composed of several containerized services running on Google Cloud Platform.

![Container Diagram](../../exports/containers.png)

## Containers

### PACE Web

**Technology**: TypeScript, React, Node.js

The main application providing:
- Frontend UI for agents, managers, and admins
- Backend API for all PACE functionality
- Integration endpoints for external systems

**Responsibilities**:
- User interface rendering
- Business logic execution
- API gateway for external integrations
- Real-time updates via WebSocket

### PACE Authenticator

**Technology**: Go, OAuth 2.0

Dedicated authentication service handling:
- Google SSO flow
- Token validation and issuance
- User synchronization with Google Workspace

See [ADR-0003: Google SSO Authentication](../adr/0003-google-sso-authentication.md) for details.

### AI Assistcraft

**Technology**: Python, FastAPI, LLM

AI subsystem providing:
- Conversation analysis
- Transcript processing
- Intelligent agent assistance
- Natural language data queries

See [ADR-0002: AI Assistcraft Architecture](../adr/0002-ai-assistcraft-architecture.md) for details.

## Databases

### Pace DB

**Technology**: PostgreSQL on Google Cloud SQL

Primary transactional database storing:
- User accounts and roles
- Listings and properties
- Applicants and leads
- Agent activities and communications

### Assistcraft DB

**Technology**: PostgreSQL on Google Cloud SQL (separate instance)

Dedicated AI database storing:
- Conversation history
- AI analysis results
- Transcript data
- Model outputs

## Communication Patterns

| From | To | Protocol | Pattern |
|------|-----|----------|---------|
| PACE Web | Authenticator | REST | Sync |
| PACE Web | AI Assistcraft | REST/SSE | Async streaming |
| PACE Web | External Portals | REST | Sync |
| Call Center | PACE Web | WebSocket | Async streaming |
| AI Assistcraft | PACE Web | MCP | Sync (tool calls) |

## Related Diagrams

- [Authentication Flow](../../exports/authFlow.png)
- [AI Components (L3)](../../exports/aiComponents.png)
- [Portal Integration](../../exports/portalIntegration.png)
