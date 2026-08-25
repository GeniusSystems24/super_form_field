import 'package:flutter/widgets.dart';
import 'package:super_core/super_core.dart' show Validator;

import '../../../../core/utils/validators.dart';
import '../../../super_date_form_field/super_date_form_field.dart';
import '../../domain/entities/super_date_range.dart';
import '../../domain/usecases/range_date_logic.dart';

/// Controller for [SuperRangeDateFormField].
///
/// The range controller owns two [SuperDateFieldController] instances so start
/// and end entry use exactly the same segmented keyboard input, parsing,
/// formatting, focus lifecycle, and malformed-date behavior as
/// [SuperDateFormField]. The aggregate controller is responsible only for
/// range-level state: fixed boundaries, min/max guards for programmatic picker
/// updates, start-before-end validation, and emitting a typed [SuperDateRange].
class SuperRangeDateFieldController extends ChangeNotifier {
  SuperRangeDateFieldController({
    SuperDateRange? initialValue,
    bool isStartFixed = false,
    bool isEndFixed = false,
    FocusNode? focusNode,
    FocusNode? startFocusNode,
    FocusNode? endFocusNode,
    this.formFieldKey,
    this.isHiden = false,
  }) : _isStartFixed = isStartFixed,
       _isEndFixed = isEndFixed {
    startController = SuperDateFieldController(
      initialValue: initialValue?.start,
      isFixed: isStartFixed,
      focusNode: startFocusNode ?? focusNode,
    );
    endController = SuperDateFieldController(
      initialValue: initialValue?.end,
      isFixed: isEndFixed,
      focusNode: endFocusNode,
    );
    text = TextEditingController();

    _lastStartDate = startDate;
    _lastEndDate = endDate;
    _syncCombinedText();

    startController.addListener(_onBoundaryControllerChanged);
    endController.addListener(_onBoundaryControllerChanged);
  }

  /// Date controller backing the editable start-date input.
  late final SuperDateFieldController startController;

  /// Date controller backing the editable end-date input.
  late final SuperDateFieldController endController;

  /// Compatibility mirror of the old combined range text.
  ///
  /// The range field no longer renders this controller. Use [startText] and
  /// [endText] for direct access to the two editable buffers.
  late final TextEditingController text;

  /// Direct access to the start input buffer.
  TextEditingController get startText => startController.text;

  /// Direct access to the end input buffer.
  TextEditingController get endText => endController.text;

  /// Compatibility alias for callers that previously supplied/read one focus
  /// node. It now represents the start-date input.
  FocusNode? get focusNode => startController.focusNode;

  GlobalKey<FormFieldState<SuperDateRange?>>? formFieldKey;

  /// Compatibility spelling retained to match other package controllers.
  bool isHiden;

  bool _isStartFixed;
  bool _isEndFixed;
  bool _touched = false;
  bool _disposed = false;
  bool _syncingBoundaries = false;

  DateTime? _minDate;
  DateTime? _maxDate;
  List<Validator<SuperDateRange?>> _validators = const [];
  bool _forceError = false;
  String _incompleteMessage = 'Select both a start date and an end date';
  String _invalidMessage = 'Enter a valid date';
  FormValidityChanged? _onValidity;
  ValueChanged<SuperDateRange?>? _onChanged;
  String? _lastReportedError;
  DateTime? _lastStartDate;
  DateTime? _lastEndDate;
  String _separator = ' → ';

  DateTime? get startDate => startController.value;
  DateTime? get endDate => endController.value;

  SuperDateRange? get value {
    final start = startDate;
    final end = endDate;
    if (start == null || end == null) return null;
    return SuperDateRange(start: start, end: end);
  }

  bool get touched =>
      _touched || startController.touched || endController.touched;

  bool get focused => startController.focused || endController.focused;

  bool get hasPartialRange => (startDate == null) != (endDate == null);

  bool get isStartFixed => _isStartFixed;
  set isStartFixed(bool value) {
    if (_isStartFixed == value) return;
    _isStartFixed = value;
    _syncingBoundaries = true;
    startController.isFixed.value = value;
    _syncingBoundaries = false;
    notifyListeners();
  }

  bool get isEndFixed => _isEndFixed;
  set isEndFixed(bool value) {
    if (_isEndFixed == value) return;
    _isEndFixed = value;
    _syncingBoundaries = true;
    endController.isFixed.value = value;
    _syncingBoundaries = false;
    notifyListeners();
  }

  bool get isFullyFixed => _isStartFixed && _isEndFixed;

  DateTime? get minDate => _minDate;
  DateTime? get maxDate => _maxDate;

  String? get error {
    if (startController.malformed || endController.malformed) {
      return _invalidMessage;
    }
    if (hasPartialRange) return _incompleteMessage;
    return runValidators(value, _validators);
  }

  String? get visibleError =>
      (touched || _forceError) && error != null ? error : null;

