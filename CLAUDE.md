# alchemist-contracts — Constitution

This repo is the **single source of truth** for every type that crosses a service boundary. If a shape
travels between middleware, backend, or frontend, it is defined here and imported everywhere else.

## Non-negotiables
- **Never hand-declare a boundary type** in another repo. Import from `@alchemist/contracts` (TS) /
  `alchemist_contracts` (Py). Stubs are generated, never hand-written.
- **Proto is the domain source model.** GraphQL (CP-3) and OpenAPI (CP-2) mirror the proto messages so
  there is one conceptual model across the seam. Keep field names aligned.
- **Version the seam.** Breaking a wire shape is a major version bump; consumers pin a version.
- **Tenant is a first-class field** on every cross-boundary entity. Isolation is enforced downstream,
  but the contract always carries `tenantId`.

## What this repo owns
- **SE-1 wire** (proto) — utterances edge→AWS, reply-text AWS→edge, call events.
- **AC-2 tool schema** — the tool-call contract for AgentCore's Tool Gateway.
- **CP-2 REST** (openapi) — commands + bulk reads.
- **CP-3 GraphQL** (`graphql/schema.graphql`) — the dashboard live feed. Live feed ONLY (see D-003).

Codegen targets: TS (`@alchemist/contracts`) + Py (`alchemist_contracts`). Publish to CodeArtifact.
