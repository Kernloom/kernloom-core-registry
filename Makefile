.PHONY: validate

validate:
	test -f core/authoring_catalog.yaml
	test -f defaults/guardrails.yaml
	test -f defaults/risk_recipes.yaml
	test -f defaults/profiles.yaml

