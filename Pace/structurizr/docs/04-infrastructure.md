# Infrastructure

## Cloud Platform

![](embed:ProductionDeployment)

PACE runs entirely on **Google Cloud Platform (GCP)**. All compute, storage, and managed services are provisioned within GCP.

## Runtime Environment

### GKE Cluster

All application workloads run on a **Google Kubernetes Engine (GKE)** cluster, organized into namespaces by system:

| Namespace | Containers | Purpose |
|---|---|---|
| `pace-web` | PACE (Payload + Next.js) | The main CRM application — UI, business logic, and API layer. |
| `pace-ai` | PACE AI Backend, MCP Servers | The AI subsystem — conversation processing, semantic search, and agentic AI tools. |

### Cloud SQL

Databases are hosted on **Google Cloud SQL** (managed PostgreSQL), separate from the GKE cluster:

| Database | Serves | Data |
|---|---|---|
| Pace DB | PACE Web | Business data — applicants, listings, users, communications, portal state. |
| PACE AI DB | PACE AI Suite | AI data — conversations, transcripts, agent execution state, embeddings. |

Cloud SQL provides automated backups, high availability, and private IP connectivity within the GCP VPC.

## CI/CD Pipeline

Code flows from development to production through a fully automated pipeline:

| Stage | Tool | What happens |
|---|---|---|
| Source control | **Bitbucket** | Developers commit code to Bitbucket repositories. |
| Build | **Bitbucket Pipelines** | On push, Pipelines builds container images and runs tests. |
| Deploy | **Argo** | Argo watches the CI/CD repository and deploys updated images to the GKE cluster using GitOps. |

The pipeline is triggered automatically on code changes. Argo runs inside the GKE cluster and manages deployments declaratively — the desired state is defined in Git, and Argo reconciles the cluster to match.

## Monitoring & Alerting

| Tool | Role |
|---|---|
| **Google Cloud Operations Suite** | Centralized observability — logs, metrics, traces, and dashboards for all GCP resources and GKE workloads. |
| **PagerDuty** | Alert routing and escalation. Cloud Operations Suite triggers PagerDuty alerts based on predefined rules (error rate spikes, resource exhaustion, health check failures). |

The **Support Team** monitors the system through Cloud Operations dashboards and responds to PagerDuty alerts.
