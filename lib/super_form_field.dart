/// GeniusLink design-system form fields for Flutter.
///
/// The package provides eight ERP-oriented inputs with one shared
/// `InputDecoration` contract:
///
/// * [SuperTextFormField] — text, email, password, and multiline input.
/// * [SuperNumericFormField] — vertically centered numeric input with a
///   contiguous square increment/decrement stepper.
/// * [SuperAttachmentFormField] — picker-agnostic drop zone and typed file list.
/// * [SuperDateFormField] — responsive segmented date entry with mobile
///   software-keyboard handling, a bottom-sheet picker, and tablet/desktop
///   hardware-key navigation with an anchored calendar.
/// * [SuperSelectFormField] — searchable typed single-select.
/// * [SuperMultiSelectFormField] — typed multi-select with removable chips.
/// * [SuperBoolFormField] — toggle or checkbox with optional true-value gate.
/// * [SuperChoiceFormField] — segmented, radio, or checkbox option group.
///
/// Decoration content comes from each field's `decoration` parameter. The
/// package maps Material labels, hints, helpers, adornments, counters, and
/// `errorText` onto the GeniusLink field foundation while retaining its own
/// control geometry, focus treatment, typography, and error badges.
///
/// Validation errors are quiet until touch/blur unless `forceError` is enabled.
/// All fields support light/dark themes and LTR/RTL layouts.
///
/// Use the complete `super_core` theme in the host application:
///
/// ```dart
/// MaterialApp(
///   theme: SuperMaterialThemeData.light(),
///   darkTheme: SuperMaterialThemeData.dark(),
/// );
/// ```
library super_form_field;

// Core foundation.
export 'src/core/core.dart';

// Features.
export 'src/features/super_text_form_field/super_text_form_field.dart';
export 'src/features/super_numeric_form_field/super_numeric_form_field.dart';
export 'src/features/super_attachment_form_field/super_attachment_form_field.dart';
export 'src/features/super_date_form_field/super_date_form_field.dart';
export 'src/features/super_select_form_field/super_select_form_field.dart';
export 'src/features/super_multi_select_form_field/super_multi_select_form_field.dart';
export 'src/features/super_bool_form_field/super_bool_form_field.dart';
export 'src/features/super_choice_form_field/super_choice_form_field.dart';
