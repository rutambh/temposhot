# Changelog — TempoShot

## [1.0.0] - 2026-09-02
- Initial release of Lite and Pro editions with 3D tactile UI.
- Generated full project documentation suite via project-docs-protocol.
- Integrated agents-work-protocol way-of-working.

## 2026-10-04 — Documentation correctness pass (Phase 7)

Task: bring `docs/` back in line with what the code demonstrably is.

Changes: rewrote `overview.md`, `api.md`, `architecture.md`, `ui.md`,
`permissions.md`, `product.md`, `database.md`, `environment.md`, `cicd.md`,
`structure/INDEX.md` and `INDEX.md` against the source; appended (never
rewrote) to `decisions.md`, `bugs.md` and `improvements.md`.

Struck as false, with evidence recorded inline:
- `didChangeAppLifecycleState` lifecycle handling, and Pro foreground
  services with notifications — neither exists anywhere in `lib/`.
- The `lib/features/` module layout — no such directory.
- Drift, `flutter_secure_storage`, SQLCipher encryption, and the `.shotlog`
  encrypted export/import format — none is a dependency or exists in code.
- The `#18181B` / `#EAB008` / `#84CC16` palette — belonged to the deleted
  `AppColors` class.
- "Production Release Ready", the delivered-APK table, 60 FPS, cold start
  under 1.2 s, and WCAG AAA — none measured, no artifacts present, release is
  signed with the debug key.
- The metronome mode — no BPM control or audio output exists.

Added: the `FieldNotebookTheme` token owner, the two painters that exist (and
a note that the third was removed), and the capture → RMS → engine → provider
path that now actually runs.

Files: `docs/*.md`, `docs/structure/INDEX.md`, `CHANGELOG.md`. No code was
changed.
