# super_form_field

A Flutter form-field toolkit for ERP and business applications, built on the
GeniusLink design system. It provides consistent decoration, validation,
responsive interaction, controller support, light and dark themes, and English
and Arabic layouts.

The package includes:

- `SuperTextFormField`
- `SuperNumericFormField`
- `SuperAttachmentFormField`
- `SuperDateFormField`
- `SuperSelectFormField<T>`
- `SuperMultiSelectFormField<T>`
- `SuperBoolFormField`
- `SuperChoiceFormField<T>`

## Features

- One `InputDecoration` contract across all fields.
- Typed values and dedicated controllers for every field.
- Built-in required, range, length, format, and selection validation.
- Custom validators with first-error-wins behavior.
- Validation errors displayed through compact error badges and tooltips.
- Responsive date input for mobile, tablet, and desktop.
- Searchable single-select and multi-select menus.
- Picker-agnostic file attachments.
- Light and dark theme support through `super_core`.
- English and Arabic package localizations.
- LTR and RTL layout support.

## Requirements

| Dependency | Minimum version |
|---|---:|
| Dart | `3.8.0` |
| Flutter | `3.32.0` |
| `super_core` | `3.0.0` |

## Installation

Add the package with Flutter:

```bash
flutter pub add super_form_field
```

Or add it manually to `pubspec.yaml`:

```yaml
dependencies:
  super_form_field: ^1.5.1
```

Import the public library:

```dart
import 'package:super_form_field/super_form_field.dart';
```

Application code should normally import only this barrel file. It exports the
form fields, their controllers, shared value types, localization helpers, and
the required `super_core` design-system APIs.

## App setup

Use `SuperMaterialThemeData` and register the package localization delegates at
the application root:

```dart
import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: SuperMaterialThemeData.light(),
      darkTheme: SuperMaterialThemeData.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates:
          SuperFormLocalizations.localizationsDelegates,
      supportedLocales: SuperFormLocalizations.supportedLocales,
      home: const AccountFormPage(),
    );
  }
}
```

All controls read their colors, typography, spacing, sizing, and interaction
tokens from the active `SuperThemeData` supplied by `super_core`.

## Quick start

```dart
class AccountFormPage extends StatefulWidget {
  const AccountFormPage({super.key});

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final _nameController = SuperTextFieldController();
  final _typeController = SuperSelectFieldController<String>();

  bool _forceErrors = false;
  String? _nameError;
  String? _typeError;

  bool get _isValid => _nameError == null && _typeError == null;

  void _submit() {
    setState(() => _forceErrors = true);

    if (!_isValid) return;

    final name = _nameController.value;
    final type = _typeController.value;

    // Send name and type to the application layer.
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SuperTextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Account name',
              hintText: 'Enter the account name',
            ),
            required: true,
            minLength: 3,
            forceError: _forceErrors,
            onValidity: (error) => _nameError = error,
          ),
          const SizedBox(height: 20),
          SuperSelectFormField<String>(
            controller: _typeController,
            decoration: const InputDecoration(
              labelText: 'Account type',
              hintText: 'Select a type',
            ),
            required: true,
            searchable: true,
            options: const [
              SuperOption(value: 'asset', label: 'Asset'),
              SuperOption(value: 'liability', label: 'Liability'),
              SuperOption(value: 'equity', label: 'Equity'),
            ],
            forceError: _forceErrors,
            onValidity: (error) => _typeError = error,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submit,
            child: const Text('Create account'),
          ),
        ],
      ),
    );
  }
}
```

## Input decoration

Every public field accepts `decoration`. Use it as the single source for labels,
hints, helper text, icons, prefixes, suffixes, counters, and external errors.

```dart
SuperTextFormField(
  decoration: const InputDecoration(
    labelText: 'Reference',
    hintText: 'Enter a reference',
    helperText: 'Visible in reports',
    prefixIcon: Icon(SffIcons.hash),
    suffixText: 'ERP',
  ),
);
```

| `InputDecoration` property | Package behavior |
|---|---|
| `label` / `labelText` | External field label |
| `hint` / `hintText` | Empty-value prompt or field statement |
| `helper` / `helperText` | Supporting content below the control |
| `icon`, `prefixIcon`, `prefix`, `prefixText` | Leading adornments |
| `suffix`, `suffixText`, `suffixIcon` | Trailing adornments |
| `counter` / `counterText` | Counter content where supported |
| `errorText` | External error displayed through the package error badge |

The package keeps ownership of field geometry, borders, fill, focus states,
disabled states, and error presentation so all field types remain visually
consistent. Use `errorText` for an external string error. The widget form of
`InputDecoration.error` is not adapted because the package error surface
requires a message for its tooltip.

