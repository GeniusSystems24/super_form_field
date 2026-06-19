// ============================================================
// features/super_choice_form_field/super_choice_form_field.dart
// ------------------------------------------------------------
// Public barrel for the SuperChoiceFormField feature (Clean Architecture):
//   domain        — the style enum + the validator-build usecase (pure Dart)
//   presentation  — the controller (Model) + the widget (View)
// ============================================================

export 'domain/entities/choice_field_config.dart';
export 'domain/usecases/choice_logic.dart';
export 'presentation/controllers/super_choice_field_controller.dart';
export 'presentation/widgets/super_choice_form_field.dart';
