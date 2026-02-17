workspace "PACE Architecture" "Sales and CRM Platform for Allsop Real Estate" {

    model {
        # ============================================================
        # ACTORS
        # ============================================================

        manager = person "Manager" "Allsop employee with Manager role." "Allsop"
        admin = person "Admin" "Allsop employee with Admin role." "Allsop"
        agent = person "Agent" "Allsop employee with Agent role." "Allsop"
        developer = person "Developer" "Configures, monitors and maintains the backend, frontend and AI systems, and data flow between integrations." "Ingemark"
        supportTeam = person "Support Team" "Maintains the system, reacts to alerts and monitors the system." "Ingemark"

        # ============================================================
        # EXTERNAL SYSTEMS
        # ============================================================

        group "Existing Allsopp CRM" {
            lookerStudio = softwareSystem "Looker Studio" "Statistics tool integrated with Salesforce." "External,Deprecated"
            salesforce = softwareSystem "Salesforce CRM" "Handles KPIs and business logic synchronization." "External,Deprecated"
        }

        group "Google Workspace" {
            googleIdentity = softwareSystem "Google Identity Services" "Source of truth for authentication." "External,GoogleWorkspace"
            gmailApi = softwareSystem "Gmail API" "Send emails as Agent or System." "External,GoogleWorkspace"
        }

        group "Exotel" {
            whatsapp = softwareSystem "WhatsApp" "WhatsApp for communication with Applicants." "External,Exotel"
            callCenter = softwareSystem "Call Center" "VoIP Call Center for Agents." "External,Exotel"
        }

        group "Real Estate Portals" {
            propertyFinder = softwareSystem "Property Finder Portal" "Real estate listings portal." "External,RealEstatePortal"
            bayut = softwareSystem "Bayut Portal" "Real estate listings portal." "External,RealEstatePortal"
            allsopPortal = softwareSystem "Allsop & Allsop Portal" "Allsop real estate listings portal." "External,RealEstatePortal"
        }

        salesforceAdapter = softwareSystem "Salesforce Adapter" "Integrates with PACE to fetch relevant data and ensure Salesforce functionality remains consistent." "External,Deprecated"

        # ============================================================
        # INFRASTRUCTURE
        # ============================================================

        group "Infrastructure" {
            gcp = softwareSystem "Google Cloud Platform" "Primary cloud provider" "Infrastructure"
            bitbucket = softwareSystem "Bitbucket" "Source code repository" "Infrastructure"
            bitbucketPipelines = softwareSystem "Bitbucket Pipelines" "CI/CD pipeline" "Infrastructure"
            argo = softwareSystem "Argo" "Deploys all components to GKE" "Infrastructure"
            pagerDuty = softwareSystem "PagerDuty" "Alerting system" "Infrastructure"
            gcpOperations = softwareSystem "Google Cloud Operations Suite" "Observability and monitoring" "Infrastructure"
        }

        # ============================================================
        # PACE PLATFORM
        # ============================================================

        group "PACE Sales and CRM Platform" {
            paceWeb = softwareSystem "PACE Web" "Pace Full-Stack Backend and Frontend Service for Applicant and Listing Management." "Ingemark" {
                paceDb = container "Pace DB" "Primary transactional database." "PostgreSQL on Google Cloud SQL" "Database"
                pace = container "PACE" "PACE Sales and CRM Platform." "Payload, Next.js"
            }

            paceAiSuite = softwareSystem "PACE AI Suite" "PACE AI Suite based on the AI Assistcraft proprietary platform. Provides AI capabilities, conversation analysis, transcript." "Ingemark" {
                assistcraftDb = container "Assistcraft DB" "Dedicated AI database." "PostgreSQL on Google Cloud SQL" "Database"
                paceAiBackend = container "PACE AI Backend" "Main AssistCraft service, backend logic and agentic functionality." "Python, FastAPI"
                mcpServer = container "MCP Server" "MCP server with specific functionality used by AI agents." "Python, FastMCP"
            }
        }

        # ============================================================
        # RELATIONSHIPS - Actors to Systems (Context level)
        # ============================================================

        manager -> paceWeb "Manager interface"
        googleIdentity -> manager "Single Sign On"

        admin -> paceWeb "Admin interface"
        googleIdentity -> admin "Single Sign On"

        agent -> paceWeb "Agent interface"
        googleIdentity -> agent "Single Sign On"

        developer -> paceWeb "Development"
        developer -> paceAiSuite "Development"
        developer -> bitbucket "Commits code"

        supportTeam -> paceWeb "Monitors and supports"
        supportTeam -> paceAiSuite "Monitors and supports"

        # ============================================================
        # RELATIONSHIPS - System level (Context diagram)
        # ============================================================

        paceWeb -> paceAiSuite "AI & other data flow" "SSE, REST API"
        paceWeb -> googleIdentity "Identity Confirmation" "REST API"

        paceWeb -> gmailApi "Share Listings (email)" "REST API"
        paceWeb -> whatsapp "Share listings (WhatsApp)" "REST API"
        paceWeb -> propertyFinder "Publish listing to Property Finder" "REST API"
        paceWeb -> bayut "Publish listing to Bayut" "REST API"
        paceWeb -> allsopPortal "Publish listing to Allsop portal" "REST API"
        paceWeb -> callCenter "Softphone and backend integration" "REST API, WebSocket"
        salesforce -> paceWeb "Initial Data Migration (CSV import)" "Manual file import"
        paceWeb -> lookerStudio "View statistics data (read-only)" "REST API"

        paceWeb -> salesforce "Salesforce fetches PACE data" "REST API"
        callCenter -> paceWeb "Real-time conversation stream" "WebSocket"

        # ============================================================
        # RELATIONSHIPS - Container level (Container diagram)
        # ============================================================

        # Actors to containers
        manager -> pace "Manager interface (INTF-USER-01)" "HTTPS/REST"
        admin -> pace "Admin interface (INTF-USER-02)" "HTTPS/REST"
        agent -> pace "Agent interface (INTF-USER-03)" "HTTPS/REST"

        # PACE internal
        pace -> paceDb "Reads/writes data (INTF-DB-01)" "PostgreSQL Wire Protocol"
        paceAiBackend -> assistcraftDb "Reads/writes AI data (INTF-DB-02)" "PostgreSQL Wire Protocol"

        # PACE <-> AI Backend
        pace -> paceAiBackend "AI streaming request (INTF-AI-01)" "HTTP SSE"
        paceAiBackend -> pace "Fetches database schema (INTF-AI-02)" "HTTP REST"

        # AI Backend <-> MCP Servers
        paceAiBackend -> mcpServer "AI agent communication (INTF-AI-04..0x)" "HTTP Streaming"
        mcpServer -> pace "Fetch PACE data (INTF-AI-03)" "HTTP REST"

        # PACE to external systems
        pace -> googleIdentity "Identity Confirmation (INTF-AUTH-02)" "HTTP REST"
        pace -> gmailApi "Send emails (INTF-PACE-03)" "HTTP REST"
        pace -> whatsapp "WhatsApp messaging (INTF-PACE-07)" "HTTP REST"
        pace -> allsopPortal "Publish listing (INTF-PACE-04)" "HTTP REST"
        pace -> bayut "Publish listing (INTF-PACE-05)" "HTTP REST"
        pace -> propertyFinder "Publish listing (INTF-PACE-06)" "HTTP REST"
        pace -> callCenter "Softphone integration (INTF-PACE-01)" "HTTP REST, WebSocket"
        pace -> lookerStudio "View statistics (INTF-PACE-02)" "HTTP REST"
        pace -> salesforceAdapter "Salesforce integration (INTF-SF-01)" "HTTP REST"
        salesforceAdapter -> salesforce "Synchronizes data" "REST API"

        # ============================================================
        # RELATIONSHIPS - Infrastructure
        # ============================================================

        bitbucket -> bitbucketPipelines "Detect changes and builds images"
        bitbucket -> argo "Connects to CI/CD repository"
        argo -> gcp "Deploys images"
        gcpOperations -> pagerDuty "Creates alerts based on rules"

        developer -> bitbucketPipelines "Modifies CI scripts"
        developer -> argo "Triggers deployments"

        supportTeam -> pagerDuty "Reacts to alerts"
        supportTeam -> gcpOperations "Monitors system"
    }

    views {
        # ============================================================
        # L1: SYSTEM CONTEXT
        # ============================================================

        systemContext paceWeb "SystemContext" "L1 - System Context" {
            include *
            include paceAiSuite
            exclude salesforceAdapter
        }

        # ============================================================
        # L2: CONTAINER VIEWS
        # ============================================================

        container paceWeb "PaceWebContainers" "L2 - PACE Platform Container Diagram" {
            # PACE Web containers
            include pace paceDb
            # PACE AI containers
            include paceAiBackend mcpServer assistcraftDb
            # Actors
            include manager admin agent developer supportTeam
            # External systems
            include googleIdentity gmailApi whatsapp callCenter
            include propertyFinder bayut allsopPortal
            include lookerStudio salesforce salesforceAdapter
            # Infrastructure
            include bitbucket bitbucketPipelines argo pagerDuty gcpOperations gcp
        }

        container paceAiSuite "PaceAiContainers" "L2 - PACE AI Suite Containers" {
            include *
            autoLayout
        }

        # ============================================================
        # STYLES
        # ============================================================

        styles {
            element "Person" {
                shape Person
                background #08427b
                color #ffffff
            }
            element "Allsop" {
                background #d4a017
                color #ffffff
            }
            element "Ingemark" {
                background #1168bd
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External" {
                background #999999
                color #ffffff
            }
            element "Deprecated" {
                background #d4a017
                opacity 70
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Database" {
                shape Cylinder
                background #438dd5
                color #ffffff
            }
            element "GoogleWorkspace" {
                background #34A853
                color #ffffff
            }
            element "Exotel" {
                background #7B1FA2
                color #ffffff
            }
            element "RealEstatePortal" {
                background #E65100
                color #ffffff
            }
            element "Infrastructure" {
                background #666666
                color #ffffff
            }
        }
    }
}
