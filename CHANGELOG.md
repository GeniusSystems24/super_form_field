# Changelog

All notable changes to **super_form_field** are documented here. The format
follows [Keep a Changelog](https://keepachangelog.com/) and the project adheres
to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- **`SuperNumericFormField`** — keyboard stepping while focused: `↑`/`↓` change
  the value by `step`, `PageUp`/`PageDown` by the new `largeStep` (defaults to
  `step * 10`). Both clamp + round like the stepper buttons. Toggle with
  `keyboardShortcuts` (default `true`). Controller adds `bumpLarge(direction)`;
  `bump` is unchanged.

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
