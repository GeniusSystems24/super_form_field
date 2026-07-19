---
name: super-form-field
description: >
  Build GeniusLink Flutter forms with super_form_field 1.3.0: text, numeric,
  attachment, date, select, multi-select, bool, and choice fields. Use the
  unified InputDecoration API, package controllers and validators, responsive
  date picker behavior, badge validation, light/dark themes, and LTR/RTL rules.
---

# Super Form Field 1.3.0

Use this skill when implementing or reviewing forms that depend on
`package:super_form_field/super_form_field.dart`.

## Setup

Prefer the complete `super_core` theme:

```dart
MaterialApp(
  theme: SuperMaterialThemeData.light(),
  darkTheme: SuperMaterialThemeData.dark(),
);
```

Import only the package barrel from application code:

```dart
import 'package:super_form_field/super_form_field.dart';
```

## Decoration contract

Every public field has one canonical decoration parameter:

```dart
decoration: const InputDecoration(
  labelText: 'Amount',
  hintText: '0.00',
  helperText: 'Enter the gross amount',
  prefixIcon: Icon(SffIcons.hash),
  prefixText: 'SAR',
  suffixText: 'incl. VAT',
),
```

Use these mappings:

- `label` / `labelText`: external field label.
- `helper` / `helperText`: helper below the control.
- `hint` / `hintText`: empty-value prompt or inline statement.
- `icon`, `prefixIcon`, `prefix`, `prefixText`: leading adornments.
- `suffix`, `suffixText`, `suffixIcon`: trailing adornments.
- `counter` / `counterText`: label-row counter.
- `errorText`: forced external error using the package error badge.

Do not add separate `label`, `placeholder`, `hint`, `leadingIcon`, `prefix`,
`suffix`, or boolean `title` properties back to public fields. `InputDecoration`
is the single source of decoration content. The package still owns borders,
control height, spacing, focus/error states, and badge validation.

## Fields

### SuperTextFormField

Value: `String`. Controller: `SuperTextFieldController`.

Use `type`, `multiline`, `rows`, `minLength`, `maxLength`, `pattern`,
`patternMessage`, `showCounter`, `clearable`, `disabled`, `readOnly`, and
`autofocus`. Prefix/suffix widgets come from `decoration`.

```dart
SuperTextFormField(
  decoration: const InputDecoration(
    labelText: 'Email',
    hintText: 'name@example.com',
    prefixIcon: Icon(SffIcons.mail),
  ),
  type: SuperTextType.email,
  required: true,
);
```

### SuperNumericFormField

Value: `num?`. Controller: `SuperNumericFieldController`.

Use `min`, `max`, `decimals`, `grouping`, `step`, `largeStep`, `stepper`,
`keyboardShortcuts`, and `allowNegative`. Units belong in
`decoration.prefixText` and `decoration.suffixText`. Numbers remain Western,
mono, and LTR. Its natural single-line editor is centered by layout inside the
authoritative field height. Stepper buttons are gap-free squares sized from the
active compact/comfortable field-height token.

### SuperAttachmentFormField

Value: `List<SuperFile>`. Controller: `SuperAttachmentFieldController`.

Use `accept`, `maxSizeMB`, `maxFiles`, `multiple`, and `onBrowse`. The host must
provide file acquisition and convert picker results to `SuperFile`. Do not add a
platform picker dependency to this package. For drag-and-drop adapters, call
`controller.setDragOver` and `controller.add`.

### SuperDateFormField

Value: `DateTime?`. Controller: `SuperDateFieldController`.

Use `format`, `minDate`, `maxDate`, `calendar`, `keyboardShortcuts`,
`clearable`, and `invalidMessage`. The hint defaults to the format placeholder.
The calendar button dismisses the keyboard. Mobile uses a modal bottom sheet;
tablet and desktop use the anchored popover. The field supplies its historical
leading calendar glyph when no leading decoration is provided. Override it with
`prefixIcon`, or suppress it with `prefixIcon: SizedBox.shrink()`.

Responsive typing uses two pure interaction policies over one shared controller:

- `MobileDateInputUseCase` translates software-keyboard editing deltas, keeps
  the caret collapsed, and prevents the IME from bypassing the segmented mask.
- `DesktopDateInputUseCase` preserves segment selection, arrow stepping,
  left/right movement, and separator shortcuts for tablet/desktop layouts.

Both implement `DateInputUseCase<Request>` and produce `DateInputIntent` values.
Do not duplicate parsing, validation, bounds, or segment state between device
modes; those responsibilities remain shared in `SuperDateFieldController` and
`DateLogic`.

### SuperSelectFormField<T>

Value: `T?`. Controller: `SuperSelectFieldController<T>`.

Provide `List<SuperOption<T>> options`. Optional behavior includes `searchable`,
`searchHint`, `clearable`, and `emptyLabel`. Disabled options cannot be selected.

### SuperMultiSelectFormField<T>

Value: `List<T>`. Controller: `SuperMultiSelectFieldController<T>`.

Use `minSelections`, `maxSelections`, `showCount`, and `searchable`.
`maxSelections` is a hard cap. Selected values render as removable chips.

### SuperBoolFormField

Value: `bool`. Controller: `SuperBoolFieldController`.

Use `style`, `enabledLabel`, `disabledLabel`, `mustBeTrue`, and
`mustBeTrueMessage`. Put a fixed acknowledgement statement in
`decoration.hintText` or `decoration.hint`; otherwise state labels are used.

### SuperChoiceFormField<T>

Value: `List<T>`. Controller: `SuperChoiceFieldController<T>`.

Use `style` (`segmented`, `radio`, or `checkbox`), `multiple`,
`minSelections`, and `maxSelections`. Checkbox style is multi-select; use
`controller.single` for a single-pick controller value.

## Validation rules

- A `Validator<T>` returns `String?`; the first error wins.
- Errors remain hidden until touch/blur unless `forceError` is true.
- Errors are shown through `ErrorBadge`, never as ordinary inline error text.
- Use `onValidity` to aggregate form validity.
- On submit, set `forceError` or call each controller's `markTouched()`.
- `InputDecoration.errorText` is treated as an external field error.
- Do not use `InputDecoration.error`; the badge validation surface requires the string from `errorText`.

```dart
bool forceErrors = false;
String? nameError;

SuperTextFormField(
  decoration: const InputDecoration(labelText: 'Name'),
  required: true,
  minLength: 3,
  forceError: forceErrors,
  onValidity: (error) => nameError = error,
);
```

## RTL and Arabic

Wrap the field in RTL `Directionality` and set `arabic: true`. Date and numeric
editing intentionally remain LTR with Western digits. Do not reverse or localize
their internal buffers.

## Architecture

Preserve the package layout:

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

Keep validation, parsing, filtering, and formatting in feature use cases. Keep
state in controllers and composition in widgets. Platform adapters such as the
mobile date `TextInputFormatter` belong in `presentation/formatters` and must
translate Flutter values into pure use-case requests rather than owning date
rules. Shared visual behavior belongs under `lib/src/core/foundation`;
decoration mapping belongs in `field_decoration.dart`.

## Review checklist

- Every new example uses `decoration: InputDecoration(...)`.
- No public field reintroduces duplicated decoration parameters.
- Package theme tokens are resolved from the ambient `SuperThemeData`.
- Mobile date changes do not alter tablet/desktop popover behavior.
- Numeric text keeps a natural-height, borderless single-line editor centered
  by layout inside `FieldBox`; do not simulate centering with padding or
  transforms.
- Numeric steppers are contiguous squares matching the active
  compact/comfortable field height.
- Error display remains badge-based.
- Application imports do not reach into `lib/src`.
