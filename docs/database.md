# Database & Local Persistence — TempoShot

## Persistence Technology
- **Engine**: SQLite / Drift or FlutterSecureStorage
- **Data Location**: App Sandboxed Storage (Android `/data/data/<package_id>/databases/`)
- **Encryption**: Key-derived local storage / SQLCipher (where applicable)

## Backup & Export Architecture
- **Format**: `.shotlog (Range string & cadence session logs)`
- **Export**: Generates local encrypted file shared via standard Android `ACTION_SEND` intent.
- **Import (Pro)**: Validates header magic and decrypts contents using user passphrase.
- **Zero Cloud**: No database records are ever synchronized to external servers.
