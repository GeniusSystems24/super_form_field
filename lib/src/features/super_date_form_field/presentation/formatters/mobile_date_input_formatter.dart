// ============================================================
// features/super_date_form_field/presentation/formatters/
// mobile_date_input_formatter.dart
// ------------------------------------------------------------
// Flutter adapter that routes software-keyboard edits through the mobile date
// interaction use case owned by SuperDateFieldController.
// ============================================================

import 'package:flutter/services.dart';

import '../controllers/super_date_field_controller.dart';

/// Converts raw mobile IME edits into the controller's canonical segmented date
/// buffer before Flutter commits them to the text field.
final class MobileDateInputFormatter extends TextInputFormatter {
  MobileDateInputFormatter(this.controller);

  final SuperDateFieldController controller;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => controller.formatMobileEdit(oldValue, newValue);
}
