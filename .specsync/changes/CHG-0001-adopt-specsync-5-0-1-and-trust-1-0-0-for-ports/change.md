---
id: CHG-0001-adopt-specsync-5-0-1-and-trust-1-0-0-for-ports
state: accepted
type: migration
base_commit: 2bb41490dbf2c11db1d550236e0c6f78c6526f4f
---

# Adopt SpecSync 5.0.1 and Trust 1.0.0 for Ports

## Intent

Adopt SpecSync 5.0.1 and Trust 1.0.0 for Ports

## Affected Canonical Specs

- None

## Acceptance Criteria

- Debug and release builds pass.
- The native Swift test suite passes.
- SpecSync 5.0.1 reports all four agent integrations and validates the committed SDD lifecycle.
- Trust doctor and verification pass through the repository's native Fledge lane.
- Existing UI, CI, signing, notarization, and release boundaries remain unchanged.

## No-spec Rationale

The migration adds governance configuration only; UI and public APIs are unchanged, and existing CI, signing, notarization, and release workflows remain independent.
