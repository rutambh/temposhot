# Architecture — TempoShot

## System Architecture
`TempoShot` is designed as an offline-first, reactive Flutter application organized into clear separation of concerns:

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   (3D Tactile Widgets, Screens, Providers / Notifiers) │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                      Domain Layer                      │
│      (Mathematical Models, Algorithms, FFT / Filters)  │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                   Data & Platform Layer                │
│  (Drift/SQLite/SecureStorage, Hardware Sensor Streams) │
└────────────────────────────────────────────────────────┘
```

## Directory Structure
```
09_temposhot/
├── lite/                       # Lite edition Flutter app (com.rutambh.temposhot)
│   ├── android/                # Native Android Gradle configuration
│   └── lib/
│       ├── core/               # Theme, 3D widgets, database, sensor wrappers
│       ├── features/           # Feature screens and state controllers
│       └── main.dart           # App entry point
├── pro/                        # Pro edition Flutter app (com.rutambh.temposhot.pro)
│   ├── android/
│   └── lib/
│       ├── core/
│       ├── features/
│       └── main.dart
├── docs/                       # Project documentation knowledge base
└── AGENTS.md                   # Agent way-of-working and registry
```

## State Management & Reactivity
- Local reactive state using Flutter `ChangeNotifier` / `ValueNotifier` or Riverpod/Provider patterns.
- Hardware streams are subscribed to during active screen lifecycle and automatically paused/cancelled on dispose.
