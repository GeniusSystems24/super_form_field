// ============================================================
// features/super_date_form_field/presentation/controllers/super_date_field_controller.dart
// ------------------------------------------------------------
// The MVC controller (Model) for a date field. The buffer is a fixed-width,
// zero-padded set of segments laid out per the configured format — full
// `YYYY-MM-DD`, or any contiguous subset (`YYYY-MM`, `YYYY`, `MM-DD`, `MM`,
// `DD`). Editing is SEGMENT-AWARE and keeps the format at all times: digits
// shift into the active segment from the RIGHT, always shown padded — typing the
// year reads `0002 → 0020 → 0202 → 2024`, then advances to the next segment;
// month/day behave the same at two digits. `↑`/`↓` step the active segment,
// `←`/`→` move between segments. Never imports a widget.
// ============================================================

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/utils/validators.dart';
import '../../domain/usecases/date_logic.dart';

class SuperDateFieldController extends ChangeNotifier {
  SuperDateFieldController({DateTime? initialValue})
      : _value = initialValue == null ? null : DateLogic.dateOnly(initialValue) {
    _dispFromValue();
    text = TextEditingController(text: _composeString().text);
    _lastComposed = text.text;
    focusNode = FocusNode(onKeyEvent: _onKey);
    text.addListener(_onTextChanged);
    focusNode.addListener(_onFocusChanged);
  }

  late final TextEditingController text;
  late final FocusNode focusNode;

  // ── value + interaction ──
  DateTime? _value;
  bool _touched = false;
  bool _syncing = false; // guards programmatic text writes from re-entrancy

  // ── segmented editing state ──
  // Segment kinds: 0 = year, 1 = month, 2 = day. _order is the present kinds in
  // display order. _disp[kind] is the zero-padded display ('' if empty);
  // _committed[kind] marks a segment as finalized (counts toward the value).
  // _buf holds the raw typed digits for the ACTIVE segment; _ai indexes _order.
  List<int> _order = const [0, 1, 2];
  final List<String> _disp = ['', '', ''];
  final List<bool> _committed = [false, false, false];
  String _buf = '';
  int _ai = 0;
  bool _fresh = true;
  String _lastComposed = '';

  // ── validation config (set by the View) ──
  List<Validator<DateTime?>> _validators = const [];
  bool _forceError = false;
  String _malformedMessage = 'Enter a valid date';
  ValidityChanged? _onValidity;
  ValueChanged<DateTime?>? _onChanged;
  String? _lastReported;

  // ── stepping config (set by the View) ──
  bool _keyboardEnabled = true;
  bool _readOnly = false;

  // ── reads ──
  DateTime? get value => _value;
  bool get touched => _touched;
  bool get focused => focusNode.hasFocus;

  /// The active segment kind (0 year · 1 month · 2 day).
  int get activeSegment => _order[_ai];

  int _width(int kind) => kind == 0 ? 4 : 2;

  /// True when the buffer holds text but no complete value yet.
  bool get malformed => text.text.trim().isNotEmpty && _value == null;

  String? get error {
    if (malformed) return _malformedMessage;
    return runValidators(_value, _validators);
  }

  /// The error shown to the user — gated on first blur ([touched]) or
  /// [_forceError]. Errors surface via the suffix badge, never inline.
  String? get visibleError => (_touched || _forceError) && error != null ? error : null;

