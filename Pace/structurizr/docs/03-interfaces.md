# Interface Catalog

All container-level interfaces on the PACE Container Diagram, organized by domain.

## User Interfaces

### INTF-USER-01 — Manager Interface

| | |
|---|---|
| **From** | Manager |
| **To** | PACE |
| **Protocol** | HTTPS / REST |
| **Authentication** | Google SSO (INTF-AUTH-02) |
| **Data** | KPI dashboards, team performance, approval workflows, listing oversight |

Web UI access for the Manager role. Managers oversee agent performance, approve workflows, and view business KPIs and statistics.

### INTF-USER-02 — Admin Interface

| | |
|---|---|
| **From** | Admin |
| **To** | PACE |
| **Protocol** | HTTPS / REST |
| **Authentication** | Google SSO (INTF-AUTH-02) |
| **Data** | System configuration, user management, data administration, portal settings |

Web UI access for the Admin role. Admins configure system settings, manage user accounts and roles, administer reference data, and configure portal integrations.

### INTF-USER-03 — Agent Interface

| | |
|---|---|
| **From** | Agent |
| **To** | PACE |
| **Protocol** | HTTPS / REST |
| **Authentication** | Google SSO (INTF-AUTH-02) |
| **Data** | Applicant records, listing management, communication tools, AI assistant, softphone |

Web UI access for the Agent role. Agents manage applicants and listings, communicate with applicants via email/WhatsApp/phone, and use the AI assistant for conversation analysis and data queries.

## Authentication

### INTF-AUTH-02 — Google Identity Confirmation

| | |
|---|---|
| **From** | PACE |
| **To** | Google Identity Services |
| **Protocol** | HTTP REST (OAuth 2.0 / OpenID Connect) |
| **Data** | ID tokens, access tokens, user profile claims (email, name, domain) |

PACE delegates all authentication to Google Identity Services. On login, the browser redirects to Google's OAuth consent flow. PACE validates the returned ID token and establishes a session. No credentials are stored in PACE — Google is the single source of truth for identity.

## Database

### INTF-DB-01 — PACE Database Access

| | |
|---|---|
| **From** | PACE |
| **To** | Pace DB |
| **Protocol** | PostgreSQL Wire Protocol (TCP 5432) |
| **Data** | Applicants, listings, users, configurations, communication logs, portal state |

Primary data path for all PACE business operations. Payload CMS manages the schema and ORM layer. Connection pooling is handled at the application level. The database is hosted on Cloud SQL with private IP access within the GCP VPC.

### INTF-DB-02 — AI Database Access

| | |
|---|---|
| **From** | PACE AI Backend |
| **To** | PACE AI DB |
| **Protocol** | PostgreSQL Wire Protocol (TCP 5432) |
| **Data** | Conversations, transcripts, agent execution state, embeddings |

Dedicated data path for the AI subsystem. Isolated from the main PACE DB to maintain separation between CRM and AI concerns. Hosted on Cloud SQL with private IP access within the GCP VPC.

## AI Integration

### INTF-AI-01 — AI Application Request

| | |
|---|---|
| **From** | PACE |
| **To** | PACE AI Backend |
| **Protocol** | HTTP SSE (Server-Sent Events) |
| **Data** | Input data for embedding/search, query parameters → search results, next best steps, AI-generated recommendations |

The primary communication channel between PACE and the AI backend. PACE sends input data (text for embedding, search queries, conversation data for analysis) and receives streamed results via SSE — including semantic search results, next best step recommendations, and AI-processed outputs. The AI backend orchestrates the processing internally, calling Vertex AI (INTF-AI-05) for LLM inference and embeddings as needed. PACE does not interact with the LLM directly.

### INTF-AI-05 — LLM Inference (Vertex AI)

| | |
|---|---|
| **From** | PACE AI Backend |
| **To** | Vertex AI |
| **Protocol** | HTTP REST (Google Vertex AI API) |
| **Data** | Prompts, model parameters → generated text, semantic search results, token streams |

The LLM inference layer. PACE AI Backend calls Vertex AI for language model operations: text generation, semantic search, conversation analysis, and agentic reasoning. The AI backend maintains its own vectorized knowledge database and handles embeddings internally — Vertex AI is used for LLM inference and semantic search capabilities that operate on top of that vector store. The AI backend constructs prompts with context from PACE data (INTF-AI-02) and MCP tool results (INTF-AI-04), sends them to Vertex AI, and processes the model output before returning application-level results to PACE (INTF-AI-01). This interface isolates the LLM dependency — switching models or providers only requires changes in the AI backend, not in PACE.

### INTF-AI-02 — Schema and Data Fetching

| | |
|---|---|
| **From** | PACE AI Backend |
| **To** | PACE |
| **Protocol** | HTTP REST |
| **Data** | Database schema definitions, field metadata, entity relationships, business data (applicants, listings, etc.) |

