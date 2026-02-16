# Ingemark Architecture Repository

Multi-project architecture documentation using LikeC4 diagrams and ADRs.

## Structure

```
ingemark-architecture/
├── docker-compose.yml    # Shared LikeC4 service
├── Makefile              # Common commands
├── Pace/                 # Project: Pace
│   ├── architecture/     # LikeC4 model and views
│   ├── docs/
│   │   ├── adr/          # Architecture Decision Records
│   │   └── guides/       # Technical documentation
│   └── exports/          # Generated diagram images
└── <OtherProject>/       # Future projects follow same structure
```

## Quick Start

```bash
# Start LikeC4 dev server (all projects)
docker compose up likec4

# Open in browser
open http://localhost:3000
```

## Working with a Project

```bash
# Export diagrams for a project
make export PROJECT=Pace

# Create new ADR
make adr PROJECT=Pace TITLE="use-redis-for-caching"
```

## Project Template

To add a new project:

```bash
mkdir -p NewProject/{architecture,docs/adr,docs/guides,exports}
```

Then create:
- `NewProject/architecture/model.c4` - Element definitions
- `NewProject/architecture/views.c4` - Diagram views
- `NewProject/likec4.config.mjs` - Project config (optional)

## Conventions

### ADR Linking

1. **Model → ADR**: Use `link` property on elements
2. **ADR → Diagram**: Reference exported SVGs or link to views
3. **Tags**: Use `#adr-XXXX` tags for filtering

### Element Naming

- Use lowercase with dots for hierarchy: `pace.backend.userService`
- Keep identifiers consistent across ADRs and model
