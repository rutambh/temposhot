# Permissions & Privacy Audit — TempoShot

## Android Permissions Matrix
| Permission | Edition | Purpose | Evidence |
|---|---|---|---|
| `INTERNET` | **OMITTED** | Strictly forbidden across all editions | [Verified] |
| `android.permission.RECORD_AUDIO` | Required during timing session | Detects acoustic transient shot impulses; no audio saved or transmitted | [Verified] |

## Zero-Network Verification
- Verified: `AndroidManifest.xml` in both `lite/` and `pro/` does NOT contain `<uses-permission android:name="android.permission.INTERNET" />`.
- Verified: No network client libraries (Dio, Http, Retrofit) are registered in `pubspec.yaml`.
