// ============================================================
// features/super_multi_select_form_field/super_multi_select_form_field.dart
// ------------------------------------------------------------
// Public barrel for the SuperMultiSelectFormField feature (Clean Architecture):
//   domain        — the option-filter + validator-build usecase (pure Dart)
//   presentation  — the controller (Model) + the widget (View)
// The shared `SuperOption<T>` value type is exported from `core`.
// ============================================================

export 'domain/usecases/multi_select_logic.dart';
export 'presentation/controllers/super_multi_select_field_controller.dart';
export 'presentation/widgets/super_multi_select_form_field.dart';
