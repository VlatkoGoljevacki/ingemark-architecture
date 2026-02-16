# ADR-0003: Google SSO Authentication

## Status

Accepted

## Date

2025-01-27

## Context

PACE needs an authentication system that:
- Leverages existing Allsop identity infrastructure
- Ensures only Allsop employees can access the system
- Provides role-based access (Manager, Admin, Agent)
- Synchronizes user data between Google Workspace and PACE

## Decision

We will implement **Google SSO (Sign-in with Google)** using Google Identity Services:

### 1. Authentication Flow
1. User clicks "Sign in with Google" on PACE Web
2. Redirect to Google Identity Services
3. User authenticates with Allsop Google Workspace credentials
4. Google returns OAuth token to PACE Authenticator
5. PACE Authenticator validates:
   - User has `@allsop.ae` email domain
   - User exists in PACE database with active status
   - User has appropriate role/permissions
6. PACE issues session token

### 2. PACE Authenticator Service
A dedicated Go service that:
- Handles OAuth 2.0 flow with Google
- Validates user against PACE database
- Manages session tokens
- Synchronizes user metadata from Google Workspace

### 3. Role Enforcement
- Roles (Manager, Admin, Agent) stored in PACE DB
- PACE Authenticator includes role in session token
- PACE Web enforces role-based access on each request

## Consequences

### Positive
- No password management in PACE
- Leverages Google's security infrastructure
- Automatic user provisioning via Workspace sync
- Familiar UX for Allsop employees

### Negative
- Dependency on Google services availability
- Cannot add non-Allsop users without Workspace changes
- Google Workspace admin must manage user lifecycle

### Risks
- Google API rate limits during peak usage
- Workspace sync delays could cause access issues

## Affected Elements

LikeC4 elements affected by this decision:

- `googleIdentity` - External identity provider
- `pace.paceAuthenticator` - Handles OAuth flow
- `pace.paceWeb` - Initiates auth, enforces roles
- `pace.paceDb` - Stores user records and roles
- `manager`, `admin`, `agent` - User actors

## Related Diagrams

- [Authentication Flow (L2)](../exports/authFlow.png)
- [System Context (L1)](../exports/systemContext.png)

## References

- [Google Identity Services documentation](https://developers.google.com/identity)
- OAuth 2.0 specification (RFC 6749)
