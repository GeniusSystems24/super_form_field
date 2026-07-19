# Super Form Field

ERP-ready Flutter form fields built on the GeniusLink design system. The package
provides consistent validation, responsive interactions, light/dark themes, and
LTR/RTL support across text, numeric, attachment, date, select, multi-select,
boolean, and choice inputs.

## Features

- Eight focused form-field widgets with matching controllers and validators.
- One `InputDecoration` API for labels, hints, helper text, icons, prefixes,
  suffixes, counters, and external error text.
- GeniusLink styling remains authoritative for field borders, spacing, type,
  focus states, disabled states, and error badges.
- Validation stays quiet until a field is touched, unless `forceError` is set.
- Responsive date interaction: software-keyboard-safe segmented entry and a
  bottom-sheet calendar on mobile; hardware-key navigation and anchored calendar
  popovers on tablet and desktop.
- Formatted numeric input with keyboard stepping and contiguous square
  increment/decrement controls that match the active field height.
- Light/dark and English/Arabic LTR/RTL parity.
- Picker-agnostic attachments with no platform picker plugin included.

## Installation

Add the package to `pubspec.yaml`:

```yaml
dependencies:
  super_form_field: ^1.3.0
```

Then import the public library:

```dart
import 'package:super_form_field/super_form_field.dart';
```

## Theme setup

`super_form_field` reads its visual tokens from `super_core`. The recommended
setup is `SuperMaterialThemeData`:

```dart
MaterialApp(
  theme: SuperMaterialThemeData.light(
    palette: SuperPalette.bluePalette,
  ),
  darkTheme: SuperMaterialThemeData.dark(
    palette: SuperPalette.bluePalette,
  ),
  home: const MyFormPage(),
);
```

All fields continue to apply the GeniusLink design language even when a custom
`InputDecoration` is supplied. Decoration content and styles are respected;
field borders, fill behavior, sizing, focus treatment, and badge-based errors
remain controlled by the package.

## InputDecoration

Every public field uses `decoration` as the single source of decoration content:

```dart
SuperTextFormField(
  decoration: const InputDecoration(
    labelText: 'Account name',
    hintText: 'Enter the account name',
    helperText: 'Shown on invoices and reports',
    prefixIcon: Icon(SffIcons.user),
    suffixText: 'EN',
  ),
  required: true,
  minLength: 3,
);
```

Common mappings are:

| InputDecoration property | Super field behavior |
|---|---|
| `label` / `labelText` | External GeniusLink field label |
| `helper` / `helperText` | Helper content below the control |
| `hint` / `hintText` | Empty-value prompt or field statement |
| `icon`, `prefixIcon`, `prefix`, `prefixText` | Leading field adornments |
| `suffix`, `suffixText`, `suffixIcon` | Trailing field adornments |
| `counter` / `counterText` | Label-row counter when supported |
| `errorText` | External error rendered through the package error badge |

For text fields, caller prefix and suffix widgets are preserved while package
controls such as clear and password visibility buttons are appended. For custom
controls, decoration slots are adapted to the shared `FieldShell` and
`FieldBox` components.

Use `errorText` when supplying an external error. The package intentionally does
not adapt `InputDecoration.error`, because its badge and tooltip validation
surface requires a message string.

## Fields

### Text

`SuperTextFormField` supports normal text, email, password, and multiline input.
It also supports clear actions, character limits, a counter, regular-expression
validation, and custom validators.

```dart
SuperTextFormField(
  decoration: const InputDecoration(
    labelText: 'Email',
    hintText: 'name@example.com',
    prefixIcon: Icon(SffIcons.mail),
  ),
  type: SuperTextType.email,
  required: true,
  clearable: true,
);
```

Useful options include `type`, `multiline`, `rows`, `minLength`, `maxLength`,
`pattern`, `patternMessage`, `showCounter`, `clearable`, `autofocus`,
`disabled`, and `readOnly`.

### Numeric

`SuperNumericFormField` formats grouped values while idle and exposes raw input
while editing. It clamps and rounds on blur, supports min/max validation, and
keeps Western digits in LTR order. The single-line editor keeps its natural
measured height and is centered by layout inside the authoritative `FieldBox`;
it is no longer forced to fill the control and then corrected with visual
offsets or hard-coded padding. The stepper buttons are contiguous squares
whose size follows the active responsive field-height token.

```dart
SuperNumericFormField(
  decoration: const InputDecoration(
    labelText: 'Amount',
    prefixText: 'SAR',
    hintText: '0.00',
  ),
  decimals: 2,
  min: 0,
  step: 0.25,
  largeStep: 10,
);
```

