# Database & Local Persistence — TempoShot

> **Corrected 2026-10-04.** Previously claimed "SQLite / Drift or
> FlutterSecureStorage", SQLCipher encryption, and a `.shotlog` encrypted
> export/import format. Drift and `flutter_secure_storage` are not
> dependencies, there is no encryption, and no `.shotlog` format exists in the
> source.

## Persistence technology

[Verified] Plain **sqflite** 2.4.3 — `openDatabase` with raw `CREATE TABLE`
statements in `lib/data/datasources/temposhot_database.dart`. No ORM, no code
generation, no migration framework.

| Aspect | Reality |
|---|---|
| Database file | `temposhot.db` via `getDatabasesPath()` |
| Location | app sandbox, `/data/data/com.rutambh.temposhot[.pro]/databases/` |
| Version | `1`, `onCreate` only — **no `onUpgrade` path exists** |
| Access | `TempoShotDatabase.instance` singleton, exposed as `tempoDatabaseProvider` |
| Backup | disabled — `android:allowBackup="false"` in both manifests |
| Encryption | **none** |

> **[Open question] — schema versioning.** With `version: 1` and no
> `onUpgrade`, any future schema change will have no migration path and will
> need one designed first. Logged in `improvements.md`.

## Schema

[Verified] Three tables, created in `_createDB`, with foreign keys declared
`ON DELETE CASCADE`.

```
drills
  id                  INTEGER PRIMARY KEY AUTOINCREMENT
  name                TEXT NOT NULL
  description         TEXT NOT NULL
  targetParTimeSec    REAL NOT NULL

strings
  id                  INTEGER PRIMARY KEY AUTOINCREMENT
  drillId             INTEGER NOT NULL  → drills(id) ON DELETE CASCADE
  shooterId           INTEGER NOT NULL
  timestamp           TEXT NOT NULL     (ISO-8601)
  totalTimeSec        REAL NOT NULL
  firstShotDelaySec   REAL NOT NULL
  notes               TEXT NOT NULL

shots
  id                  INTEGER PRIMARY KEY AUTOINCREMENT
  stringId            INTEGER NOT NULL  → strings(id) ON DELETE CASCADE
  shotNumber          INTEGER NOT NULL
  splitTimeSec        REAL NOT NULL
  cumulativeTimeSec   REAL NOT NULL
```

[Verified] Foreign keys are **declared but not enforced at runtime** — SQLite
requires `PRAGMA foreign_keys = ON` per connection and no such pragma is issued.
Cascade deletes therefore depend on the explicit child delete in
`deleteString`, which removes `shots` before `strings` by hand.

[Verified] One row is seeded on create: drill `Bill Drill (6 Shots)`,
target par `2.50`s.

## Lite gating behaviour

[Verified] `insertStringWithShots` implements the 10-string cap by **evicting
the oldest row**, not by refusing the insert:

```
if (count >= AppConstants.liteMaxStrings)  // 10
    delete the oldest string (ORDER BY id ASC LIMIT 1)
```

This is a silent overwrite of the user's oldest record. It is the current
behaviour and is documented here so it is not mistaken for an upgrade prompt.

## What is not true

| Previous claim | Reality |
|---|---|
| "Drift / SQLite" | sqflite only; `drift` is not in `pubspec.yaml` |
| "FlutterSecureStorage" | not a dependency; no secrets are stored |
| "Key-derived local storage / SQLCipher" | the database file is plaintext SQLite |
| "`.shotlog` encrypted export" | no such format exists |
| "Import (Pro) validates header magic and decrypts" | no import path exists in either edition |
| "local encrypted file shared via `ACTION_SEND`" | sharing is a plain-text string via `share_plus` |

## Export that does exist

[Verified] One, and it is text, not a file: `StringSummaryScreen` builds a
plain-text summary (total time, shot count, first shot, fastest split) and hands
it to `share_plus`. There is no CSV, no PDF, and no Pro-only export in the code
— the paywall screen advertises them as future capabilities.