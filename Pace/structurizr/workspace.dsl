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
            salesforce = softwareSystem "Salesforce CRM" "Handles KPIs and business logic synchronization." "External,Deprecated" {
                url "http://localhost:3001/workspace/documentation#salesforce-crm-deprecated"
            }
        }

        group "Google Workspace" {
            googleIdentity = softwareSystem "Google Identity Services" "Source of truth for authentication." "External,GoogleWorkspace" {
                url "http://localhost:3001/workspace/documentation#google-identity-services"
            }
            gmailApi = softwareSystem "Gmail API" "Send emails as Agent or System." "External,GoogleWorkspace" {
                url "http://localhost:3001/workspace/documentation#gmail-api"
            }
            googleCalendarApi = softwareSystem "Google Calendar API" "Agent calendar management — viewings, meetings, availability." "External,GoogleWorkspace" {
                url "http://localhost:3001/workspace/documentation#google-calendar-api"
            }
            lookerStudio = softwareSystem "Looker Studio" "Embedded analytics and KPI dashboards." "External,GoogleWorkspace" {
                url "http://localhost:3001/workspace/documentation#looker-studio"
            }
            vertexAi = softwareSystem "Vertex AI" "LLM inference and semantic search." "External,GoogleWorkspace" {
                url "http://localhost:3001/workspace/documentation#vertex-ai"
            }
        }

        group "Exotel" {
            whatsapp = softwareSystem "WhatsApp" "WhatsApp for communication with Applicants." "External,Exotel" {
                url "http://localhost:3001/workspace/documentation#whatsapp"
            }
            callCenter = softwareSystem "Call Center" "VoIP Call Center for Agents." "External,Exotel" {
                url "http://localhost:3001/workspace/documentation#call-center"
            }
        }

        group "Real Estate Portals" {
            propertyFinder = softwareSystem "Property Finder Portal" "Real estate listings portal." "External,RealEstatePortal" {
                url "http://localhost:3001/workspace/documentation#property-finder-portal"
            }
            bayut = softwareSystem "Bayut Portal" "Real estate listings portal." "External,RealEstatePortal" {
                url "http://localhost:3001/workspace/documentation#bayut-portal"
            }
            allsopPortal = softwareSystem "Allsop & Allsop Portal" "Allsop real estate listings portal." "External,RealEstatePortal" {
                url "http://localhost:3001/workspace/documentation#allsop--allsop-portal"
            }
        }

        salesforceAdapter = softwareSystem "Salesforce Adapter" "Pulls data from PACE and maps it to Salesforce data models." "External" {
            url "http://localhost:3001/workspace/documentation#salesforce-adapter"
        }

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
                url "http://localhost:3001/workspace/documentation#pace-web-containers"
                paceDb = container "Pace DB" "Primary transactional database." "PostgreSQL on Google Cloud SQL" "Database" {
                    url "http://localhost:3001/workspace/documentation#pace-db"
                }
                pace = container "PACE" "PACE Sales and CRM Platform." "Payload, Next.js" {
                    url "http://localhost:3001/workspace/documentation#pace"
                }
            }

            paceAiSuite = softwareSystem "PACE AI Suite" "PACE AI Suite. Provides AI capabilities, conversation analysis, transcript." "Ingemark" {
                url "http://localhost:3001/workspace/documentation#pace-ai-suite-containers"
                assistcraftDb = container "PACE AI DB" "Dedicated AI database." "PostgreSQL on Google Cloud SQL" "Database" {
                    url "http://localhost:3001/workspace/documentation#pace-ai-db"
                }
                paceAiBackend = container "PACE AI Backend" "Main AI service, backend logic and agentic functionality." "Python, FastAPI" {
                    url "http://localhost:3001/workspace/documentation#pace-ai-backend"
                }
                mcpServer = container "MCP Servers" "MCP server with specific functionality used by AI agents." "Python, FastMCP" {
                    url "http://localhost:3001/workspace/documentation#mcp-servers"
                }
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
        paceAiSuite -> vertexAi "LLM inference and semantic search" "REST API"
        paceWeb -> googleIdentity "Identity Confirmation" "REST API"

        paceWeb -> gmailApi "Share Listings (email)" "REST API"
        paceWeb -> googleCalendarApi "Viewings, meetings, availability" "REST API"
        paceWeb -> whatsapp "Share listings (WhatsApp)" "REST API"
        paceWeb -> propertyFinder "Publish listing to Property Finder" "REST API"
        paceWeb -> bayut "Publish listing to Bayut" "REST API"
        paceWeb -> allsopPortal "Publish listing to Allsop portal" "REST API"
        paceWeb -> callCenter "Softphone and backend integration" "REST API, WebSocket"
        salesforce -> paceWeb "Initial Data Migration (CSV import)" "Manual file import"
        paceWeb -> lookerStudio "Embedded analytics dashboards" "iframe"

        paceWeb -> salesforce "Salesforce fetches PACE data" "REST API"
        callCenter -> paceWeb "Real-time conversation stream" "WebSocket"

        # ============================================================
        # RELATIONSHIPS - Container level (Container diagram)
        # ============================================================

        # Actors to containers
        manager -> pace "Manager interface (INTF-USER-01)" "HTTPS/REST" {
            url "http://localhost:3001/workspace/documentation#intf-user-01-%E2%80%94-manager-interface"
        }
        admin -> pace "Admin interface (INTF-USER-02)" "HTTPS/REST" {
            url "http://localhost:3001/workspace/documentation#intf-user-02-%E2%80%94-admin-interface"
        }
        agent -> pace "Agent interface (INTF-USER-03)" "HTTPS/REST" {
            url "http://localhost:3001/workspace/documentation#intf-user-03-%E2%80%94-agent-interface"
        }

        # PACE internal
        pace -> paceDb "Reads/writes data (INTF-DB-01)" "PostgreSQL Wire Protocol" {
            url "http://localhost:3001/workspace/documentation#intf-db-01-%E2%80%94-pace-database-access"
        }
        paceAiBackend -> assistcraftDb "Reads/writes AI data (INTF-DB-02)" "PostgreSQL Wire Protocol" {
            url "http://localhost:3001/workspace/documentation#intf-db-02-%E2%80%94-ai-database-access"
        }

        # PACE <-> AI Backend
        pace -> paceAiBackend "AI application request (INTF-AI-01)" "HTTP SSE" {
            url "http://localhost:3001/workspace/documentation#intf-ai-01-%E2%80%94-ai-application-request"
        }
        paceAiBackend -> pace "Fetches schema and data (INTF-AI-02)" "HTTP REST" {
            url "http://localhost:3001/workspace/documentation#intf-ai-02-%E2%80%94-schema-and-data-fetching"
        }

        # AI Backend <-> MCP Servers
        paceAiBackend -> mcpServer "AI agent communication (INTF-AI-04..0x)" "HTTP Streaming" {
            url "http://localhost:3001/workspace/documentation#intf-ai-040x-%E2%80%94-ai-agent-to-mcp-communication"
        }

        # AI Backend to LLM
        paceAiBackend -> vertexAi "LLM inference and semantic search (INTF-AI-05)" "HTTP REST" {
            url "http://localhost:3001/workspace/documentation#intf-ai-05-%E2%80%94-llm-inference-vertex-ai"
        }
        mcpServer -> pace "Fetch PACE data (INTF-AI-03)" "HTTP REST" {
            url "http://localhost:3001/workspace/documentation#intf-ai-03-%E2%80%94-mcp-data-retrieval"
        }

        # PACE to external systems
        pace -> googleIdentity "Identity Confirmation (INTF-AUTH-02)" "HTTP REST" {
            url "http://localhost:3001/workspace/documentation#intf-auth-02-%E2%80%94-google-identity-confirmation"
        }
        pace -> gmailApi "Send emails (INTF-PACE-03)" "HTTP REST" {
            url "http://localhost:3001/workspace/documentation#intf-pace-03-%E2%80%94-gmail-email"
        }
        pace -> googleCalendarApi "Calendar sync (INTF-PACE-08)" "HTTP REST, Webhooks" {
            url "http://localhost:3001/workspace/documentation#intf-pace-08-%E2%80%94-google-calendar-viewings--scheduling"
        }
        pace -> whatsapp "WhatsApp messaging (INTF-PACE-07)" "HTTP REST" {
            url "http://localhost:3001/workspace/documentation#intf-pace-07-%E2%80%94-whatsapp-messaging"
        }
        pace -> allsopPortal "Publish listing (INTF-PACE-04)" "HTTP REST" {
            url "http://localhost:3001/workspace/documentation#intf-pace-04-%E2%80%94-allsop--allsop-portal-listing-publication"
        }
        pace -> bayut "Publish listing (INTF-PACE-05)" "HTTP REST" {
            url "http://localhost:3001/workspace/documentation#intf-pace-05-%E2%80%94-bayut-listing-publication"
        }
        pace -> propertyFinder "Publish listing (INTF-PACE-06)" "HTTP REST" {
            url "http://localhost:3001/workspace/documentation#intf-pace-06-%E2%80%94-property-finder-listing-publication"
        }
        pace -> callCenter "Softphone integration (INTF-PACE-01)" "iframe, WebRTC, REST Webhooks" {
            url "http://localhost:3001/workspace/documentation#intf-pace-01-%E2%80%94-call-center-softphone"
        }
        pace -> lookerStudio "Embedded analytics (INTF-PACE-02)" "iframe" {
            url "http://localhost:3001/workspace/documentation#intf-pace-02-%E2%80%94-looker-studio-embedded-analytics"
        }
        salesforceAdapter -> pace "Fetches PACE data (INTF-SF-01)" "HTTP REST" {
            url "http://localhost:3001/workspace/documentation#intf-sf-01-%E2%80%94-salesforce-adapter"
        }
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

        # ============================================================
        # DEPLOYMENT - Production
        # ============================================================

        deploymentEnvironment "Production" {
            deploymentNode "Google Cloud Platform" "" "" "CloudProvider" {
                deploymentNode "GKE Cluster" "" "Kubernetes" {
                    deploymentNode "pace-web" "PACE Web namespace" "" {
                        containerInstance pace
                    }
                    deploymentNode "pace-ai" "PACE AI Suite namespace" "" {
                        containerInstance paceAiBackend
                        containerInstance mcpServer
                    }
                    softwareSystemInstance argo
                }
                deploymentNode "Cloud SQL" "" "Google Cloud SQL" {
                    containerInstance paceDb
                    containerInstance assistcraftDb
                }
                softwareSystemInstance gcpOperations
            }
            deploymentNode "Atlassian Cloud" "" "" "CloudProvider" {
                softwareSystemInstance bitbucket
                softwareSystemInstance bitbucketPipelines
            }
            deploymentNode "PagerDuty" "" "" "CloudProvider" {
                softwareSystemInstance pagerDuty
            }
        }
    }

    !docs docs

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
            include manager admin agent
            # External systems
            include googleIdentity gmailApi googleCalendarApi whatsapp callCenter vertexAi
            include propertyFinder bayut allsopPortal
            include lookerStudio salesforce salesforceAdapter
        }

        container paceAiSuite "PaceAiContainers" "L2 - PACE AI Suite Containers" {
            include *
            autoLayout
        }

        # ============================================================
        # DEPLOYMENT VIEW
        # ============================================================

        deployment * "Production" "ProductionDeployment" "Production Deployment - Infrastructure & Runtime" {
            include *
            autoLayout lr
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