While focused, Arrow Up/Down changes the value by `step`; Page Up/Down uses
`largeStep` or `step * 10`. Disable this with `keyboardShortcuts: false`.

### Attachment

`SuperAttachmentFormField` displays a drop zone and validated file list. Supply
`onBrowse` from the host application so the package remains independent of a
specific picker plugin.

```dart
SuperAttachmentFormField(
  decoration: const InputDecoration(
    labelText: 'Supporting documents',
    hintText: 'Browse or drag files here',
    helperText: 'PDF or DOCX only',
    prefixIcon: Icon(SffIcons.uploadCloud),
  ),
  accept: '.pdf,.docx',
  maxSizeMB: 10,
  maxFiles: 5,
  onBrowse: () async {
    // Convert results from file_picker, image_picker, or another host service.
    return <SuperFile>[];
  },
);
```

Create files with `SuperFile(id:, name:, size:, mimeType:, path:, bytes:)`.
For OS drag-and-drop integrations, call `controller.setDragOver(...)` and
`controller.add(...)` from the host adapter.

### Date

`SuperDateFormField` provides segmented, zero-padded date input with configurable
formats and min/max bounds.

```dart
SuperDateFormField(
  decoration: const InputDecoration(
    labelText: 'Posting date',
    helperText: 'Must be inside the open period',
  ),
  format: SuperDateFormat.yearMonthDay,
  minDate: DateTime(2026, 1, 1),
  maxDate: DateTime(2026, 12, 31),
  clearable: true,
);
```

Tapping the calendar button dismisses the keyboard. On mobile, the calendar is
shown in a modal bottom sheet; tablet and desktop retain the anchored popover
that flips above the field when required.

The default leading calendar glyph is kept when no leading decoration is
supplied. Override it with `prefixIcon`, or suppress it with
`prefixIcon: SizedBox.shrink()`. The available formats are `yearMonthDay`,
`yearMonth`, `year`, `monthDay`, `month`, and `day`.

Date entry also adapts to the active `SuperDeviceMode`:

- **Mobile:** software-keyboard deltas are translated by
  `MobileDateInputUseCase`. The caret stays collapsed, and typed digits replace
  the active segment without showing persistent selection handles or allowing
  the raw IME value to corrupt the date mask.
- **Tablet and desktop:** `DesktopDateInputUseCase` preserves segment selection,
  arrow-key stepping, left/right navigation, and separator shortcuts.

Both policies emit the same platform-neutral `DateInputIntent` operations and
share one controller, parser, validator chain, calendar logic, and date value.
Advanced integrations can inject custom `DateInputUseCase<Request>`
implementations through the `SuperDateFieldController` constructor without
changing the widget API.

### Select

`SuperSelectFormField<T>` is a typed single-select field with optional search,
clear, disabled options, and a responsive anchored menu.

```dart
SuperSelectFormField<String>(
  decoration: const InputDecoration(
    labelText: 'Account type',
    hintText: 'Select a type',
    prefixIcon: Icon(SffIcons.hash),
  ),
  required: true,
  searchable: true,
  clearable: true,
  options: const [
    SuperOption(value: 'asset', label: 'Asset'),
    SuperOption(value: 'liability', label: 'Liability'),
  ],
  onChanged: (value) {},
);
```

### Multi-select

`SuperMultiSelectFormField<T>` displays selected values as removable chips and
keeps its menu open while values are toggled.

```dart
SuperMultiSelectFormField<String>(
  decoration: const InputDecoration(
    labelText: 'Permissions',
    hintText: 'Select permissions',
  ),
  options: const [
    SuperOption(value: 'post', label: 'Post entries'),
    SuperOption(value: 'approve', label: 'Approve entries'),
  ],
  minSelections: 1,
  maxSelections: 4,
  searchable: true,
  showCount: true,
);
```

`maxSelections` is a hard selection cap. The value is always `List<T>`.

### Boolean

`SuperBoolFormField` renders a toggle or checkbox. Use `decoration.hintText` or
`decoration.hint` for a fixed statement; otherwise the field displays
`enabledLabel` or `disabledLabel` according to its state.

```dart
SuperBoolFormField(
  decoration: const InputDecoration(
    labelText: 'Compliance',
    hintText: 'I confirm that the transaction was reviewed',
  ),
  style: SuperBoolStyle.checkbox,
  mustBeTrue: true,
  mustBeTrueMessage: 'Confirmation is required',
);
```

### Choice

`SuperChoiceFormField<T>` renders a small fixed option set as a segmented
control, radio list, or checkbox list.