## Fields

### Text field

`SuperTextFormField` supports regular text, email, password, and multiline
input.

```dart
SuperTextFormField(
  decoration: const InputDecoration(
    labelText: 'Email address',
    hintText: 'name@example.com',
    prefixIcon: Icon(SffIcons.mail),
  ),
  type: SuperTextType.email,
  required: true,
  clearable: true,
  maxLength: 120,
);
```

Common options:

- `type`: `text`, `email`, or `password`.
- `multiline` and `rows` for long-form input.
- `minLength`, `maxLength`, `pattern`, and `patternMessage`.
- `showCounter`, `clearable`, and `autofocus`.
- `disabled`, `readOnly`, `arabic`, and `forceError`.

### Numeric field

`SuperNumericFormField` supports grouped display values, decimal precision,
range validation, negative-value control, keyboard shortcuts, and an optional
stepper.

```dart
SuperNumericFormField(
  decoration: const InputDecoration(
    labelText: 'Amount',
    hintText: '0.00',
    prefixText: 'SAR',
  ),
  required: true,
  decimals: 2,
  min: 0,
  max: 1000000,
  step: 0.25,
  largeStep: 100,
);
```

While focused, Arrow Up and Arrow Down change the value by `step`. Page Up and
Page Down use `largeStep`, or `step * 10` when `largeStep` is not supplied. Set
`keyboardShortcuts: false` or `stepper: false` when those interactions are not
needed.

### Attachment field

`SuperAttachmentFormField` renders an attachment drop zone and a validated list
of `SuperFile` values. File acquisition remains the responsibility of the host
application, so the package does not depend on a picker plugin.

```dart
SuperAttachmentFormField(
  decoration: const InputDecoration(
    labelText: 'Supporting documents',
    hintText: 'Browse or drop files here',
    helperText: 'PDF and DOCX files only',
    prefixIcon: Icon(SffIcons.uploadCloud),
  ),
  required: true,
  accept: '.pdf,.docx',
  maxSizeMB: 10,
  maxFiles: 5,
  onBrowse: () async {
    // Use file_picker, image_picker, or an application service here.
    return <SuperFile>[];
  },
);
```

A `SuperFile` carries platform-neutral metadata:

```dart
final file = SuperFile(
  id: 'invoice-42',
  name: 'invoice.pdf',
  size: 245760,
  mimeType: 'application/pdf',
  path: '/local/path/invoice.pdf',
);
```

For desktop drag-and-drop adapters, pass an external
`SuperAttachmentFieldController` and call `setDragOver`, `add`, `remove`, or
`clear` from the host integration.

### Date field

`SuperDateFormField` provides segmented date editing, configurable formats,
range validation, keyboard navigation, and a responsive calendar picker.

```dart
SuperDateFormField(
  decoration: const InputDecoration(
    labelText: 'Posting date',
    helperText: 'Must be inside the open fiscal period',
  ),
  required: true,
  format: SuperDateFormat.yearMonthDay,
  minDate: DateTime(2026, 1, 1),
  maxDate: DateTime(2026, 12, 31),
  clearable: true,
);
```

Available formats:

| Value | Display |
|---|---|
| `SuperDateFormat.yearMonthDay` | `YYYY-MM-DD` |
| `SuperDateFormat.yearMonth` | `YYYY-MM` |
| `SuperDateFormat.year` | `YYYY` |
| `SuperDateFormat.monthDay` | `MM-DD` |
| `SuperDateFormat.month` | `MM` |
| `SuperDateFormat.day` | `DD` |

On mobile, the calendar opens in a modal bottom sheet and segmented editing is
adapted for software keyboards. Tablet and desktop use an anchored popover with
hardware-key navigation. Set `calendar: false` or `keyboardShortcuts: false` to
disable those behaviors.

The leading calendar icon is used when no leading decoration is supplied. Use
`prefixIcon` to replace it, or `prefixIcon: SizedBox.shrink()` to suppress it.

### Select field

`SuperSelectFormField<T>` is a typed single-select control with optional search,
clear behavior, disabled options, descriptions, icons, and option groups.

```dart
SuperSelectFormField<int>(
  decoration: const InputDecoration(
    labelText: 'Parent account',
    hintText: 'Select an account',
  ),
  searchable: true,
  clearable: true,
  options: const [
    SuperOption(
      value: 1000,
      label: 'Cash',
      description: 'Current assets',
      icon: SffIcons.hash,
      group: 'Assets',
    ),
    SuperOption(
      value: 2000,
      label: 'Accounts payable',
      group: 'Liabilities',
    ),
  ],
  onChanged: (accountId) {},
);
```

