# Build, Release & CI/CD — TempoShot

## Release APK Artifacts
Release builds are compiled with `--split-per-abi` and copied to `D:\Apps\apks\`:

| Edition | ABI | File Name | Target Package |
|---|---|---|---|
| **Lite** | `arm64-v8a` | `09_TempoShot_Lite_arm64-v8a.apk` | `com.rutambh.temposhot` |
| **Lite** | `x86_64` | `09_TempoShot_Lite_x86_64.apk` | `com.rutambh.temposhot` |
| **Pro** | `arm64-v8a` | `09_TempoShot_Pro_arm64-v8a.apk` | `com.rutambh.temposhot.pro` |
| **Pro** | `x86_64` | `09_TempoShot_Pro_x86_64.apk` | `com.rutambh.temposhot.pro` |

## Build Command
```powershell
flutter build apk --target-platform android-arm64,android-x64 --split-per-abi --release
```
