# alchemist-contracts

**The single source of truth for every type that crosses a service boundary in Alchemist Business OS.**
If a shape travels between middleware, backend, or frontend, it is defined here and imported everywhere
else — never hand-declared. Stubs are generated, never hand-written. See [`CLAUDE.md`](./CLAUDE.md) for
the constitution and [`ARCHITECTURE.md`](./ARCHITECTURE.md) for the boundary map.

## The four boundaries

| Boundary | ID | Authored artifact | Direction / scope |
|---|---|---|---|
| Edge ↔ AWS wire | **SE-1** | [`proto/alchemist/v0/se1.proto`](./proto/alchemist/v0/se1.proto) | utterances edge→AWS · reply-text AWS→edge · call events |
| Agent tool calls | **AC-2** | [`proto/alchemist/v0/ac2.proto`](./proto/alchemist/v0/ac2.proto) | AgentCore Tool Gateway invocation contract |
| Dashboard commands + bulk reads | **CP-2** | [`openapi/openapi.yaml`](./openapi/openapi.yaml) | REST: book/mark-won/escalate/call-back · LiveKit token · list reads |
| Dashboard live feed | **CP-3** | [`graphql/schema.graphql`](./graphql/schema.graphql) | AppSync live read + subscribe (no user commands) |

**Proto is the domain source model** ([`domain.proto`](./proto/alchemist/v0/domain.proto)). GraphQL and
OpenAPI mirror those messages so there is one conceptual model across the seam. Every cross-boundary
entity carries `tenantId`.

## Layout

```
proto/alchemist/v0/   domain.proto · se1.proto · ac2.proto  (+ proto/buf.yaml)
graphql/              schema.graphql (CP-3)  ·  appsync-aws.graphql (codegen-only scalar/directive shim)
openapi/              openapi.yaml (CP-2)
buf.gen.yaml          proto → gen/ts + gen/py (buf remote plugins)
codegen.ts            CP-3 SDL → gen/ts/graphql.ts
scripts/              make-barrels.mjs (TS namespaced barrels)
python/               alchemist_contracts/ facade package (re-exports generated modules)
gen/                  ALL generated output (gitignored)
```

## Generated packages

| Target | Package | Import |
|---|---|---|
| TypeScript | `@alchemist/contracts` | `import { proto, graphql, openapi } from "@alchemist/contracts"` |
| Python | `alchemist-contracts` (dist) | `from alchemist_contracts import se1, ac2, domain, openapi` |

The TS root export is **namespaced** (`proto` / `graphql` / `openapi`) so same-named types across seams
don't collide. Subpath exports `@alchemist/contracts/graphql` and `/openapi` are also available.

## Build

Prereqs: Node ≥ 20, Python ≥ 3.10, network access (buf uses remote plugins). `buf`/`protoc` need **not**
be installed globally — `buf` ships via the `@bufbuild/buf` dev dependency.

```bash
make install      # npm install + pip install -r requirements-dev.txt
make gen          # proto + graphql + openapi → gen/ts and gen/py
make build        # build-ts (tsc → dist) + build-py (sdist/wheel)
```

Granular targets: `make gen-proto`, `make gen-ts`, `make gen-py`, `make build-ts`, `make build-py`.

> `gen/` is gitignored — generated stubs are build artifacts, produced fresh in CI and shipped inside
> the published packages. Run `make gen` before `tsc`, `pip install -e .`, or `python -m build`.

## Publishing (CodeArtifact)

Consumers **pin a version**; breaking a wire shape is a major bump (see `CLAUDE.md` → "Version the seam").

```bash
# npm → CodeArtifact
aws codeartifact login --tool npm --domain <DOMAIN> --domain-owner <ACCT_ID> --repository <REPO>
make publish-ts                       # see .npmrc.example for the scope registry line

# pip → CodeArtifact
aws codeartifact login --tool twine --domain <DOMAIN> --domain-owner <ACCT_ID> --repository <REPO>
make publish-py
```

## Editing the contract — rules

- **Never hand-edit anything in `gen/`.** Change the authored artifact (proto / graphql / openapi) and
  regenerate.
- **Proto first.** Add/much a domain field in `domain.proto`, then mirror it in GraphQL + OpenAPI with
  the same field name.
- **CP-3 is a live feed only.** No user-facing GraphQL mutations — commands go to CP-2 REST. Reads/subs
  are `@aws_cognito_user_pools`; `publish*` mutations are `@aws_iam` (backend only). A subscription may
  only filter on a field present in the bound mutation's return payload.
- **Tenant is first-class.** Every cross-boundary entity carries `tenantId`; isolation (`PK =
  TENANT#<id>`) is enforced in the backend resolver, not assumed from the argument.