Search matches both `label` and `description`, without case sensitivity.

### Multi-select field

`SuperMultiSelectFormField<T>` displays selected values as removable chips and
keeps the options menu open while values are toggled.

```dart
SuperMultiSelectFormField<String>(
  decoration: const InputDecoration(
    labelText: 'Permissions',
    hintText: 'Select permissions',
  ),
  searchable: true,
  required: true,
  minSelections: 1,
  maxSelections: 4,
  showCount: true,
  options: const [
    SuperOption(value: 'read', label: 'Read'),
    SuperOption(value: 'create', label: 'Create'),
    SuperOption(value: 'update', label: 'Update'),
    SuperOption(value: 'delete', label: 'Delete'),
  ],
  onChanged: (permissions) {},
);
```

`maxSelections` is enforced as a hard selection cap. The field value is always
`List<T>`.

### Boolean field

`SuperBoolFormField` renders either a toggle or a checkbox. Use `mustBeTrue` for
acknowledgement and compliance gates.

```dart
SuperBoolFormField(
  decoration: const InputDecoration(
    labelText: 'Confirmation',
    hintText: 'I confirm that this entry was reviewed',
  ),
  style: SuperBoolStyle.checkbox,
  mustBeTrue: true,
  mustBeTrueMessage: 'Confirmation is required',
);
```

When `decoration.hint` and `decoration.hintText` are absent, the control shows
`enabledLabel` or `disabledLabel` according to its current value.

### Choice field

`SuperChoiceFormField<T>` renders a small fixed option set inline as a segmented
control, radio list, or checkbox list.

```dart
SuperChoiceFormField<String>(
  decoration: const InputDecoration(
    labelText: 'Entry status',
    helperText: 'Choose the initial workflow state',
  ),
  style: SuperChoiceStyle.segmented,
  options: const [
    SuperOption(value: 'draft', label: 'Draft'),
    SuperOption(value: 'posted', label: 'Posted'),
  ],
  onChanged: (values) {},
);
```

Use:

- `SuperChoiceStyle.segmented` for two to four short options.
- `SuperChoiceStyle.radio` for a single selection from a longer inline list.
- `SuperChoiceStyle.checkbox` with `multiple: true` for multiple selections.

The value is always `List<T>`. For single-select use, read the first value or use
`SuperChoiceFieldController<T>.single`.

## Options

`SuperOption<T>` separates the displayed label from the domain value:

```dart
const option = SuperOption<String>(
  value: 'asset',
  label: 'Asset',
  description: 'Resources controlled by the business',
  icon: SffIcons.hash,
  group: 'Balance sheet',
);
```

Use `disabled: true` to keep an option visible but unavailable. For simple
value-to-label mappings, use `SuperOption.fromMap`:

```dart
final options = SuperOption.fromMap<int>({
  1: 'Cash',
  2: 'Bank',
  3: 'Inventory',
});
```

## Validation

A validator returns an error message or `null`:

```dart
String? positiveAmount(num? value) {
  if (value == null || value <= 0) {
    return 'Enter an amount greater than zero';
  }
  return null;
}
```

Pass custom validators through `validators`:

```dart
SuperNumericFormField(
  decoration: const InputDecoration(labelText: 'Amount'),
  required: true,
  validators: [positiveAmount],
  onValidity: (error) {
    // error is null when the field is valid.
  },
);
```

Built-in validators run before custom validators, and the first error wins.
Errors remain visually quiet until the field is touched, unless `forceError` is
true. `onValidity` reports the current raw error whenever it changes.

The validation API is intentionally controller- and callback-based. These
widgets do not rely on `FormState.validate()`. Aggregate field errors in the
screen controller, state object, Bloc, Cubit, or other presentation-state layer
used by the application.

## Controllers

Each widget can create and dispose its own controller, or receive an external
controller when imperative access is required.

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

Example:

```dart
class ControlledAmountField extends StatefulWidget {
  const ControlledAmountField({super.key});

  @override
  State<ControlledAmountField> createState() =>
      _ControlledAmountFieldState();
}

class _ControlledAmountFieldState extends State<ControlledAmountField> {
  final _controller = SuperNumericFieldController(initialValue: 100);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SuperNumericFormField(
          controller: _controller,
          decoration: const InputDecoration(labelText: 'Amount'),
          decimals: 2,
        ),
        TextButton(
          onPressed: () => _controller.setValue(0),
          child: const Text('Reset amount'),
        ),
      ],
    );
  }
}
```

External controllers must be disposed by the owner that created them.

