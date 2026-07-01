# Super Form Field

GeniusLink design-system **form fields for Flutter** — eight precision inputs
for ERP and accounting screens, on one shared field foundation:

| Widget | Purpose |
|---|---|
| **`SuperTextFormField`** | Text · email · password · multiline · prefix/suffix · clear · character counter |
| **`SuperNumericFormField`** | Grouped thousands while idle, raw digits while editing, clamp + round on blur, `+/-` stepper, unit adornments |
| **`SuperAttachmentFormField`** | Drag-drop / browse drop zone + typed file list with per-file and field-level validation |
| **`SuperDateFormField`** | Masked `YYYY-MM-DD` mono input + calendar popover, min/max bounds, ISO `DateTime?` value |
| **`SuperSelectFormField<T>`** | Searchable single-select dropdown over typed `SuperOption<T>` options, clearable, above/below popover |
| **`SuperMultiSelectFormField<T>`** | Multi-select with in-field removable chips, count pill, checkable popover, min/max selections |
| **`SuperBoolFormField`** | Boolean toggle or checkbox — active/status flags, acknowledgements, `mustBeTrue` gate |
| **`SuperChoiceFormField<T>`** | Inline option group — segmented control, radio list, or checkbox list |

Every field shares the GeniusLink look: a 4px-radius bordered control, electric
royal-blue focus, JetBrains Mono numerics, and **validation that surfaces only
through a suffix error badge (icon + tooltip) — never inline text**. Light/dark
and LTR/RTL come for free. The package is **dependency-free** (no platform
plugins).

---

## Install

```yaml
# pubspec.yaml
dependencies:
  super_form_field: ^1.0.1
```

Register the theme extension once so the fields pick up colors, then build:

```dart
import 'package:super_form_field/super_form_field.dart';

MaterialApp(
  theme:     ThemeData(extensions: const [SuperThemeData.light]),
  darkTheme: ThemeData(extensions: const [SuperThemeData.dark]),
  // RTL: wrap with Directionality(textDirection: TextDirection.rtl, …)
);
```

> **Fonts** — the kit references Manrope / Inter / JetBrains Mono / Noto Naskh
> Arabic. Drop the `.ttf` files under `assets/fonts/` and uncomment the `fonts:`
> block in `pubspec.yaml` to match the design system pixel-for-pixel. Without
> them Flutter falls back to the platform default; everything still works.

---

## Quick start

### Text

```dart
SuperTextFormField(
  label: 'Name English',
  required: true,
  placeholder: 'e.g. Current Assets',
  leadingIcon: SffIcons.user,
  clearable: true,
  minLength: 3,
  onChanged: (value) => print(value),
  onValidity: (error) => print(error == null ? 'valid' : error),
);

// email · password · multiline + counter
SuperTextFormField(label: 'Email', type: SuperTextType.email, required: true);
SuperTextFormField(label: 'Password', type: SuperTextType.password, minLength: 8);
SuperTextFormField(label: 'Notes', multiline: true, rows: 4, maxLength: 200, showCounter: true);
```

### Numeric

```dart
SuperNumericFormField(
  label: 'Debit Amount',
  required: true,
  prefix: 'SAR',
  decimals: 2,
  min: 0,
  allowNegative: false,
  onChanged: (num? v) => print(v),
);

SuperNumericFormField(label: 'Quantity', min: 1, max: 9999, step: 1);
SuperNumericFormField(label: 'Tax Rate', suffix: '%', decimals: 1, min: 0, max: 100, step: 0.5);
```

**Keyboard stepping** (on by default while the field is focused):
`↑`/`↓` change the value by `step`; `PageUp`/`PageDown` change it by `largeStep`
(defaults to `step * 10`). Both clamp to `min`/`max` and round to `decimals`.
Disable with `keyboardShortcuts: false`.

```dart
SuperNumericFormField(
  label: 'Quantity', min: 1, max: 9999,
  step: 1,         // ↑ / ↓
  largeStep: 10,   // PageUp / PageDown
);
```

### Attachment

```dart
SuperAttachmentFormField(
  label: 'Attachments',
  required: true,
  accept: '.pdf,.docx,.xlsx,.png,.jpg',
  maxSizeMB: 5,
  maxFiles: 4,
  onBrowse: () async {
    // Wire your picker here and return a List<SuperFile>.
    // e.g. with file_picker:
    //   final res = await FilePicker.platform.pickFiles(allowMultiple: true);
    //   return res!.files.map((f) => SuperFile(
    //     id: f.name, name: f.name, size: f.size, bytes: f.bytes)).toList();
    return const <SuperFile>[];
  },
  onChanged: (files) => print('${files.length} files'),
);
```

