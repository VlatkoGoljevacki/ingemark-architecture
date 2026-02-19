# Components

## PACE Web Containers

### PACE

| | |
|---|---|
| **Technology** | Payload CMS, Next.js |
| **Runtime** | Node.js on GKE (`pace-web` namespace) |
| **Role** | Full-stack backend and frontend service |

The core application serving the web UI for all user roles. Payload CMS provides the backend with a headless API and admin UI, while Next.js handles server-side rendering and the agent-facing frontend. Responsible for applicant management, listing management, communication orchestration, and integration with all external systems.

### Pace DB

| | |
|---|---|
| **Technology** | PostgreSQL on Google Cloud SQL |
| **Role** | Primary transactional database |

Stores all business data: applicants, listings, user accounts, configurations, communication logs, and portal syndication state. Managed by Google Cloud SQL with automated backups and high availability.

## PACE AI Suite Containers

### PACE AI Backend

| | |
|---|---|
| **Technology** | Python, FastAPI |
| **Runtime** | Python on GKE (`pace-ai` namespace) |
| **Role** | Main AI service with agentic functionality |

The central AI service. Handles AI conversation processing, transcript analysis, and agentic workflows. Streams responses back to PACE via SSE. Fetches the PACE database schema to generate context-aware queries. Orchestrates MCP tool calls for specialized operations.

### MCP Servers

| | |
|---|---|
| **Technology** | Python, FastMCP |
| **Runtime** | Python on GKE (`pace-ai` namespace) |
| **Role** | Tool servers for AI agents |

Model Context Protocol servers that expose specialized tools to the AI backend. Each MCP server provides domain-specific functions (e.g., fetching listings, querying applicant data) that AI agents can invoke during agentic workflows. Communicates with PACE via REST to retrieve business data.

### PACE AI DB

| | |
|---|---|
| **Technology** | PostgreSQL on Google Cloud SQL |
| **Role** | Dedicated AI database |

Stores AI-specific data: conversation histories, transcripts, agent execution state, and embeddings. Isolated from the main PACE DB to maintain separation of concerns between the CRM and AI subsystems.

## External Systems

### Google Identity Services

| | |
|---|---|
| **Provider** | Google Workspace |
| **Protocol** | OAuth 2.0 / OpenID Connect |
| **Role** | Source of truth for authentication |

All Allsop employees authenticate via Google SSO. PACE delegates identity verification to Google Identity Services and does not manage credentials directly.

### Gmail API

| | |
|---|---|
| **Provider** | Google Workspace |
| **Protocol** | Google Gmail REST API |
| **Role** | Email delivery |

Used to send emails on behalf of agents or as system notifications. Listing share emails, applicant correspondence, and automated notifications are dispatched through the Gmail API using delegated credentials.

### Google Calendar API

| | |
|---|---|
| **Provider** | Google Workspace |
| **Protocol** | Google Calendar REST API + Push Notifications (Webhooks) |
| **Role** | Agent calendar management |

Manages agent calendars for property viewings, meeting bookings, and availability tracking. PACE uses Google Calendar as the source of truth for all calendar functionality (scheduling, conflict detection, reminders, attendee notifications). Applicants are notified of viewings via email through Google Calendar's built-in notification system. PACE maintains a custom wrapper layer with its own database records for viewing-specific metadata (viewing details, applicant/agent associations, status tracking) that Google Calendar does not natively support.

### Vertex AI

| | |
|---|---|
| **Provider** | Google Cloud |
| **Protocol** | Vertex AI REST API |
| **Role** | LLM inference and embedding services |

Google's managed AI platform used by the PACE AI Backend for LLM inference and semantic search. The AI backend maintains its own vectorized knowledge database and handles embeddings internally — Vertex AI provides the language model capabilities (text generation, reasoning, conversation analysis) that operate on top of that vector store. The LLM dependency is isolated behind the AI backend — PACE Web does not call Vertex AI directly.

### WhatsApp

| | |
|---|---|
| **Provider** | Exotel |
| **Protocol** | WhatsApp Business API (REST) |
| **Role** | Applicant messaging |

Enables agents to communicate with applicants via WhatsApp. Messages are sent through Exotel's WhatsApp Business API integration. Used for listing shares, follow-ups, and applicant communication.

### Call Center

| | |
|---|---|
| **Provider** | Exotel |
| **Protocol** | REST API + WebSocket |
| **Role** | VoIP softphone and call streaming |

Provides softphone capabilities embedded in the PACE UI. Agents can make and receive calls directly from the platform. Real-time call events and audio streams are delivered via WebSocket for live call tracking and recording.

### Property Finder Portal

| | |
|---|---|
| **Provider** | Property Finder |
| **Protocol** | REST API |
| **Role** | Listing syndication |

UAE real estate listings portal. PACE publishes and syncs property listings to Property Finder, maintaining listing status, pricing, and media assets.

### Bayut Portal

| | |
|---|---|
| **Provider** | Bayut (Dubizzle Group) |
| **Protocol** | REST API |
| **Role** | Listing syndication |

UAE real estate listings portal. PACE publishes and syncs property listings to Bayut, maintaining listing status, pricing, and media assets.

### Allsop & Allsop Portal

| | |
|---|---|
| **Provider** | Allsop & Allsop |
| **Protocol** | REST API |
| **Role** | Company listing portal |

Allsop's own real estate listings website. PACE publishes listings directly to the company portal, ensuring the public-facing website stays in sync with the CRM.

### Looker Studio

| | |
|---|---|
| **Provider** | Google Workspace |
| **Protocol** | Embedded iframe |
| **Role** | Embedded analytics and KPI dashboards |

Google's data visualization tool embedded in PACE as an iframe. Provides agents and managers with analytics dashboards and KPI reports without leaving the platform.

### Salesforce CRM (Deprecated)

| | |
|---|---|
| **Provider** | Salesforce |
| **Protocol** | REST API / CSV import |
| **Role** | Legacy CRM |
| **Status** | **Deprecated** — data migration source only |

The previous CRM system. Historical data was migrated to PACE via CSV import.

### Salesforce Adapter

| | |
|---|---|
| **Protocol** | REST API |
| **Role** | Salesforce data synchronization |

A service managed by the Salesforce/Allsop side that pulls data from PACE's REST APIs and maps it to Salesforce's own data models. PACE has no knowledge of or dependency on the Salesforce schema — it simply exposes APIs that the adapter consumes.
