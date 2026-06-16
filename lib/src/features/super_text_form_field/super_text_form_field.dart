// ============================================================
// features/super_text_form_field/super_text_form_field.dart
// ------------------------------------------------------------
// Public barrel for the SuperTextFormField feature (Clean Architecture):
//   domain        — value types + the validator-build usecase (pure Dart)
//   presentation  — the controller (Model) + the widget (View)
// ============================================================

export 'domain/entities/text_field_config.dart';
export 'domain/usecases/build_text_validators.dart';
export 'presentation/controllers/super_text_field_controller.dart';
export 'presentation/widgets/super_text_form_field.dart';