  void configure({
    required List<Validator<SuperDateRange?>> validators,
    required bool forceError,
    DateTime? minDate,
    DateTime? maxDate,
    String incompleteMessage = 'Select both a start date and an end date',
    String invalidMessage = 'Enter a valid date',
    String separator = ' → ',
    FormValidityChanged? onValidity,
    ValueChanged<SuperDateRange?>? onChanged,
  }) {
    _validators = validators;
    _forceError = forceError;
    _minDate = minDate == null ? null : RangeDateLogic.dateOnly(minDate);
    _maxDate = maxDate == null ? null : RangeDateLogic.dateOnly(maxDate);
    _incompleteMessage = incompleteMessage;
    _invalidMessage = invalidMessage;
    _onValidity = onValidity;
    _onChanged = onChanged;
    if (_separator != separator) {
      _separator = separator;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) _syncCombinedText();
      });
    }
  }

  void reportInitialValidity() => _reportValidity();

  void markTouched() {
    if (_touched) return;
    _touched = true;
    startController.markTouched();
    endController.markTouched();
    _reportValidity();
    notifyListeners();
  }

  /// Sets both boundaries while preserving whichever boundary is fixed.
  void setValue(SuperDateRange? range) => setRange(range);

  void setRange(SuperDateRange? range, {bool markTouched = false}) {
    final proposedStart = _isStartFixed
        ? startDate
        : range == null
        ? null
        : RangeDateLogic.dateOnly(range.start);
    final proposedEnd = _isEndFixed
        ? endDate
        : range == null
        ? null
        : RangeDateLogic.dateOnly(range.end);

    if (!_canAccept(proposedStart, proposedEnd)) return;
    _commitBoundaries(
      start: proposedStart,
      end: proposedEnd,
      markTouched: markTouched,
    );
  }

  void pickRange(SuperDateRange range) {
    setRange(range, markTouched: true);
  }

  void setStartDate(DateTime? date, {bool markTouched = false}) {
    if (_isStartFixed) return;
    final proposed = date == null ? null : RangeDateLogic.dateOnly(date);
    if (proposed != null && !_withinBounds(proposed)) return;
    final end = endDate;
    if (proposed != null && end != null && proposed.isAfter(end)) return;
    _commitBoundaries(start: proposed, end: end, markTouched: markTouched);
  }

  void setEndDate(DateTime? date, {bool markTouched = false}) {
    if (_isEndFixed) return;
    final proposed = date == null ? null : RangeDateLogic.dateOnly(date);
    if (proposed != null && !_withinBounds(proposed)) return;
    final start = startDate;
    if (proposed != null && start != null && proposed.isBefore(start)) return;
    _commitBoundaries(start: start, end: proposed, markTouched: markTouched);
  }

  /// Clears only mutable boundaries. Fixed dates are retained.
  void clear() {
    if (isFullyFixed) return;
    _commitBoundaries(
      start: _isStartFixed ? startDate : null,
      end: _isEndFixed ? endDate : null,
      markTouched: true,
    );
  }

  bool _canAccept(DateTime? start, DateTime? end) {
    if (start != null && !_withinBounds(start)) return false;
    if (end != null && !_withinBounds(end)) return false;
    if (start != null && end != null && start.isAfter(end)) return false;
    return true;
  }

  bool _withinBounds(DateTime date) =>
      RangeDateLogic.isWithinBounds(date, minDate: _minDate, maxDate: _maxDate);

  void _commitBoundaries({
    required DateTime? start,
    required DateTime? end,
    required bool markTouched,
  }) {
    _syncingBoundaries = true;
    try {
      _writeBoundary(
        controller: startController,
        value: start,
        fixed: _isStartFixed,
        markTouched: markTouched,
      );
      _writeBoundary(
        controller: endController,
        value: end,
        fixed: _isEndFixed,
        markTouched: markTouched,
      );
    } finally {
      _syncingBoundaries = false;
    }

    if (markTouched) _touched = true;
    _publishBoundarySnapshot();
  }

  void _writeBoundary({
    required SuperDateFieldController controller,
    required DateTime? value,
    required bool fixed,
    required bool markTouched,
  }) {
    if (fixed) return;
    if (markTouched) {
      if (value == null) {
        controller.clear();
      } else {
        controller.pick(value);
      }
      return;
    }
    controller.setValue(value);
  }

  void _onBoundaryControllerChanged() {
    if (_disposed || _syncingBoundaries) return;
    _publishBoundarySnapshot();
  }

  void _publishBoundarySnapshot() {
    final nextStart = startDate;
    final nextEnd = endDate;
    final changed = nextStart != _lastStartDate || nextEnd != _lastEndDate;

    _lastStartDate = nextStart;
    _lastEndDate = nextEnd;
    _syncCombinedText();

    if (changed) _onChanged?.call(value);
    _reportValidity();
    notifyListeners();
  }

  void _syncCombinedText() {
    final next = RangeDateLogic.formatRange(
      startDate,
      endDate,
      separator: _separator,
    );
    if (text.text == next) return;
    text.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  void _reportValidity() {
    final next = error;
    if (next == _lastReportedError) return;
    _lastReportedError = next;
    _onValidity?.call(next);
  }

  @override
  void dispose() {
    _disposed = true;
    startController.removeListener(_onBoundaryControllerChanged);
    endController.removeListener(_onBoundaryControllerChanged);
    startController.dispose();
    endController.dispose();
    text.dispose();
    super.dispose();
  }
}
