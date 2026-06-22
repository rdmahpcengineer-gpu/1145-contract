# Skill: seam-contracts

Authoring + versioning the boundary contracts (proto · graphql · openapi) and their codegen.

## Proto (domain source)
- One message per domain entity; `tenantId` on every cross-boundary entity.
- SE-1 wire = utterances (edge→AWS), reply-text (AWS→edge), call events. AC-2 = tool-call schema.

## GraphQL (CP-3 AppSync) — rules
1. **Live feed only** — Query + Subscription for the dashboard; no user-facing mutations.
2. **Auth:** reads/subscriptions `@aws_cognito_user_pools`; `publish*` mutations `@aws_iam` (backend only).
3. **Subscription filtering:** the filter arg MUST be a returned field of the bound mutation
   (`@aws_subscribe`). Design payloads accordingly.
4. **Tenant isolation** is a resolver concern (`PK = TENANT#<tenantId>`), enforced in the backend, not
   the schema.
5. GraphQL types **mirror the proto messages** — same names, same shape.

## OpenAPI (CP-2 REST)
- Commands (book/mark-won/escalate/call-back), LiveKit token issuance, and bulk reads. Everything that
  mutates state or returns large lists. AppSync never carries commands.

## Codegen
- proto → TS + Py; openapi → typed client (TS) + server stubs; graphql → TS types (frontend) and, where
  the backend resolvers are Py, the publish-payload input types.
- Stubs are generated artifacts — never edited by hand. Publish to CodeArtifact; consumers pin a version.
