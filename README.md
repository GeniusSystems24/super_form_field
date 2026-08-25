# super_form_field

A Flutter form-field toolkit for ERP and business applications, built on the
GeniusLink design system. It provides consistent decoration, validation,
responsive interaction, controller support, light and dark themes, and English
and Arabic layouts.

The package includes:

- `SuperTextFormField`
- `SuperOTPFormField`
- `SuperNumericFormField`
- `SuperAttachmentFormField`
- `SuperDateFormField`
- `SuperRangeDateFormField`
- `SuperSelectFormField<T>`
- `SuperMultiSelectFormField<T>`
- `SuperBoolFormField`
- `SuperChoiceFormField<T>`
- `SuperDropdownButton<T>`
- `SuperDropdownButtonFormField<T>`
- `SuperPopupMenuButton<T>`

## Features

- One `InputDecoration` contract across all fields.
- Typed values and dedicated controllers for every field.
- Built-in required, range, length, format, and selection validation.
- Declarative text masks powered by `mask_text_input_formatter`.
- Segmented OTP/PIN input with paste, SMS autofill, and completion callbacks.
- Custom validators with first-error-wins behavior.
- Validation errors displayed through compact error badges and tooltips.
- Responsive date input for mobile, tablet, and desktop.
- Responsive two-calendar date-range selection with configurable presets.
- Searchable single-select and multi-select menus.
- Design-system dropdown buttons and anchored popup action menus.
- Picker-agnostic file attachments.
- Light and dark theme support through `super_core`.
- English and Arabic package localizations.
- LTR and RTL layout support.

## Requirements

| Dependency | Minimum version |
|---|---:|
| Dart | `3.8.0` |
| Flutter | `3.32.0` |
| `super_core` | `3.6.0` |
| `mask_text_input_formatter` | `2.9.0` |

## Installation

Add the package with Flutter:

```bash
flutter pub add super_form_field
```

Or add it manually to `pubspec.yaml`:

```yaml
dependencies:
  super_form_field: ^1.11.0+1
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
    final textTheme = SuperTextTheme();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: SuperMaterialThemeData.light(
        textTheme: textTheme,
        primaryTextTheme: textTheme,
      ),
      darkTheme: SuperMaterialThemeData.dark(
        textTheme: textTheme,
        primaryTextTheme: textTheme,
      ),
      themeMode: ThemeMode.system,
      localizationsDelegates:
          SuperFormLocalizations.localizationsDelegates,
      supportedLocales: SuperFormLocalizations.supportedLocales,
      home: const AccountFormPage(),
    );
  }
}
```

All controls read colors, spacing, sizing, and interaction tokens from the
active `SuperThemeData`. Typography is read separately from the required
`SuperTextTheme` installed on `SuperMaterialThemeData` by `super_core` 3.6.0.
Normal field styles preserve the font families carried by `SuperTextTheme`;
they no longer overwrite them with `SuperTokensData.bodyFont` / `monoFont`.

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

## Material-compatible input behavior

The text, OTP, numeric, date, select, and multi-select fields expose the useful
Material editing controls that apply to their input model:

- `keyboardType`, `inputFormatters`, `textDirection`, `textInputAction`,
  `textCapitalization`, and `keyboardAppearance`.
- `onFieldSubmitted`, `onEditingComplete`, `onTap`, `onTapOutside`, and
  `onTapUpOutside`.
- Autofill, cursor/selection behavior, context menus, restoration, IME learning,
  focus requests, and clipping where applicable.
- `onSaved` for Material naming, plus `onSave` as a compatibility alias. Supply
  only one of them.
- `autovalidateMode` and typed participation in `FormState.validate()` and
  `FormState.save()`.

Text, numeric, date, select, and multi-select retain their broader
editor-specific options such as autocorrect, suggestions, smart punctuation,
and scrolling. OTP input intentionally disables autocorrect, suggestions,
and smart punctuation. Caller formatters run first, followed by the optional
digits-only restriction and the package exact-length limiter.

For `SuperSelectFormField` and `SuperMultiSelectFormField`, keyboard and editing
properties configure the menu search editor and therefore take effect when
`searchable` is `true`. Their tap and outside-tap callbacks belong to the
selection trigger. Date input always applies its internal formatter after any
custom `inputFormatters` so the configured date mask remains valid.

## Fields

### Text field

`SuperTextFormField` supports regular text, email, phone, password, and
multiline input.

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

For phone-number input, use the semantic phone type and add only the formatting
or validation rules required by your product and locale. The optional `mask`
API is powered by `mask_text_input_formatter`:

