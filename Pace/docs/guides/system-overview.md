# PACE System Overview

## What is PACE?

PACE (Property Agent CRM & Engagement) is a Sales and CRM platform built to replace Allsop's existing Salesforce-based CRM system. It provides:

- **Listing Management**: Create, update, and publish real estate listings
- **Applicant Management**: Track and manage property applicants
- **Agent Tools**: Communication, scheduling, and workflow management
- **AI Assistance**: Intelligent conversation analysis and agent support

## System Context

![System Context Diagram](../../exports/systemContext.png)

PACE integrates with multiple external systems:

| System | Purpose | Direction |
|--------|---------|-----------|
| Google Identity | SSO authentication | Inbound |
| Gmail API | Email sending | Outbound |
| WhatsApp | Messaging | Outbound |
| Call Center (VoIP) | Voice communication | Bidirectional |
| Property Finder | Listing publication | Outbound |
| Bayut | Listing publication | Outbound |
| Allsop Portal | Listing publication | Outbound |
| Salesforce | Data sync (legacy) | Bidirectional |

## User Roles

### Agent
Front-line users who manage applicants and listings within their area of jurisdiction.

### Manager
Supervisory role with visibility across their team's activities and reporting capabilities.

### Admin
System administrators who configure the platform and manage user access.

## Architecture Decisions

Key architectural decisions are documented as ADRs:

- [ADR-0001: Salesforce Integration Strategy](../adr/0001-salesforce-integration-strategy.md)
- [ADR-0002: AI Assistcraft Architecture](../adr/0002-ai-assistcraft-architecture.md)
- [ADR-0003: Google SSO Authentication](../adr/0003-google-sso-authentication.md)

## Related Diagrams

- [System Context (L1)](../../exports/systemContext.png) - High-level overview
- [Containers (L2)](../../exports/containers.png) - Internal structure
- [AI Components (L3)](../../exports/aiComponents.png) - AI subsystem detail
