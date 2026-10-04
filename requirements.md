# TempoShot — Development Requirements & Specifications

**Lite Package:** `com.rutambh.temposhot`  
**Pro Package:** `com.rutambh.temposhot.pro`  
**Platform:** Android 8.0+ (API 26) / Flutter  
**Pro Price:** $14.99 (One-Time Paid App on Google Play)  
**Architecture:** 100% On-Device, Real-Time Audio Envelope Shot Detection, Zero Network  
**Audio Permission Rule:** `RECORD_AUDIO` requested strictly on active live session screen. Stopped immediately on pause.  

---

## 1. Executive Summary & Core Value Proposition
TempoShot is an offline sports shot timer and dry-fire practice logbook for USPSA, IDPA, and practical shooting athletes. It detects shot breaks using audio envelope energy thresholding, records precise split times, generates random start beeps, and tracks dry-fire par times without cloud accounts, location tracking, or firearm registration.

---

## 2. UI / UX Design System (Outdoor Sun-Glare & Safety Orange)

### Color Palette Tokens
* **Deep Matte Background (`black`):** `#0D0D0D` (Deep contrast shooting bay canvas)
* **High-Visibility Accent (`blaze`):** `#E24A1A` (Safety blaze orange indicator)
* **Primary Readout Text (`paper`):** `#F5F2EA` (Bright high-contrast paper white)
* **Secondary / Drills (`olive`):** `#6E6A62` (Tactical olive grey)
* **Dividers & Grids (`steel`):** `#C9C3B6` (Steel divider accents)

### Typography & Sound Controls
* **Live Timer Display:** 80sp High-Legibility Monospace
* **Start Beep Synthesizer:** Standard 1 kHz tone at maximum clean output (plus optional vibration pulse)
* **Glaring Sunlight Legibility:** Tested for direct outdoor shooting bay visibility.

---

## 3. Detailed Development Tracks, Phases & Tasks

### TRACK 1: Audio Signal Processing & Shot Detection
#### Phase 1.1: Audio Envelope Detector
* **Task 1.1.1 (High-Speed Audio Stream):** Sample microphone input at 44.1/48 kHz via AudioRecord while session screen is foregrounded.
* **Task 1.1.2 (Bandpass & Envelope Calculation):** Apply high-pass filter (>1 kHz) to attenuate speech/wind and compute short-window RMS energy envelope.
* **Task 1.1.3 (Adaptive Noise Floor & Threshold):** Dynamic background threshold with user sensitivity slider.
* **Task 1.1.4 (Echo & Split Debounce Guard):** Enforce minimum split lockout window (0.15s) to eliminate acoustic echo double-triggers.
* **Task 1.1.5 (Session Lifecycle Safety):** Release microphone stream immediately on `onPause` or screen navigation.

#### Phase 1.2: Timer & Par Beeper Engine
* **Task 1.2.1 (Randomized Start Delay):** Configurable random delay between 1.0 and 4.0 seconds after arming.
* **Task 1.2.2 (Dry-Fire Par Timer):** Start beep + Par beep (e.g. 1.80s draw-to-first-shot par) without requiring microphone audio.

---

### TRACK 2: Shooter Database & Drill Strings
#### Phase 2.1: Relational Schema
* **Task 2.1.1 (Shooters Table - Pro):** `Shooter(id, name)`. Lite supports 1 profile; Pro supports up to 4 local shooter profiles.
* **Task 2.1.2 (Drills Table):** `Drill(id, name, description, targetParTime)` (e.g. *"Bill Drill"*, *"El Presidente"*, *"Failure Drill"*). Lite has 1 drill; Pro has unlimited.
* **Task 2.1.3 (Strings & Shots Tables):**
  - `ShotString(id, drillId, shooterId, timestamp, totalTimeSec, firstShotDelaySec, notes)`
  - `Shot(id, stringId, shotNumber, splitTimeSec, cumulativeTimeSec)`
* **Task 2.1.4 (Lite Retention):** Lite stores last 10 strings; Pro stores unlimited history.

---

### TRACK 3: User Interface & Session Screens
#### Phase 3.1: Sports Safety & Session Setup
* **Task 3.1.1 (Store-Safe Sports Disclaimer):** First-run onboarding: *"Sports shot timer for target training. Wear approved hearing protection. Not connected to any firearm hardware."*
* **Task 3.1.2 (Home Dashboard):** Last string recap, **Start Live-Fire**, and **Start Dry-Fire Par** CTAs.

#### Phase 3.2: Live Timer & String Review
* **Task 3.2.1 (Live-Fire Armed Screen):** Blaze orange armed state, randomized countdown, real-time split list, mic listening indicator, and big **STOP** button.
* **Task 3.2.2 (String Summary Screen):** Split table (Shot #, Split Time, Total Time), manual **Delete Errant Shot** button, and Save to Drill action.
* **Task 3.2.3 (Dry-Fire Par Screen):** Instant visual & acoustic par timer with optional apartment silent vibration mode (Pro).
* **Task 3.2.4 (Pro Sensitivity Wizard):** Calibrate microphone threshold against 3 test live shots (.22 LR, 9mm, Shotgun).

---

### TRACK 4: Data Export & Pro Gating
#### Phase 4.1: Export Protocols
* **Task 4.1.1 (Pro Practice Log CSV):** Export split data and drill performance strings via Android share sheet.
* **Task 4.1.2 (Pro Practice PDF Card):** Printable drill card with split trend histograms.
* **Task 4.1.3 (Lite Migration):** Import Lite shot strings into Pro.

#### Phase 4.2: Lite Paywall
* **Task 4.2.1 (Soft Gating after 10th String):** Friendly upgrade card for unlimited drills, multiple shooters, sensitivity profiles, and PDF reports (`com.rutambh.temposhot.pro`).

---

## 4. Verification & Acceptance Criteria
1. **Zero Location / Zero Map:** Confirm NO location permission or mapping libraries exist.
2. **Audio Lifecycle Test:** Verify microphone is strictly released when user leaves the live timer screen.
3. **Split Calculation Precision:** Verify millisecond split timestamps match synthetic pulse audio tests within ±5ms.
4. **Offline Resilience:** Complete live and dry-fire strings in Airplane Mode at an indoor Faraday-cage shooting range.
