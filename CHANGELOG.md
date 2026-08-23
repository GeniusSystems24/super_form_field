# Changelog

All notable changes to **super_form_field** are documented here. The format
follows [Keep a Changelog](https://keepachangelog.com/) and the project adheres
to [Semantic Versioning](https://semver.org/).

## [1.11.0] — 2026-08-23

- Simplified `SuperRangeDatePicker` by removing the internal Start/End boundary cards and connector; the picker footer now contains only Cancel, Reset, and Apply actions.
- Made `SuperRangeDateFormField` and the range picker's Start/End boundary controls responsive, automatically switching between one-row and two-row layouts based on available width.
- Fixed `SuperRangeDatePicker` so dimmed/outside-month days are display-only and cannot be clicked, hovered, or selected.
- Compact desktop range picker layout: removes fixed-height whitespace, uses a content-driven preset/calendar body, reduces the anchored overlay width, and refreshes Cancel/Reset/Apply button density and hierarchy.
- Matched `SuperRangeDatePicker` desktop calendar typography, day-cell, and navigation sizing to the compact `MiniCalendar` density.

### Added

<!-- SUPER_RANGE_DATE_PICKER_FIRST_DAY_OF_WEEK_V1 -->
- Added configurable `firstDayOfWeek` support to both `SuperRangeDateFormField` and `SuperRangeDatePicker`. Use `DateTime.monday` through `DateTime.sunday`; weekday headers and calendar-grid alignment now rotate together on desktop, tablet, and mobile.

- Added `SuperRangeDateFormField` with a typed `SuperDateRange` value and a
  dedicated `SuperRangeDateFieldController` following the package controller
  metadata, validation, focus, hidden-state, and Form integration conventions.
- Added independent `isStartFixed` and `isEndFixed` boundary guards. A fixed
  boundary cannot be changed by manual calendar selection, preset selection,
  clear actions, or controller mutations; fixing both makes the range immutable.
- Added `minDate` / `maxDate` range constraints for manual selection,
  programmatic controller edits, validation, and predefined suggestions.
- Added a responsive range picker matching the two-calendar reference layout,
  including separate start/end value boxes, month/year navigation, reset,
  apply, selected-range highlighting, and a preset rail.
- Added configurable `SuperDateRangeSuggestion` presets. `null` uses package
  defaults, `[]` removes all defaults, and callers can replace or extend the
  defaults with custom resolver callbacks.
- Added default Past 7 days, Previous 30 days, Previous 6 months, and Previous
  year suggestions.
- Added range logic/controller regression tests and a dedicated gallery screen
  covering defaults, fixed boundaries, bounds, custom presets, and fully fixed
  ranges.

### Changed

- Redesigned `SuperRangeDatePicker` with a responsive multi-view date-range UI:
  two adjacent months and a preset rail on wide desktop, two months with compact
  preset chips on tablet, and a single swipeable month on mobile. Range selection
  now uses a continuous band with circular endpoints, min/max-aware navigation,
  RTL-aware controls, and explicit Cancel/Reset/Apply actions without adding a
  Syncfusion dependency.

- Changed `SuperRangeDateFormField` to render separate Start date and End date inputs backed by `SuperDateFormField`; both accept keyboard edits, while the range picker opens only from the calendar action. Fixed-boundary and min/max rules now cover keyboard entry and remain synchronized with picker updates.

- Updated package exports, README, example documentation, gallery navigation,
  and `SKILL.md` for the 1.11.0 range-date API.

## [1.10.0]

### Added

- Added `isFixed`, `focusNode`, `formFieldKey`, and compatibility `isHiden`
  metadata to field controllers, following the controller/view contract used by
  `AutoSuggestionsBox`.
- Added type-correct `FormFieldState` keys for text, numeric, OTP, date, select,
  multi-select, and dropdown form-field controllers.
- Added a controller-state gallery screen demonstrating fixed, focus, form key,
  hidden, and guarded programmatic mutation behavior.
- Added regression tests for fixed mutation guards, select menu closing,
  dropdown direct-value guards, focus-node ownership, and hidden rendering.

### Changed

- Controller-backed field views now treat `isFixed` as a full-contrast read-only
  lock instead of a disabled state.
- Public controller mutation methods no-op while fixed.
- Open select/multi-select menus close when their controllers become fixed.
- Controller-owned editor focus nodes are now optional host-supplied nodes and
  are disposed only when the controller created them.

## [1.9.0] — 2026-08-15

### Added

- Added `SuperDropdownEditingController<T>` for programmatic typed selection in both `SuperDropdownButton<T>` and `SuperDropdownButtonFormField<T>`.

- Added `SuperDropdownButton<T>`, a lightweight typed dropdown control built on
  the package `FieldBox`, `FieldPopover`, `OptionMenu`, and `OptionTile`
  foundation.
- Added `SuperDropdownButtonFormField<T>` with `FormState.validate()`,
  `FormState.save()`, reset, required-value validation, and the standard
  `InputDecoration` shell.
- Added `SuperPopupMenuButton<T>` for typed action menus with icon or custom
  triggers, disabled options, keyboard activation, selected state, and shared
  design-system menu styling.
- Added gallery screens demonstrating controlled dropdowns, Form integration,
  disabled options, icon popup triggers, and custom popup triggers.

### Changed

- Updated the public library exports and package documentation for the three new
  controls.
- Updated README and `SKILL.md` usage guidance for dropdown and popup-menu APIs.

### Fixed

- Fixed recursive `SuperPopupMenuButton<T>` submenu height so each nested level shrink-wraps to its items instead of inheriting the full overlay height; `menuMaxHeight` remains only the scrolling upper bound.

- Fixed `SuperPopupMenuButton<T>` nested branches so cascading submenus are inserted as overlay entries above the root popover barrier; branch clicks/hover now open real child menus at arbitrary depth.

## [1.8.2] — 2026-08-10

### Changed

- Updated the package for `super_core 3.3.0`, where `SuperMaterialThemeData`
  requires explicit `SuperTextTheme` values for both `textTheme` and
  `primaryTextTheme`.
- Migrated all form-field typography reads away from the removed
  `SuperThemeData.textTheme` API. Package internals now use
  `BuildContext.sffTextTheme`, backed by the active `SuperMaterialThemeData`,
  while examples use `context.superTextTheme`.
- Updated the example app to rebuild `SuperTextTheme` explicitly when switching
  between English/LTR and Arabic/RTL presentation.
- Raised the documented and example minimum `super_core` version to `3.3.0`.
- Updated README, package docs, tests, example documentation, and AI skill
  guidance for the new typography ownership model.
- Documented that `fontFamily` remains an explicit token-level override and
  must not be inferred from `SuperTextTheme` or the removed `_familyOf` helper.
- Stopped overriding non-Arabic text styles with `SuperTokensData.bodyFont` or
  `monoFont`, so custom `SuperTextTheme` font families now flow through fields
  unchanged. The explicit field-level `arabic: true` fallback remains.

### Fixed

- Fixed compile errors caused by references to the removed
  `SuperThemeData.textTheme` getter and by no-argument
  `SuperMaterialThemeData.light()` / `dark()` calls.

### Tests

- Added a widget regression proving that custom `SuperTextTheme` body font
  families reach `SuperTextFormField` without being overwritten by token
  font metadata.

## [1.8.1] — 2026-08-01

### Added

- Added Arabic and English localization keys for the dedicated phone-input and
  OTP example screens, including labels, hints, helper text, result states,
  actions, and success messages.
- Added localized gallery titles and subtitles for the phone and OTP examples.

### Changed

- Updated the phone and OTP example screens to read their visible text from
  `SuperFormTranslation` instead of embedding English-only strings.

## [1.8.0] — 2026-08-01

### Added

- Added declarative `mask`, `maskFilter`, and `maskAutoCompletionType`
  properties to `SuperTextFormField`, powered by
  `mask_text_input_formatter`.
- Added default `#` digit, `A` Latin-letter, and `N` alphanumeric mask
  placeholders while allowing product-specific placeholder rules.
- Added `onUnmaskedChanged` and `onUnmaskedSaved` callbacks for values without
  mask literals, while preserving the visible masked value in `onChanged`,
  `onSaved`, and the text controller.
- Re-exported `MaskAutoCompletionType` and `MaskTextInputFormatter` from the
  text-field feature for advanced formatter composition.

### Changed

- Custom `inputFormatters` now run before an optional text mask so the mask is
  the final formatting authority.
- Updated the phone example to format Yemeni mobile numbers with the new mask
  API and save the unmasked value.
- Updated package metadata, documentation, skill guidance, and widget coverage
  for masked input.

## [1.7.0] — 2026-08-01

### Added

- Added `SuperOTPFormField` with segmented code cells backed by one Material
  editor for reliable paste, SMS one-time-code autofill, keyboard input, and
  accessibility semantics.
- Added `SuperOTPFieldController`, exact-length validation, localized English
  and Arabic OTP messages, `onCompleted`, secure display, numeric and
  alphanumeric modes, responsive cells, and typed `Form` save/reset support.
- Added Material-style keyboard, formatter, submission, outside-tap, autofill,
  context-menu, restoration, IME, max-length enforcement, cursor, and cell
  customization options.
- Added a dedicated `OTPFieldDemo` gallery screen covering SMS codes, secure
  transaction PINs, alphanumeric backup codes, completion, and form saving.
- Added widget coverage for filtering, length limiting, completion, validation,
  reset, secure rendering, public exports, and gallery navigation.

### Changed

- Updated the public library, package documentation, example application, and
  AI skill to include the ninth form-field component.

## [1.6.2] — 2026-08-01

### Added

- Added a dedicated `PhoneFieldDemo` screen to the example gallery and a
  navigation widget regression for it.
- Demonstrated international phone characters, phone autofill, keyboard
  appearance, outside-tap dismissal, submission, and typed `FormState.save()`.
- Added a country-specific composition example using a dialing-code prefix,
  digits-only formatting, maximum length, and a product-owned validation
  pattern without changing the package-wide phone defaults.

### Changed

- Added the phone example to the gallery launcher and refreshed package, skill,
  and example documentation for version 1.6.2.

## [1.6.1] — 2026-07-31

### Added

- Added `SuperTextType.phone` to `SuperTextFormField`. It selects
  `TextInputType.phone` by default for single-line input while leaving
  locale-specific validation and formatting to `pattern`, `inputFormatters`,
  or custom validators.
- Added package documentation, gallery coverage, and a widget regression for
  the phone keyboard default.

## [1.6.0] — 2026-07-31

### Added

- Added Material-compatible text-input configuration to
  `SuperTextFormField`, `SuperNumericFormField`, `SuperDateFormField`,
  `SuperSelectFormField`, and `SuperMultiSelectFormField`, including keyboard
  type/action/appearance, input formatters, text direction and capitalization,
  submission/editing/tap callbacks, cursor and selection configuration,
  scrolling, autofill, context menus, restoration, and IME behavior.
- Added typed `Form` integration for the five fields through `onSaved`, the
  requested `onSave` compatibility alias, and `autovalidateMode`.
- Added text-field-specific styling, line, max-length-enforcement, and cursor
  controls where they apply.

### Changed

- Search-related text-input properties on select and multi-select fields are
  forwarded to their menu search editor; trigger tap and outside-tap callbacks
  remain attached to the selection field itself.
- Custom date input formatters now run before the package date formatter so the
  segmented date mask remains authoritative.

### Tests

- Added constructor coverage for the Material-compatible properties on all five
  fields and typed `FormState.save()` coverage, including the `onSave` alias.

## [1.5.0] — 2026-07-29

### Added

- Added Flutter-localizations support for package-owned English and Arabic
  strings through `SuperFormTranslation.localizationsDelegates` and
  `SuperFormTranslation.supportedLocales`.
- Localized built-in validation messages, select search and empty states,
  placeholders, attachment actions and file errors, boolean default captions,
  numeric stepper tooltips, and date calendar labels.

### Changed

- Updated the example gallery to register the package localization delegates and
  switch locale when toggling LTR/RTL.
- Updated `README.md` and the package skill for the 1.5.0 localization setup.

## [1.3.0] — 2026-07-19

### Changed

- Unified the public decoration API across all eight form fields. Each field now
  accepts a single `InputDecoration` through `decoration` instead of separate
  `label`, `placeholder`, `hint`, `leadingIcon`, `prefix`, `suffix`, or boolean
  `title` parameters.
- Added a shared decoration adapter that maps Material decoration slots onto the
  GeniusLink `FieldShell` and `FieldBox` while retaining package-owned borders,
  sizing, focus treatment, typography, and error-badge behavior.
- Supported `label`/`labelText`, `helper`/`helperText`, `hint`/`hintText`, leading
  and trailing adornments, counters, styles, icon colors/constraints, and
  `errorText` consistently across applicable controls.
- Kept deprecated `FieldShell.label` and `FieldShell.hint` bridges for direct
  foundation consumers. Public form-field constructors now use `decoration` as
  their single decoration source.
- Updated every example to the new `InputDecoration` API.
- Replaced the example's local `SectionCard` implementation with the component
  exported by `super_core`, using `SuperMarker` and dynamic theme tokens.

### Improved

- `SuperDateFormField` now dismisses the software keyboard when the calendar
  button is tapped.
- Date selection opens in a modal bottom sheet on mobile. Tablet and desktop
  continue using the anchored calendar popover with automatic above/below
  placement. The historical leading calendar glyph remains the default and can
  be replaced through `InputDecoration.prefixIcon`.
- Refined the mobile calendar bottom sheet with a dedicated mobile sheet
  surface, responsive spacing, integrated header/close affordance, stronger
  visual hierarchy, and an expanded calendar layout better suited to touch
  screens.
- Fixed mobile software-keyboard date entry at the interaction layer. Mobile
  edits now pass through `MobileDateInputUseCase` and an IME formatter that
  preserves segment state, keeps the caret collapsed, and prevents repeated
  selection handles or corrupted values. Desktop hardware-key behavior remains
  isolated in `DesktopDateInputUseCase` and is unchanged.
- Fixed `SuperNumericFormField` vertical text alignment at its root cause. The
  collapsed single-line editor is no longer forced to expand to the full
  `FieldBox`; its actual measured render box is centered by layout instead, with
  no visual offsets or hard-coded padding.
- Numeric increment and decrement controls are now contiguous squares. Their
  width and height both resolve from the active compact/comfortable field-height
  token, the shared seam avoids a double border or inter-button gap, and the
  group sits flush with the field's trailing edge without an extra inset.
- `FieldIconButton` now supports optional width, height, border, and border-radius
  overrides while preserving its existing square default.
- The example gallery now uses `SuperAppBar` from `super_core` instead of the
  Material `AppBar`.

### Tests

- Added constructor coverage for the unified decoration API across all eight
  fields.
- Added widget regressions for decoration adaptation, mobile date keyboard
  dismissal and bottom-sheet presentation, retained tablet popovers, and
  measured numeric-editor centering, square full-height steppers, and a
  gap-free stepper seam.
- Added unit coverage for desktop/mobile date interaction use cases and a
  regression that enters a complete date through the mobile formatter while
  verifying stable segments and a collapsed caret.

### Documentation

- Rewrote `README.md` in pub.dev style with installation, theme setup, complete
  field examples, validation, controllers, responsive behavior, RTL guidance,
  and a 1.3.0 migration table.
- Updated package metadata, public library documentation, example documentation,
  and the AI skill for the current architecture and API.

---

## [1.1.0] — 2026-07-16

### Changed

- Upgraded to **super_core 1.1.0**. No source changes required — surfaces are
  read via `SuperThemeData.of(context)`, which `SuperMaterialThemeData` (now a
  `ThemeData` subclass) registers automatically, so palette, brightness **and**
  the responsive `SuperDeviceMode` (mobile / tablet / desktop) tokens flow
  through with no extra wiring:

  ```dart
  MaterialApp(
    theme:     SuperMaterialThemeData.light(mode: SuperDeviceMode.desktop),
    darkTheme: SuperMaterialThemeData.dark(mode: SuperDeviceMode.desktop),
  );
  ```

- Minimum raised to `dart >=3.8.0`, `flutter >=3.32.0`.

---

## [1.0.1] — 2026-07-14

### Changed

- Upgraded to **super_core 1.0.0**. No source changes required — all field
  surfaces are read via `SuperThemeData.of(context)` and `SuperFieldTheme`, both
  of which are auto-registered by `SuperMaterialThemeData`. Palette switching and
  light/dark mode work without any extra wiring:

  ```dart
  MaterialApp(
    theme:     SuperMaterialThemeData.light(palette: SuperPalette.greenPalette),
    darkTheme: SuperMaterialThemeData.dark(palette: SuperPalette.greenPalette),
    // All SuperFormField widgets adapt automatically.
  );
  ```

- Input border focus color and error color now resolve from
  `Theme.of(context).colorScheme.primary` / `.error` respectively, so every
  field automatically reflects the active palette without any per-field
  configuration.

---

## [1.0.0] — 2026-06-19

The **1.0** release rounds the kit out into a full ERP form toolkit: four new
option- and boolean-driven fields join the original four, all on the same shared
foundation, validation contract (silent-until-touched, suffix error badge), and
light/dark + LTR/RTL parity. No breaking changes to the existing four fields.

### Added

- **`SuperSelectFormField<T>`** — a searchable single-select dropdown over typed
  `SuperOption<T>` options. A tappable FieldBox trigger opens a popover that
  drops below the control and flips above when there's no room. Props:
  `options`, `searchable` + `searchHint`, `clearable`, `placeholder`,
  `leadingIcon`, `emptyLabel`, plus the shared `required` / `validators` /
  `forceError` / `arabic` / `density` / `disabled` / `readOnly`. Value is `T?`.
  Options carry `value` / `label` / optional `description` / `icon` / `disabled`.
  - `SuperSelectFieldController<T>` (Model): `value` / `selectedOption` /
    `filtered` / `isOpen` / `open()` / `close()` / `select(option)` /
    `setValue(T?)` / `clear()` / `markTouched()`.
  - `SelectLogic` (pure domain): `filter` (label + description), `buildValidators`.
- **`SuperMultiSelectFormField<T>`** — multi-select with the chosen values shown
  as removable chips inside the field, a label-right count pill, and a checkable
  popover that stays open across toggles. Props: `options`, `searchable`,
  `minSelections`, `maxSelections` (a hard cap — further picks are blocked),
  `showCount`, plus the shared validation/theme props. Value is `List<T>`.
  - `SuperMultiSelectFieldController<T>` (Model): `values` / `isSelected` /
    `selectedOptions` / `count` / `atCapacity` / `toggle(option)` /
    `removeValue(v)` / `setValues` / `clear()`.
  - `MultiSelectLogic` (pure domain): `filter`, `buildValidators` (required ▸ min
    ▸ max).
- **`SuperBoolFormField`** — a labelled boolean drawn as a sliding **toggle**
  (default) or a **checkbox**, with an `enabledLabel` / `disabledLabel` state
  caption or a custom `title` statement. A `mustBeTrue` gate covers required
  acknowledgements (terms, compliance). Value is `bool`.
  - `SuperBoolFieldController` (Model): `value` / `set(bool)` / `toggle()` /
    `setValue(bool)` / `markTouched()`.
  - `buildBoolValidators` (pure domain): the `mustBeTrue` rule + custom chain;
    `SuperBoolStyle` enum.
- **`SuperChoiceFormField<T>`** — an **inline** option group (no popover): a
  horizontal **segmented** control, a **radio** list, or a **checkbox** list.
  Best for small fixed sets (status, period, document types). `multiple`,
  `minSelections`, `maxSelections`. Value is `List<T>` (with a `single`
  convenience on the controller).
  - `SuperChoiceFieldController<T>` (Model): `values` / `single` / `isSelected` /
    `pick(value)` / `setValues` / `setSingle` / `clear()`.
  - `ChoiceLogic` (pure domain): `buildValidators`; `SuperChoiceStyle` enum.
- **Shared core** — a generic `SuperOption<T>` value type (`core/entities`) plus
  reusable foundation widgets: `FieldPopover` (anchored above/below dropdown
  overlay), `OptionMenu` (themed popover surface), `OptionTile` (+
  `OptionGroupHeader`), `MenuSearchField`, and `SuperChip`. New `SffIcons`:
  `chevronDown` / `chevronUp` / `check` / `checkboxOn` / `checkboxOff` /
  `radioOn` / `radioOff`.
- **Example app** — four new demos (Select / Multi-Select / Bool / Choice), each
  with a *Validate* submit-sweep, registered in the gallery launcher.
- **Tests** — pure-domain unit tests for `SelectLogic`, `MultiSelectLogic`,
  `ChoiceLogic`, and `buildBoolValidators`.

### Roadmap

Planned for future minor releases (non-breaking): `SuperPhoneFormField`
(country code + national number), `SuperCurrencyFormField` (amount + currency
preset), `SuperTimeFormField` / date-time, `SuperRangeFormField` (numeric / date
ranges), `SuperColorFormField`, and masked inputs (IBAN / tax id / card).

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
