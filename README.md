# kernloom-core-registry

`kernloom-core-registry` contains Kernloom-delivered vocabulary, defaults, guardrails, risk recipes, context and evidence profiles, and stage defaults.

## Build

No binary build is required for Slice 0.

## Test

```sh
make validate
```

## Release

Registry releases must validate schemas, guardrail safety, vocabulary consistency, default profiles and risk recipes.

## Dependencies

This repo is data-only at Slice 0. Forge will consume it through registry loaders in later slices.

## Related Repos

Enterprise registries extend this repo. Policy repos compile KNI values against generated authoring catalogs.

