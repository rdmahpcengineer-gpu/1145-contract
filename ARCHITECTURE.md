# alchemist-contracts — Architecture

Owns the shapes crossing four boundaries. Each has one authored artifact + generated stubs.

| Boundary | ID | Artifact | Consumers |
|---|---|---|---|
| Edge ↔ AWS wire | SE-1 | `proto/` | middleware (Py), backend (Py) |
| Agent tool calls | AC-2 | `proto/` or tool schema | backend AgentCore |
| Dashboard commands + reads | CP-2 | `openapi.yaml` | frontend (TS), backend |
| Dashboard live feed | CP-3 | `graphql/schema.graphql` | frontend (codegen), backend (CDK builds AppSync from it) |

## CP-3 specifics (the part most likely to drift)
- **Live feed only.** Query + Subscription for the dashboard; IAM-auth `publish*` mutations for the
  backend. No user-facing mutations — those are CP-2 REST.
- **Auth split:** reads/subscriptions `@aws_cognito_user_pools`; publishers `@aws_iam`.
- **Subscription filter footgun:** a subscription can only filter on an argument that appears as a field
  in the bound mutation's RETURN payload. `Call` carries `tenantId`, `TranscriptTurn` carries `callId`
  for exactly this reason.
- **Tenant isolation** lives in the backend resolver (`PK = TENANT#<tenantId>`), not assumed from the arg.

## Build-first gate
Stand up v0 of SE-1 wire + AC-2 tool schema + `graphql/schema.graphql` before middleware/backend start,
or they hand-stub boundary code and drift.
