GOCACHE ?= /tmp/kernloom-gocache
GOMODCACHE ?= /tmp/kernloom-gomodcache
TRIVY ?= trivy
COSIGN ?= cosign
DIST ?= dist

.PHONY: validate checksums sbom vuln-scan release-provenance release-sign release-promote-check release-check

validate:
	test -f core/authoring_catalog.yaml
	test -f defaults/guardrails.yaml
	test -f defaults/risk_recipes.yaml
	test -f defaults/profiles.yaml
	cd ../kernloom-core && GOCACHE=$(GOCACHE) GOMODCACHE=$(GOMODCACHE) go run ./cmd/kernloomctl registry validate --core-registry ../kernloom-core-registry

checksums:
	mkdir -p $(DIST)
	tar --sort=name --owner=0 --group=0 --numeric-owner -czf $(DIST)/kernloom-core-registry-artifacts.tar.gz core defaults schemas
	sha256sum $(DIST)/kernloom-core-registry-artifacts.tar.gz > $(DIST)/checksums.txt

release-provenance: checksums
	{ \
		echo "{"; \
		echo "  \"kind\": \"KernloomRegistryReleaseProvenance\","; \
		echo "  \"source_commit\": \"$$(git rev-parse HEAD)\","; \
		echo "  \"checksums\": \"$(DIST)/checksums.txt\""; \
		echo "}"; \
	} > $(DIST)/provenance.json

sbom:
	@command -v $(TRIVY) >/dev/null 2>&1 || { echo "trivy is required for SBOM generation"; exit 127; }
	mkdir -p $(DIST)
	$(TRIVY) fs --format cyclonedx --output $(DIST)/sbom.cdx.json .

vuln-scan:
	@command -v $(TRIVY) >/dev/null 2>&1 || { echo "trivy is required for vulnerability scanning"; exit 127; }
	$(TRIVY) fs --exit-code 1 --severity HIGH,CRITICAL .

release-sign: checksums
	@command -v $(COSIGN) >/dev/null 2>&1 || { echo "cosign is required for release signing"; exit 127; }
	$(COSIGN) sign-blob --yes --output-signature $(DIST)/checksums.txt.sig $(DIST)/checksums.txt

release-promote-check: validate checksums sbom release-provenance
	test -s $(DIST)/checksums.txt
	test -s $(DIST)/sbom.cdx.json
	test -s $(DIST)/provenance.json

release-check: validate checksums sbom vuln-scan release-provenance release-promote-check
