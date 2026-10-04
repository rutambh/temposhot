# Architecture Decision Records (ADRs) — TempoShot

### ADR-01
ADR-01: Microsecond Acoustic Transient Detection - Peak-derivative algorithm to distinguish sharp gunshots from ambient range echo.

### ADR-02
ADR-02: Zero Audio Retention - Buffers inspected strictly in RAM for transient spike detection and discarded in real-time.

### ADR-03
ADR-03: High-Visibility Range UI - Segmented LCD simulation readable under direct bright outdoor sunlight.

---

## Additions 2026-10-04 (append-only; nothing above is deleted)

ADR-01 and ADR-03 are **superseded** by ADR-04 and ADR-05. ADR-02 is
**confirmed** against the source. Originals are retained above for history.

### ADR-02 — re-verified [Verified]
"Buffers inspected strictly in RAM and discarded in real-time" holds.
`RecordPluginRecorder.startPcmStream` maps each PCM block to an
`AudioSample` (one double) and drops it; nothing writes audio to disk or
transmits it. Confirmed by reading `microphone_audio_capture_source.dart`
and the schema in `database.md` — there is no audio column or blob table.

### ADR-04: RMS energy, not peak-derivative [Supersedes ADR-01]
Detection reduces each block to root-mean-square amplitude rather than a
peak/derivative transient. `RmsCalculator` states the reason in-source: a
gunshot is a short burst whose peak is brief and jittery, while its energy
over a block is stable enough to threshold. Timestamps come from
`DateTime`, i.e. millisecond resolution — **not** microsecond. There is no
FFT anywhere in the codebase.

### ADR-05: Field Notebook Grid replaces the high-visibility LCD simulation [Supersedes ADR-03]
The visual language is no longer a segmented LCD simulation optimised for
direct sunlight. It is cream dot-grid paper with a bundled serif
(Newsreader) for every number, one ink-blue action colour and olive for
status. Rationale recorded in `ui.md`. Trade-off accepted: legibility in
direct sun is no longer a design constraint and has not been re-tested
outdoors.

### ADR-06: Colours are owned in one file, not per widget
`FieldNotebookTokens` is the sole owner of colour and type in `lib/`. The
previous `AppColors` class was deleted rather than kept alongside, because
two palettes coexisted would guarantee drift. Enforced by review; there is no
lint rule that prevents a new hex from being introduced.

### ADR-07: Microphone lifetime is owned by provider disposal
Release of the capture device is tied to an `autoDispose` Riverpod provider
held with `ref.watch` inside the live timer's `build`, not to an app-lifecycle
observer. Chosen because it is testable without a real device: the widget
suite asserts disposal on leaving the screen. Consequence recorded in
`api.md` — backgrounding the app does **not** currently stop capture.
