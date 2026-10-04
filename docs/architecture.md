# Architecture — TempoShot

> **Corrected 2026-10-04.** This file previously described a `lib/features/`
> layout and a "Drift/SQLite/SecureStorage" data layer. Neither directory
> exists; Drift and `flutter_secure_storage` are not dependencies. Rewritten
> against the tree as it is on disk.

## Layers as they exist

Three layers, named by directory rather than by diagram:

```
lib/
├── core/          constants, the one theme token owner, shared widgets
├── domain/        pure Dart: audio maths, the detector, models — no Flutter UI
├── data/          sqflite persistence + the microphone capture seam
└── presentation/  screens and Riverpod providers
```

[Verified] `lib/domain/` imports nothing from `presentation/` or `data/`. The
detector and the audio maths are plain Dart with injected seams, which is what
makes them testable without a widget tree or a device.

## Directory structure

```
09_temposhot/
├── lite/                       # com.rutambh.temposhot
│   ├── android/
│   ├── assets/fonts/           # Newsreader + PublicSans, bundled
│   ├── lib/
│   │   ├── core/constants/app_constants.dart
│   │   ├── core/theme/field_notebook_theme.dart     # the only colour/type owner
│   │   ├── core/widgets/                            # dot_grid_background, paper_card
│   │   ├── core/widgets/3d/                         # chassis, LCD panel, scope, pusher
│   │   ├── data/datasources/                        # temposhot_database, audio_capture_source,
│   │   │                                            #   microphone_audio_capture_source
│   │   ├── domain/audio/                            # rms_calculator, noise_floor_estimator
│   │   ├── domain/engine/shot_detection_engine.dart
│   │   ├── domain/models/                           # drill, shot_record, shot_string
│   │   ├── presentation/<feature>/                  # dashboard, live, dryfire, summary,
│   │   │                                            #   history, paywall, safety
│   │   ├── presentation/providers/app_providers.dart
│   │   └── main.dart
│   ├── test/{domain,data,widget,theme}/
│   └── tool/style_sheet/index.html
├── pro/                        # com.rutambh.temposhot.pro — same lib tree
├── docs/
└── AGENTS.md
```

> **Struck:** the previous tree listed `lib/features/shot_timer`,
> `lib/features/metronome`, `lib/features/oscilloscope` and
> `lib/features/strings`. No `features/` directory exists in either edition.

[Verified] `diff -rq lite/lib pro/lib` reports no differences: the two editions
currently ship a byte-identical `lib/`. Their separation lives entirely in
`pubspec.yaml` (`name:`), `android/app/build.gradle.kts` (`namespace`,
`applicationId`) and the manifest. **This is convention, not enforcement** —
nothing prevents the trees drifting apart again.

## The audio path that actually runs

[Verified] Capture → reduction → detection → provider, end to end:

```
record plugin (PCM16 @44.1kHz mono)
      │  startStream
      ▼
RecordPluginRecorder ──_toDoubles──► List<double> in -1.0…1.0
      │
      ▼
MicrophoneAudioCaptureSource        one AudioSample per PCM block
                                    (max of peak and RMS ÷ 32768)
      │  Stream<AudioSample>.broadcast()   (long-lived; see below)
      ▼
LiveTimerScreen._onAudioSample
      │  setState → oscilloscope buffer (40 samples)
      │  engine.processAudioSample(amplitude, eventTime:)
      ▼
ShotDetectionEngine
      │  1. amplitude < detectionThreshold → NoiseFloorEstimator.addSample, return false
      │  2. now − startBeep < 150 ms since last shot      → return false (lockout)
      │  3. otherwise                                     → record ShotRecord
      ▼
_engine.recordedShots ──► splits table on screen ──► StringSummaryScreen ──► sqflite
```

### Decisions that matter inside this path

[Verified] **The output stream is long-lived.** Both `MicrophoneAudioCaptureSource`
and `SimulatedAudioCaptureSource` create their `StreamController` eagerly and
return it from `samples` unconditionally. Creating it inside `start()` is wrong
here: the live timer subscribes *first* and starts *second`, so it would have
listened to a dead `Stream.empty()` and never received a sample. Both sources
are `.broadcast()` so `close()` completes even if nothing ever listened.

[Verified] **The engine is session-scoped and injectable.** `clock`, `random`
and `noiseFloor` are constructor parameters, so arming delay and shot timing
are deterministic under `fakeAsync`. `armTimer` takes an optional `startDelay`
that overrides the 1.0–4.0 s randomised lead-in.

[Verified] **The engine currently runs the fixed-threshold path.** The provider
constructs `ShotDetectionEngine()` with no `noiseFloor`, so
`detectionThreshold` is `sensitivityThreshold` (default `0.65`) from
`AppConstants`. The adaptive `NoiseFloorEstimator` is fully implemented and
tested, but **no production wiring passes it in**. Treating the noise floor as
live behaviour today would be a documentation error.

## State management

[Verified] Riverpod only — `flutter_riverpod` 2.6.1. `ChangeNotifier`,
`ValueNotifier` and `StreamBuilder`-as-state-management do not appear in `lib/`.

| Provider | Kind | Purpose |
|---|---|---|
| `tempoDatabaseProvider` | `Provider` | singleton `TempoShotDatabase` |
| `allStringsProvider` / `stringCountProvider` / `allDrillsProvider` | `FutureProvider` | sqflite reads |
| `audioCaptureSourceProvider` | `Provider.autoDispose` | owns the microphone; `ref.onDispose` disposes it |
| `shotEngineProvider` | `Provider.autoDispose` | one detector per live-timer session |

[Verified] Both `autoDispose` providers are held with `ref.watch` inside
`LiveTimerScreen.build`. Holding them with `ref.read` tears the microphone down
on the next frame while the timer is still running; the widget tests pin this.

## Theme application

[Verified] `MaterialApp.builder` wraps the navigator — not `home:` — in
`FieldNotebookTheme` and `DotGridBackground`. Every pushed route therefore
inherits the same tokens and the same paper. Wrapping `home:` alone left the
live timer and summary on bare scaffold colour and made dark mode a no-op.
Every screen's `Scaffold.backgroundColor` is `Colors.transparent` so the paper
painted by `DotGridPainter` shows through.