```dart
String? rawPhone;

SuperTextFormField(
  decoration: const InputDecoration(
    labelText: 'Phone number',
    hintText: '+967 7X XXX XXXX',
    prefixIcon: Icon(Icons.phone_outlined),
  ),
  type: SuperTextType.phone,
  mask: '+967 ## ### ####',
  autofillHints: const [AutofillHints.telephoneNumber],
  onUnmaskedChanged: (value) => rawPhone = value,
);
```

The default mask placeholders are `#` for digits, `A` for Latin letters, and
`N` for Latin letters or digits. Override them with `maskFilter`, and select
`MaskAutoCompletionType.lazy` or `MaskAutoCompletionType.eager` through
`maskAutoCompletionType`.

`onChanged` and `onSaved` receive the visible masked value.
`onUnmaskedChanged` and `onUnmaskedSaved` receive only placeholder characters,
without literals such as spaces, separators, or a fixed dialing-code prefix.
Custom `inputFormatters` run before the mask formatter so the mask remains the
final formatting authority.

`SuperTextType.phone` still does not impose a global mask, digits-only
formatter, or phone regex because valid formats vary by locale and product.

Common options:

- `type`: `text`, `email`, `phone`, or `password`. For single-line input, the
  `phone` type selects `TextInputType.phone` unless `keyboardType` is supplied
  explicitly.
- `multiline` and `rows` for long-form input.
- `minLength`, `maxLength`, `pattern`, and `patternMessage`.
- `showCounter`, `clearable`, and `autofocus`.
- `mask`, `maskFilter`, `maskAutoCompletionType`, `onUnmaskedChanged`, and
  `onUnmaskedSaved` for declarative masked input.
- `disabled`, `readOnly`, `arabic`, and `forceError`.

### OTP field

`SuperOTPFormField` renders a verification code as separate cells while using
one real editor internally. This preserves paste, SMS one-time-code autofill,
desktop keyboard input, and predictable `Form` behavior.

```dart
final otpController = SuperOTPFieldController();

SuperOTPFormField(
  controller: otpController,
  decoration: const InputDecoration(
    labelText: 'Verification code',
    hintText: 'Enter the code sent by SMS',
    helperText: 'The code expires in five minutes.',
    prefixIcon: Icon(Icons.sms_outlined),
  ),
  length: 6,
  required: true,
  autofillHints: const [AutofillHints.oneTimeCode],
  onCompleted: (code) {
    // Verify the completed code through the application layer.
  },
  onSaved: (code) {
    // Receives the code from FormState.save().
  },
);
```

OTP behavior:

- `length` sets the exact accepted code length and the number of visual cells.
- `digitsOnly` defaults to `true`, adding a numeric keyboard and digits-only
  formatter. Set it to `false` for alphanumeric backup codes.
- `obscureText` masks a PIN without changing the saved value.
- `onCompleted` runs once for each newly completed value, including pasted and
  autofilled codes.
- Caller `inputFormatters` run first, followed by the optional digits-only
  restriction and the package length limiter. Use `maxLengthEnforcement`
  when composition behavior must differ from the enforced default.
- `boxWidth`, `boxHeight`, `spacing`, `borderRadius`, and `textStyle` customize
  the cells without replacing package focus and validation states.
- `showCounter`, `disabled`, `readOnly`, `autofocus`, `forceError`,
  `onFieldSubmitted`, outside-tap callbacks, and typed Form saving are supported.
- OTP content remains LTR by default, including inside an RTL application. Set
  `textDirection` explicitly only when the product requires another order.

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

### Range date field

<!-- SUPER_RANGE_DATE_PICKER_SYNCFUSION_INSPIRED_V1 -->
`SuperRangeDatePicker` uses a responsive enterprise date-range layout inspired
by the interaction model of mature multi-view pickers: desktop uses two adjacent
months with a vertical quick-range rail, tablet keeps two months with horizontal
preset chips, and mobile switches to one swipeable month with touch-sized cells.
Range selection is drawn as a continuous tinted band with circular start/end
anchors, while today, disabled dates, fixed boundaries, `minDate`/`maxDate`, and
RTL navigation retain the package theme and rules. The implementation is native
to `super_form_field`; it does not require the Syncfusion package.

<!-- SUPER_RANGE_DATE_PICKER_FIRST_DAY_OF_WEEK_V1 -->
The calendar week start is configurable with `firstDayOfWeek`. Use Dart's
weekday constants so the intent remains explicit; the default stays Sunday for
backward-compatible rendering:

```dart
SuperRangeDateFormField(
  firstDayOfWeek: DateTime.monday,
);

// The standalone picker exposes the same setting.
SuperRangeDatePicker(
  firstDayOfWeek: DateTime.saturday,
  onApply: (range) {},
);
```

