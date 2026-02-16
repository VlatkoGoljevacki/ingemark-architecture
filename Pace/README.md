# PACE Architecture

PACE (Property Agent CRM & Engagement) - Sales and CRM platform for Allsop real estate.

## Quick Start

```bash
# From repo root
docker compose up likec4

# Open http://localhost:3000 and navigate to Pace
```

## Structure

```
Pace/
├── architecture/           # LikeC4 model files
│   ├── spec.c4             # Element kinds, styles, tags
│   ├── model.c4            # Elements and relationships
│   └── views.c4            # Diagram definitions
├── docs/
│   ├── adr/                # Architecture Decision Records
│   │   ├── 0001-salesforce-integration-strategy.md
│   │   ├── 0002-ai-assistcraft-architecture.md
│   │   └── 0003-google-sso-authentication.md
│   └── guides/             # Technical documentation
│       ├── system-overview.md
│       └── container-architecture.md
└── exports/                # Generated diagram images
```

## Diagrams

| View | Level | Description |
|------|-------|-------------|
| `systemContext` | L1 | High-level system and external integrations |
| `containers` | L2 | Internal PACE containers and databases |
| `authFlow` | L2 | Authentication flow focused view |
| `portalIntegration` | L2 | Real estate portal publishing |
| `communicationChannels` | L2 | Email, WhatsApp, VoIP integrations |
| `aiComponents` | L3 | AI Assistcraft internal components |
| `salesforceIntegration` | L2 | Legacy CRM integration |
| `infrastructure` | Infra | CI/CD and deployment |

## ADR ↔ Diagram Linking

### From Model to ADR
Elements link to ADRs via the `link` property:
```c4
salesforce = externalSystem 'Salesforce CRM' {
  link ./docs/adr/0001-salesforce-integration-strategy.md 'ADR-0001'
  #adr-0001
}
```

### From ADR to Diagram
ADRs reference exported diagrams:
```markdown
## Related Diagrams
- [Salesforce Integration View](../exports/salesforceIntegration.png)
```

### Tags
Use `#adr-XXXX` tags to filter elements by decision:
```c4
view salesforceElements {
  include element.tag == #adr-0001
}
```

## Export Diagrams

```bash
# From repo root
make export PROJECT=Pace
```

## Create New ADR

```bash
make adr PROJECT=Pace TITLE="use-kafka-for-events"
```
