# API & Hardware Service Contracts — TempoShot

## Sensor & Platform Services
- [Verified] **Sensor Interface**: `Microphone (Acoustic Transient Peak Stream)`
- [Verified] **Audio Stream**: `On-Demand Microphone (RECORD_AUDIO active only while armed/running)`
- [Verified] **Network Communication**: `Zero Internet (No android.permission.INTERNET)`

## Lifecycle & Resource Management
1. **Acquisition**: Sensor and microphone streams are initialized only when the corresponding screen is active.
2. **Release**: Streams are immediately paused or canceled upon navigating away or app pause (`WidgetsBindingObserver.didChangeAppLifecycleState`).
3. **Zero Leaks**: Background execution is restricted strictly to user-enabled Pro foreground services with ongoing persistent notifications.