The field stays **picker-agnostic**: `onBrowse` (and `controller.add(...)` for
OS drag-and-drop) hand files in as `SuperFile` metadata, so you choose
`file_picker`, `image_picker`, a server record, or a test fixture.

### Date

The same input chrome the web ledger uses: a masked, mono `YYYY-MM-DD` text
field with a trailing calendar trigger that opens a month-grid popover. The
value is a date-only `DateTime?` (`null` when empty); typed text is masked live
and a non-empty, incomplete entry raises the suffix badge on blur.

```dart
SuperDateFormField(
  label: 'Posting Date',
  required: true,
  initialValue: DateTime(2024, 1, 1),
  minDate: DateTime(2024, 1, 1),
  maxDate: DateTime(2024, 12, 31),
  onChanged: (DateTime? v) => print(v),
);

// configurable format · type-only · clearable · custom invalid message
SuperDateFormField(label: 'Period', format: SuperDateFormat.yearMonth);
SuperDateFormField(label: 'Fiscal Year', format: SuperDateFormat.year);
SuperDateFormField(label: 'Due', calendar: false, clearable: true);
```

**Formats** — `format:` chooses which segments show (any contiguous run of
year/month/day): `yearMonthDay` (default), `yearMonth`, `year`, `monthDay`,
`month`, `day`. The placeholder follows the format (`YYYY-MM`, `MM-DD`, …) and
the calendar trigger only appears when a day segment is present. The value is
always a `DateTime?` — absent parts fill with defaults (year → current, month →
1, day → 1).

The field — and the popover — keep Western digits, mono, and LTR even in RTL
layouts, matching the design system's international-accounting rule. The
calendar opens **below the trigger icon**, flipping **above** it when there isn't
room below. Tap a day (or **Today**) to commit; out-of-range days are disabled.
`minDate` / `maxDate` add `Must be on or after …` / `… or before …` validators.

**Keyboard editing** keeps the format at all times — each segment is fixed-width
and zero-padded, and digits shift in from the right: typing the year reads
`0002 → 0020 → 0202 → 2024`, then advances to the next segment; month and day
behave the same at two digits (with smart early-advance, e.g. a leading `4` for
the day). Editing is **segment-aware**: whichever segment the cursor is on is the
one you edit, flowing rightward (year → month → day; the day is terminal, so
further digits keep re-editing it). `←`/`→` move between segments; a separator
key (`-` `/` `.`) jumps to the next.

**Keyboard stepping** (on by default while focused): `↑`/`↓` step the active
segment, wrapping within its own range (month `1↔12`, day within the month
length) — the year is unbounded. Disable with `keyboardShortcuts: false`, or
drive it from a controller via `step.stepSegment(kind, ±1)` /
`step.stepAtCursor(±1)`.

### Select

A searchable single-select dropdown over typed options. The value is `T?`
(`null` when nothing is chosen); options are `SuperOption<T>` (a domain `value`
presented as a `label`, with optional `description` / `icon` / `disabled`).

```dart
SuperSelectFormField<String>(
  label: 'Account Type',
  required: true,
  placeholder: 'Choose a type…',
  options: const [
    SuperOption(value: 'asset', label: 'Asset'),
    SuperOption(value: 'liability', label: 'Liability'),
    SuperOption(value: 'equity', label: 'Equity'),
  ],
  onChanged: (String? v) => print(v),
);

// searchable + clearable, with descriptions
SuperSelectFormField<String>(
  label: 'Reporting Currency',
  searchable: true,
  clearable: true,
  initialValue: 'SAR',
  options: const [
    SuperOption(value: 'SAR', label: 'SAR — Saudi Riyal', description: 'ر.س'),
    SuperOption(value: 'USD', label: 'USD — US Dollar', description: r'$'),
  ],
);

// build options from a value→label map
final options = SuperOption.fromMap({'draft': 'Draft', 'posted': 'Posted'});
```

The trigger opens a popover that drops **below** the control and flips **above**
when there isn't room; the panel matches the control width. `searchable: true`
adds a filter box (matches label + description). Disabled options render dimmed
and can't be picked.

### Multi-select

