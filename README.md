# Ingemark Architecture Index

Central index for all Ingemark project architecture documentation. Each project maintains its own architecture repository with diagrams, documentation, and ADRs. This repo provides a lightweight landing page — project sites are deployed at runtime, not committed here.

## Projects

| Project | Tooling | Repository |
|---|---|---|
| PACE | Structurizr DSL | [pace-architecture](../pace-architecture) |

## How It Works

```
ingemark-architecture/          # This repo (committed)
├── index.html                  # Landing page linking to all projects
├── standards/                  # Company-wide conventions and templates
├── projects/                   # Runtime content (gitignored)
│   ├── pace/                   # Deployed by pace-architecture CI
│   └── <project-x>/           # Deployed by project-x CI
├── docker-compose.yml
└── Makefile
```

The `projects/` directory is **not committed** — it is populated at runtime. Each project's CI pipeline builds its static site and deploys the output to `projects/<name>/` on whatever server hosts the index.

### Deployment Flow

```
pace-architecture repo          ingemark-architecture server
┌─────────────────────┐         ┌──────────────────────────┐
│ workspace.dsl       │  CI     │ index.html               │
│ docs/               │ ─────>  │ projects/pace/  (deploy)  │
│ adrs/               │  build  │                          │
│ docker-compose.yml  │  + push │                          │
└─────────────────────┘         └──────────────────────────┘
```

Each project repo is responsible for:
1. Building its own static site (Structurizr, LikeC4, MkDocs — whatever it uses)
2. Pushing the build output to `projects/<name>/` on the index server

The index repo is responsible for:
1. The landing page (`index.html`)
2. Company-wide standards and templates
3. Serving the aggregated content

## Local Development

### Serve the Index

```bash
make serve
# or
npx serve .
```

Open [http://localhost:3000](http://localhost:3000).

### Populate a Project Locally

From the project repo (e.g., `pace-architecture`):

```bash
# Build the static site
docker compose run --rm site-generatr

# Deploy to the local index
cp -r build/* ../ingemark-architecture/projects/pace/
```

Then refresh the index page — the PACE link will work.

### Add a New Project

1. Create a new architecture repo for the project
2. Add a compose file with the appropriate site generator
3. Add a link in `index.html` pointing to `projects/<name>/master/`
4. Configure the project's CI to deploy build output to `projects/<name>/`

## Standards

### ADR Format

All projects use [adr-tools](https://github.com/npryce/adr-tools) format for Architecture Decision Records:

```markdown
# <number>. <Title>

Date: YYYY-MM-DD

## Status

Proposed | Accepted | Deprecated | Superseded

## Context

[Why is this decision needed?]

## Decision

[What was decided?]

## Consequences

[What are the implications?]
```

### Architecture Tooling

Projects can use any C4-compatible tooling:

| Tool | Best For | Site Generator |
|---|---|---|
| [Structurizr DSL](https://docs.structurizr.com/dsl) | Manually positioned diagrams, mature C4 support | [structurizr-site-generatr](https://github.com/avisi-cloud/structurizr-site-generatr) |
| [LikeC4](https://likec4.dev/) | Flexible views, code-first approach | Built-in export |
| Plain Markdown | Simple documentation without diagrams | [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) |
