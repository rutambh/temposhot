# Product Specification — TempoShot

## 1. Product Vision
[Verified] TempoShot provides an on-device utility for: A dual-mode acoustic timer that acts as a firearms range shot timer (detecting gunshots/splits) and an ultra-precise metronome.

## 2. Target Audience & Problem Statement
- **Problem**: Users require reliable, immediate measurements and tracking without invasive trackers, accounts, or battery-draining network background sync.
- **Audience**: Individuals, athletes, clinicians, engineers, and hobbyists seeking private, offline tools.

## 3. How to Use
1. Select Mode: Shot Timer (Range Mode) or Precision Metronome (Music Mode).
2. Set Threshold / BPM: Adjust audio peak sensitivity or dial target BPM.
3. Press Tactile ARM Button: Listen for the start buzzer.
4. Read Results: View First Shot Time, Split Times, and shot string timeline on the 3D Backlit LCD Display.

## 4. Core Features & Business Rules
- [Verified] **Dual-Edition Model**:
  - **Lite (`com.rutambh.temposhot`)**: Core functionality, local history retention limit, standard CSV export, non-intrusive Pro upgrade card.
  - **Pro (`com.rutambh.temposhot.pro`)**: Unlimited history, advanced analysis charts, custom PDF clinician/summary reports, and encrypted `.shotlog (Range string & cadence session logs)` backup/restore.
- [Verified] **Sensor Integration**: Microphone (Acoustic Transient Peak Stream)
- [Verified] **Audio Stream**: On-Demand Microphone (RECORD_AUDIO active only while armed/running)
- [Verified] **Privacy Guarantee**: Zero Internet (No android.permission.INTERNET)

## 5. Information Architecture & Modules
- **core**: High-speed audio buffer transient detector, Par-time buzzer engine, 3D timer chassis & LCD painters
- **features/shot_timer**: TactileTimerChassis3D, BacklitLcdDisplay3D, start buzzer delay, instant split-time matrix, string total
- **features/metronome**: Sample-accurate audio metronome (30-300 BPM), time signature subdivision, visual pendulum swing
- **features/oscilloscope**: AudioEnvelopeOscilloscope3D live wave trace with user-adjustable noise gate / shot threshold
- **features/strings**: Match/stage string history, cadence consistency index, CSV/PDF match score export

## 6. Non-Functional Requirements
- [Verified] 60 FPS smooth rendering for 3D CustomPainter widgets.
- [Verified] Cold start launch time < 1.2 seconds.
- [Verified] Zero data egress over the network.
