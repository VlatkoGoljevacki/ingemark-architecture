# Container Architecture Overview

This document describes the PACE platform at the container level, covering all components and their interfaces as shown in the Container Diagram below.

![](embed:PaceWebContainers)

## Platform Composition

The PACE platform consists of two software systems:

- **PACE Web** — The full-stack CRM and sales application (Payload + Next.js) with its primary PostgreSQL database.
- **PACE AI Suite** — The AI subsystem providing conversation analysis, transcription, and agentic AI capabilities.

Three user roles interact with the platform: **Manager**, **Admin**, and **Agent** — all Allsop employees authenticated via Google Identity (SSO).

## External Integrations

The platform integrates with external services organized by domain:

| Domain | Systems | Purpose |
|---|---|---|
| Google Workspace / Cloud | Google Identity Services, Gmail API, Google Calendar API, Looker Studio, Vertex AI | Authentication (SSO), email delivery, agent scheduling, embedded analytics, LLM inference |
| Exotel | WhatsApp, Call Center | Applicant messaging and VoIP softphone |
| Real Estate Portals | Property Finder, Bayut, Allsop & Allsop Portal | Listing publication and syndication |
| Legacy CRM | Salesforce CRM, Salesforce Adapter | Data migration and backward compatibility (deprecated) |