  // ── View → controller config ──
  void configure({
    required List<Validator<DateTime?>> validators,
    required bool forceError,
    List<int> segments = const [0, 1, 2],
    String malformedMessage = 'Enter a valid date',
    bool keyboardEnabled = true,
    bool readOnly = false,
    ValidityChanged? onValidity,
    ValueChanged<DateTime?>? onChanged,
  }) {
    _validators = validators;
    _forceError = forceError;
    _malformedMessage = malformedMessage;
    _keyboardEnabled = keyboardEnabled;
    _readOnly = readOnly;
    _onValidity = onValidity;
    _onChanged = onChanged;

    if (!_sameOrder(segments, _order)) {
      _order = List<int>.from(segments);
      _ai = 0;
      _buf = '';
      _fresh = true;
      _dispFromValue();
      // Re-render after the frame so we don't mutate the editing controller
      // mid-build of a mounted field.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _render();
      });
    }
  }

  bool _sameOrder(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Reports the current validity once — call after the first frame so a host
  /// `onValidity` that calls setState never runs during build.
  void reportInitialValidity() => _reportValidity();

  /// Marks the field touched without changing its value (submit-sweep helper).
  void markTouched() {
    if (_touched) return;
    _touched = true;
    notifyListeners();
  }

  // ── external value setters ────────────────────────────────────────────────

  /// Programmatically set the value (external reset / linked range).
  void setValue(DateTime? v) {
    _value = v == null ? null : DateLogic.dateOnly(v);
    _dispFromValue();
    _ai = 0;
    _buf = '';
    _fresh = true;
    _recomputeValue();
    _render();
    _emit();
    notifyListeners();
  }

  /// Pick a date from the calendar popup: commits the present segments, marks
  /// touched, and writes the formatted text.
  void pick(DateTime date) {
    final d = DateLogic.dateOnly(date);
    for (final k in _order) {
      final v = k == 0 ? d.year : (k == 1 ? d.month : d.day);
      _disp[k] = v.toString().padLeft(_width(k), '0');
      _committed[k] = true;
    }
    _ai = 0;
    _buf = '';
    _fresh = true;
    _touched = true;
    _recomputeValue();
    _render();
    _emit();
    notifyListeners();
  }

  /// Clear the field.
  void clear() {
    for (final k in [0, 1, 2]) {
      _disp[k] = '';
      _committed[k] = false;
    }
    _value = null;
    _ai = 0;
    _buf = '';
    _fresh = true;
    _touched = true;
    _render();
    _emit();
    notifyListeners();
  }

  // ── arrow-key segment stepping ───────────────────────────────────────────

  /// Segment kind (0 year · 1 month · 2 day) for a cursor [offset] in a
  /// canonical `YYYY-MM-DD` buffer. Retained for the full format.
  static int segmentForOffset(int offset) {
    if (offset <= 4) return 0;
    if (offset <= 7) return 1;
    return 2;
  }

  /// Step the segment under the cursor by [direction] (±1).
  void stepAtCursor(int direction) {
    final off = text.selection.baseOffset;
    final i = off < 0 ? _ai : _indexForOffset(off);
    stepSegment(_order[i], direction);
  }

  /// Step a present [kind] (0 year · 1 month · 2 day) by [direction] (±1). The
  /// segment wraps within its own range (month 1↔12, day 1↔month-length); the
  /// year is unbounded above. Seeds empty segments from today first so the value
  /// resolves.
  void stepSegment(int kind, int direction) {
    if (_readOnly || !_order.contains(kind)) return;
    _ai = _order.indexOf(kind);
    // Seed any empty present segments from today so the value can form.
    final now = DateLogic.dateOnly(DateTime.now());
    for (final k in _order) {
      if (_disp[k].isEmpty) {
        final tv = k == 0 ? now.year : (k == 1 ? now.month : now.day);
        _disp[k] = tv.toString().padLeft(_width(k), '0');
        _committed[k] = true;
      }
    }
    final cur = int.parse(_disp[kind]);
    int v;
    if (kind == 0) {
      v = cur + direction;
      if (v < 1) v = 1;
    } else if (kind == 1) {
      v = ((cur - 1 + direction) % 12 + 12) % 12 + 1;
    } else {
      final maxd = _dayMax();
      v = ((cur - 1 + direction) % maxd + maxd) % maxd + 1;
    }
    _disp[kind] = v.toString().padLeft(_width(kind), '0');
    _committed[kind] = true;
    if (kind == 0 || kind == 1) _clampDayToMonth();
    _buf = '';
    _fresh = true;
    _touched = true;
    _recomputeValue();
    _render();
    _emit();
    notifyListeners();
  }

  int _dayMax() {
    final hasY = _order.contains(0) && _disp[0].isNotEmpty;
    final hasM = _order.contains(1) && _disp[1].isNotEmpty;
    final y = hasY ? int.parse(_disp[0]) : DateTime.now().year;
    final m = hasM ? int.parse(_disp[1]) : 1;
    return DateTime(y, m + 1, 0).day;
  }

  void _clampDayToMonth() {
    if (!_order.contains(2) || _disp[2].isEmpty) return;
    final maxd = _dayMax();
    if (int.parse(_disp[2]) > maxd) _disp[2] = maxd.toString().padLeft(2, '0');
  }

  // ── segmented typing ──────────────────────────────────────────────────────

  void _dispFromValue() {
    for (final k in [0, 1, 2]) {
      _disp[k] = '';
      _committed[k] = false;
    }
    if (_value != null) {
      for (final k in _order) {
        final v = k == 0 ? _value!.year : (k == 1 ? _value!.month : _value!.day);
        _disp[k] = v.toString().padLeft(_width(k), '0');
        _committed[k] = true;
      }
    }
  }

  /// Shift a digit into the active segment from the right (always zero-padded to
  /// width), auto-advancing when the segment fills (or can't take a 2nd digit).
  void _typeDigit(String d) {
    if (_readOnly) return;
    final kind = _order[_ai];
    final w = _width(kind);
    if (_fresh) {
      _buf = d;
      _fresh = false;
    } else {
      _buf = _buf + d;
      if (_buf.length > w) _buf = _buf.substring(_buf.length - w);
    }
    _disp[kind] = _buf.padLeft(w, '0');
    _committed[kind] = false;
    final n = int.parse(_buf);
    final full = _buf.length >= w;
    final early = (kind == 1 && _buf.length == 1 && n > 1) || (kind == 2 && _buf.length == 1 && n > 3);
    if (full || early) _finalizeAndAdvance();
    _commit();
  }

  void _commitActive() {
    final kind = _order[_ai];
    if (_buf.isEmpty) return;
    var n = int.parse(_buf);
    if (kind == 1) n = n.clamp(1, 12);
    if (kind == 2) n = n.clamp(1, 31);
    _disp[kind] = kind == 0 ? _buf.padLeft(4, '0') : n.toString().padLeft(2, '0');
    _committed[kind] = true;
  }

  void _finalizeAndAdvance() {
    _commitActive();
    if (_order[_ai] != 0) _clampDayToMonth();
    if (_ai < _order.length - 1) _ai++;
    _buf = '';
    _fresh = true; // terminal segment re-arms to overwrite
  }

  void _backspace() {
    if (_readOnly) return;
    final kind = _order[_ai];
    final w = _width(kind);
    if (_buf.isNotEmpty) {
      _buf = _buf.substring(0, _buf.length - 1);
      _disp[kind] = _buf.isEmpty ? '' : _buf.padLeft(w, '0');
      _committed[kind] = false;
    } else if (_ai > 0) {
      _ai--;
      final pk = _order[_ai];
      _buf = _disp[pk].isEmpty ? '' : int.parse(_disp[pk]).toString();
      _committed[pk] = false;
      _fresh = false;
    }
    _commit();
  }

  /// A separator key (`-` `/` `.` `:` space) commits the active segment and
  /// jumps to the next one.
  void _jumpSeparator() {
    if (_readOnly) return;
    if (_buf.isNotEmpty) _commitActive();
    if (_ai < _order.length - 1) {
      _ai++;
      _buf = '';
      _fresh = true;
    }
    _commit();
  }

  void _moveActive(int delta) {
    if (_buf.isNotEmpty) _commitActive();
    final ni = _ai + delta;
    if (ni >= 0 && ni < _order.length) {
      _ai = ni;
      _buf = '';
      _fresh = true;
    }
    _commit();
  }

  // ── value + render ──────────────────────────────────────────────────────

  void _commit() {
    _recomputeValue();
    _render();
    _emit();
    notifyListeners();
  }

  void _recomputeValue() {
    if (!_order.every((k) => _committed[k])) {
      _value = null;
      return;
    }
    final y = _order.contains(0) ? int.parse(_disp[0]) : null;
    final m = _order.contains(1) ? int.parse(_disp[1]) : null;
    final dd = _order.contains(2) ? int.parse(_disp[2]) : null;
    _value = DateLogic.compose(year: y, month: m, day: dd);
  }

  ({String text, int selStart, int selEnd}) _composeString() {
    var maxShown = _ai;
    for (var i = 0; i < _order.length; i++) {
      if (_disp[_order[i]].isNotEmpty && i > maxShown) maxShown = i;
    }
    final buf = StringBuffer();
    var selStart = 0;
    var selEnd = 0;
    for (var i = 0; i <= maxShown; i++) {
      if (i > 0) buf.write('-');
      final start = buf.length;
      buf.write(_disp[_order[i]]);
      if (i == _ai) {
        selStart = start;
        selEnd = buf.length;
      }
    }
    return (text: buf.toString(), selStart: selStart, selEnd: selEnd);
  }

  void _render() {
    final c = _composeString();
    _lastComposed = c.text;
    _syncing = true;
    text.value = TextEditingValue(
      text: c.text,
      selection: TextSelection(baseOffset: c.selStart, extentOffset: c.selEnd),
    );
    _syncing = false;
  }

  /// The active [_order] index for a cursor [offset] — the count of separators
  /// before it (works for any format width).
  int _indexForOffset(int offset) {
    final t = text.text;
    if (t.isEmpty) return 0;
    var idx = 0;
    for (var i = 0; i < offset && i < t.length; i++) {
      if (t[i] == '-') idx++;
    }
    return idx.clamp(0, _order.length - 1);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (_readOnly) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final hw = HardwareKeyboard.instance;
    // Let OS / app shortcuts (copy, paste, select-all, …) through.
    if (hw.isControlPressed || hw.isMetaPressed || hw.isAltPressed) return KeyEventResult.ignored;
    final k = event.logicalKey;

    if (k == LogicalKeyboardKey.arrowUp && _keyboardEnabled && !hw.isShiftPressed) {
      stepAtCursor(1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowDown && _keyboardEnabled && !hw.isShiftPressed) {
      stepAtCursor(-1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowLeft && !hw.isShiftPressed) {
      _moveActive(-1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowRight && !hw.isShiftPressed) {
      _moveActive(1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.backspace) {
      _backspace();
      return KeyEventResult.handled;
    }
    final ch = event.character;
    if (ch != null && ch.length == 1) {
      if (RegExp(r'[0-9]').hasMatch(ch)) {
        _typeDigit(ch);
        return KeyEventResult.handled;
      }
      if ('-/.: '.contains(ch)) {
        _jumpSeparator();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  // Fires for paste / IME text changes AND selection-only changes (clicks).
  void _onTextChanged() {
    if (_syncing) return;
    if (text.text == _lastComposed) {
      final off = text.selection.baseOffset;
      if (off >= 0) {
        if (_buf.isNotEmpty) _commitActive();
        _ai = _indexForOffset(off);
        _buf = '';
        _fresh = true;
      }
      return;
    }
    // Paste / IME fallback: take the digits, fill segments left-to-right.
    final digits = text.text.replaceAll(RegExp(r'[^0-9]'), '');
    var pos = 0;
    for (final k in _order) {
      final w = _width(k);
      if (pos >= digits.length) {
        _disp[k] = '';
        _committed[k] = false;
        continue;
      }
      final chunk = digits.substring(pos, (pos + w).clamp(0, digits.length));
      pos += chunk.length;
      var n = int.parse(chunk);
      if (k == 1) n = n.clamp(1, 12);
      if (k == 2) n = n.clamp(1, 31);
      _disp[k] = k == 0 ? chunk.padLeft(4, '0') : n.toString().padLeft(2, '0');
      _committed[k] = chunk.length == w;
    }
    _ai = _order.length - 1;
    _buf = '';
    _fresh = true;
    _recomputeValue();
    _render();
    _emit();
    notifyListeners();
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus) {
      _ai = 0;
      _buf = '';
      _fresh = true;
      _render();
    } else {
      _touched = true;
      if (_buf.isNotEmpty) _commitActive();
      _recomputeValue();
      _render();
      _emit();
    }
    notifyListeners();
  }

  void _emit() {
    _onChanged?.call(_value);
    _reportValidity();
  }

  void _reportValidity() {
    final e = error;
    if (e != _lastReported) {
      _lastReported = e;
      _onValidity?.call(e);
    }
  }

  @override
  void dispose() {
    text.removeListener(_onTextChanged);
    focusNode.removeListener(_onFocusChanged);
    text.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
