# Docs Index — TempoShot

Read top to bottom when onboarding. Read selectively during triage (see
`AGENTS.md`). Every non-trivial claim in these docs carries an evidence tag —
`[Verified]`, `[Inferred]` or `[Open question]` — and was derived by reading the
source. Anything not verifiable was left out.

## Pillar docs

| # | Doc | Covers |
|---|-----|--------|
| 1 | [overview.md](overview.md) | What TempoShot is, verified stack, real constraints, what is absent |
| 2 | [product.md](product.md) | What ships, how it is used, and what the paywall advertises but does not do |
| 3 | [architecture.md](architecture.md) | Real directory tree, the capture → RMS → engine → provider path, state management |
| 4 | [structure/INDEX.md](structure/INDEX.md) | Module map, test map, non-source directories, edition relationship |
| 5 | [environment.md](environment.md) | Verified toolchain, commands, and what could not be tested here |
| 6 | [ui.md](ui.md) | Field Notebook tokens, bundled typefaces, widget inventory, the two painters |
| 7 | [database.md](database.md) | sqflite schema, Lite gating, what is *not* encrypted |
| 8 | [api.md](api.md) | The microphone capture contract, resource lifecycle, non-network outbound intents |
| 9 | [permissions.md](permissions.md) | Android permission audit and the zero-network evidence |
| 10 | [cicd.md](cicd.md) | Build commands, signing status, absence of CI |
| 11 | [decisions.md](decisions.md) | Append-only ADRs, with 2026-10-04 supersessions noted |
| 12 | [bugs.md](bugs.md) | Append-only bug log — BUG-01…BUG-07 |
| 13 | [improvements.md](improvements.md) | Append-only open questions — IMP-01…IMP-08 |

Root files: [AGENTS.md](../AGENTS.md) · [CHANGELOG.md](../CHANGELOG.md)

## Start here

- **Is the app real or aspirational?** [overview.md](overview.md) — the
  "What exists" table and the three struck claims.
- **How does audio become a split time?** [architecture.md](architecture.md) —
  the audio path diagram.
- **What can it not do?** [product.md](product.md) §5–6,
  [improvements.md](improvements.md).

## Known gaps in the docs themselves

- [product.md](product.md) §7 and [improvements.md](improvements.md) IMP-07:
  performance and AAA contrast are **unmeasured**. Only 4.5:1 contrast and
  390 dp overflow are actually tested.
- Nothing here has been verified on a real device or in a browser.