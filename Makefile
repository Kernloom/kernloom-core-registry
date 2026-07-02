GOCACHE ?= /tmp/kernloom-gocache
GOMODCACHE ?= /tmp/kernloom-gomodcache

.PHONY: validate

validate:
	test -f core/authoring_catalog.yaml
	test -f defaults/guardrails.yaml
	test -f defaults/risk_recipes.yaml
	test -f defaults/profiles.yaml
	cd ../kernloom-core && GOCACHE=$(GOCACHE) GOMODCACHE=$(GOMODCACHE) go run ./cmd/kernloomctl registry validate --core-registry ../kernloom-core-registry