The AI backend fetches both schema and business data from PACE via REST APIs. Schema retrieval enables context-aware query generation — the AI understands the data model without hardcoded knowledge. Business data retrieval provides the AI with real-time CRM data (applicants, listings, activities, etc.) needed for conversation context, analysis, and agentic workflows. All data the PACE AI Suite needs from PACE Web flows through this REST interface — there is no direct database access between the two systems.

### INTF-AI-03 — MCP Data Retrieval

| | |
|---|---|
| **From** | MCP Servers |
| **To** | PACE |
| **Protocol** | HTTP REST |
| **Data** | Business data (listings, applicants, configurations) scoped to the AI agent's request |

MCP tool servers fetch business data from PACE on behalf of AI agents. When an agent needs real-time data (e.g., "show me listings in Dubai Marina"), the MCP server calls PACE's API to retrieve the relevant records and returns them as tool results.

### INTF-AI-04..0x — AI Agent to MCP Communication

| | |
|---|---|
| **From** | PACE AI Backend |
| **To** | MCP Servers |
| **Protocol** | HTTP Streaming (MCP over HTTP) |
| **Data** | Tool invocations (function name, arguments) → tool results (structured data) |

The agentic communication channel. The AI backend orchestrates tool calls by streaming requests to MCP servers. Each MCP server exposes domain-specific tools (e.g., listing search, applicant lookup, data aggregation). The `..0x` suffix indicates the interface scales with additional MCP servers as new tools are added.

## External System Integrations

### INTF-PACE-01 — Call Center (Softphone)

| | |
|---|---|
| **From** | PACE |
| **To** | Call Center (Exotel) |
| **Protocol** | Omni Toolbar SDK (iframe + JS events) + WebRTC (voice) + HTTP REST (webhooks) |
| **Data** | Call events, interaction lifecycle, agent state, disposition codes, CRM record mapping |

Exotel's contact center is embedded in PACE using the **CRM Integration (Iframe Model)** — a loosely-coupled approach where the Omni Toolbar runs independently inside an iframe and communicates with PACE exclusively via events. PACE remains the source of truth for navigation and data; the toolbar handles all telephony concerns.

**Embedding:** The PACE frontend hosts a `<div id="ameyoIframeDiv">` container. The toolbar loads from `https://<eccDomain>/omniapp/toolbar/index.html` and is initialized with a lightweight JS SDK:

```javascript
sdk.initialize({ context: "crm", origin: "https://<pace_domain>", instanceId: "ameyoIframe" });
```

**Integration layers:**

1. **Iframe + Event-Driven SDK (UI + Control)** — The toolbar runs independently inside the iframe and communicates with PACE through defined events. The interaction lifecycle is: toolbar initializes → agent logs in → interaction arrives → toolbar emits event → PACE reacts (screen pop, data fetch) → agent completes work → toolbar emits wrap-up event. Core integration points:
   - **SSO/Login**: `login` / `forceLogin` — PACE authenticates the agent into the toolbar
   - **Click-to-Dial**: `initiateInteraction()` — PACE triggers outbound calls with applicant data
   - **Screen Pop**: `showCrm` event — toolbar notifies PACE of incoming call, PACE looks up the applicant record
   - **Disposition**: `disposeInteraction()` — PACE sends wrap-up data (disposition code, notes) after call ends
2. **WebRTC (Voice)** — Voice calls are handled via WebRTC within the iframe. Audio is peer-to-peer between the agent's browser and Exotel's infrastructure — PACE does not process or route audio directly.
3. **REST Webhooks (Backend Events)** — Call events are pushed from Exotel to PACE's backend via REST webhooks. This allows PACE to log call activity, associate calls with applicant records, and trigger workflows independently of the frontend SDK events.

**SSO / Authentication:** The Omni Toolbar uses a CRM-initiated login model — not token-based SSO. PACE authenticates the agent into the toolbar by calling `sdk.login({ username, password })` with the agent's Ameyo credentials after the agent logs into PACE via Google SSO. User IDs must match between PACE and Ameyo. `sdk.forceLogin()` is available to override an existing session (e.g., agent left logged in elsewhere). Session teardown via `sdk.logout()`.

> **Architectural consideration:** This model requires PACE to store or derive Ameyo credentials per agent, since actual username/password are passed through the SDK (no OAuth/JWT token exchange). Credentials must be stored encrypted with appropriate access controls. Alternatively, investigate whether Exotel supports a token-based or API-key-based authentication flow for programmatic login to avoid credential storage.

**Prerequisites:** Ameyo user accounts provisioned with matching PACE user IDs, SDK initialization with CRM context and origin.

