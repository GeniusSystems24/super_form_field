// ============================================================
// features/super_numeric_form_field/super_numeric_form_field.dart
// ------------------------------------------------------------
// Public barrel for the SuperNumericFormField feature (Clean Architecture):
//   domain        — the numeric logic usecase (sanitise / clamp / validators)
//   presentation  — the controller (Model) + the widget (View)
// ============================================================

export 'domain/usecases/numeric_logic.dart';
export 'presentation/controllers/super_numeric_field_controller.dart';
export 'presentation/widgets/super_numeric_form_field.dart';
