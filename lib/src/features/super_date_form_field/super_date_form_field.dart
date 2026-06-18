// ============================================================
// features/super_date_form_field/super_date_form_field.dart
// ------------------------------------------------------------
// Public barrel for the SuperDateFormField feature (Clean Architecture):
//   domain        — the date logic usecase (mask / parse / format / validators)
//   presentation  — the controller (Model) + the widget (View) + MiniCalendar
// ============================================================

export 'domain/usecases/date_logic.dart';
export 'presentation/controllers/super_date_field_controller.dart';
export 'presentation/widgets/mini_calendar.dart';
export 'presentation/widgets/super_date_form_field.dart';
