# Changelog

All notable changes to **super_form_field** are documented here. The format
follows [Keep a Changelog](https://keepachangelog.com/) and the project adheres
to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.2.0] — 2026-06-18

### Added

- **`SuperDateFormField`** — a new field matching the web ledger's date input: a
  masked, mono `YYYY-MM-DD` text entry with a trailing calendar trigger that
  opens a `MiniCalendar` month-grid popover (prev/next month, today outlined,
  selection filled accent, **Today** shortcut). Value is a date-only `DateTime?`;
  typed text masks live and a non-empty incomplete entry raises the suffix badge
  on blur. Props: `minDate` / `maxDate` (auto bounds validators), `calendar`
  (show/hide the popover), `keyboardShortcuts` (arrow-key segment stepping),
  `clearable`, `leadingIcon`, `invalidMessage`, plus the
  shared `required` / `validators` / `forceError` / `arabic` / `density` /
  `disabled` / `readOnly`. Western-digit, mono, LTR even in RTL.
  - **Segment-aware typing**: the buffer is `YYYY`·`MM`·`DD` and the cursor's
    segment is the one edited — typing overwrites it and auto-advances rightward
    (year→month→day; the day is terminal, so extra digits keep re-editing it).
    `←`/`→` move between segments; a separator key jumps to the next.
  - **Arrow-key segment stepping** (while focused, on by default): `↑`/`↓`
    increment/decrement the active segment (day rolls across months; month/year
    clamp the day to the new month length; result clamps to `minDate`/`maxDate`).
    Toggle with `keyboardShortcuts`.
  - `SuperDateFieldController` (Model) with `value` / `error` / `pick(DateTime)`
    / `setValue(DateTime?)` / `clear()` / `markTouched()` / `stepSegment` /
    `stepAtCursor`.
  - `DateLogic` (pure domain usecase): `mask`, `parse`, `format`, `dateOnly`,
    `sameDay`, `buildValidators`.
  - `SffIcons.calendar` / `calendarDays` / `chevronLeft` / `chevronRight` added.
- **`SuperNumericFormField`** — keyboard stepping while focused: `↑`/`↓` change
  the value by `step`, `PageUp`/`PageDown` by the new `largeStep` (defaults to
  `step * 10`). Both clamp + round like the stepper buttons. Toggle with
  `keyboardShortcuts` (default `true`). Controller adds `bumpLarge(direction)`;
  `bump` is unchanged.
- **Example app** — a fourth demo, *Super Date Field*, with three usage examples
  (basic / controlled linked range / validated bilingual submit-sweep) under
  `example/lib/demos/date/`.
- **Tests** — pure-domain unit tests for `DateLogic` (mask / parse / validators).

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
