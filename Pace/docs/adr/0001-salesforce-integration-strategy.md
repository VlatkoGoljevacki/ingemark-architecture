# ADR-0001: Salesforce Integration Strategy

## Status

Accepted

## Date

2025-01-27

## Context

PACE is being built to eventually replace the existing Allsop CRM based on Salesforce. During the transition period, both systems need to coexist and share data. We need to decide how data flows between PACE and Salesforce.

Key considerations:
- Salesforce handles KPIs and external business logic
- Agents, Applicants, and Listings need to be synchronized
- Looker Studio depends on Salesforce data for statistics
- We want PACE to be the source of truth long-term

## Decision

We will implement a **pull-based integration** where Salesforce fetches data from PACE:

1. **Salesforce Adapter Layer**: Salesforce will contain an adapter that:
   - Fetches data from PACE via REST API
   - Transforms PACE data models to Salesforce objects
   - Handles conflict resolution (Salesforce as secondary)

2. **Initial Migration**: One-time CSV import for historical data migration from Salesforce to PACE

3. **Looker Studio**: PACE Web will provide read-only API access for statistics data

## Consequences

### Positive
- PACE becomes the source of truth immediately
- Salesforce integration is a soft dependency (PACE works without it)
- Clear data ownership boundaries
- Gradual migration path

### Negative
- Salesforce adapter development is Allsop's responsibility
- Potential data staleness if Salesforce polling is infrequent
- Looker Studio dashboards may need redesign to use PACE APIs directly

### Risks
- Salesforce adapter bugs could cause data inconsistency
- Performance impact if Salesforce polls too frequently

## Affected Elements

LikeC4 elements affected by this decision:

- `salesforce` - Contains the adapter layer
- `pace.paceWeb` - Exposes REST API for Salesforce to consume
- `lookerStudio` - Consumes statistics from PACE

## Related Diagrams

- [Salesforce Integration View](../exports/salesforceIntegration.png)
- [System Context View](../exports/systemContext.png)

## References

- Salesforce Connect documentation
- PACE API specification (internal)
