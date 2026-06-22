# v0 Build Summary — alchemist-contracts

Stood up **v0 of all four boundary contracts** so middleware, backend, and frontend can build against
generated stubs instead of hand-stubbing the seam. Codegen verified end-to-end for both TypeScript and
Python.

## Delivered

| Boundary | Artifact | Notes |
|---|---|---|
| **SE-1** wire | `proto/alchemist/v0/se1.proto` | `Utterance` (edge→AWS), `ReplyText` (AWS→edge), `CallEvent` lifecycle + `Se1Bridge` service. `tenantId`/`seq`/`ts` on the wire. |
| **AC-2** tools | `proto/alchemist/v0/ac2.proto` | `ToolInvocation`/`ToolResult` envelope, `oneof` over 6 tools (check-availability, book, capture-lead, escalate, callback, mark-won) + `ToolGateway` service. |
| domain source | `proto/alchemist/v0/domain.proto` | `Call`, `TranscriptTurn`, `CallBrief`, `Lead`, `Conversation`, `Kpi` + enums — names/shape mirror CP-3. |
| **CP-2** REST | `openapi/openapi.yaml` | Commands (book / mark-won / escalate / call-back), LiveKit token, paged reads; Cognito bearer auth. |
| **CP-3** live feed | `graphql/schema.graphql` (existing v0) | Used unchanged. Added codegen-only `graphql/appsync-aws.graphql` shim for AppSync scalars/directives. |

## Codegen → two published packages

- **`@alchemist/contracts`** (TS): buf (proto) + graphql-codegen + openapi-typescript → namespaced root
  export `{ proto, graphql, openapi }` → `tsc` to `dist/`.
- **`alchemist-contracts`** (Py): proto via buf + pydantic models from OpenAPI, behind an
  `alchemist_contracts` facade (`se1`, `ac2`, `domain`, `openapi`).
- `Makefile` orchestrates both; CodeArtifact publish targets + `.npmrc.example` included. Proto codegen
  uses buf **remote plugins** (no local `protoc` needed; network required at gen time).

## Validation

`make gen` produced all stubs; TS compiled; the TS root export resolved; a Python smoke test constructed
a message across **all four boundaries** — all green. Generated `gen/`, `dist/`, `node_modules/`,
`.venv/` are gitignored (stubs are build artifacts shipped inside the published packages).

## Known v0 gap

No separate Python types for CP-3 publish payloads — the backend's `publish*` inputs mirror the proto
domain messages, which are already generated for Py.
