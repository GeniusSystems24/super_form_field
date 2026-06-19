---
name: super-form-field
description: >
  Use the super_form_field Flutter package to build GeniusLink design-system
  form inputs — SuperTextFormField (text/email/password/multiline),
  SuperNumericFormField (formatted numeric with stepper),
  SuperAttachmentFormField (file drop zone + list), SuperDateFormField
  (masked YYYY-MM-DD + calendar), SuperSelectFormField (searchable single-select
  dropdown), SuperMultiSelectFormField (chips + checkable popover),
  SuperBoolFormField (toggle/checkbox), and SuperChoiceFormField (segmented /
  radio / checkbox group). Apply when a Flutter app needs validated, themed
  (light/dark, LTR/RTL) ERP form fields whose errors surface through a suffix
  badge tooltip rather than inline text.
---

# Super Form Field — Agent Skill

`super_form_field` ships eight GeniusLink form inputs on one field foundation.
This skill tells you how to wire them correctly.

## When to use

- Any Flutter form built in the GeniusLink visual language (dark-first ERP /
  accounting screens, bilingual English+Arabic).
- You need validation that is **silent until blur** and shown via a **suffix
  error badge tooltip**, never as inline text.
- You need numeric inputs that group thousands at rest, clean to raw digits
  while editing, and clamp/round on blur.
- You need a file-attachment field with typed validation but **no** assumptions
  about which picker plugin the app uses.

## Setup (do this once)

1. Add the dependency (path or hosted) in `pubspec.yaml`.
2. Register the theme extension on the `MaterialApp`:
   ```dart
   theme:     ThemeData(extensions: const [SuperThemeData.light]),
   darkTheme: ThemeData(extensions: const [SuperThemeData.dark]),
   ```
3. For Arabic, wrap the subtree in `Directionality(textDirection: TextDirection.rtl, …)`
   and set `arabic: true` on the field (switches to the Noto Naskh Arabic face).
4. (Optional but recommended) add the brand `.ttf` fonts under `assets/fonts/`
   and uncomment the `fonts:` block — Manrope, Inter, JetBrains Mono, Noto Naskh
   Arabic.

`import 'package:super_form_field/super_form_field.dart';` exposes everything.

## The four core fields

### SuperTextFormField
Key props: `label`, `required`, `placeholder`, `hint`, `type`
(`SuperTextType.text|email|password`), `leadingIcon` (use `SffIcons.*`),
`prefix`/`suffix`, `clearable`, `multiline` + `rows`, `minLength`/`maxLength`,
`pattern` + `patternMessage`, `showCounter` (needs `maxLength`), `validators`
(extra `Validator<String>`), `density`, `disabled`, `readOnly`, `arabic`,
`onChanged`, `onValidity`, `forceError`.

### SuperNumericFormField
Key props: `label`, `required`, `min`, `max`, `decimals`, `grouping`, `step`,
`largeStep`, `stepper`, `keyboardShortcuts`, `allowNegative`, `prefix`/`suffix`
(mono units like `SAR`, `%`), `leadingIcon`, `validators` (`Validator<num?>`),
`onChanged` (`num?`), `onValidity`, `forceError`. Value type is `num?` — `null`
means empty. **Keyboard stepping** (while focused, on by default): `↑`/`↓` by
`step`, `PageUp`/`PageDown` by `largeStep` (defaults `step * 10`); set
`keyboardShortcuts: false` to disable, or drive it via `controller.bump(±1)` /
`controller.bumpLarge(±1)`.

### SuperAttachmentFormField
Key props: `label`, `required`, `accept` (`".pdf,.docx"` or `"image/*"`),
`maxSizeMB`, `maxFiles`, `multiple`, `onBrowse` (async → `List<SuperFile>`),
`onChanged` (`List<SuperFile>`), `onValidity`, `forceError`.
**You must supply `onBrowse`** — the package has no picker. Build `SuperFile`
from your picker result: `SuperFile(id, name, size, mimeType?, path?, bytes?)`.
For OS drag-and-drop, call `controller.setDragOver(bool)` and `controller.add(files)`.

