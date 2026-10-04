# Bug Log — TempoShot

(Append-only log of resolved and active bugs)

## 2026-10-04 — audit findings (append-only)

### BUG-01 — Live timer could never receive a microphone sample [FIXED]
`MicrophoneAudioCaptureSource` created its output `StreamController` inside
`start()`, and `samples` returned `Stream.empty()` until then. The live timer
subscribes *first* and starts *second*, so it subscribed to the dead stream and
no audio ever reached the detector. **Real capture would never have detected a
shot in production.** The existing tests missed it because they all subscribed
*after* `start()` — the order production never uses.
Fixed by making the controller long-lived and returning it unconditionally.
Regression test: "a listener that subscribes before start() still receives
samples". Confirmed failing against the old code.

### BUG-02 — Notebook paper was never painted [FIXED]
`DotGridBackground` painted dots onto a transparent sheet, and every screen
sets `Scaffold.backgroundColor: Colors.transparent` so the paper shows through.
The app therefore fell back to the platform window background.
Measured on the render: **43% of the light dashboard was fully transparent and
0% was cream paper.** Fixed by filling the paper rect before the dots.
After: 0% transparent, 43% cream (light) / 43% `#23241F` (dark). Pinned by a
pixel-level test on `DotGridPainter`.

### BUG-03 — Simulated audio source leaked its sampler [FIXED]
`SimulatedAudioCaptureSource.start()` created a 20 ms `Timer.periodic` it never
kept a reference to, so `stop()` closed the stream but left the timer running
for the life of the process. Surfaced as a pending-timer test failure.

### BUG-04 — App shell wrapped `home:`, not the navigator [FIXED]
`FieldNotebookTheme` and `DotGridBackground` were applied to `home:` only.
Every pushed route (live timer, summary, history, paywall) rendered with no
inherited tokens and no paper, and dark mode was a no-op on the dashboard
because the light palette was pinned in `home:`. Moved into
`MaterialApp.builder`, which sits above the navigator.

### BUG-05 — Late-text overflow at 390 dp [FIXED]
Two `Row`s on the dashboard overflowed by 62 px and 83 px at 390 dp. Also
pre-existing overflows in the readout panel rows and the pusher label. Fixed
with `Flexible` + `TextOverflow.ellipsis`, `FittedBox`, and tabular figures.
Pinned by 390 dp widget tests that fail on any overflow.

### BUG-06 — Lite gating silently deletes the user's oldest string [OPEN]
`insertStringWithShots` evicts the oldest row when the 10-string cap is hit,
with no warning in the UI. Documented in `database.md`. Not changed in this
pass; the fix is a product decision, not a documentation one.

### BUG-07 — Pro's launcher label says "TempoShot Lite" [OPEN]
`pro/android/app/src/main/AndroidManifest.xml` declares
`android:label="TempoShot Lite"`. One-line defect, deliberately left unfixed
in the documentation pass.
