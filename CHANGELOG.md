# Changelog

All notable changes to **super_form_field** are documented here. The format
follows [Keep a Changelog](https://keepachangelog.com/) and the project adheres
to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.2.0] — 2026-06-18

### Added

- **`SuperDateFormField`** — a new field matching the web ledger's date input: a
  fixed-width, zero-padded segmented buffer with a trailing calendar trigger that
  opens a `MiniCalendar` month-grid popover (prev/next month, today outlined,
  selection filled accent, **Today** shortcut). Value is a `DateTime?`; a
  non-empty incomplete entry raises the suffix badge on blur. Props: `format`
  (year-month-day / year-month / year / month-day / month / day), `minDate` /
  `maxDate` (auto bounds validators), `calendar` (show/hide the popover),
  `keyboardShortcuts`, `clearable`, `leadingIcon`, `invalidMessage`, plus the
  shared `required` / `validators` / `forceError` / `arabic` / `density` /
  `disabled` / `readOnly`. Western-digit, mono, LTR even in RTL.
  - **Configurable format**: any contiguous run of year/month/day; the
    placeholder follows the format and the calendar shows only when a day is
    present. Absent parts fill the value with defaults (year→current, month→1,
    day→1).
  - **Segment-aware, format-preserving typing**: each segment is fixed-width and
    zero-padded; digits shift in from the right (`0002→0020→0202→2024`). The
    cursor's segment is the one edited — typing flows year→month→day (day
    terminal; extra digits keep re-editing it), with smart early-advance for
    month/day. `←`/`→` move between segments; a separator key jumps to the next.
  - **Arrow-key segment stepping** (while focused, on by default): `↑`/`↓` step
    the active segment, wrapping within its own range (month `1↔12`, day within
    the month length; year unbounded). Toggle with `keyboardShortcuts`.
  - **Smart calendar placement**: the popover drops below the trigger icon, and
    flips above it when there isn't room below.
  - `SuperDateFieldController` (Model) with `value` / `error` / `pick(DateTime)`
    / `setValue(DateTime?)` / `clear()` / `markTouched()` / `stepSegment` /
    `stepAtCursor`.
  - `DateLogic` (pure domain usecase): `mask`, `parse`, `format`, `dateOnly`,
    `sameDay`, `compose`, `buildValidators`; `SuperDateFormat` enum.
  - `SffIcons.calendar` / `calendarDays` / `chevronLeft` / `chevronRight` added.
- **`SuperNumericFormField`** — keyboard stepping while focused: `↑`/`↓` change
  the value by `step`, `PageUp`/`PageDown` by the new `largeStep` (defaults to
  `step * 10`). Both clamp + round like the stepper buttons. Toggle with
  `keyboardShortcuts` (default `true`). Controller adds `bumpLarge(direction)`;
  `bump` is unchanged.
- **Example app** — a fourth demo, *Super Date Field*, with four usage examples
  (basic / controlled linked range / validated bilingual submit-sweep /
  configurable formats) under `example/lib/demos/date/`.
- **Tests** — pure-domain unit tests for `DateLogic` (parse / validators /
  compose / formats) and segment stepping.

## [0.1.0] — 2026-06-16

Initial release. Ports three React GeniusLink form-field tools to Flutter on a
shared, dependency-free field foundation.

### Added

- **Core foundation** (`lib/src/core/`)
  - `SuperTokens` — theme-independent brand constants (palette, type faces,
    radii, 4px spacing scale, control metrics, motion).
  - `SuperFieldTheme` — `ThemeExtension` with `light` / `dark` presets and lerp.
  - `SuperText` — the GeniusLink type ramp (Manrope / Inter / JetBrains Mono).
  - `FieldShell`, `FieldBox`, `ErrorBadge`, `FieldIconButton`, `CountPill`,
    `SffIcons` — the shared field chrome.
  - `runValidators` + `Validator<T>` / `ValidityChanged` typedefs; `SuperFormat`
    number + byte formatters.
- **`SuperTextFormField`** — text / email / password types, multiline with row
  count, prefix & suffix adornments, leading icon, clearable, password reveal,
  character counter, `required` / `minLength` / `maxLength` / `pattern` / custom
  validators, disabled & read-only, Arabic face + RTL.
  - `SuperTextFieldController` (Model) + `buildTextValidators` (domain usecase).
- **`SuperNumericFormField`** — grouped-while-idle / raw-while-editing display,
  clamp + round on blur, `+/-` stepper, decimals, grouping, `min` / `max` /
  `allowNegative`, prefix/suffix units; numbers stay Western-digit, right-mono.
  - `SuperNumericFieldController` (Model) + `NumericLogic` (domain usecase).
- **`SuperAttachmentFormField`** — dashed drop zone (drag-over glow), typed file
  list with type glyph + size + remove, per-file errors (size/type) and
  field-level `required` / `maxFiles` validation, single vs. multiple, file
  count pill. Picker-agnostic via `onBrowse` + `controller.add`.
  - `SuperAttachmentFieldController` (Model), `SuperFile` entity,
    `AttachmentLogic` (domain usecase).
- **Behavioral parity with React**: validation surfaces only through the suffix
  `ErrorBadge` (icon + tooltip), gated on first blur (`touched`) or `forceError`;
  `onValidity` reports the current error on every change.
- **Example app** — runnable gallery with three demos (account form, journal
  entry, supporting documents) and global Light/Dark + LTR/RTL toggles.
- **Tests** — pure-domain unit tests for the validator chains and numeric logic.

### Notes

- Icons substitute Flutter's Material `*_outlined` glyphs for the in-house SVG
  set (flagged for swap).
- OS-level drag-and-drop requires a host plugin; the controller exposes the
  hooks (`setDragOver`, `add`) to wire one.
