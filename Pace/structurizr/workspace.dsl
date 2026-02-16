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
            googleIdentity = softwareSystem "Google Identity Services" "Source of truth for authentication." "External"
            gmailApi = softwareSystem "Gmail API" "Send emails as Agent or System." "External"
        }

        group "Communications" {
            whatsappProvider = softwareSystem "WhatsApp Provider" "WhatsApp for communication with Applicants." "External"
            callCenter = softwareSystem "Call Center" "VoIP Call Center for Agents." "External"
        }

        group "Real Estate Portals" {
            propertyFinder = softwareSystem "Property Finder Portal" "Real estate listings portal." "External"
            bayut = softwareSystem "Bayut Portal" "Real estate listings portal." "External"
            allsopPortal = softwareSystem "Allsop & Allsop Portal" "Allsop real estate listings portal." "External"
        }

        # ============================================================
        # INFRASTRUCTURE
        # ============================================================

        group "Infrastructure" {
            gcp = softwareSystem "Google Cloud Platform" "Primary cloud provider" "Infrastructure"
            bitbucket = softwareSystem "Bitbucket" "Source code repository" "Infrastructure"
            bitbucketPipelines = softwareSystem "Bitbucket Pipelines" "CI/CD pipeline" "Infrastructure"
        }

        # ============================================================
        # PACE PLATFORM (split into two systems)
        # ============================================================

        group "PACE Sales and CRM Platform" {
            paceWeb = softwareSystem "PACE Web" "Pace Full-Stack Backend and Frontend Service for Applicant and Listing Management." "Ingemark" {
                paceDb = container "Pace DB" "Primary transactional database." "PostgreSQL on Google Cloud SQL" "Database"
                paceWebApp = container "PACE Web App" "Full-Stack Backend and Frontend." "TypeScript, React, Node.js"
            }

            paceAiSuite = softwareSystem "PACE AI Suite" "PACE AI Suite based on the AI Assistcraft proprietary platform. Provides AI capabilities, conversation analysis, transcript." "Ingemark" {
                assistcraftDb = container "Assistcraft DB" "Dedicated AI database." "PostgreSQL on Google Cloud SQL" "Database"
                aiAssistcraft = container "AI Assistcraft" "AI Suite for conversation analysis." "Python, LLM" {
                    assistcraftBackend = component "Assistcraft Backend" "Main backend service." "Python, FastAPI"
                    mcpServers = component "MCP Servers" "Model Context Protocol servers." "Python, MCP" "WIP"
                }
            }
        }

        # ============================================================
        # RELATIONSHIPS - Actors to Systems
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
        # RELATIONSHIPS - PACE Internal
        # ============================================================

        paceWeb -> paceAiSuite "AI & other data flow" "SSE, REST API"
        paceWeb -> googleIdentity "Identity Confirmation" "REST API"

        # Container-level relationships
        paceWebApp -> paceDb "Reads/writes data" "SQL"
        aiAssistcraft -> assistcraftDb "Reads/writes AI data" "SQL"
        assistcraftBackend -> paceWebApp "Fetches database schema" "REST API"
        mcpServers -> paceWebApp "Fetch data via MCP" "MCP Protocol"

        # ============================================================
        # RELATIONSHIPS - PACE to External
        # ============================================================

        paceWeb -> gmailApi "Share Listings (email)" "REST API"
        paceWeb -> whatsappProvider "Share listings (WhatsApp)" "REST API"
        paceWeb -> propertyFinder "Publish listing to Property Finder" "REST API"
        paceWeb -> bayut "Publish listing to Bayut" "REST API"
        paceWeb -> allsopPortal "Publish listing to Allsop portal" "REST API"
        paceWeb -> callCenter "Softphone and backend integration" "REST API, WebSocket"
        paceWeb -> salesforce "Initial Data Migration (CSV import)" "Manual file import"
        paceWeb -> lookerStudio "View statistics data (read-only)" "REST API"

        # ============================================================
        # RELATIONSHIPS - External to PACE
        # ============================================================

        salesforce -> paceWeb "Salesforce fetches PACE data" "REST API"
        callCenter -> paceWeb "Real-time conversation stream" "WebSocket"

        # ============================================================
        # RELATIONSHIPS - Infrastructure
        # ============================================================

        bitbucket -> bitbucketPipelines "Triggers build"
        bitbucketPipelines -> paceWeb "Deploys"
        bitbucketPipelines -> paceAiSuite "Deploys"
    }

    views {
        # ============================================================
        # L1: SYSTEM CONTEXT
        # ============================================================

        systemContext paceWeb "SystemContext" "L1 - System Context" {
            include *
            include paceAiSuite
        }

        # ============================================================
        # L2: CONTAINER VIEWS
        # ============================================================

        container paceWeb "PaceWebContainers" "L2 - PACE Web Containers" {
            include *
        }

        container paceAiSuite "PaceAiContainers" "L2 - PACE AI Suite Containers" {
            include *
        }

        # ============================================================
        # L3: AI COMPONENTS
        # ============================================================

        component aiAssistcraft "AIComponents" "L3 - AI Assistcraft Components" {
            include *
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
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Database" {
                shape Cylinder
                background #438dd5
                color #ffffff
            }
            element "Infrastructure" {
                background #666666
                color #ffffff
            }
            element "WIP" {
                background #d4a017
                opacity 80
            }
        }
    }
}
