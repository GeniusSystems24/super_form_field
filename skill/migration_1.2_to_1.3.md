---
name: super-form-field-migration-1-2-to-1-3
description: >
  Migrate Flutter applications and package examples from super_form_field 1.2.x
  to 1.3.0. Replace duplicated decoration arguments with InputDecoration,
  preserve controller and validation behavior, adopt responsive date input and
  picker behavior, and verify GeniusLink design-system consistency.
---

# Migrate `super_form_field` 1.2.x to 1.3.0

Use this migration skill when upgrading an application, example project, or
package integration from `super_form_field` 1.2.x to 1.3.0.

## Migration goals

The migration must:

- Replace field-specific decoration arguments with one `InputDecoration`.
- Preserve values, controllers, validators, callbacks, disabled/read-only state,
  density, RTL behavior, and business rules.
- Keep `InputDecoration` as the single source of label, hint, helper, prefix,
  suffix, icon, counter, and external error content.
- Preserve package-owned field borders, sizing, focus/error treatment, and the
  GeniusLink visual language.
- Keep mobile and desktop date interactions separated without duplicating date
  parsing or validation logic.
- Update examples, tests, and documentation together with production code.

## Version update

Update the dependency constraint:

```yaml
dependencies:
  super_form_field: ^1.3.0
```

When the package is used from a monorepo, keep the existing path and update only
its resolved package version as appropriate:

```yaml
dependencies:
  super_form_field:
    path: ../super_form_field
```

Run after source migration:

```bash
flutter pub get
flutter analyze
flutter test
```

## Primary breaking API change

All eight public form fields now accept:

```dart
decoration: const InputDecoration(...)
```

Do not reintroduce the removed `label`, `placeholder`, `hint`, `leadingIcon`,
`prefix`, `suffix`, or boolean `title` parameters in application wrappers.

### Decoration mapping

| 1.2.x argument | 1.3.0 replacement |
|---|---|
| `label: 'Amount'` | `decoration: InputDecoration(labelText: 'Amount')` |
| `placeholder: '0.00'` | `decoration: InputDecoration(hintText: '0.00')` |
| `hint: 'Optional note'` | `decoration: InputDecoration(helperText: 'Optional note')` |
| `leadingIcon: SffIcons.hash` | `decoration: InputDecoration(prefixIcon: Icon(SffIcons.hash))` |
| `prefix: 'SAR'` | `decoration: InputDecoration(prefixText: 'SAR')` |
| `suffix: '%'` | `decoration: InputDecoration(suffixText: '%')` |
| `title: 'I agree'` on bool fields | `decoration: InputDecoration(hintText: 'I agree')` |

Use `helperText` for explanatory text displayed below a control. Use `hintText`
for text displayed inside an empty field or for the fixed statement rendered by
`SuperBoolFormField`.

## Field-by-field migration

### `SuperTextFormField`

Before:

```dart
SuperTextFormField(
  label: 'Email',
  placeholder: 'name@example.com',
  hint: 'Used for account notifications',
  leadingIcon: SffIcons.mail,
  prefix: 'mailto:',
  suffix: '.com',
  type: SuperTextType.email,
  required: true,
)
```

After:

```dart
SuperTextFormField(
  decoration: const InputDecoration(
    labelText: 'Email',
    hintText: 'name@example.com',
    helperText: 'Used for account notifications',
    prefixIcon: Icon(SffIcons.mail),
    prefixText: 'mailto:',
    suffixText: '.com',
  ),
  type: SuperTextType.email,
  required: true,
)
```

### `SuperNumericFormField`

Before:

```dart
SuperNumericFormField(
  label: 'Debit amount',
  placeholder: '0.00',
  hint: 'Enter the transaction amount',
  leadingIcon: SffIcons.hash,
  prefix: 'SAR',
  suffix: 'incl. VAT',
  decimals: 2,
  stepper: true,
)
```

After:

```dart
SuperNumericFormField(
  decoration: const InputDecoration(
    labelText: 'Debit amount',
    hintText: '0.00',
    helperText: 'Enter the transaction amount',
    prefixIcon: Icon(SffIcons.hash),
    prefixText: 'SAR',
    suffixText: 'incl. VAT',
  ),
  decimals: 2,
  stepper: true,
)
```