**Reference:** [Exotel Omni Toolbar](https://docs.exotel.com/harmony/omni-toolbar)

### INTF-PACE-02 — Looker Studio (Embedded Analytics)

| | |
|---|---|
| **From** | PACE |
| **To** | Looker Studio |
| **Protocol** | Embedded iframe |
| **Data** | Statistics dashboards, KPI reports (read-only, view mode only) |

Looker Studio (free version) reports are embedded in the PACE UI as iframes, providing agents and managers with analytics dashboards without leaving the platform.

**Embedding:** Reports are loaded via `https://lookerstudio.google.com/embed/reporting/<REPORT_ID>/page/<PAGE_ID>` inside an iframe. Reports render in view-only mode with interactive filters and date controls. A Looker Studio watermark is always present (cannot be removed in the free version).

**Access control options (to be decided):**

| Approach | Security | Complexity | Notes |
|---|---|---|---|
| **Google Workspace domain restriction** | Medium | Low | Restrict report sharing to the Allsop Google Workspace domain. Works because all users already authenticate via Google SSO (INTF-AUTH-02). Coarse-grained — all-or-nothing, no per-role data filtering. |
| **URL parameters for filtering** | Low | Low | PACE dynamically generates embed URLs with user/role-specific filter params. Params are visible in the DOM and can be manipulated by users — **not suitable for data isolation**. |
| **Community Connector + token** | High | High | PACE generates a short-lived signed token (e.g., JWT) per user, passed via the embed URL's `config` param. A custom Community Connector validates the token against PACE's backend and returns only authorized data. Most secure, but requires building and maintaining a custom connector. |

> **Recommendation:** Start with Google Workspace domain restriction (all Allsop employees can view). If per-role data filtering is needed later, evaluate the Community Connector + token approach. URL parameters should only be used as a UX convenience (default view), never as a security boundary.

### INTF-PACE-03 — Gmail (Email)

| | |
|---|---|
| **From** | PACE |
| **To** | Gmail API |
| **Protocol** | HTTP REST (Google Gmail API) |
| **Data** | Email messages (to, from, subject, body, attachments), listing share payloads |

Sends emails through the Gmail API using delegated credentials. Used for listing share emails to applicants, system notifications, and agent-initiated correspondence. Emails are sent as the agent's Google Workspace identity.

### INTF-PACE-08 — Google Calendar (Viewings & Scheduling)

| | |
|---|---|
| **From** | PACE |
| **To** | Google Calendar API |
| **Protocol** | HTTP REST (Google Calendar API v3) + Push Notifications (Webhooks) |
| **Data** | Calendar events (viewings, meetings), agent availability, attendee lists, extended properties |

Bidirectional integration with Google Calendar for managing agent schedules, property viewings, and meeting bookings.

**PACE → Google Calendar (outbound):**
- Create/update/delete calendar events on agent calendars (viewings, meetings)
- Check agent availability (freebusy queries) for scheduling
- Events include extended properties for PACE-specific metadata (viewing ID, listing reference, applicant reference)
- Applicants are added as event attendees — Google Calendar handles sending email invitations and reminders to them automatically

**Google Calendar → PACE (inbound):**
- Push notifications (webhooks) via watch channels notify PACE when events are created, modified, or deleted on the agent's calendar (e.g., agent reschedules directly in Google Calendar)
- PACE syncs the change back to its own database to keep wrapper records consistent

**PACE wrapper layer:**
PACE maintains its own records in Pace DB (INTF-DB-01) for viewing-specific data that Google Calendar does not natively support: viewing details, applicant/agent associations across multiple viewings, viewing status tracking, and aggregate views (e.g., all appointments for a given applicant or agent). The calendar UI in PACE uses a React calendar component with this combined data.

**Authentication:** Uses Google Workspace service account with domain-wide delegation, or per-agent OAuth consent, to access agent calendars.

### INTF-PACE-04 — Allsop & Allsop Portal (Listing Publication)

| | |
|---|---|
| **From** | PACE |
| **To** | Allsop & Allsop Portal |
| **Protocol** | TBD |
| **Data** | Listing details (title, description, pricing, location, media assets, status) |
| **Status** | **Integration path under investigation** |

Allsop & Allsop's website is the company's public-facing property listings portal. It is not a third-party marketplace — it is Allsop's own brokerage site. The portal currently sources its listing data from Salesforce (Propertybase), not from PACE directly.

As PACE replaces Salesforce as the primary CRM, the portal data path needs to be resolved. Two options are under consideration:

1. **PACE → Salesforce Adapter → Propertybase → Portal** — Continue syncing listing data to Propertybase via the Salesforce Adapter (INTF-SF-01), and the portal continues reading from Salesforce as it does today. This preserves the existing portal integration but adds latency and maintains a dependency on the deprecated Salesforce pipeline.
2. **PACE → Portal (direct)** — The portal reads listing data directly from PACE via a new API. This removes the Salesforce dependency but requires changes to the portal's data source.

> **Action required**: Confirm with the Allsop portal team which integration path will be used. This interface definition will be updated once the approach is decided.

### INTF-PACE-05 — Bayut (Listing Publication)

| | |
|---|---|
| **From** | PACE |
| **To** | Bayut Portal |
| **Protocol** | XML Feed Syndication (current) / REST API (under investigation) |
| **Data** | Listing details (title, description, pricing, location, media assets, status) |

Syncs property listings to Bayut (Dubizzle Group).

**Current integration model — XML Feed Syndication (pull):** PACE generates and hosts an XML feed at a publicly accessible URL. Bayut's system periodically pulls this feed to sync listing data. Listings are created, updated, or removed implicitly through feed content changes. This is Bayut's established integration model used by most CRM platforms.

**Potential REST API (push) — under investigation:** Bayut has reportedly introduced REST API functionality for listing management. If confirmed, this would allow PACE to push listing create/update/unpublish operations directly via API calls, similar to the Property Finder Enterprise API (INTF-PACE-06). This would provide real-time sync and explicit operation control compared to the feed-based approach.

> **Action required**: Investigate whether Bayut's REST API is available for listing management and evaluate migration from XML feed to REST push.

### INTF-PACE-06 — Property Finder (Listing Publication)

| | |
|---|---|
| **From** | PACE |
| **To** | Property Finder Portal |
| **Protocol** | HTTP REST (Enterprise API, OAuth 2.0 / JWT) |
| **Data** | Listing details (title, description, pricing, location, media assets, status), webhook events |

Publishes and syncs property listings to Property Finder via their Enterprise API. Supports the full listing lifecycle: create (draft), update, publish, and unpublish. Authentication uses OAuth 2.0 with API Key + Secret, producing JWT bearer tokens. Property Finder also provides webhooks for event notifications (publication status, lead assignments). Supports create, update, and unpublish operations for listing syndication.

### INTF-PACE-07 — WhatsApp (Messaging)

| | |
|---|---|
| **From** | PACE |
| **To** | WhatsApp (Exotel) |
| **Protocol** | HTTP REST (WhatsApp Business API via Exotel) |
| **Data** | Template messages (carousel + standard), delivery status, incoming replies |

Sends WhatsApp messages to applicants through Exotel's WhatsApp Business API. Primary use case is sharing property listings with applicants.

**Messaging model:**

WhatsApp is architecturally a two-way platform — there is no "notification-only" mode that prevents recipients from replying. However, template messages function as effective one-way notifications:

- **Business-initiated (outbound):** PACE sends a pre-approved template message. If the recipient does not reply, no conversation window opens and no further interaction occurs.
- **Customer-initiated (inbound):** If a recipient replies, a 24-hour Customer Service Window (CSW) opens during which PACE can send free-form messages. After 24h, only template messages can be sent again.
- **Billing:** Per-message pricing (since July 2025) — each template message is billed individually. Free-form messages within an active CSW are free.

**Template types for listing shares:**

| Template | Use case | Constraints |
|---|---|---|
| **Carousel template** | 2–10 listings | 2–10 cards, each with 1 image (1125x600px recommended), 160-char body, up to 2 buttons (URL/quick reply). Image, body text, and button URL are parameterized per card. |
| **Standard media template** | Single listing | 1 header image, up to 1024-char body with variables, up to 3 buttons. |

PACE needs both template types: a carousel for multi-listing shares and a standard media template for single-listing shares (carousel minimum is 2 cards).

**Broadcast (one-to-many):**

PACE can send the same template to multiple applicants. There is no native batch endpoint — each recipient requires an individual API call (`POST /messages`). Each recipient is fully independent (own conversation window, own billing). Default throughput: ~80 messages/second.

| Messaging tier | Unique contacts per 24h |
|---|---|
| Tier 1 (new) | 1,000 |
| Tier 2 | 10,000 |
| Tier 3 | 100,000 |
| Tier 4 (verified) | Unlimited |

Tiers upgrade automatically based on volume and quality rating. Since October 2025, limits apply at the business portfolio level, not per phone number.

> **Note:** If PACE does not intend to handle inbound replies, implement an application-level strategy (e.g., auto-reply with "this number does not accept replies" or silently ignore incoming messages).

### INTF-SF-01 — Salesforce Adapter

| | |
|---|---|
| **From** | Salesforce Adapter |
| **To** | PACE |
| **Protocol** | HTTP REST |
| **Data** | CRM records (applicants, listings, activities) |

PACE exposes REST APIs that the Salesforce Adapter consumes. The adapter pulls data from PACE and handles all mapping to Salesforce's own data models — PACE has no knowledge of or dependency on the Salesforce schema. The direction of responsibility is: PACE provides the data, Salesforce takes care of fetching and transforming it.
