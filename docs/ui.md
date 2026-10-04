# UI — Field Notebook Grid Design System

> **Corrected 2026-10-04.** This file documented a "Range Polymer Matte"
> palette (`#18181B` / `#EAB008` / `#84CC16`) that belonged to the deleted
> `AppColors` class. That class no longer exists; it was replaced by
> `FieldNotebookTokens`. The yellow/green values below were never the shipped
> tokens even before deletion.

## Style 9 — Field Notebook Grid

Cream dot-grid paper, one serif for numbers, a single ink-blue action colour,
olive reserved for status and limits. Dark mode is designed separately, not
inverted.

## The token owner

[Verified] `lib/core/theme/field_notebook_theme.dart` is the **only** file in
`lib/` containing a colour literal. Widgets read semantic roles from it; they
never name a hex. `grep -rn "AppColors" lib` returns nothing.

[Verified] `FieldNotebookTokens` provides two `const` palettes — `light` and
`dark` — a static `of(BuildContext)` resolver that picks between them from the
ambient `Theme` brightness, a `contrast(a, b)` WCAG relative-luminance ratio,
and three type styles: `readout()`, `label()`, `body()`. `tabular`
(`FontFeature.tabularFigures`) is applied inside `readout()` so a running timer
never jitters in width.

### Light

| Role | Hex | Use |
|---|---|---|
| `background` | `#F6F3EA` | the paper |
| `surface` | `#FCFAF4` | cards, chassis |
| `surfaceRaised` | `#FFFFFF` | readout panel, oscilloscope |
| `grid` | `#DDD7C6` | dot-grid ink, 16 dp pitch |
| `border` | `#DED8C7` | hairlines |
| `primary` | `#2F4858` | ink blue — the single action colour |
| `onPrimary` | `#FFFFFF` | text on primary |
| `accent` | `#6B7355` | olive — status and limits only |
| `text` | `#23221C` | body |
| `textMuted` | `#5A5B4E` | secondary |
| `success` / `warning` / `error` | `#3D6B34` / `#7A5C1E` / `#9E3B2C` | |

### Dark

| Role | Hex |
|---|---|
| `background` / `surface` / `surfaceRaised` | `#23241F` / `#2E302A` / `#34362E` |
| `grid` | `#34362E` — **24 dp pitch**, deliberately sparser |
| `border` | `#43453D` |
| `primary` / `onPrimary` | `#7FA6C4` / `#1B2228` |
| `accent` | `#A3B08C` |
| `text` / `textMuted` | `#EDEBE1` / `#A0A192` |
| `success` / `warning` / `error` | `#7FBF7A` / `#D9B063` / `#E08070` |

[Verified] A test asserts four specific pairs exceed 4.5:1 in both modes:
`text`/`background`, `textMuted`/`background`, `text`/`surface`, and
`primary`/`surface`. Other combinations are not asserted.

## Type

[Verified] Two faces, **bundled** in `assets/fonts/` and registered in both
`pubspec.yaml` files. They are bundled rather than fetched because the app
holds a strict zero-network guarantee, which rules out `google_fonts`-style
runtime fetching.

| Family | Role | File |
|---|---|---|
| **Newsreader** (serif) | `readout()` — every number the user reads as data | `assets/fonts/Newsreader.ttf` |
| **PublicSans** (sans) | body, labels, buttons | `assets/fonts/PublicSans.ttf` |

[Verified] A test reads `pubspec.yaml`, checks each declared asset exists on
disk, checks no font file is left undeclared, and validates the TrueType magic
bytes (`00 01 00 00`).

## Widgets

[Verified] The full inventory under `lib/core/widgets/`:

| Widget | Role |
|---|---|
| `DotGridBackground` + `DotGridPainter` | dot-grid paper behind the app shell |
| `PaperCard` | the card surface — cream, hairline border, one paper-tinted shadow, 88% opaque so the grid reads faintly through |
| `TactileTimerChassis3D` | clipboard-style frame around the timer, with corner registration marks |
| `BacklitLcdDisplay3D` | the readout panel: status line, big figure, split line |
| `AudioEnvelopeOscilloscope3D` + `_OscilloscopePainter` | live input envelope trace |
| `TactilePusherButton3D` | primary action; depresses 4 dp, shadow collapses |

> Class names retain the `3D` suffix from the earlier skeuomorphic build. The
> treatments themselves are flat paper now; only the names are historical.

## The painters

[Verified] There are **two** `CustomPainter`s in `lib/`, not three:

| Painter | File | Notes |
|---|---|---|
| `DotGridPainter` | `dot_grid_background.dart` | public so a test can paint it directly |
| `_OscilloscopePainter` | `3d/audio_envelope_oscilloscope_3d.dart` | private |

> A third, `_GlassSpecularGlarePainter` inside `BacklitLcdDisplay3D`, existed
> until the Field Notebook pass and was **removed** — the readout panel is
> paper, and a glass glare had nothing to sit on. It is absent from the source.

[Verified] `DotGridPainter.paint` lays the paper rect down **first**, then the
dots. This ordering is load-bearing and was a real defect: painting only the
dots leaves the sheet transparent, and because every screen keeps its Scaffold
transparent, the app fell back to the platform window background — 43% of the
light dashboard measured as fully transparent and 0% as cream paper. After the
fix: 0% transparent, 43% cream (light) / 43% `#23241F` (dark).

## Motion & feedback

[Verified] `TactilePusherButton3D` animates press state over 70 ms
(`AnimatedContainer` + `Matrix4.translationValues`). The live timer repaints at
30 ms while running; `DotGridBackground` sits inside a `RepaintBoundary` so the
paper is not repainted with it.

## Verifying this style

[Verified] `flutter test test/theme/style_sheet_renderer_test.dart` renders both
screens at 390 dp in light and dark with the real TTFs loaded, writes PNGs to
`build/style-sheet/`, and inlines them into `build/style-sheet/sheet.html` from
the tracked template `tool/style_sheet/index.html`. The output is in `build/`
and therefore gitignored.