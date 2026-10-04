# API & Hardware Service Contracts — TempoShot

> **Corrected 2026-10-04.** This file previously claimed a microphone stream,
> `didChangeAppLifecycleState` lifecycle handling, and Pro foreground services.
> None of that existed in the source. Every claim below was re-derived by
> reading the files named beside it.

## The one hardware dependency: microphone capture

[Verified] The app's only hardware input is the microphone. There is no
separate sensor abstraction — the "Sensor" and "Audio Stream" rows that
previously appeared here were the same single contract described twice.

| Aspect | Reality | Source |
|---|---|---|
| Capture backend | `record` plugin, `AudioEncoder.pcm16bits`, 44 100 Hz, mono | `lib/data/datasources/microphone_audio_capture_source.dart` |
| PCM decode | little-endian signed Int16 ÷ 32768 → `-1.0…1.0` | `MicrophoneRecorder` impl, `_toDoubles` |
| Block reduction | `sampleFromPcm` → `AudioSample`, amplitude = **max(peak, RMS)** ÷ 32768, clamped 0–1 | `lib/data/datasources/audio_capture_source.dart` |
| Seams | `AudioCaptureSource`, `MicrophoneRecorder` interfaces | same |
| Network | none — no `INTERNET` permission, no network packages | `android/app/src/main/AndroidManifest.xml`, `pubspec.yaml` |

[Verified] Capture exists in three interchangeable implementations behind
`AudioCaptureSource`:

| Implementation | Used by |
|---|---|
| `MicrophoneAudioCaptureSource` | production, via `audioCaptureSourceProvider` |
| `SimulatedAudioCaptureSource` | tests, and the documented fallback where no capture plugin exists |
| `UnavailableAudioCaptureSource` | permission refused or no microphone — emits nothing, never throws |

## Lifecycle & resource management — as implemented

[Verified] **Acquisition.** `MicrophoneAudioCaptureSource.start()` is called
from `_LiveTimerScreenState.initState()` via `_listenForShots()`, which first
checks `isAvailable` so a refused permission is never re-prompted.

[Verified] **Release.** Capture is owned by an `autoDispose` Riverpod provider
(`audioCaptureSourceProvider`) whose `ref.onDispose` calls `source.dispose()`.
The live timer holds it with `ref.watch(audioCaptureSourceProvider)` in `build`,
so leaving the screen — by navigation *or* by teardown — releases the hardware.
This is provider-disposal, **not** an app-lifecycle observer.

> **Struck:** the previous claim that release happens via
> `WidgetsBindingObserver.didChangeAppLifecycleState` was false. A repository-wide
> search for `didChangeAppLifecycleState`, `WidgetsBindingObserver` and
> `AppLifecycleState` across `lib/` returns nothing.
>
> **Consequence, stated plainly:** if the OS backgrounds the app while the live
> timer is open, capture is not explicitly stopped. Whether the plugin's stream
> survives backgrounding has **not** been verified — see the open question in
> `improvements.md`.

> **Struck:** "background execution is restricted to user-enabled Pro foreground
> services with ongoing persistent notifications." There are no services,
> notifications, or `foregroundServiceType` declarations in either manifest.

## Haptics

[Verified] The engine calls `HapticFeedback.heavyImpact()` on the start beep
and `mediumImpact()` on each registered shot
(`lib/domain/engine/shot_detection_engine.dart`). This is why the engine needs
a test binding initialised.

## Outbound intents (not network)

[Verified] Two OS interactions leave the sandbox, neither of them a network
call, and neither requires the `INTERNET` permission:

- `share_plus` → share a plain-text string summary from `StringSummaryScreen`.
- `url_launcher` → the Play Store URL in `ProPaywallScreen`
  (`AppConstants.playStoreUrl`), via `LaunchMode.externalApplication`.