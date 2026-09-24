# super_form_field

[![Pub](https://img.shields.io/pub/v/super_form_field.svg)](https://pub.dev/packages/super_form_field)
[![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.32.0-02569B?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A Flutter form-field toolkit for ERP and business applications, built on the
GeniusLink design system. `super_form_field` provides typed inputs, shared
validation and decoration behavior, responsive interaction, controller support,
light/dark themes, and English/Arabic layouts.

The package keeps form controls visually and behaviorally consistent through a
shared `FormFieldShell`/field foundation while still exposing typed APIs for
text, numeric, date, selection, attachment, OTP, boolean, choice, dropdown, and
popup-menu workflows.

<details>
<summary>Table of contents</summary>

<!-- TOC -->
- [Features](#features)
- [Get started](#get-started)
  - [Install](#install)
  - [App setup](#app-setup)
  - [Quick start](#quick-start)
- [Fields](#fields)
  - [Text](#text)
  - [OTP](#otp)
  - [Numeric](#numeric)
  - [Attachment](#attachment)
  - [Date](#date)
  - [Date range](#date-range)
  - [Single select](#single-select)
  - [Multi-select](#multi-select)
  - [Boolean](#boolean)
  - [Choice](#choice)
  - [Dropdown and popup menu](#dropdown-and-popup-menu)
- [Select sources](#select-sources)
  - [Local source](#local-source)
  - [Async source](#async-source)
  - [Multi-select sources](#multi-select-sources)
- [Input decoration and field shell](#input-decoration-and-field-shell)
- [Validation and Form integration](#validation-and-form-integration)
- [Controllers](#controllers)
- [Desktop keyboard and focus behavior](#desktop-keyboard-and-focus-behavior)
- [Responsive behavior](#responsive-behavior)
- [Localization and RTL](#localization-and-rtl)
- [Advanced public API](#advanced-public-api)
- [Examples](#examples)
- [Documentation](#documentation)
<!-- TOC -->
</details>

## Features

- Unified `InputDecoration` behavior across form fields.
- Shared `FormFieldShell` layout for labels, helpers, validation, and field
  geometry.
- Typed values and dedicated controllers.
- Built-in required, range, length, format, and selection validation.
- Material `FormState.validate()` and `FormState.save()` integration on editable
  typed fields.
- Text masks through `mask_text_input_formatter`.
- Segmented OTP/PIN input with paste and one-time-code autofill.
- Grouped numeric display, precision rules, stepping, and keyboard shortcuts.
- Responsive date and date-range interaction.
- Searchable single-select and multi-select controls.
- Raw-value local and async source APIs for select fields.
- Debounced external queries while locally available values remain immediately
  searchable.
- Picker-agnostic attachment input.
- Design-system dropdown buttons and popup action menus.
- Single-stop desktop focus traversal for composite input fields.
- Light/dark themes through `super_core`.
- English and Arabic localization with LTR/RTL support.

## Get started

### Install

Add the package:

```bash
flutter pub add super_form_field
```

Or add it manually:

```yaml
dependencies:
  super_form_field: ^1.15.0
```

Import the public barrel:

```dart
import 'package:super_form_field/super_form_field.dart';
```

Application code should normally import only this file. It exports the public
fields, controllers, source APIs, shared value types, localization helpers, and
design-system foundations intended for package consumers.

### App setup

Use the GeniusLink material theme and register the package localizations:

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
    final textTheme = SuperTextTheme();

    return MaterialApp(
      theme: SuperMaterialThemeData.light(
        textTheme: textTheme,
        primaryTextTheme: textTheme,
      ),
      darkTheme: SuperMaterialThemeData.dark(
        textTheme: textTheme,
        primaryTextTheme: textTheme,
      ),
      themeMode: ThemeMode.system,
      localizationsDelegates: SuperFormLocalizations.localizationsDelegates,
      supportedLocales: SuperFormLocalizations.supportedLocales,
      home: const CustomerFormPage(),
    );
  }
}
```

### Quick start

```dart
class CustomerFormPage extends StatefulWidget {
  const CustomerFormPage({super.key});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = SuperTextFieldController();
  final _type = SuperSelectFieldController<String>();

  @override
  void dispose() {
    _name.dispose();
    _type.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          SuperTextFormField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Customer name',
              hintText: 'Enter a name',
            ),
            required: true,
            minLength: 3,
          ),
          const SizedBox(height: 16),
          SuperSelectFormField<String>(
            controller: _type,
            decoration: const InputDecoration(
              labelText: 'Customer type',
              hintText: 'Select a type',
            ),
            required: true,
            source: SuperSelectSources.list(
              ['retail', 'wholesale', 'government'],
            ),
            optionBuilder: (items, index, value) => SuperOption(
              value: value,
              label: value,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
```

## Fields

### Text

`SuperTextFormField` supports normal text, email, phone, password, multiline,
masking, counters, clear actions, autofill, formatters, and typed form saving.

```dart
SuperTextFormField(
  decoration: const InputDecoration(
    labelText: 'Reference',
    hintText: 'INV-0001',
  ),
  required: true,
  maxLength: 20,
);
```

For masked input:

```dart
SuperTextFormField(
  decoration: const InputDecoration(labelText: 'Phone'),
  type: SuperTextType.phone,
  mask: '+967 ## ### ####',
  onUnmaskedChanged: (value) {
    // Raw placeholder characters only.
  },
);
```

### OTP

`SuperOTPFormField` uses one real editor behind segmented cells, preserving
desktop typing, paste, one-time-code autofill, validation, and form saving.

```dart
SuperOTPFormField(
  decoration: const InputDecoration(labelText: 'Verification code'),
  length: 6,
  required: true,
  autofillHints: const [AutofillHints.oneTimeCode],
  onCompleted: (code) {},
);
```

### Numeric

`SuperNumericFormField` supports grouped display values, decimal precision,
range validation, negative values, stepping, and keyboard shortcuts.

```dart
SuperNumericFormField(
  decoration: const InputDecoration(labelText: 'Amount'),
  required: true,
  decimals: 2,
  min: 0,
  max: 1000000,
  step: 1,
);
```

`stepper` is responsive when omitted: it is hidden on mobile and shown on
tablet/desktop. Set `stepper: true` or `stepper: false` to override that
behavior. Increment/decrement actions remain part of the field interaction
without becoming additional desktop Tab stops.

### Attachment

`SuperAttachmentFormField` is picker-agnostic. The host application provides
the browse/drop integration and the field manages typed `SuperFile` values,
validation, and presentation.

```dart
SuperAttachmentFormField(
  decoration: const InputDecoration(
    labelText: 'Supporting documents',
    hintText: 'Browse or drop files',
  ),
  accept: '.pdf,.docx',
  maxFiles: 5,
  maxSizeMB: 10,
  onBrowse: () async {
    return <SuperFile>[];
  },
);
```

### Date

`SuperDateFormField` provides segmented editing, configurable formats, min/max
validation, keyboard navigation, and a responsive calendar surface.

```dart
SuperDateFormField(
  decoration: const InputDecoration(labelText: 'Posting date'),
  format: SuperDateFormat.yearMonthDay,
  minDate: DateTime(2026, 1, 1),
  maxDate: DateTime(2026, 12, 31),
  required: true,
);
```

### Date range

`SuperRangeDateFormField` manages a typed `SuperDateRange` with configurable
boundaries and responsive range picking.

```dart
SuperRangeDateFormField(
  decoration: const InputDecoration(labelText: 'Reporting period'),
  required: true,
  minDate: DateTime(2026, 1, 1),
  maxDate: DateTime(2026, 12, 31),
);
```

### Single select

`SuperSelectFormField<T>` consumes one raw-value `SuperSelectSource<T>`. The
source owns data acquisition; `optionBuilder` owns display/search metadata.

```dart
SuperSelectFormField<String>(
  decoration: const InputDecoration(labelText: 'Account type'),
  searchable: true,
  source: SuperSelectSources.list(
    ['asset', 'liability', 'equity', 'income', 'expense'],
  ),
  optionBuilder: (items, index, value) => SuperOption(
    value: value,
    label: value,
  ),
);
```

### Multi-select

`SuperMultiSelectFormField<T>` follows the same source model while returning a
typed `List<T>` and rendering selected values as removable chips.

```dart
SuperMultiSelectFormField<String>(
  decoration: const InputDecoration(labelText: 'Permissions'),
  searchable: true,
  source: SuperMultiSelectSources.list(
    ['read', 'create', 'update', 'delete'],
  ),
  optionBuilder: (items, index, value) => SuperOption(
    value: value,
    label: value,
  ),
  minSelections: 1,
  maxSelections: 3,
);
```

### Boolean

`SuperBoolFormField` renders a toggle or checkbox and supports `mustBeTrue` for
acknowledgement/compliance flows.

```dart
SuperBoolFormField(
  decoration: const InputDecoration(labelText: 'Confirmation'),
  style: SuperBoolStyle.checkbox,
  mustBeTrue: true,
);
```

### Choice

`SuperChoiceFormField<T>` is designed for small fixed option sets. It supports
segmented, radio, and checkbox presentation.

```dart
SuperChoiceFormField<String>(
  decoration: const InputDecoration(labelText: 'Status'),
  style: SuperChoiceStyle.segmented,
  options: const [
    SuperOption(value: 'draft', label: 'Draft'),
    SuperOption(value: 'posted', label: 'Posted'),
  ],
);
```

### Dropdown and popup menu

Use `SuperDropdownButton<T>` for lightweight typed selection,
`SuperDropdownButtonFormField<T>` when a dropdown must participate directly in
a `Form`, and `SuperPopupMenuButton<T>` for anchored action menus.

```dart
SuperDropdownButton<String>(
  decoration: const InputDecoration(hintText: 'Select status'),
  options: const [
    SuperOption(value: 'active', label: 'Active'),
    SuperOption(value: 'inactive', label: 'Inactive'),
  ],
  onChanged: (value) {},
);
```

## Select sources

Version `1.15.0` exposes source APIs for single-select and multi-select
fields in the same data/presentation separation style used by
`SuperAutoSuggestionsBox`:

- the widget receives one source;
- the source returns raw `T` values;
- `optionBuilder` maps raw values to `SuperOption<T>`;
- local values are available immediately;
- debounce applies only to asynchronous/external queries.

### Local source

```dart
final source = SuperSelectSources.list<String>(
  ['Cash', 'Bank', 'Inventory'],
);
```

For strings, the shorter convenience factory is also available:

```dart
final source = SuperSelectSources.strings(
  ['Cash', 'Bank', 'Inventory'],
);
```

The source stays presentation-free:

```dart
SuperSelectFormField<String>(
  source: source,
  optionBuilder: (items, index, value) => SuperOption(
    value: value,
    label: value,
  ),
);
```

### Async source

The async callback receives the active field `BuildContext` and the current
search query:

```dart
final source = SuperSelectSources.async<Warehouse>(
  (context, query) => repository.searchWarehouses(query),
  initialItems: cachedWarehouses,
);
```

Use it with field-level query controls:

```dart
SuperSelectFormField<Warehouse>(
  searchable: true,
  debounce: const Duration(milliseconds: 300),
  minChars: 2,
  source: source,
  optionBuilder: (items, index, warehouse) => SuperOption(
    value: warehouse,
    label: warehouse.name,
    description: warehouse.code,
  ),
);
```

`debounce` delays only asynchronous source work. Values already present in
`initialItems` or the source cache remain available to the menu immediately.

`minChars` prevents an external query until the trimmed search text reaches the
configured length.

### Multi-select sources

The same factories are available through `SuperMultiSelectSources`:

```dart
final source = SuperMultiSelectSources.async<User>(
  (context, query) => repository.searchUsers(query),
  initialItems: cachedUsers,
);

SuperMultiSelectFormField<User>(
  searchable: true,
  source: source,
  optionBuilder: (items, index, user) => SuperOption(
    value: user,
    label: user.name,
    description: user.email,
  ),
);
```

## Input decoration and field shell

Public fields use `InputDecoration` for content-level configuration:

```dart
SuperTextFormField(
  decoration: const InputDecoration(
    labelText: 'Reference',
    hintText: 'Enter a reference',
    helperText: 'Visible in reports',
    prefixIcon: Icon(Icons.tag_outlined),
    suffixText: 'ERP',
  ),
);
```

The package retains ownership of field geometry, borders, fill, focus state,
disabled/read-only treatment, and validation placement so different field types
stay visually consistent.

`FormFieldShell` is the shared outer layout used for label, helper, error,
fixed-state, and field-content composition. Composite fields use the same
foundation rather than implementing independent shell geometry.

### Validation position

Validated fields support:

| Value | Behavior |
| --- | --- |
| `ValidationPosition.suffixIcon` | Error badge inside the field suffix |
| `ValidationPosition.underBox` | Error text below the field |
| `ValidationPosition.labelTrailing` | Error badge at the end of the label row |

When no field-level position is provided, the package can use
`SuperFormField.validationPosition`; otherwise the responsive fallback is
under-box on mobile and label-trailing on larger layouts.

```dart
SuperFormField.validationPosition = ValidationPosition.suffixIcon;
```

## Validation and Form integration

Custom validators return an error string or `null`:

```dart
String? positiveAmount(num? value) {
  if (value == null || value <= 0) {
    return 'Enter an amount greater than zero';
  }
  return null;
}
```

```dart
SuperNumericFormField(
  decoration: const InputDecoration(labelText: 'Amount'),
  required: true,
  validators: [positiveAmount],
);
```

Built-in validation runs before custom validators and the first error wins.

Editable typed fields participate in Flutter `Form`:

```dart
final formKey = GlobalKey<FormState>();

Form(
  key: formKey,
  child: SuperSelectFormField<String>(
    source: SuperSelectSources.strings(['Cash', 'Bank']),
    optionBuilder: (items, index, value) =>
        SuperOption(value: value, label: value),
    required: true,
    onSaved: (value) {
      // Save the typed selection.
    },
  ),
);

// Later:
formKey.currentState!.validate();
formKey.currentState!.save();
```

## Controllers

Use an external controller when the application needs imperative access.
Otherwise, fields can manage controllers internally.

| Field | Controller | Value |
| --- | --- | --- |
| `SuperTextFormField` | `SuperTextFieldController` | `String` |
| `SuperOTPFormField` | `SuperOTPFieldController` | `String` |
| `SuperNumericFormField` | `SuperNumericFieldController` | `num?` |
| `SuperAttachmentFormField` | `SuperAttachmentFieldController` | `List<SuperFile>` |
| `SuperDateFormField` | `SuperDateFieldController` | `DateTime?` |
| `SuperRangeDateFormField` | `SuperRangeDateFieldController` | `SuperDateRange?` |
| `SuperSelectFormField<T>` | `SuperSelectFieldController<T>` | `T?` |
| `SuperMultiSelectFormField<T>` | `SuperMultiSelectFieldController<T>` | `List<T>` |
| `SuperBoolFormField` | `SuperBoolFieldController` | `bool` |
| `SuperChoiceFormField<T>` | `SuperChoiceFieldController<T>` | `List<T>` |

Example:

```dart
final amount = SuperNumericFieldController(initialValue: 100);

SuperNumericFormField(
  controller: amount,
  decoration: const InputDecoration(labelText: 'Amount'),
);

// Read or update through the controller.
final current = amount.value;
amount.setValue(250);
```

Dispose externally owned controllers when their owner is disposed.

## Desktop keyboard and focus behavior

Composite inputs behave as one logical form field in desktop/web focus
traversal. A single `Tab` moves from the active editor/trigger to the next form
field; internal prefix, suffix, clear, calendar, stepper, help, and fixed-state
actions do not consume an extra normal traversal stop.

Typical flow:

```text
previous field
    |
   Tab
    v
current super_form_field
    |
   Tab
    v
next field
```

Interactive internal actions remain clickable. `Shift + Tab` performs reverse
traversal in one step.

Select controls keep keyboard interaction on their main trigger. Searchable
menus use their search editor after the menu is opened.

## Responsive behavior

Field sizing and interaction adapt to the active GeniusLink device mode.

Common field densities:

- `FieldDensity.comfortable`
- `FieldDensity.compact`

Date and range-date controls use mobile-friendly sheets/pickers on compact
devices and anchored desktop/tablet interactions on larger layouts.

Select and multi-select menus keep local items responsive while async search
work follows `debounce` and `minChars`.

## Localization and RTL

Register:

```dart
localizationsDelegates: SuperFormLocalizations.localizationsDelegates,
supportedLocales: SuperFormLocalizations.supportedLocales,
```

The package includes English and Arabic strings and supports LTR/RTL field
layout. Explicit strings supplied by the application continue to take
precedence over package defaults where the relevant API allows them.

## Advanced public API

The public barrel exposes shared building blocks for custom design-system
controls.

| API | Purpose |
| --- | --- |
| `SuperOption<T>` | Typed option metadata |
| `SuperFile` | Platform-neutral attachment metadata |
| `Validator<T>` | Typed custom validation callback |
| `ValidationPosition` | Validation surface placement |
| `FieldDensity` | Compact/comfortable density |
| `FormFieldShell` | Shared label/helper/error/fixed-state shell |
| `FieldBox` | Shared bordered field container |
| `FieldIconButton` | In-field icon action |
| `FieldPopover` | Anchored responsive popover |
| `OptionMenu` / `OptionTile` | Option-driven menu primitives |
| `MenuSearchField` | Search editor for option menus |
| `SuperChip` | Removable selected-value chip |
| `ErrorBadge` | Compact tooltip-backed error indicator |
| `SuperFormLocalizations` | Localization registration helpers |

Prefer the high-level fields for normal application forms. Use these foundations
when building a custom control that must match the package's geometry and theme.

## Examples

The package includes an example gallery covering the field types, controllers,
validation modes, source strategies, LTR/RTL behavior, and light/dark themes.

```bash
cd example
flutter run
```

See the [`example`](example) directory for source code.

## Documentation

- [API documentation](https://pub.dev/documentation/super_form_field/latest/)
- [Package page](https://pub.dev/packages/super_form_field)
- [Homepage](https://geniussystems24.github.io/super_form_field)
- [Repository](https://github.com/GeniusSystems24/super_form_field)
- [Issue tracker](https://github.com/GeniusSystems24/super_form_field/issues)
- [Changelog](CHANGELOG.md)
- [License](LICENSE)

Current package version: `1.15.0`.
