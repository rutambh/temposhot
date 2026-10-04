# Build, Release & CI/CD — TempoShot

> **Corrected 2026-10-04.** The previous version presented a table of four
> named release APKs as delivered artifacts. Those files do not exist on this
> machine, and the release signing configuration is not store-capable.

## Build commands

```powershell
# Release APK, split per ABI
flutter build apk --target-platform android-arm64,android-x64 --split-per-abi --release

# Debug APK for a connected device or emulator
flutter build apk --debug
```

Run inside `lite/` or `pro/`; the editions differ in Gradle config, not in
`lib/`.

## Package identity

| Edition | `namespace` | `applicationId` | `minSdk` |
|---|---|---|---|
| Lite | `com.rutambh.temposhot` | `com.rutambh.temposhot` | 26 |
| Pro | `com.rutambh.temposhot.pro` | `com.rutambh.temposhot.pro` | 26 |

[Verified] from `android/app/build.gradle.kts` in each edition. Both declare
`versionName = flutter.versionName` and `versionCode = flutter.versionCode`,
i.e. from `pubspec.yaml` (`1.0.0+100`).

> **[Open question] — Pro's launcher label.** The Pro manifest still declares
> `android:label="TempoShot Lite"`. Two APKs with different application IDs but
> the same user-visible name will be confusing in a launcher, and it contradicts
> the identity table above. Tracked in `bugs.md`; deliberately unfixed in this
> documentation pass.

## Signing — not store-ready

[Verified] In **both** editions the release build type is:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

[Verified] No keystore (`*.jks`) and no `key.properties` exists anywhere under
`lite/android` or `pro/android`.

Consequence: an APK built with the command above is signed with the local
machine's debug key. It installs and runs, but it **cannot** be published to
Google Play, and it cannot be upgraded in place by any other-signed build. A
release keystore must be created, referenced from `key.properties`, and its
secrets kept out of the repository before any submission.

> **Secrets note, per protocol:** this file records the *names and locations* of
> the signing inputs that will be needed. It deliberately contains no keystore
> path, alias, or password, and none should ever be added here.

## CI — none

[Verified] There is no CI configuration in the repository: no
`.github/workflows`, no `.gitlab-ci.yml`, no `Jenkinsfile`, no
`fastlane/`, and no `codemagic.yaml`. Verification is run manually per edition:

```powershell
flutter analyze   # expect: No issues found!
flutter test      # expect: 49 passed, exit 0
```

Both must be run in `lite/` **and** `pro/`.

## Artifacts

[Verified] The previously documented output directory `D:\Apps\apks\` **does not
exist on this machine** — the directory itself is absent, not merely empty. No
release APK is present in the repository. The following table records the
*intended* naming convention; it is not a manifest of files that exist.

| Edition | ABI | Intended filename | Package |
|---|---|---|---|
| Lite | arm64-v8a | `09_TempoShot_Lite_arm64-v8a.apk` | `com.rutambh.temposhot` |
| Lite | x86_64 | `09_TempoShot_Lite_x86_64.apk` | `com.rutambh.temposhot` |
| Pro | arm64-v8a | `09_TempoShot_Pro_arm64-v8a.apk` | `com.rutambh.temposhot.pro` |
| Pro | x86_64 | `09_TempoShot_Pro_x86_64.apk` | `com.rutambh.temposhot.pro` |

> The command builds both ABIs in one invocation; splitting and copying is a
> manual step with no script committed to the repository.