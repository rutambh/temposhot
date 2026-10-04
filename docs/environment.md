# Environment & Build Setup — TempoShot

> **Corrected 2026-10-04.** The version floors below were `>= 3.19.0` /
> `>= 3.3.0`. Replaced with the toolchain actually verified on this machine and
> the constraint the project actually declares.

## Verified toolchain

| Component | Verified | Where it is pinned |
|---|---|---|
| Flutter | **3.44.0** stable | not pinned in-repo; whatever the machine has |
| Dart | **3.12.0** | `environment.sdk: ^3.7.0` in both `pubspec.yaml` |
| Android `minSdk` | **26** (Android 8.0) | `android/app/build.gradle.kts` |
| `compileSdk` / `targetSdk` | Flutter defaults | not pinned in-repo |
| JDK | 17 target | `kotlin { compilerOptions { jvmTarget = JVM_17 } }` |

[Verified] The pubspec declares `sdk: ^3.7.0`, so Dart 3.7 is the true floor.
Flutter itself is not pinned anywhere — there is no `.fvmrc`, no
`fvm_config.json`, and no Flutter version assertion in CI, because there is no
CI configuration in this repository.

## Commands

```powershell
# Work inside one edition; the two trees are identical but their Gradle
# configuration is not.
cd D:\Apps\10apps\09_temposhot\lite      # or \pro

flutter pub get
flutter run                              # needs a connected device or emulator
flutter test                             # 49 tests
flutter analyze                          # must report "No issues found!"

# Regenerate the visual style sheet into build/style-sheet/
flutter test test\theme\style_sheet_renderer_test.dart
```

## Testing constraints observed on this machine

[Verified] **No browser is installed.** Neither Chrome nor Edge is present and
`CHROME_EXECUTABLE` is empty, so `flutter test --platform chrome` and any web
build cannot run here. The project's web verification step has therefore not
been performed. Do not treat a passing `flutter test` as web coverage — the
suite runs on the Flutter test host only.

[Verified] **No physical device is connected.** Every result in these docs comes
from widget and unit tests. In particular, the microphone path has been
exercised against a fake `MicrophoneRecorder` and a simulated source, never
against real audio hardware.

## Microphone testing

[Verified] The `record` plugin has no test implementation, so pumping the live
timer without an override throws `MissingPluginException`. Widget tests that
need the timer supply their own `AudioCaptureSource` via
`audioCaptureSourceProvider.overrideWith`. On a device, grant the permission at
runtime; a refusal must surface the reason in the splits table rather than an
empty panel.

## Release builds

See `cicd.md` — release builds are currently signed with the debug key, which
is the first thing to fix before any store submission.