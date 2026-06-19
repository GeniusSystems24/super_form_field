/// Super Form Field — GeniusLink design-system form fields for Flutter.
///
/// A focused, dependency-free package porting three React form-field tools to
/// Flutter on a shared GeniusLink field foundation:
///
///   • [SuperTextFormField]        — validated text / email / password, multiline,
///                                   prefix/suffix, clear, counter.
///   • [SuperNumericFormField]     — grouped-while-idle / raw-while-editing numeric
///                                   input, clamp + round on blur, +/- stepper.
///   • [SuperAttachmentFormField]  — drop-zone + typed file list with per-file +
///                                   field-level validation.
///   • [SuperDateFormField]        — masked `YYYY-MM-DD` input + calendar popover,
///                                   min/max bounds, ISO `DateTime?` value.
///
/// Every field surfaces validation ONLY through the suffix ErrorBadge (icon +
/// tooltip) — never inline text — and supports light/dark + LTR/RTL.
///
/// Architecture: Clean Architecture per feature with an MVC presentation split.
///   domain/      — entities + usecases (pure Dart, no Flutter)
///   presentation/— controllers (the Model / state) + widgets (the View)
/// Shared, cross-feature code lives in `lib/src/core/`.
///
/// Register the theme extension once:
/// ```dart
/// MaterialApp(
///   theme:     ThemeData(extensions: const [SuperThemeData.light]),
///   darkTheme: ThemeData(extensions: const [SuperThemeData.dark]),
/// );
/// ```
library;

export 'package:super_core/super_core.dart'
    hide FieldShell, FieldDensity, Validator, ValidityChanged;

// ── Core foundation ──────────────────────────────────────────────────────
export 'src/core/core.dart';

// ── Features ───────────────────────────────────────────────────────────────
export 'src/features/super_text_form_field/super_text_form_field.dart';
export 'src/features/super_numeric_form_field/super_numeric_form_field.dart';
export 'src/features/super_attachment_form_field/super_attachment_form_field.dart';
export 'src/features/super_date_form_field/super_date_form_field.dart';