```dart
SuperChoiceFormField<String>(
  decoration: const InputDecoration(
    labelText: 'Entry state',
    helperText: 'Choose the initial workflow state',
  ),
  style: SuperChoiceStyle.segmented,
  options: const [
    SuperOption(value: 'draft', label: 'Draft'),
    SuperOption(value: 'posted', label: 'Posted'),
  ],
);
```

Checkbox style is multi-select. Segmented and radio styles are single-select by
default. Use `multiple`, `minSelections`, and `maxSelections` to configure the
selection contract.

## Validation

A validator returns an error string or `null`:

```dart
String? positiveAmount(num? value) {
  if (value == null || value <= 0) return 'Enter an amount greater than zero';
  return null;
}
```

Pass custom validators through each field's `validators` list. Built-in rules
run first, and the first error wins. Errors become visible after touch/blur or
when `forceError` is true. `onValidity` receives the current error string.

```dart
bool forceErrors = false;
String? amountError;

SuperNumericFormField(
  decoration: const InputDecoration(labelText: 'Amount'),
  required: true,
  validators: [positiveAmount],
  forceError: forceErrors,
  onValidity: (error) => amountError = error,
);
```

## Controllers

Every field can manage its own controller or receive an external one:

| Field | Controller | Value |
|---|---|---|
| `SuperTextFormField` | `SuperTextFieldController` | `String` |
| `SuperNumericFormField` | `SuperNumericFieldController` | `num?` |
| `SuperAttachmentFormField` | `SuperAttachmentFieldController` | `List<SuperFile>` |
| `SuperDateFormField` | `SuperDateFieldController` | `DateTime?` |
| `SuperSelectFormField<T>` | `SuperSelectFieldController<T>` | `T?` |
| `SuperMultiSelectFormField<T>` | `SuperMultiSelectFieldController<T>` | `List<T>` |
| `SuperBoolFormField` | `SuperBoolFieldController` | `bool` |
| `SuperChoiceFormField<T>` | `SuperChoiceFieldController<T>` | `List<T>` |

Controllers expose imperative operations such as `setValue`, `clear`, selection
methods, and `markTouched`, while widgets remain the public presentation entry
point.

## Internationalization and directionality

Wrap Arabic content in `Directionality` and set `arabic: true` on the field:

```dart
Directionality(
  textDirection: TextDirection.rtl,
  child: SuperTextFormField(
    arabic: true,
    decoration: const InputDecoration(
      labelText: 'اسم الحساب',
      hintText: 'أدخل اسم الحساب',
    ),
  ),
);
```

Numeric and date buffers intentionally retain Western digits and LTR editing
behavior in RTL layouts.

## Migrating to 1.3.0

Version 1.3.0 replaces duplicated decoration parameters with `decoration`:

| Before | 1.3.0 |
|---|---|
| `label: 'Amount'` | `decoration: InputDecoration(labelText: 'Amount')` |
| `placeholder: '0.00'` | `decoration: InputDecoration(hintText: '0.00')` |
| `hint: 'Optional note'` | `decoration: InputDecoration(helperText: 'Optional note')` |
| `leadingIcon: SffIcons.hash` | `decoration: InputDecoration(prefixIcon: Icon(SffIcons.hash))` |
| `prefix: 'SAR'` | `decoration: InputDecoration(prefixText: 'SAR')` |
| `suffix: '%'` | `decoration: InputDecoration(suffixText: '%')` |
| boolean `title: 'I agree'` | `decoration: InputDecoration(hintText: 'I agree')` |

`FieldShell.label` and `FieldShell.hint` remain as deprecated compatibility
bridges for applications that imported the foundation widget directly. Public
form fields use only `InputDecoration` for decoration content.

## Architecture

Each feature keeps the existing package structure:

```text
lib/src/features/<feature>/
├── domain/
│   ├── entities/
│   └── usecases/
└── presentation/
    ├── controllers/
    ├── formatters/
    └── widgets/
```

The date feature keeps desktop and mobile interaction policies in separate,
pure use cases behind `DateInputUseCase<Request>`. The controller coordinates
the shared segmented state, while the mobile formatter is only a Flutter adapter
from `TextEditingValue` to a platform-neutral request. This keeps Flutter IME and
hardware-key details out of the interaction policies and avoids duplicating date
business rules.

Shared chrome, validation primitives, options, formatters, and the decoration
adapter live under `lib/src/core`. Application code should import only
`package:super_form_field/super_form_field.dart`.

## Example

Run the gallery from the package root:

```bash
cd example
flutter pub get
flutter run
```

The example includes all eight fields, light/dark switching, LTR/RTL switching,
validation flows, date formats, linked date ranges, and ERP-oriented scenarios.
