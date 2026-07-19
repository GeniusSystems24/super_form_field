// ============================================================
// features/super_date_form_field/domain/usecases/date_input_intent.dart
// ------------------------------------------------------------
// Shared, platform-neutral contracts for responsive date-input use cases.
// ============================================================

/// Selects the interaction policy used by the date-field controller.
///
/// Desktop preserves segment selection and hardware-key navigation. Mobile
/// consumes software-keyboard editing deltas and keeps the caret collapsed.
enum DateInputInteractionMode { desktop, mobile }

/// Operations produced by a date-input interaction use case.
enum DateInputIntentType {
  insertDigits,
  backspace,
  clearSegment,
  nextSegment,
  previousSegment,
  stepUp,
  stepDown,
  replaceText,
}

/// A platform-neutral date-input operation.
class DateInputIntent {
  const DateInputIntent({
    required this.type,
    this.text = '',
    this.offset,
  });

  final DateInputIntentType type;

  /// Digits for [DateInputIntentType.insertDigits], or replacement text for
  /// [DateInputIntentType.replaceText].
  final String text;

  /// Editing offset used by the controller to resolve the target segment.
  final int? offset;
}

/// Contract implemented by desktop and mobile date-input policies.
abstract interface class DateInputUseCase<Request> {
  DateInputIntent? execute(Request request);
}

/// Hardware-key categories understood by [DesktopDateInputRequest].
enum DesktopDateInputKey {
  arrowUp,
  arrowDown,
  arrowLeft,
  arrowRight,
  backspace,
  character,
  other,
}

/// Primitive desktop request, independent of Flutter key-event classes.
class DesktopDateInputRequest {
  const DesktopDateInputRequest({
    required this.key,
    this.character,
    this.hasModifier = false,
    this.shiftPressed = false,
    this.keyboardShortcutsEnabled = true,
  });

  final DesktopDateInputKey key;
  final String? character;
  final bool hasModifier;
  final bool shiftPressed;
  final bool keyboardShortcutsEnabled;
}

/// Primitive mobile software-keyboard replacement request.
///
/// Selection offsets are integers so the mobile policy remains pure Dart and
/// can be tested without Flutter bindings.
class MobileDateEditRequest {
  const MobileDateEditRequest({
    required this.oldText,
    required this.newText,
    required this.oldSelectionStart,
    required this.oldSelectionEnd,
  });

  final String oldText;
  final String newText;
  final int oldSelectionStart;
  final int oldSelectionEnd;
}