### SuperDateFormField
Key props: `label`, `required`, `placeholder` (defaults to the format template),
`format` (`SuperDateFormat.yearMonthDay` | `yearMonth` | `year` | `monthDay` |
`month` | `day`), `minDate`, `maxDate` (add bounds validators), `calendar`
(show/hide the popover — only when the format has a day; default `true`),
`keyboardShortcuts` (arrow-key segment stepping — default `true`), `clearable`,
`leadingIcon` (defaults to `SffIcons.calendar`, pass `null` to hide),
`invalidMessage`, `validators` (`Validator<DateTime?>`), `onChanged`
(`DateTime?`), `onValidity`, `forceError`, `arabic`, `density`, `disabled`,
`readOnly`. Value is a `DateTime?` — absent format parts fill with defaults
(year→current, month→1, day→1). **Editing keeps the zero-padded format**: digits
shift into the active segment from the right (`0002→0020→2024`) and the cursor's
segment is the one edited — typing flows year→month→day (day terminal). `←`/`→`
move segments; `↑`/`↓` step the active one (wraps within its range). The calendar
opens below the icon, flipping above when there's no room. Pick from the
popover, or drive it from a `SuperDateFieldController` via `pick(DateTime)`,
`setValue(DateTime?)`, `clear()`, `stepSegment(kind, ±1)`, `stepAtCursor(±1)`.

## The four option / boolean fields

All four use the generic `SuperOption<T>` value type from `core`
(`SuperOption(value: T, label: String, description?, icon?, disabled?)`; build
lists with `SuperOption.fromMap({value: label})`).

### SuperSelectFormField&lt;T&gt;
Searchable single-select dropdown. Key props: `options` (required
`List<SuperOption<T>>`), `searchable` + `searchHint`, `clearable`, `placeholder`,
`leadingIcon`, `emptyLabel`, plus shared `required` / `validators`
(`Validator<T?>`) / `forceError` / `arabic` / `density` / `disabled` /
`readOnly`. `onChanged` is `ValueChanged<T?>` — value is `T?` (`null` = empty).
The popover drops below the control, flipping above when needed, and matches the
control width. Disabled options can't be picked.

### SuperMultiSelectFormField&lt;T&gt;
Multi-select with in-field removable chips + a checkable popover that stays open
across toggles. Key props: `options`, `searchable`, `minSelections`,
`maxSelections` (a **hard cap** — extra picks are blocked), `showCount` (the
`n selected` label-right pill). `onChanged` is `ValueChanged<List<T>>` — value is
`List<T>`.

### SuperBoolFormField
A labelled boolean as a sliding toggle (default) or checkbox. Key props: `label`,
`style` (`SuperBoolStyle.toggle | checkbox`), `enabledLabel` / `disabledLabel`
(status caption) OR `title` (a statement, e.g. "I accept …"), `mustBeTrue` +
`mustBeTrueMessage` (required-acceptance gate), shared validation/theme props.
`onChanged` is `ValueChanged<bool>` — value is `bool`. The whole row is tappable.

### SuperChoiceFormField&lt;T&gt;
Inline option group (no popover). Key props: `options`, `style`
(`SuperChoiceStyle.segmented | radio | checkbox`), `multiple` (segmented/radio
default single; checkbox is multi), `minSelections`, `maxSelections`. `onChanged`
is `ValueChanged<List<T>>` — value is `List<T>`; for single-pick styles read one
value via `controller.single`. The error shows in the FieldShell label-right
slot. Best for small fixed sets (status, period, document types).

## Rules that matter

- **Never** expect inline error text under a field — errors are a tooltip on the
  suffix `ErrorBadge`. To show a field-level summary, read `controller.error`.
- Validation is gated on `touched` (first blur) OR `forceError`. On submit, set
  `forceError: true` for every field (or call `controller.markTouched()`), then
  check validity.
- Aggregate form validity with `onValidity: (error) { … }` per field, or hold a
  controller per field and read `controller.error`.
- Numbers are always Western digits, right-aligned, mono — do not override this
  for RTL.
- Use `SffIcons` for `leadingIcon` (e.g. `SffIcons.mail`, `SffIcons.user`,
  `SffIcons.lock`, `SffIcons.hash`, `SffIcons.search`).

## Minimal submit-sweep pattern

```dart
bool _force = false;
String? _nameError;

SuperTextFormField(
  label: 'Name English', required: true, minLength: 3,
  forceError: _force,
  onValidity: (e) => _nameError = e,
);

void _submit() {
  setState(() => _force = true);
  if (_nameError == null /* && other errors null */) { /* proceed */ }
}
```

## Architecture (for extending)

Clean Architecture per feature; the **controller** is the Model
(`ChangeNotifier`, single source of truth), the **widget** is the thin View, and
`domain/` holds pure validator/format logic that is unit-testable without
Flutter. Add new constraints by extending the `build*Validators` / `*Logic`
usecase in `domain/`, not by stuffing logic into the widget.

## Don't

- Don't reach into `lib/src/` internals from app code — import only the public
  barrel.
- Don't add a picker dependency to the package; wire it at the app via `onBrowse`.
- Don't recolor numbers or move the error badge inline.
