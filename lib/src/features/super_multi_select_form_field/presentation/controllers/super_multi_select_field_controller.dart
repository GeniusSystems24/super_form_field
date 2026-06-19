// ============================================================
// features/super_multi_select_form_field/presentation/controllers/super_multi_select_field_controller.dart
// ------------------------------------------------------------
// The MVC controller (the Model) for a multi-select field. Owns the chosen
// value list, the open/closed dropdown state, and the search query; derives the
// error from the validator chain. Toggling an option adds/removes its value
// (capped at maxSelections); the menu stays open across toggles. Validation is
// silent until touched (the menu closes once) or the host forces it. Generic
// over the option value type. The controller never imports a widget.
// ============================================================

import 'package:flutter/widgets.dart';

import '../../../../core/core.dart';
import '../../domain/usecases/multi_select_logic.dart';

class SuperMultiSelectFieldController<T> extends ChangeNotifier {
  SuperMultiSelectFieldController({List<T>? initialValue})
      : _values = [...?initialValue] {
    searchText = TextEditingController();
    searchFocus = FocusNode();
    searchText.addListener(_onQuery);
  }

  late final TextEditingController searchText;
  late final FocusNode searchFocus;

  // ── value + interaction ──
  final List<T> _values;
  bool _open = false;
  bool _touched = false;
  String _query = '';

  // ── config (set by the View) ──
  List<SuperOption<T>> _options = const [];
  int? _maxSelections;
  List<Validator<List<T>>> _validators = const [];
  bool _forceError = false;
  ValidityChanged? _onValidity;
  ValueChanged<List<T>>? _onChanged;
  String? _lastReported;

  // ── reads ──
  List<T> get values => List.unmodifiable(_values);
  bool get isOpen => _open;
  bool get touched => _touched;
  String get query => _query;
  bool get isEmpty => _values.isEmpty;
  int get count => _values.length;

  bool isSelected(T value) => _values.contains(value);

  /// The options after applying the current search query.
  List<SuperOption<T>> get filtered => MultiSelectLogic.filter(_options, _query);

  /// The chosen options, in the options' declared order.
  List<SuperOption<T>> get selectedOptions =>
      _options.where((o) => _values.contains(o.value)).toList();

  /// True when the cap is reached and further options can't be added.
  bool get atCapacity => _maxSelections != null && _values.length >= _maxSelections!;

  String? get error => runValidators<List<T>>(values, _validators);
  String? get visibleError => (_touched || _forceError) && error != null ? error : null;

  // ── View → controller config ──
  void configure({
    required List<SuperOption<T>> options,
    int? maxSelections,
    required List<Validator<List<T>>> validators,
    required bool forceError,
    ValidityChanged? onValidity,
    ValueChanged<List<T>>? onChanged,
  }) {
    _options = options;
    _maxSelections = maxSelections;
    _validators = validators;
    _forceError = forceError;
    _onValidity = onValidity;
    _onChanged = onChanged;
  }

  void reportInitialValidity() => _reportValidity();

  // ── menu ──
  void open() {
    if (_open) return;
    _open = true;
    notifyListeners();
  }

  void close() {
    if (!_open) return;
    _open = false;
    _touched = true;
    searchText.clear();
    notifyListeners();
  }

  void toggleMenu() => _open ? close() : open();

  // ── selection ──
  /// Add or remove [option]'s value. No-op when disabled, or when adding past
  /// the maxSelections cap. Keeps the menu open.
  void toggle(SuperOption<T> option) {
    if (option.disabled) return;
    if (_values.contains(option.value)) {
      _values.remove(option.value);
    } else {
      if (atCapacity) return;
      _values.add(option.value);
    }
    _touched = true;
    _emit();
    notifyListeners();
  }

  /// Remove a single value (the chip × affordance).
  void removeValue(T value) {
    if (!_values.remove(value)) return;
    _touched = true;
    _emit();
    notifyListeners();
  }

  /// Replace the whole selection (external reset).
  void setValues(List<T> vs) {
    _values
      ..clear()
      ..addAll(vs);
    _emit();
    notifyListeners();
  }

  /// Clear all selections.
  void clear() {
    if (_values.isEmpty) return;
    _values.clear();
    _touched = true;
    _emit();
    notifyListeners();
  }

  void markTouched() {
    if (_touched) return;
    _touched = true;
    notifyListeners();
  }

  void _onQuery() {
    if (_query == searchText.text) return;
    _query = searchText.text;
    notifyListeners();
  }

  void _emit() {
    _onChanged?.call(values);
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
    searchText.removeListener(_onQuery);
    searchText.dispose();
    searchFocus.dispose();
    super.dispose();
  }
}