Common imperative operations include:

| Controller | Common operations |
|---|---|
| `SuperTextFieldController` | `setValue`, `clear`, `markTouched`, `toggleObscure` |
| `SuperNumericFieldController` | `setValue`, `bump`, `bumpLarge` |
| `SuperAttachmentFieldController` | `add`, `remove`, `clear`, `setDragOver` |
| `SuperDateFieldController` | `setValue`, `pick`, `clear`, `markTouched` |
| `SuperSelectFieldController<T>` | `select`, `setValue`, `clear`, `markTouched` |
| `SuperMultiSelectFieldController<T>` | `toggle`, `removeValue`, `setValues`, `clear` |
| `SuperBoolFieldController` | `set`, `setValue`, `toggle`, `markTouched` |
| `SuperChoiceFieldController<T>` | `pick`, `setValues`, `setSingle`, `clear` |

## Localization and RTL

The package includes English and Arabic strings for built-in validation
messages, search and empty states, attachment actions, numeric controls,
boolean captions, and calendar content.

Register the delegates once:

```dart
MaterialApp(
  locale: const Locale('ar'),
  localizationsDelegates:
      SuperFormLocalizations.localizationsDelegates,
  supportedLocales: SuperFormLocalizations.supportedLocales,
  theme: SuperMaterialThemeData.light(),
  darkTheme: SuperMaterialThemeData.dark(),
  home: const ArabicFormPage(),
);
```

Use normal Flutter directionality and set `arabic: true` when the field should
use the package's Arabic typography behavior:

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

Application-owned labels, option text, helper text, and custom validation
messages are not translated automatically. Numeric and segmented date editing
retain Western digits and LTR editing behavior inside RTL layouts.

## Responsive behavior

Most visual sizing comes from the active `SuperThemeData` and its
`SuperDeviceMode`. The date field also changes its interaction model:

| Device mode | Date interaction |
|---|---|
| Mobile | Software-keyboard-safe segmented editing and modal bottom-sheet calendar |
| Tablet | Hardware-key segmented editing and anchored calendar popover |
| Desktop | Hardware-key navigation, stepping shortcuts, and anchored calendar popover |

Use `FieldDensity` on supported fields when the screen requires a denser or more
comfortable control layout.

## Advanced public API

The main barrel also exports lower-level building blocks for custom controls.
Prefer the eight form-field widgets for normal application screens.

### Shared values and helpers

| API | Purpose |
|---|---|
| `SuperOption<T>` | Typed option descriptor for select and choice fields |
| `SuperFile` | Platform-neutral attachment descriptor |
| `Validator<T>` | Custom validation callback type |
| `ValidityChanged` | Validation-state callback type |
| `FieldDensity` | Shared compact or comfortable field-density setting |
| `SuperFormLocalizations` | Supported locales and localization delegates |
| `SuperFormTranslation` | Generated package translation lookup |
| `SffIcons` | Package icon vocabulary |
| `SuperFieldContextX` | `context.sffTheme` and `context.sffColorScheme` |

### Field foundation

| API | Purpose |
|---|---|
| `FieldShell` | External label, helper, counter, and field layout |
| `FieldBox` | Bordered shell for composed custom controls |
| `FieldIconButton` | Design-system icon action used inside fields |
| `FieldPopover` | Anchored responsive popover surface |
| `OptionMenu` | Menu container for option-driven controls |
| `OptionTile` | Selectable option row |
| `OptionGroupHeader` | Group label inside an option menu |
| `MenuSearchField` | Search input for option menus |
| `SuperChip` | Removable selected-value chip |
| `CountPill` | Compact count indicator |
| `ErrorBadge` | Tooltip-based validation error indicator |

### Pure logic and date interaction

The package exports pure logic helpers such as `DateLogic`, `NumericLogic`,
`SelectLogic`, `MultiSelectLogic`, `ChoiceLogic`, and `AttachmentLogic` for unit
testing or advanced integrations. It also exports `DateInputIntent`,
`DesktopDateInputUseCase`, `MobileDateInputUseCase`, and `MiniCalendar` for
custom date-input adapters.

## Example application

Run the included gallery from the package root:

```bash
cd example
flutter pub get
flutter run
```

The gallery demonstrates all eight fields, controller-driven values, validation
flows, date formats, linked ranges, light and dark themes, and LTR and RTL
layouts.

## Additional information

- [Repository](https://github.com/GeniusSystems24/super_form_field)
- [Issue tracker](https://github.com/GeniusSystems24/super_form_field/issues)
- [Changelog](CHANGELOG.md)
- [License](LICENSE)

This package is licensed under the MIT License.
