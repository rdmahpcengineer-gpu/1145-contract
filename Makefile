# alchemist-contracts — codegen + build orchestration.
# Proto is the domain source; everything else mirrors it. Stubs are generated, never hand-edited.
.PHONY: install gen gen-proto gen-ts gen-py build build-ts build-py publish-ts publish-py clean

install:
	npm install
	python3 -m pip install -r requirements-dev.txt

## ── codegen ──
gen-proto:                 ## proto -> gen/ts + gen/py (buf remote plugins; needs network)
	npx buf generate proto

gen-ts: gen-proto          ## + CP-3 graphql types + CP-2 openapi types, then barrels
	npm run gen:graphql
	npm run gen:openapi
	node scripts/make-barrels.mjs

gen-py: gen-proto          ## + CP-2 openapi -> pydantic v2 models
	mkdir -p gen/py/alchemist_contracts_openapi
	: > gen/py/alchemist_contracts_openapi/__init__.py
	datamodel-codegen \
		--input openapi/openapi.yaml --input-file-type openapi \
		--output gen/py/alchemist_contracts_openapi/models.py \
		--output-model-type pydantic_v2.BaseModel

gen: gen-ts gen-py         ## generate everything

## ── build packages ──
build-ts: gen-ts
	npx tsc -p tsconfig.json

build-py: gen-py
	python3 -m build

build: build-ts build-py

## ── publish to CodeArtifact (consumers pin a version) ──
# Auth first:  see README "Publishing". npm uses .npmrc; twine uses ~/.pypirc / env.
publish-ts: build-ts
	npm publish

publish-py: build-py
	# Upload ONLY the python sdist/wheel. `make build` also emits the TS bundle
	# into dist/, so a bare `dist/*` glob feeds twine non-distribution files and
	# fails ("Unknown distribution format"). Scope to the python artifacts.
	twine upload --repository codeartifact dist/alchemist_contracts-*

clean:
	rm -rf gen dist build *.egg-info