`firstDayOfWeek` accepts `DateTime.monday` through `DateTime.sunday` and rotates
both the weekday header and the actual date grid. It does not change keyboard
date parsing, formatting, validation, `minDate`, or `maxDate`.

`SuperRangeDateFormField` stores a typed `SuperDateRange` and renders **two
separate keyboard-editable `SuperDateFormField` inputs**: one for the start date
and one for the end date. Tapping or focusing either input only edits that date;
the range-selection surface opens **only** from the trailing calendar action.
Because the boundary inputs reuse `SuperDateFormField`, they share its segmented
keyboard entry, ISO parsing/formatting, malformed-date behavior, and min/max
validation.

```dart
final controller = SuperRangeDateFieldController(
  initialValue: SuperDateRange(
    start: DateTime(2026, 1, 1),
    end: DateTime(2026, 3, 31),
  ),
);

SuperRangeDateFormField(
  controller: controller,
  decoration: const InputDecoration(
    labelText: 'Reporting period',
    helperText: 'Type either date or use the calendar action.',
  ),
  startDecoration: const InputDecoration(labelText: 'Start date'),
  endDecoration: const InputDecoration(labelText: 'End date'),
  isStartFixed: true,
  minDate: DateTime(2026, 1, 1),
  maxDate: DateTime(2026, 12, 31),
);
```

`isStartFixed: true` makes only the start input read-only and preserves that
boundary during picker/preset changes. `isEndFixed: true` does the same for the
end input. `minDate` and `maxDate` validate keyboard-entered values and constrain
calendar/preset selection. A range picked from the selection form is written
back into both visible date inputs, keeping controller state and text buffers
synchronized.

The picker uses the package defaults when `suggestions` is null:
Past 7 days, Previous 30 days, Previous 6 months, and Previous year. Pass an
empty list to remove all presets, replace them with custom resolvers, or
extend the defaults:

```dart
SuperRangeDateFormField(
  suggestions: [
    ...SuperDateRangeSuggestion.defaults,
    SuperDateRangeSuggestion(
      label: 'Month to date',
      resolve: (now) => SuperDateRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month, now.day),
      ),
    ),
  ],
);
```

When both boundaries are fixed, neither keyboard entry nor the picker can
change them. Presets are constrained by the same fixed-boundary, minimum-date,
maximum-date, and start-before-end rules as manual calendar selection.

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

## Dropdown and popup menu buttons

`SuperDropdownButton<T>` is a lightweight typed selector. It uses
`SuperOption<T>` and the same `FieldBox`, `FieldPopover`, `OptionMenu`, and
`OptionTile` foundation as the package's select fields. Use
`SuperDropdownEditingController<T>` when the selection must also be changed
programmatically.

```dart
final statusController = SuperDropdownEditingController<String>(
  initialValue: 'active',
);

SuperDropdownButton<String>(
  controller: statusController,
  decoration: const InputDecoration(hintText: 'Select status…'),
  options: const [
    SuperOption(value: 'active', label: 'Active'),
    SuperOption(value: 'hold', label: 'On hold'),
  ],
  onChanged: (value) {},
);

// Programmatic selection.
statusController.setValue('hold');
statusController.clear();
```

Dispose controllers owned by a `State` object from `State.dispose()`.

`SuperDropdownButton<T>` still supports the existing `value` API when no
controller is supplied. Do not provide a non-null `value` together with a
controller.

Use `SuperDropdownButtonFormField<T>` when the value must participate in a
`Form`. It supports `controller`, `initialValue`, `validator`, `onSaved`,
`required`, and `autovalidateMode` while preserving the package decoration and
validation surface. Provide either `controller` or `initialValue`, not both.

```dart
final warehouseController = SuperDropdownEditingController<String>();

SuperDropdownButtonFormField<String>(
  controller: warehouseController,
  required: true,
  decoration: const InputDecoration(labelText: 'Warehouse'),
  options: const [
    SuperOption(value: 'riyadh', label: 'Riyadh'),
    SuperOption(value: 'jeddah', label: 'Jeddah'),
  ],
  onChanged: (value) {},
  onSaved: (value) {},
);
```

`SuperPopupMenuButton<T>` is for actions rather than form selection. It accepts
the same typed `SuperOption<T>` descriptors, supports disabled entries, and can
use either its default icon trigger or any custom `child`.

```dart
SuperPopupMenuButton<String>(
  tooltip: 'More actions',
  options: const [
    SuperOption(value: 'edit', label: 'Edit'),
    SuperOption(value: 'archive', label: 'Archive'),
  ],
  onSelected: (action) {},
);
```

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

