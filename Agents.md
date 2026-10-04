# TempoShot — Agent Development Instructions & Guidelines

## Mission Overview
You are building **TempoShot** (`com.rutambh.temposhot` for Lite, `com.rutambh.temposhot.pro` for Pro), an offline acoustic shot timer and dry-fire par trainer.

---

## 1. Development Sequence & Approval Gate
1. **Develop Lite Edition First:**
   - Scaffold Flutter project inside `09_temposhot/lite/` (`com.rutambh.temposhot`).
   - Implement Track 1 (Microphone envelope thresholding, randomized 1–4s start delay, 0.15s minimum split debounce, dry-fire par mode), Track 2 (1 drill, 10 strings), Track 3 (Black `#0D0D0D` + blaze orange `#E24A1A` theme, 80sp live timer display), and Track 4 (Soft Pro gate after 10 strings).
   - Ensure microphone stream is strictly active only while live timer screen is foregrounded.
   - Verify zero location or GPS permissions exist in the project.

2. **User Review Gate (STRICT):**
   - Present the completed Lite application to the user.
   - **DO NOT build `pro/` until the user explicitly reviews and approves the Lite implementation.**

3. **Develop Pro Edition Upon Approval:**
   - Create `09_temposhot/pro/` (`com.rutambh.temposhot.pro`).
   - Implement Pro capabilities:
     - Unlimited drills, strings, and 4 local shooter profiles
     - Auto-calibration sensitivity wizard (.22 LR, 9mm, Shotgun profiles)
     - String comparison overlays and split consistency charts
     - Practice PDF report and CSV exporter
     - Lite session migration

---

## 2. Applicable Gemini Skills to Leverage
* **`ui-styling` & `material-3`:** Build outdoor high-visibility `#0D0D0D` matte black theme with `#E24A1A` blaze orange indicators.
* **`security-review`:** Audit manifest to ensure `ACCESS_FINE_LOCATION` and `INTERNET` are strictly absent and `android:allowBackup="false"` is set.
* **`tdd-workflow`:** Write unit tests for split time calculation, minimum split debounce (0.15s), and noise floor adaptation.

<!-- BEGIN: agents-work-protocol -->
Maintained by agents-work-protocol. Sections between markers are protocol-managed;
everything outside them is yours.

## Project Snapshot
Core idea (owner's words): "A dual-mode acoustic timer that acts as a firearms range shot timer (detecting gunshots/splits) and an ultra-precise metronome."
Stack: Flutter (Dart 3.x) + record / audio stream + Drift / SQLite
Run/build/test: `flutter run`, `flutter test`, `flutter build apk --target-platform android-arm64,android-x64 --split-per-abi --release`
Out of scope: Cloud synchronization, network telemetry, accounts, medical diagnosis claims

## Registry
Skills/MCPs/plugins/docs available for THIS project — one line each:

| Name | Type | Provides / when to use |
|---|---|---|
| agents-work-protocol | skill | Governs way-of-working, triage, planning, and task close-outs |
| project-docs-protocol | skill | Governs project documentation, changelog-first maintenance |
| ui-styling | skill | Material 3 & Tailwind utility styling |
| ui-ux-pro-max | skill | 3D tactile design intelligence & skeuomorphic UI components |
| security-review | skill | Verifies Zero-Network guarantee and permission auditing |
| tdd-workflow | skill | Test-driven development for sensor algorithms & calculations |
| docs/INDEX.md | doc | Navigation hub for all project documentation — read first |
| docs/product.md | doc | Product vision, domain rules, and user guides |
| docs/architecture.md | doc | Layered architecture, folder structure, and module boundaries |
| docs/permissions.md | doc | Android permissions matrix & Zero-Internet audit |
| docs/ui.md | doc | 3D tactile design system, color tokens, and custom painters |

## Lessons & Common Fixes
- [build] Gradle daemon disappeared during high memory build -> stop daemon via `./gradlew --stop` before rebuilding -> build succeeds smoothly.
- [sensor] Device lacking hardware sensor -> SensorGuardDialog informs user with graceful UI fallback instead of crash.

## User Workstyle
- Strict preference for evidence-based verification before assertions.
- Deliverables must exist physically on disk before claiming completion.

## Plans Index
| Date | Task (plans/ folder) | Tracks | Status |
|---|---|---|---|
| 2026-09-02 | Initial release and docs setup | Docs, Protocol | Completed |
<!-- END: agents-work-protocol -->
