# Build prompt — alchemist-contracts

Read `CLAUDE.md`, `ARCHITECTURE.md`; use the `seam-contracts` skill.

1. Scaffold the package (TS + Py codegen pipelines, CodeArtifact publish config).
2. Author **proto** domain messages + SE-1 wire v0 (utterances, reply-text, call events) and the AC-2
   tool schema.
3. Take `graphql/schema.graphql` (provided) as the **CP-3 v0**. Validate it against the dashboard data
   shapes; do not add user-facing mutations.
4. Author a **CP-2 openapi** skeleton for commands + bulk reads (book, mark-won, escalate, call-back,
   LiveKit token, list reads).
5. Wire codegen: proto + openapi + graphql → `@alchemist/contracts` (TS) and `alchemist_contracts` (Py).
6. Tag v0.1.0 and document the version/pin policy.