`SuperTextFormField`, `SuperOTPFormField`, `SuperNumericFormField`,
`SuperDateFormField`, `SuperRangeDateFormField`, `SuperSelectFormField`, and
`SuperMultiSelectFormField` also participate in an
ancestor `Form`. `FormState.validate()` uses their existing typed validator
chains, and `FormState.save()` invokes `onSaved` (or the `onSave` compatibility
alias) with the typed value. The attachment, bool, and choice fields retain the
controller/callback validation workflow described above.

## Controllers

Each widget can create and dispose its own controller, or receive an external
controller when imperative access is required.

| Field | Controller | Value |
|---|---|---|
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
| `SuperOTPFieldController` | `setValue`, `clear`, `requestFocus`, `markTouched`, `resetTouched` |
| `SuperNumericFieldController` | `setValue`, `bump`, `bumpLarge` |
| `SuperAttachmentFieldController` | `add`, `remove`, `clear`, `setDragOver` |
| `SuperDateFieldController` | `setValue`, `pick`, `clear`, `markTouched` |
| `SuperSelectFieldController<T>` | `select`, `setValue`, `clear`, `markTouched` |
| `SuperMultiSelectFieldController<T>` | `toggle`, `removeValue`, `setValues`, `clear` |
| `SuperBoolFieldController` | `set`, `setValue`, `toggle`, `markTouched` |
| `SuperChoiceFieldController<T>` | `pick`, `setValues`, `setSingle`, `clear` |

## Localization and RTL

The package includes English and Arabic strings for built-in validation
messages, OTP length errors, search and empty states, attachment actions,
numeric controls, boolean captions, calendar content, and the dedicated phone
and OTP example screens.

Register the delegates once:

```dart
final textTheme = SuperTextTheme(isArabic: true);
MaterialApp(
  locale: const Locale('ar'),
  localizationsDelegates:
      SuperFormLocalizations.localizationsDelegates,
  supportedLocales: SuperFormLocalizations.supportedLocales,
  theme: SuperMaterialThemeData.light(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
  ),
  darkTheme: SuperMaterialThemeData.dark(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
  ),
  home: const ArabicFormPage(),
);
```

For app-wide Arabic typography, build the active theme with
`SuperTextTheme(isArabic: true)`. Use normal Flutter directionality and set
`arabic: true` only when a field needs the package's field-level Arabic-font
fallback:

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
messages are not translated automatically. Numeric, OTP, and segmented date
editing retain Western digits and LTR behavior inside RTL layouts by default.

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
Prefer the public form-field widgets and design-system controls for normal application screens.

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

The package exports pure logic helpers such as `buildOTPValidators`,
`DateLogic`, `NumericLogic`,
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

The gallery demonstrates all form fields plus the dropdown and popup-menu controls,
including dedicated phone-input and OTP-input screens. It covers international phone formatting, OTP paste and
one-time-code autofill, secure PIN display, controller-driven values,
validation flows, typed `FormState.save()`, date formats, linked ranges, light
and dark themes, and LTR and RTL layouts.

## Additional information

- [Repository](https://github.com/GeniusSystems24/super_form_field)
- [Issue tracker](https://github.com/GeniusSystems24/super_form_field/issues)
- [Changelog](CHANGELOG.md)
- [License](LICENSE)

This package is licensed under the MIT License.

## Controller field metadata

Version 1.10.0 aligns the package's field controllers with the controller/view
contract used by `AutoSuggestionsBox`. Controller-backed fields expose:

```dart
final ValueNotifier<bool> isFixed;
FocusNode? focusNode;
GlobalKey<FormFieldState<TValue>>? formFieldKey;
bool isHiden;
```

`isFixed` is a **view/read-only lock**, not a disabled state. The field keeps
normal contrast, user interaction is blocked, and public controller mutation
methods no-op while the lock is active. Select/dropdown overlays close when the
controller becomes fixed.

`focusNode` lets the host associate focus with the controller. Controllers that
need an editor focus node create one when none is supplied and only dispose
nodes they own.

`formFieldKey` is forwarded to the inner `FormField` where that component has
one, so hosts can call APIs such as `validate()`, `save()`, and `reset()` from
the controller relationship:

```dart
final formFieldKey = GlobalKey<FormFieldState<String>>();
final controller = SuperTextFieldController(
  formFieldKey: formFieldKey,
  isFixed: false,
);

controller.isFixed.value = true;
controller.focusNode?.requestFocus();
controller.formFieldKey?.currentState?.validate();
```

`isHiden` intentionally preserves the existing misspelling for compatibility.
When true, controller-backed field views render `SizedBox.shrink()`. Because it
is a plain compatibility flag rather than a notifier, update it inside a host
rebuild (for example, `setState`).
