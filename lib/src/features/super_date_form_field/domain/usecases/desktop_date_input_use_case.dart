// ============================================================
// features/super_date_form_field/domain/usecases/
// desktop_date_input_use_case.dart
// ------------------------------------------------------------
// Pure desktop interaction policy. Presentation converts Flutter KeyEvent data
// into DesktopDateInputRequest before invoking this use case.
// ============================================================

import 'date_input_intent.dart';

/// Converts desktop hardware-key input into date-editing intents.
///
/// OS and application shortcuts are deliberately ignored so copy, paste,
/// select-all, and other host behavior remain available.
class DesktopDateInputUseCase
    implements DateInputUseCase<DesktopDateInputRequest> {
  const DesktopDateInputUseCase();

  @override
  DateInputIntent? execute(DesktopDateInputRequest request) {
    if (request.hasModifier) return null;

    switch (request.key) {
      case DesktopDateInputKey.arrowUp:
        if (!request.keyboardShortcutsEnabled || request.shiftPressed) {
          return null;
        }
        return const DateInputIntent(type: DateInputIntentType.stepUp);
      case DesktopDateInputKey.arrowDown:
        if (!request.keyboardShortcutsEnabled || request.shiftPressed) {
          return null;
        }
        return const DateInputIntent(type: DateInputIntentType.stepDown);
      case DesktopDateInputKey.arrowLeft:
        if (request.shiftPressed) return null;
        return const DateInputIntent(
          type: DateInputIntentType.previousSegment,
        );
      case DesktopDateInputKey.arrowRight:
        if (request.shiftPressed) return null;
        return const DateInputIntent(type: DateInputIntentType.nextSegment);
      case DesktopDateInputKey.backspace:
        return const DateInputIntent(type: DateInputIntentType.backspace);
      case DesktopDateInputKey.character:
        final character = request.character;
        if (character == null || character.length != 1) return null;
        if (_digit.hasMatch(character)) {
          return DateInputIntent(
            type: DateInputIntentType.insertDigits,
            text: character,
          );
        }
        if (_separators.contains(character)) {
          return const DateInputIntent(
            type: DateInputIntentType.nextSegment,
          );
        }
        return null;
      case DesktopDateInputKey.other:
        return null;
    }
  }

  static final RegExp _digit = RegExp(r'^[0-9]$');
  static const String _separators = '-/.: ';
}
