# Codebase Structure — TempoShot

## Module Map
| Module | Path | Description |
|---|---|---|
| `core` | `lib/core` | High-speed audio buffer transient detector, Par-time buzzer engine, 3D timer chassis & LCD painters |
| `features/shot_timer` | `lib/features/shot_timer` | TactileTimerChassis3D, BacklitLcdDisplay3D, start buzzer delay, instant split-time matrix, string total |
| `features/metronome` | `lib/features/metronome` | Sample-accurate audio metronome (30-300 BPM), time signature subdivision, visual pendulum swing |
| `features/oscilloscope` | `lib/features/oscilloscope` | AudioEnvelopeOscilloscope3D live wave trace with user-adjustable noise gate / shot threshold |
| `features/strings` | `lib/features/strings` | Match/stage string history, cadence consistency index, CSV/PDF match score export |