Do not add padding, transforms, or fixed vertical offsets around the numeric
editor. Version 1.3.0 centers the naturally measured single-line editor inside
`FieldBox`. Increment and decrement controls are contiguous squares whose width
and height resolve from the active field-height token.

### `SuperAttachmentFormField`

Before:

```dart
SuperAttachmentFormField(
  label: 'Documents',
  hint: 'PDF or image, up to 10 MB',
  onBrowse: browseFiles,
)
```

After:

```dart
SuperAttachmentFormField(
  decoration: const InputDecoration(
    labelText: 'Documents',
    helperText: 'PDF or image, up to 10 MB',
  ),
  onBrowse: browseFiles,
)
```

Keep file acquisition in the host application. Do not add a picker plugin to
`super_form_field` itself.

### `SuperDateFormField`

Before:

```dart
SuperDateFormField(
  label: 'Posting date',
  placeholder: 'YYYY-MM-DD',
  hint: 'Select the accounting date',
  leadingIcon: SffIcons.calendar,
)
```

After:

```dart
SuperDateFormField(
  decoration: const InputDecoration(
    labelText: 'Posting date',
    hintText: 'YYYY-MM-DD',
    helperText: 'Select the accounting date',
    prefixIcon: Icon(SffIcons.calendar),
  ),
)
```

The field supplies its historical calendar leading icon when `prefixIcon` is
not provided. Replace it with another widget through `prefixIcon`, or suppress
it explicitly:

```dart
decoration: const InputDecoration(
  labelText: 'Posting date',
  prefixIcon: SizedBox.shrink(),
)
```

Responsive behavior in 1.3.0:

- Mobile software-keyboard edits use `MobileDateInputUseCase` through
  `MobileDateInputFormatter`.
- Tablet and desktop hardware-key interactions use `DesktopDateInputUseCase`.
- Both produce `DateInputIntent` values through `DateInputUseCase<Request>`.
- Parsing, formatting, bounds, validation, and segmented state remain shared in
  `DateLogic` and `SuperDateFieldController`.
- The calendar button dismisses the keyboard.
- Mobile opens a dedicated modal bottom sheet with an expanded touch layout.
- Tablet and desktop keep the anchored calendar popover.

Do not branch date parsing or validation by platform inside the widget.

### `SuperSelectFormField<T>`

Before:

```dart
SuperSelectFormField<Account>(
  label: 'Account',
  placeholder: 'Choose an account',
  hint: 'Required for posting',
  leadingIcon: SffIcons.search,
  options: accounts,
)
```

After:

```dart
SuperSelectFormField<Account>(
  decoration: const InputDecoration(
    labelText: 'Account',
    hintText: 'Choose an account',
    helperText: 'Required for posting',
    prefixIcon: Icon(SffIcons.search),
  ),
  options: accounts,
)
```

### `SuperMultiSelectFormField<T>`

Before:

```dart
SuperMultiSelectFormField<String>(
  label: 'Permissions',
  placeholder: 'Select permissions',
  hint: 'Choose one or more values',
  leadingIcon: SffIcons.search,
  options: permissions,
)
```

After:

```dart
SuperMultiSelectFormField<String>(
  decoration: const InputDecoration(
    labelText: 'Permissions',
    hintText: 'Select permissions',
    helperText: 'Choose one or more values',
    prefixIcon: Icon(SffIcons.search),
  ),
  options: permissions,
)
```

### `SuperBoolFormField`

Before:

```dart
SuperBoolFormField(
  label: 'Approval',
  title: 'I confirm the balance is correct',
  hint: 'Required before posting',
  mustBeTrue: true,
)
```

After:

```dart
SuperBoolFormField(
  decoration: const InputDecoration(
    labelText: 'Approval',
    hintText: 'I confirm the balance is correct',
    helperText: 'Required before posting',
  ),
  mustBeTrue: true,
)
```

When `hintText`/`hint` is absent, the field continues to show its enabled or
disabled state label.

### `SuperChoiceFormField<T>`

Before:

```dart
SuperChoiceFormField<String>(
  label: 'Payment method',
  hint: 'Choose one option',
  options: paymentMethods,
)
```

After:

```dart
SuperChoiceFormField<String>(
  decoration: const InputDecoration(
    labelText: 'Payment method',
    helperText: 'Choose one option',
  ),
  options: paymentMethods,
)
```

