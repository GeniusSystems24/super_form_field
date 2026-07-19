// ============================================================
// features/super_date_form_field/domain/usecases/
// mobile_date_input_use_case.dart
// ------------------------------------------------------------
// Pure mobile interaction policy. It compares old/new software-keyboard values
// and converts the editing delta into a platform-neutral date-input intent.
// ============================================================

import 'date_input_intent.dart';

/// Converts a mobile IME or software-keyboard replacement delta into one intent.
///
/// Mobile keyboards usually replace a selection or insert text directly into
/// the editing value; they do not reliably emit hardware key events. This use
/// case therefore extracts the inserted or removed range while preserving the
/// controller's segmented date semantics.
class MobileDateInputUseCase
    implements DateInputUseCase<MobileDateEditRequest> {
  const MobileDateInputUseCase();

  @override
  DateInputIntent? execute(MobileDateEditRequest request) {
    if (request.oldText == request.newText) return null;

    final prefix = _commonPrefixLength(request.oldText, request.newText);
    final suffix = _commonSuffixLength(
      request.oldText,
      request.newText,
      prefix,
    );
    final oldEnd = request.oldText.length - suffix;
    final newEnd = request.newText.length - suffix;
    final removed = request.oldText.substring(prefix, oldEnd);
    final inserted = request.newText.substring(prefix, newEnd);

    final selectionStart = _validOffset(request.oldSelectionStart)
        ? request.oldSelectionStart
        : prefix;
    final selectionEnd = _validOffset(request.oldSelectionEnd)
        ? request.oldSelectionEnd
        : selectionStart;
    final hadSelection = selectionStart != selectionEnd;
    final targetOffset = hadSelection
        ? (selectionStart < selectionEnd ? selectionStart : selectionEnd)
        : prefix;

    final digits = inserted.replaceAll(_nonDigit, '');
    if (digits.isNotEmpty) {
      return DateInputIntent(
        type: DateInputIntentType.insertDigits,
        text: digits,
        offset: targetOffset,
      );
    }

    if (inserted.isNotEmpty && inserted.split('').every(_isSeparator)) {
      return DateInputIntent(
        type: DateInputIntentType.nextSegment,
        offset: targetOffset,
      );
    }

    if (inserted.isEmpty && removed.isNotEmpty) {
      return DateInputIntent(
        type: hadSelection || removed.length > 1
            ? DateInputIntentType.clearSegment
            : DateInputIntentType.backspace,
        offset: targetOffset,
      );
    }

    // Unknown IME/composing replacements fall back to deterministic full-text
    // normalization rather than allowing raw input to bypass the date mask.
    return DateInputIntent(
      type: DateInputIntentType.replaceText,
      text: request.newText,
      offset: targetOffset,
    );
  }

  static bool _validOffset(int value) => value >= 0;

  static bool _isSeparator(String character) => '-/.: '.contains(character);

  static int _commonPrefixLength(String a, String b) {
    final limit = a.length < b.length ? a.length : b.length;
    var index = 0;
    while (index < limit && a.codeUnitAt(index) == b.codeUnitAt(index)) {
      index++;
    }
    return index;
  }

  static int _commonSuffixLength(String a, String b, int prefixLength) {
    final maxA = a.length - prefixLength;
    final maxB = b.length - prefixLength;
    final limit = maxA < maxB ? maxA : maxB;
    var count = 0;
    while (count < limit &&
        a.codeUnitAt(a.length - 1 - count) ==
            b.codeUnitAt(b.length - 1 - count)) {
      count++;
    }
    return count;
  }

  static final RegExp _nonDigit = RegExp(r'[^0-9]');
}
