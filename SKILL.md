---
name: super-form-field
description: >
  Build GeniusLink Flutter forms with super_form_field 1.8.2: text, OTP, numeric,
  attachment, date, select, multi-select, bool, and choice fields. Use the
  unified InputDecoration API, package controllers and validators, responsive
  date picker behavior, localized en/ar package strings, badge validation,
  light/dark themes, and LTR/RTL rules.
---

# Super Form Field 1.8.2

Use this skill when implementing or reviewing forms that depend on
`package:super_form_field/super_form_field.dart`.

## Setup

Prefer the complete `super_core` theme:

```dart
final textTheme = SuperTextTheme();
MaterialApp(
  theme: SuperMaterialThemeData.light(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
  ),
  darkTheme: SuperMaterialThemeData.dark(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
  ),
  localizationsDelegates: SuperFormLocalizations.localizationsDelegates,
  supportedLocales: SuperFormLocalizations.supportedLocales,
);
```

### `super_core` 3.3.0 typography contract

`SuperMaterialThemeData.light` and `SuperMaterialThemeData.dark` now require
`textTheme` and `primaryTextTheme`, both of type `SuperTextTheme`. Typography is
no longer stored on `SuperThemeData`.

- Read package typography with `context.superTextTheme` in application/example code.
- Form-field internals use `context.sffTextTheme`.
- Never generate `context.sffTheme.textTheme`, `context.superTheme.textTheme`,
  or `SuperThemeData.of(context).textTheme`; those APIs no longer exist.
- Build Arabic typography explicitly with `SuperTextTheme(isArabic: true)`.
- If device-specific typography is required, build `SuperTextTheme` with the
  matching device-density arguments instead of expecting `SuperThemeData` to
  regenerate it.
- `fontFamily` on `SuperMaterialThemeData` is an explicit token-level override;
  do not infer it from `SuperTextTheme` or recreate the removed `_familyOf`
  behavior from `super_core`.
- When deriving a field style from `context.sffTextTheme`, preserve that
  style's font family. Do not overwrite normal text with
  `tokens.bodyFont` or `tokens.monoFont`. A field-level `arabic: true` may
  still opt into `tokens.arabicFont` as an explicit fallback.

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

## Material-compatible input behavior

For text, numeric, date, select, and multi-select fields, preserve the broad
Material-compatible editing API: keyboard and formatter options,
submission/editing/tap callbacks, cursor/selection controls, scrolling,
autofill, context menus, restoration, IME learning, `autovalidateMode`, and typed
Form saving. OTP exposes the relevant keyboard, formatter, direction, action,
submission, outside-tap, autofill, context-menu, restoration, IME, cursor, and
Form options while intentionally disabling autocorrect, suggestions, and smart
punctuation. Prefer `onSaved`; keep `onSave` as a compatibility alias and reject
supplying both.

Select and multi-select keyboard/editing properties configure only the menu
search editor and are effective when `searchable` is true. Trigger tap and
outside-tap callbacks belong to the selection field. Apply custom date formatters
before the internal segmented formatter so package date invariants remain last.

## Fields

### SuperTextFormField

Value: `String`. Controller: `SuperTextFieldController`.

Use `type` (`text`, `email`, `phone`, or `password`), `multiline`, `rows`,
`minLength`, `maxLength`, `pattern`,
`patternMessage`, `showCounter`, `clearable`, `disabled`, `readOnly`, and
`autofocus`. Use `mask`, `maskFilter`, and `maskAutoCompletionType` for
declarative masked input. Prefix/suffix widgets come from `decoration`.

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

`SuperTextType.phone` selects `TextInputType.phone` by default for single-line
input. Do not impose a global digits-only formatter, mask, or phone regex;
phone formats are locale- and product-specific. Configure them at the call site
when required.

Text masks use `mask_text_input_formatter`. The built-in placeholders are `#`
for digits, `A` for Latin letters, and `N` for alphanumeric input. Caller
`inputFormatters` must run before the mask formatter. Keep `onChanged` and
`onSaved` mapped to the visible value, while `onUnmaskedChanged` and
`onUnmaskedSaved` expose the value without mask literals.

The example gallery includes a dedicated `PhoneFieldDemo` screen showing an
international field and a country-specific composition using a prefix, mask,
pattern, autofill hints, submission, and typed form saving.

### SuperOTPFormField

Value: `String`. Controller: `SuperOTPFieldController`.

Use `length` for the exact code length. The field uses one hidden Material
editor and separate visual cells, so paste, SMS one-time-code autofill, desktop
keyboard input, and `FormState.save()` remain reliable.

```dart
SuperOTPFormField(
  decoration: const InputDecoration(
    labelText: 'Verification code',
    helperText: 'Enter the code sent by SMS.',
    prefixIcon: Icon(Icons.sms_outlined),
  ),
  length: 6,
  required: true,
  onCompleted: (code) {},
);
```

Keep these invariants:

- `digitsOnly` defaults to true and supplies both the numeric keyboard and
  digits-only formatter. Set it false for alphanumeric codes.
- Caller `inputFormatters` run first, followed by the optional digits-only
  restriction and the package length limiter. Preserve the enforced
  `maxLengthEnforcement` default.
- `onCompleted` fires once for each newly completed value, including paste and
  autofill.
- `obscureText` affects only the visual cells; saved/controller values remain
  unchanged.
- OTP cells default to LTR even inside RTL pages. Preserve explicit
  `textDirection` overrides.
- Responsive layout shrinks cells down to the supported minimum and then uses
  horizontal scrolling rather than overflowing.
- Keep badge validation, `InputDecoration` mapping, `onSaved`/`onSave`, and
  `FormState.validate/reset` behavior consistent with the other editable fields.

The gallery includes `OTPFieldDemo` with SMS, secure PIN, and alphanumeric
backup-code examples.

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
- Use `onValidity` to aggregate form validity. The text, OTP, numeric, date, select, and multi-select fields also support `FormState.validate()` and `FormState.save()`.
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

Register `SuperFormLocalizations.localizationsDelegates` and
`SuperFormLocalizations.supportedLocales` on the host `MaterialApp`. Built-in
package strings support `en` and `ar`: validation messages, search/empty states,
attachment actions, bool state labels, numeric stepper tooltips, calendar
labels, and the phone/OTP gallery examples. Caller-provided strings remain the
application's responsibility.

Build app-wide Arabic typography with `SuperTextTheme(isArabic: true)`. Wrap the
field in RTL `Directionality`; use `arabic: true` only when that field needs the
package's explicit Arabic-font fallback. Date and numeric editing intentionally
remain LTR with Western digits. Do not reverse or localize their internal
buffers.

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
- OTP changes preserve paste, autofill, exact-length validation, and completion semantics.
- No public field reintroduces duplicated decoration parameters.
- Colors, spacing, sizing, and interaction tokens are resolved from the ambient
  `SuperThemeData`; typography is resolved separately from
  `context.sffTextTheme` / `context.superTextTheme`.
- Mobile date changes do not alter tablet/desktop popover behavior.
- Numeric text keeps a natural-height, borderless single-line editor centered
  by layout inside `FieldBox`; do not simulate centering with padding or
  transforms.
- Numeric steppers are contiguous squares matching the active
  compact/comfortable field height.
- Error display remains badge-based.
- Application imports do not reach into `lib/src`.