## Additional `InputDecoration` support

Version 1.3.0 adapts these slots to the package foundation:

- `label` / `labelText`
- `helper` / `helperText`
- `hint` / `hintText`
- `icon`
- `prefixIcon`, `prefix`, `prefixText`
- `suffixIcon`, `suffix`, `suffixText`
- `counter`, `counterText`
- `errorText`
- related styles and icon constraints

The package intentionally retains ownership of its field border, height,
radius, spacing, focus, hover, disabled, and error-badge presentation. Do not
expect arbitrary `InputDecoration.border` overrides to replace the GeniusLink
field shell.

Use `errorText` for an external string error:

```dart
SuperTextFormField(
  decoration: InputDecoration(
    labelText: 'Reference',
    errorText: serverError,
  ),
)
```

Do not use `InputDecoration.error`; package validation is string-based and
renders through `ErrorBadge`.

## Validation and controller compatibility

Controller types and value contracts remain unchanged:

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

Preserve existing `initialValue`, `onChanged`, `onValidity`, `validators`,
`forceError`, `disabled`, `readOnly`, and `arabic` arguments unless the
application requirements explicitly change.

## Example scaffold migration

Use `SuperAppBar` from `super_core` instead of Material `AppBar` in package
examples:

```dart
Scaffold(
  appBar: SuperAppBar(
    title: const Text('Super Form Field'),
  ),
  body: const DemoBody(),
)
```

Use section and card components exported by `super_core`; do not restore a local
`SectionCard` copy in the example project.

## Recommended automated migration workflow

1. Update `pubspec.yaml` to 1.3.0.
2. Search for all eight `Super*FormField` constructors.
3. Move every old decoration argument into one `InputDecoration`.
4. Remove the migrated named arguments from the constructor.
5. Preserve non-decoration arguments exactly.
6. Update wrappers and reusable application components before leaf screens.
7. Update all examples and tests.
8. Verify mobile and desktop date behavior separately.
9. Verify numeric text centering and contiguous square steppers at all supported
   device modes.
10. Run formatting, analysis, tests, and the example application.

Useful searches:

```bash
rg "Super(Text|Numeric|Attachment|Date|Select|MultiSelect|Bool|Choice)FormField" lib test example
rg "\b(label|placeholder|hint|leadingIcon|prefix|suffix|title):" lib test example
rg "AppBar\(" example/lib
```

Treat search results carefully: `label`, `hint`, `prefix`, and `suffix` may also
belong to unrelated Flutter widgets.

## Verification checklist

- [ ] Package dependency resolves to 1.3.0.
- [ ] Every public Super form field uses `decoration: InputDecoration(...)`.
- [ ] No removed decoration parameter remains on a Super field constructor.
- [ ] Labels, helper text, hints, prefixes, suffixes, icons, and counters render
      in the same semantic positions as before.
- [ ] Required, custom, and external errors still render through the error badge.
- [ ] Existing controllers and callbacks preserve their value contracts.
- [ ] Mobile date typing keeps a collapsed caret and a stable segmented mask.
- [ ] Mobile calendar opens in the dedicated bottom sheet after keyboard
      dismissal.
- [ ] Tablet and desktop date fields still use the anchored popover and hardware
      keyboard shortcuts.
- [ ] Numeric text is vertically centered without padding/transform hacks.
- [ ] Numeric stepper buttons are gap-free squares matching field height.
- [ ] RTL layouts preserve Western-digit LTR editing for date and numeric fields.
- [ ] Example scaffolds use `SuperAppBar` and `super_core` section components.
- [ ] `dart format`, `flutter analyze`, `flutter test`, and example builds pass.

## Architecture guardrails

Preserve the package structure:

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

Apply these rules during migration:

- Business rules, parsing, filtering, and validation belong in domain use cases.
- Controllers own state and coordinate use cases.
- Widgets compose presentation and translate user gestures into controller
  operations.
- Flutter-specific IME adapters belong in `presentation/formatters`.
- Shared visual behavior belongs under `lib/src/core/foundation`.
- Decoration mapping remains centralized in `field_decoration.dart`.
- Application code imports the public barrel only:

```dart
import 'package:super_form_field/super_form_field.dart';
```

Never import application code from `package:super_form_field/src/...`.