Multi-select with the chosen values shown as removable **chips** inside the
field and a checkable popover that stays open across toggles. The value is
`List<T>`.

```dart
SuperMultiSelectFormField<String>(
  label: 'Permissions',
  required: true,
  searchable: true,
  minSelections: 1,
  maxSelections: 3,            // hard cap — further picks are blocked
  options: const [
    SuperOption(value: 'post', label: 'Post entries', description: 'Create & submit'),
    SuperOption(value: 'approve', label: 'Approve'),
    SuperOption(value: 'reverse', label: 'Reverse'),
  ],
  onChanged: (List<String> v) => print(v),
);
```

A label-right **count pill** shows `n selected`. Tapping a chip's × removes that
value; tapping the field opens/closes the menu.

### Bool

A labelled boolean drawn as a sliding **toggle** (default) or a **checkbox**.
Use `enabledLabel` / `disabledLabel` for a status caption, or `title` for a
statement (acknowledgements). `mustBeTrue` gates required confirmations.

```dart
SuperBoolFormField(
  label: 'Account Status',
  initialValue: true,
  enabledLabel: 'Active',
  disabledLabel: 'Inactive',
  onChanged: (bool v) => print(v),
);

// checkbox acknowledgement that must be accepted
SuperBoolFormField(
  label: 'Confirmation',
  required: true,
  style: SuperBoolStyle.checkbox,
  title: 'I confirm these details are accurate.',
  mustBeTrue: true,
  mustBeTrueMessage: 'You must confirm before saving.',
);
```

### Choice

An **inline** option group (no popover) — a horizontal **segmented** control, a
**radio** list, or a **checkbox** list. Best for small fixed sets. The value is
`List<T>`; single-pick styles keep one element (read `controller.single`).

```dart
// segmented, single-pick
SuperChoiceFormField<String>(
  label: 'Status',
  required: true,
  initialValue: const ['draft'],
  options: const [
    SuperOption(value: 'draft', label: 'Draft'),
    SuperOption(value: 'posted', label: 'Posted'),
    SuperOption(value: 'void', label: 'Void'),
  ],
);

// radio list (single) · checkbox list (multi, min/max)
SuperChoiceFormField<String>(label: 'Period', style: SuperChoiceStyle.radio, options: periods);
SuperChoiceFormField<String>(
  label: 'Document Types',
  style: SuperChoiceStyle.checkbox,
  minSelections: 1,
  maxSelections: 3,
  options: docTypes,
);
```

`checkbox` style is multi-pick by default; pass `multiple: true` to allow
multiple picks in any style.

---

## Controllers (optional)

Each field manages its own state, but you can pass a controller to read/drive it
from outside — the standard Flutter pattern:

```dart
final name = SuperTextFieldController(initialValue: 'Cash');
SuperTextFormField(controller: name, label: 'Name');
// later:  name.value   name.error   name.clear()   name.markTouched()

final amount = SuperNumericFieldController(initialValue: 5240);
SuperNumericFormField(controller: amount, label: 'Amount', decimals: 2);
// later:  amount.value   amount.bump(1)   amount.bumpLarge(1)   amount.setValue(0)

final docs = SuperAttachmentFieldController();
SuperAttachmentFormField(controller: docs, label: 'Docs');
// later:  docs.files   docs.add([...])   docs.remove(id)   docs.setDragOver(true)

final date = SuperDateFieldController(initialValue: DateTime(2024, 1, 1));
SuperDateFormField(controller: date, label: 'Date');
// later:  date.value   date.error   date.pick(DateTime)   date.setValue(null)   date.markTouched()

final type = SuperSelectFieldController<String>(initialValue: 'asset');
SuperSelectFormField<String>(controller: type, label: 'Type', options: types);
// later:  type.value   type.selectedOption   type.open()   type.close()   type.clear()

final perms = SuperMultiSelectFieldController<String>(initialValue: const ['post']);
SuperMultiSelectFormField<String>(controller: perms, label: 'Permissions', options: all);
// later:  perms.values   perms.toggle(option)   perms.removeValue(v)   perms.clear()

final active = SuperBoolFieldController(initialValue: true);
SuperBoolFormField(controller: active, label: 'Status');
// later:  active.value   active.toggle()   active.set(false)   active.markTouched()

final status = SuperChoiceFieldController<String>(initialValue: const ['draft']);
SuperChoiceFormField<String>(controller: status, label: 'Status', options: states);
// later:  status.values   status.single   status.pick(value)   status.setSingle('posted')
```

