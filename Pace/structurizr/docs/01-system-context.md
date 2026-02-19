# System Context

## What is PACE?

![](embed:SystemContext)

PACE is Allsop & Allsop's sales and CRM platform. It replaces the legacy Salesforce CRM with a purpose-built system for managing the full lifecycle of real estate sales — from listing properties and finding applicants, to scheduling viewings, closing deals, and reporting on performance.

The platform is developed and maintained by Ingemark for Allsop & Allsop, a real estate brokerage operating in the UAE.

## Who Uses PACE?

PACE serves three Allsop employee roles, each with a tailored interface:

| Role | What they do in PACE |
|---|---|
| **Agent** | Day-to-day operations: manage applicants and listings, communicate with clients via email, WhatsApp, and phone, schedule property viewings, use the AI assistant for data queries and conversation analysis. |
| **Manager** | Oversight: review team performance and KPIs, approve workflows, monitor listing activity, and access analytics dashboards. |
| **Admin** | Configuration: manage user accounts and roles, configure system settings, administer reference data, and set up portal integrations. |

All users sign in through their Allsop Google Workspace account (Single Sign-On) — PACE does not manage passwords.

Two additional roles support the platform behind the scenes:

| Role | Responsibility |
|---|---|
| **Developer** (Ingemark) | Builds and maintains the platform — code, AI systems, integrations, and CI/CD pipelines. |
| **Support Team** (Ingemark) | Monitors system health, responds to alerts, and handles operational incidents. |

## What Does PACE Do?

PACE covers the core workflows of a real estate sales operation:

### Applicant Management

Agents track prospective buyers and tenants throughout the sales funnel. Each applicant record captures contact details, preferences, interaction history, and viewing activity.

### Listing Management

Properties are created and maintained in PACE with full details — description, pricing, location, media assets, and status. Listings are published to external real estate portals (Property Finder, Bayut, and Allsop's own website) directly from the platform.

### Communication

Agents communicate with applicants through multiple channels without leaving PACE:

- **Email** — sent via Gmail on behalf of the agent
- **WhatsApp** — listing shares and follow-ups via WhatsApp Business
- **Phone** — an embedded softphone (powered by Exotel) for making and receiving calls directly in the browser

### Scheduling

Property viewings and meetings are managed through Google Calendar integration. Agents can check availability, schedule viewings, and send automatic calendar invitations to applicants — all from within PACE.

### Analytics

Managers and agents access KPI dashboards and performance reports through embedded Looker Studio visualizations, without leaving the platform.

### AI Assistant

PACE includes an AI-powered assistant that helps agents with:

- **Data queries** — natural language questions about applicants, listings, and activity ("show me all 2-bedroom listings in Dubai Marina under 2M AED")
- **Conversation analysis** — automatic analysis of call transcripts and communication patterns
- **Next best steps** — AI-generated recommendations for follow-up actions based on applicant activity

The AI capabilities are provided by a separate subsystem (PACE AI Suite) that uses Google Vertex AI for language model processing.

## External Services

PACE connects to several external services, grouped by purpose:

### Authentication

| Service | Purpose |
|---|---|
| Google Identity Services | Single Sign-On — all Allsop employees authenticate through their Google Workspace account. |

### Communication

| Service | Purpose |
|---|---|
| Gmail API | Send emails on behalf of agents (listing shares, follow-ups, notifications). |
| WhatsApp (Exotel) | Send WhatsApp messages to applicants (listing shares, follow-ups). |
| Call Center (Exotel) | Embedded softphone for browser-based calling. |

### Scheduling & Analytics

| Service | Purpose |
|---|---|
| Google Calendar API | Manage agent calendars — schedule viewings, check availability, send invitations. |
| Looker Studio | Embedded analytics dashboards and KPI reports. |

### Listing Portals

| Service | Purpose |
|---|---|
| Property Finder | Publish and sync listings to the Property Finder portal. |
| Bayut | Publish and sync listings to the Bayut portal. |
| Allsop & Allsop Portal | Publish listings to Allsop's own website. |

### AI

| Service | Purpose |
|---|---|
| Vertex AI (Google Cloud) | Language model inference for the AI assistant — powers data queries, conversation analysis, and recommendations. |

### Legacy

| Service | Purpose |
|---|---|
| Salesforce CRM | The previous CRM system. Historical data was migrated to PACE. Now deprecated. |
| Salesforce Adapter | A service that pulls data from PACE and syncs it to Salesforce for backward compatibility. |

## Platform Architecture

At the highest level, PACE consists of two systems:

- **PACE Web** — the main application that all users interact with. It handles the UI, business logic, data storage, and all external integrations. Built with Payload CMS and Next.js.
- **PACE AI Suite** — the AI subsystem. It provides conversation analysis, semantic search, and agentic AI capabilities. Built with Python and FastAPI. Communicates with PACE Web via REST and Server-Sent Events (SSE).

PACE Web is the central hub — it orchestrates all user-facing functionality and delegates AI tasks to the AI Suite. The AI Suite in turn calls Google Vertex AI for language model processing, but this is invisible to users and to PACE Web.
