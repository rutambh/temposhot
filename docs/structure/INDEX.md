# Codebase Structure — TempoShot

> **Corrected 2026-10-04.** The previous map listed `lib/features/shot_timer`,
> `lib/features/metronome`, `lib/features/oscilloscope` and
> `lib/features/strings`. No `features/` directory exists. Replaced with the
> real tree. [Verified] by `find lib -name '*.dart'`.

## Module map

Paths are relative to an edition root (`lite/` or `pro/`).

| Module | Path | Contents |
|---|---|---|
| **theme** | `lib/core/theme/` | `field_notebook_theme.dart` — the only colour and type owner in the codebase |
| **constants** | `lib/core/constants/` | `app_constants.dart` — package IDs, 10-string cap, 0.15 s lockout, 0.65 default sensitivity, Play Store URL |
| **shared widgets** | `lib/core/widgets/` | `dot_grid_background.dart` (public `DotGridPainter`), `paper_card.dart` |
| **timer widgets** | `lib/core/widgets/3d/` | `tactile_timer_chassis_3d.dart`, `backlit_lcd_display_3d.dart`, `audio_envelope_oscilloscope_3d.dart` (private `_OscilloscopePainter`), `tactile_pusher_button_3d.dart` |
| **capture** | `lib/data/datasources/` | `audio_capture_source.dart` (interface + simulated + unavailable + PCM→amplitude), `microphone_audio_capture_source.dart` (plugin seam) |
| **persistence** | `lib/data/datasources/` | `temposhot_database.dart` — raw sqflite |
| **audio maths** | `lib/domain/audio/` | `rms_calculator.dart`, `noise_floor_estimator.dart` |
| **detection** | `lib/domain/engine/` | `shot_detection_engine.dart` — arming, thresholds, lockout, shot records |
| **models** | `lib/domain/models/` | `shot_record.dart`, `shot_string.dart`, `drill.dart` |
| **providers** | `lib/presentation/providers/` | `app_providers.dart` — the single provider file |
| **screens** | `lib/presentation/` | `dashboard/`, `live/`, `dryfire/`, `summary/`, `history/`, `paywall/`, `safety/` |
| **entry point** | `lib/main.dart` | `TempoShotApp` — theme, `MaterialApp.builder` shell |

## Test map

| Area | Files |
|---|---|
| Detection maths & engine | `test/domain/acoustic_detection_test.dart`, `test/domain/shot_detection_engine_test.dart` |
| Capture seam & PCM decode | `test/data/microphone_audio_capture_source_test.dart` |
| Live timer, end to end through the widget tree | `test/widget/live_timer_audio_test.dart` |
| Readout panel | `test/widget/backlit_lcd_display_3d_test.dart` |
| Theme tokens, contrast, 390 dp rendering, shell wiring | `test/theme/field_notebook_theme_test.dart` |
| Style-sheet renderer (writes to `build/style-sheet/`) | `test/theme/style_sheet_renderer_test.dart` |

## Non-source directories worth knowing

| Path | Why |
|---|---|
| `assets/fonts/` | Newsreader + PublicSans, bundled |
| `tool/style_sheet/index.html` | tracked template for the generated style sheet |
| `build/style-sheet/` | generated PNGs and `sheet.html` — gitignored |

## Edition relationship

[Verified] `diff -rq lite/lib pro/lib` reports **no differences**: the two
`lib/` trees are byte-identical, as are `tool/`. The test trees differ only by
the `package:temposhot/` → `package:temposhot_pro/` import rewrite. Edition
identity lives in `pubspec.yaml`, `build.gradle.kts`, and the manifest — and
this is convention, not something the build enforces.