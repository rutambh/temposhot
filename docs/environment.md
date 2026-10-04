# Environment & Build Setup — TempoShot

## Prerequisites
- **Flutter SDK**: `>= 3.19.0`
- **Dart SDK**: `>= 3.3.0`
- **Android SDK**: API level 26+ (Android 8.0 Oreo) up to API 34+
- **JDK**: Java 17 (recommended for modern Gradle 8.x)

## Development Commands
```powershell
# Navigate to desired edition (lite or pro)
cd d:\Apps\10apps\09_temposhot\lite
# or
cd d:\Apps\10apps\09_temposhot\pro

# Fetch dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Run unit tests
flutter test

# Build release APKs with split per ABI
flutter build apk --target-platform android-arm64,android-x64 --split-per-abi --release
```

## Hardware Testing Notes
- For testing sensor-based features on emulators, use the Android Emulator Extended Controls (Virtual Sensors tab) or test directly on a physical Android device.
