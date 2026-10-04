# Permissions & Privacy Audit — TempoShot

> **Corrected 2026-10-04.** Re-derived by reading both manifests directly. The
> previous matrix omitted `VIBRATE` and claimed "no network client libraries"
> without listing what was actually checked.

## Android permissions matrix

Both editions declare exactly two permissions. Verified by reading
`lite/android/app/src/main/AndroidManifest.xml` and the Pro equivalent.

| Permission | Lite | Pro | Purpose | Evidence |
|---|---|---|---|---|
| `android.permission.RECORD_AUDIO` | present | present | Microphone capture for shot-break detection. Audio blocks are reduced to an RMS amplitude and discarded; no audio is written to disk or transmitted. | [Verified] both manifests |
| `android.permission.VIBRATE` | present | present | Haptic feedback on the start beep and each shot break. | [Verified] both manifests |
| `android.permission.INTERNET` | **omitted** | **omitted** | Forbidden. | [Verified] absent from both |

[Verified] There are no other `<uses-permission>` entries, and no
`<uses-feature>` or `foregroundServiceType` declarations in either manifest.

## Other manifest facts

| Setting | Value | Both editions |
|---|---|---|
| `android:allowBackup` | `false` | [Verified] |
| `android:label` | `TempoShot Lite` | [Verified] — see open question below |

> **[Open question] — Pro's launcher label is wrong.** `pro/android/app/src/main/AndroidManifest.xml`
> still declares `android:label="TempoShot Lite"`, so Pro installs under the Lite
> name. This is a one-line defect in Pro's manifest, **not** a documentation
> issue, and it was deliberately left unfixed in this documentation pass.
> Tracked in `bugs.md`.

## Zero-network guarantee — still enforced

[Verified] The guarantee still holds. The evidence, in the order it was checked:

1. **Permission.** `grep -rn "INTERNET" lite/android pro/android` → no match.
   Without the permission the platform cannot open a socket, so this is the
   load-bearing control rather than a policy statement.
2. **Dependencies.** `pubspec.yaml` in both editions contains no networking
   package: no `http`, `dio`, `firebase_*`, `web_socket_channel`, `graphql_flutter`.
   Full runtime dependency list: `flutter_riverpod`, `sqflite`, `path_provider`,
   `path`, `shared_preferences`, `intl`, `url_launcher`, `share_plus`, `record`.
3. **Fonts are bundled.** `assets/fonts/Newsreader.ttf` and `PublicSans.ttf`
   ship in the APK. No font is fetched at runtime, which is why
   `google_fonts` was deliberately not adopted.
4. **Application code.** No `HttpClient`, socket, or URL-fetching call exists in
   `lib/`.

## Data that leaves the sandbox — and does not touch a network

[Verified] Two OS-mediated interactions, neither requiring `INTERNET`:

| Action | Mechanism | Data |
|---|---|---|
| Share a string summary | `share_plus`, user-initiated chooser | plain text: total, shot count, first shot, fastest split |
| Open the Play Store listing | `url_launcher`, `LaunchMode.externalApplication` | the Pro package URL |

Neither is automatic; both require an explicit tap.

## Local data

[Verified] The sqflite database lives in the app sandbox
(`/data/data/com.rutambh.temposhot*/databases/temposhot.db`). With
`allowBackup="false"`, it is excluded from Android's cloud backup and from
`adb backup`. See `database.md` for the schema and for what is *not* encrypted.