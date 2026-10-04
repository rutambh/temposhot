# Product Specification — TempoShot

> **Corrected 2026-10-04.** The previous version described a metronome mode, a
> `features/` module layout, cadence consistency scoring, and CSV/PDF export.
> None of those exist. What follows describes shipping behaviour only; anything
> aspirational is marked as such.

## 1. Product vision

[Verified] TempoShot is an offline acoustic timer for practical-shooting
practice: it listens for shot breaks through the microphone, records the split
between each one, and writes the resulting string down.

## 2. Audience

[Verified] Shooters practising USPSA/IDPA-style drills, at a range or dry, who
want timing results kept on their own device with no account and no network.

## 3. How it is used

[Verified] The flows that exist in the code:

1. **Live-fire string** — Dashboard → *Start live-fire timer* → the timer arms
   with a randomised 1–4 s delay → the start beep fires → shot breaks are
   detected acoustically → *Stop & review string* → the string summary screen
   → *Save string to logbook*.
2. **Dry-fire par** — Dashboard → *Start dry-fire par* → set the target par
   time → *Start par beep* → a fixed 2 s lead-in then the par beep.
3. **History** — Dashboard → history icon → stored strings, or a composed
   empty state.
4. **Pro pitch** — Dashboard → *Pro* → feature list → Play Store listing.

## 4. Feature rules, as implemented

[Verified] **Detection.** A sample must clear `detectionThreshold` and must be
at least `minSplitLockoutSec` (0.15 s) after the previous shot. Split and
cumulative times are stored to two decimal places.

[Verified] **Arming.** The lead-in is randomised between 1.0 s and 4.0 s
(`armTimer`), with a `startDelay` override available for deterministic tests.

[Verified] **Manual override.** A *Record shot break* pusher appears on the
live timer only while running, and a shot can be logged by tap when the
microphone misses one or when capture is unavailable.

[Verified] **Unavailable capture is explained, not hidden.** If the microphone
is refused or absent, the source reports a reason and the splits table shows
that reason plus the instruction to record manually. It never pretends to
detect shots.

[Verified] **Lite gating.** 10 strings retained; the oldest is silently
evicted on insert (see `database.md`).

[Verified] **Privacy.** No `INTERNET` permission, no networking package, fonts
bundled rather than fetched. See `permissions.md`.

## 5. Advertised but not implemented

[Verified] `ProPaywallScreen` markets capabilities that are absent from the
code. Listed here so a reader does not mistake the paywall copy for a
roadmap commitment or a shipped feature:

- unlimited strings and shooter profiles
- a drill/par-stage library
- calibrated per-gun sensitivity profiles (.22 LR, 9mm, PCC, 12 gauge)
- PDF scorecards
- CSV export

`AGENTS.md` scopes all of these to a future Pro edition. None is implemented.

## 6. Not present at all

[Verified] **Precision metronome.** The project's core-idea sentence mentions
one; there is no BPM control, no audio output, no time signature, and no
pendulum. `overview.md` preserves the original sentence and flags this
contradiction rather than resolving it.

## 7. Non-functional state

[Verified] 49 tests pass and `flutter analyze` is clean in both editions.
Struck from the previous version, which asserted 60 FPS, a cold start under
1.2 s, and WCAG AAA: none of those were ever measured, and no measurement
harness exists in the repo. What *is* asserted:

- four specific pairs (`text`/`background`, `textMuted`/`background`,
  `text`/`surface`, `primary`/`surface`) exceed **4.5:1** (WCAG AA) in both
  modes — a unit test, not a manual audit. Other combinations are untested;
- both key screens render at **390 dp with zero overflow** in both modes —
  a widget test;
- no text is left to overflow: the longest labels use `Flexible` +
  `TextOverflow.ellipsis` or `FittedBox`.

> **[Open question]** AAA-level contrast, 60 FPS, and cold-start timing remain
> unmeasured. Logged in `improvements.md`.