### Validation timing

Errors stay silent until the field is **touched** (first blur) or you force them
— e.g. a submit sweep:

```dart
bool force = false;
// in the field:  forceError: force
// on submit:     setState(() => force = true);
```

`onValidity(String? error)` fires on every change with the current error (null =
valid), so a form can aggregate validity across many fields.

---

## Architecture

Clean Architecture **per feature**, with an MVC presentation split:

```
lib/
  src/
    core/                         shared foundation (theme, validators, field chrome)
      (theme/type/sizes come from the shared super_core package)
      entities/   super_option (the generic SuperOption<T> choice type)
      utils/      validators
      foundation/ field_shell · field_box · error_badge · field_icon_button · sff_icon · count_pill
                  super_chip · field_popover · option_menu · option_tile · menu_search_field
    features/
      super_text_form_field/
        domain/         text_field_config · build_text_validators        (pure Dart)
        presentation/   super_text_field_controller (Model) · super_text_form_field (View)
      super_numeric_form_field/
        domain/         numeric_logic
        presentation/   super_numeric_field_controller · super_numeric_form_field
      super_attachment_form_field/
        domain/         super_file · attachment_logic
        presentation/   super_attachment_field_controller · super_attachment_form_field
      super_date_form_field/
        domain/         date_logic                                       (pure Dart)
        presentation/   super_date_field_controller · super_date_form_field · mini_calendar
      super_select_form_field/
        domain/         select_logic                                     (pure Dart)
        presentation/   super_select_field_controller · super_select_form_field
      super_multi_select_form_field/
        domain/         multi_select_logic
        presentation/   super_multi_select_field_controller · super_multi_select_form_field
      super_bool_form_field/
        domain/         bool_field_config · build_bool_validators        (pure Dart)
        presentation/   super_bool_field_controller · super_bool_form_field
      super_choice_form_field/
        domain/         choice_field_config · choice_logic               (pure Dart)
        presentation/   super_choice_field_controller · super_choice_form_field
  super_form_field.dart           public barrel
example/                          runnable gallery (8 demos, theme + dir toggles)
test/                             pure-domain unit tests
```

- **domain** is pure Dart (no Flutter import beyond drawing types) — the
  validator chains and numeric/attachment rules are unit-testable on their own.
- **presentation/controllers** are the **Model** (`ChangeNotifier`): the single
  source of truth for value + interaction state + derived error.
- **presentation/widgets** are the thin **View**: they translate declarative
  props into controller config and render the foundation chrome.

---

## Run the example

```bash
cd example
flutter run        # or flutter run -d chrome / macos / etc.
```

Toggle Light/Dark and English/Arabic from the launcher; each demo has a
**Validate** button that force-shows every error badge.

---

## Roadmap

Planned for future **minor** releases — additive, on the same foundation and
validation contract, no breaking changes to the eight current fields:

| Planned field | Purpose |
|---|---|
| **`SuperPhoneFormField`** | Country-code selector + national number, format + length validation |
| **`SuperCurrencyFormField`** | Amount + currency-code preset (numeric field paired with a select) |
| **`SuperTimeFormField`** | Masked `HH:mm` (+ optional seconds) and a date-time composite |
| **`SuperRangeFormField`** | Numeric / date **ranges** (from–to) with cross-field validation |
| **`SuperColorFormField`** | Swatch + hex input for tags / category colors |
| **Masked inputs** | IBAN · tax id · card number — reusable mask + checksum validators |

Have an ERP field you need next? The Clean-Architecture split means a new field
is a `domain/` usecase + a controller (Model) + a thin widget (View) — open an
issue describing the input and its validation rules.

## Notes & substitutions

- **Icons** map to Flutter's bundled Material `*_outlined` glyphs (close to the
  GeniusLink 1.5px outlined set). Swap `SffIcons` for the in-house SVG marks
  when they ship.
- **Numbers** stay Western digits and right-aligned mono even in RTL — the
  international accounting standard the design system mandates.
- **OS drag-and-drop** isn't bundled (it needs a platform plugin); the drop zone
  exposes `controller.setDragOver(bool)` + `controller.add(...)` so you can wire
  `super_drag_and_drop` or desktop drop targets yourself.

See `CHANGELOG.md` for version history and `SKILL.md` for the agent skill.
