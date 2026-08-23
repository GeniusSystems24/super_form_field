/// GeniusLink design-system form fields for Flutter.
///
/// The package provides ERP-oriented form inputs plus design-system dropdown
/// and popup-menu controls with one shared visual language:
///
/// * [SuperTextFormField] — text, email, phone, password, multiline, and
///   declaratively masked input.
/// * [SuperOTPFormField] — segmented verification-code input with paste,
///   one-time-code autofill, secure display, and completion callbacks.
/// * [SuperNumericFormField] — vertically centered numeric input with a
///   contiguous square increment/decrement stepper.
/// * [SuperAttachmentFormField] — picker-agnostic drop zone and typed file list.
/// * [SuperDateFormField] — responsive segmented date entry with mobile
///   software-keyboard handling, a bottom-sheet picker, and tablet/desktop
///   hardware-key navigation with an anchored calendar.
/// * [SuperRangeDateFormField] — typed start/end date ranges with two-calendar
///   selection, fixed boundaries, min/max constraints, and configurable presets.
/// * [SuperSelectFormField] — searchable typed single-select.
/// * [SuperMultiSelectFormField] — typed multi-select with removable chips.
/// * [SuperBoolFormField] — toggle or checkbox with optional true-value gate.
/// * [SuperChoiceFormField] — segmented, radio, or checkbox option group.
/// * [SuperDropdownButton] — typed design-system dropdown button.
/// * [SuperDropdownButtonFormField] — Form-integrated typed dropdown button.
/// * [SuperPopupMenuButton] — anchored design-system action menu button.
///
/// Decoration content comes from each field's `decoration` parameter. The
/// package maps Material labels, hints, helpers, adornments, counters, and
/// `errorText` onto the GeniusLink field foundation while retaining its own
/// control geometry, focus treatment, typography, and error badges.
///
/// Validation errors are quiet until touch/blur unless `forceError` is enabled.
/// Text, OTP, numeric, date, range-date, select, and multi-select fields expose Material
/// keyboard and editing callbacks and participate in `FormState.validate()` /
/// `save()` with typed values. All fields support light/dark themes and
/// LTR/RTL layouts.
///
/// Use the complete `super_core` theme in the host application:
///
/// ```dart
/// final textTheme = SuperTextTheme();
/// MaterialApp(
///   theme: SuperMaterialThemeData.light(
///     textTheme: textTheme,
///     primaryTextTheme: textTheme,
///   ),
///   darkTheme: SuperMaterialThemeData.dark(
///     textTheme: textTheme,
///     primaryTextTheme: textTheme,
///   ),
/// );
/// ```
library super_form_field;

// Core foundation.
export 'src/core/core.dart';
export 'localization/super_form_localizations.dart';

// Features.
export 'src/features/super_text_form_field/super_text_form_field.dart';
export 'src/features/super_otp_form_field/super_otp_form_field.dart';
export 'src/features/super_numeric_form_field/super_numeric_form_field.dart';
export 'src/features/super_attachment_form_field/super_attachment_form_field.dart';
export 'src/features/super_date_form_field/super_date_form_field.dart';
export 'src/features/super_range_date_form_field/super_range_date_form_field.dart';
export 'src/features/super_select_form_field/super_select_form_field.dart';
export 'src/features/super_multi_select_form_field/super_multi_select_form_field.dart';
export 'src/features/super_bool_form_field/super_bool_form_field.dart';
export 'src/features/super_choice_form_field/super_choice_form_field.dart';
export 'src/features/super_dropdown_button/super_dropdown_button.dart';
export 'src/features/super_popup_menu_button/super_popup_menu_button.dart';
