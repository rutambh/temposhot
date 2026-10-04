# Improvements Log — TempoShot

(Append-only log of planned optimizations and enhancements)

## 2026-10-04 — open questions and unverified claims (append-only)

### IMP-01 — App backgrounding does not stop microphone capture [OPEN QUESTION]
`api.md` previously claimed release happened via
`didChangeAppLifecycleState`. No such observer exists anywhere in `lib/`.
Capture is released only when the live-timer route is disposed. Whether the
`record` plugin's stream survives backgrounding has **not** been verified. This
is the highest-risk open item: a backgrounded timer could keep the mic hot.

### IMP-02 — The adaptive noise floor is not wired into production [OPEN QUESTION]
`NoiseFloorEstimator` is implemented and unit-tested, but
`shotEngineProvider` constructs `ShotDetectionEngine()` with no `noiseFloor`,
so the shipped detector uses the fixed 0.65 sensitivity threshold. Either wire
it in or delete the dead path — the documentation deliberately does not claim
adaptive behaviour.

### IMP-03 — No metronome exists [OPEN QUESTION]
The project's core-idea sentence promises a "precision metronome". There is no
BPM control, no audio output, no time signature. Preserved verbatim in
`overview.md` with the contradiction flagged. The user must decide whether to
build it or amend the core idea.

### IMP-04 — Schema has no migration path [OPEN QUESTION]
The database opens at `version: 1` with `onCreate` only and no `onUpgrade`.
The first schema change will need a migration designed before it is written.

### IMP-05 — Foreign keys are declared but not enforced [OPEN QUESTION]
`ON DELETE CASCADE` is declared on both child tables, but SQLite only honours
it with `PRAGMA foreign_keys = ON`, which is never issued. Deletes work today
only because `deleteString` removes `shots` by hand first.

### IMP-06 — The two editions are identical by convention only [OPEN QUESTION]
`diff -rq lite/lib pro/lib` is clean today. Nothing in the build prevents them
drifting apart, which is precisely how the Pro tests ended up importing
`package:temposhot/` and failing to compile. A sync check in CI would make the
invariant real.

### IMP-07 — Performance claims were never measured [OPEN QUESTION]
The previous `product.md` asserted 60 FPS, cold start under 1.2 s and WCAG AAA.
None was ever measured and no harness exists. AAA contrast and frame timing
remain unverified. What *is* tested: 4.5:1 contrast for the documented pairs,
and zero overflow at 390 dp.

### IMP-08 — No browser on the dev machine [OPEN QUESTION]
Chrome and Edge are both absent and `CHROME_EXECUTABLE` is empty, so the
planned web verification could not run. No `flutter test --platform chrome` or
web build has been executed at any point.

### IMP-09 — The instructions file is tracked as `Agents.md`, not `AGENTS.md` [OPEN QUESTION]
`git ls-files` reports `Agents.md`. Every reference to it — this protocol, the
`docs/INDEX.md` root-files line, and most tooling — spells it `AGENTS.md`. On
this Windows checkout the two are the same file, so `git add AGENTS.md` appears
to work. On a case-sensitive filesystem it is a **different path**: the
add silently stages nothing and the change is lost from the commit. This was
observed directly during the documentation pass — the registry edit landed in
the working tree but not in the commit. Renaming the tracked file to
`AGENTS.md` would make the pathspec behave identically everywhere.
