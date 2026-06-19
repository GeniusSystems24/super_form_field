// ============================================================
// features/super_bool_form_field/super_bool_form_field.dart
// ------------------------------------------------------------
// Public barrel for the SuperBoolFormField feature (Clean Architecture):
//   domain        — the style enum + the validator-build usecase (pure Dart)
//   presentation  — the controller (Model) + the widget (View)
// ============================================================

export 'domain/entities/bool_field_config.dart';
export 'domain/usecases/build_bool_validators.dart';
export 'presentation/controllers/super_bool_field_controller.dart';
export 'presentation/widgets/super_bool_form_field.dart';
