// ============================================================
// features/super_select_form_field/presentation/controllers/super_select_field_controller.dart
// ------------------------------------------------------------
// The MVC controller (the Model) for a single-select field — the single source
// of truth the thin View renders. It owns the chosen value, the open/closed
// state of the dropdown, the search query (when searchable), and derives the
// error from the resolved validator chain. Validation is silent until the field
// is touched (the menu closes once) or the host forces it. Generic over the
// option value type. The controller never imports a widget.
// ============================================================

import 'package:flutter/widgets.dart';

import 'package:super_form_field/super_form_field.dart' show SuperOption;
import '../../../../core/utils/validators.dart';
import '../../domain/usecases/select_logic.dart';

class SuperSelectFieldController<T> extends ChangeNotifier {
  SuperSelectFieldController({T? initialValue}) : _value = initialValue {
    searchText = TextEditingController();
    searchFocus = FocusNode();
    searchText.addListener(_onQuery);
  }

  /// Backing controller for the in-menu search box.
  late final TextEditingController searchText;

  /// Focus node for the in-menu search box (autofocused when the menu opens).
  late final FocusNode searchFocus;

  // ── value + interaction ──
  T? _value;
  bool _open = false;
  bool _touched = false;
  String _query = '';

  // ── config (set by the View) ──
  List<SuperOption<T>> _options = const [];
  List<Validator<T?>> _validators = const [];
  bool _forceError = false;
  ValidityChanged? _onValidity;
  ValueChanged<T?>? _onChanged;
  String? _lastReported;

  // ── reads ──
  T? get value => _value;
  bool get isOpen => _open;
  bool get touched => _touched;
  String get query => _query;
  List<SuperOption<T>> get options => _options;

  /// The options after applying the current search query.
  List<SuperOption<T>> get filtered => SelectLogic.filter(_options, _query);

  /// The option whose value matches [value], or null.
  SuperOption<T>? get selectedOption {
    for (final o in _options) {
      if (o.value == _value) return o;
    }
    return null;
  }

  /// The raw validation error (independent of touched state).
  String? get error => runValidators<T?>(_value, _validators);

  /// The error to actually display — gated on touched / forceError.
  String? get visibleError =>
      (_touched || _forceError) && error != null ? error : null;

  // ── View → controller config ──
  void configure({
    required List<SuperOption<T>> options,
    required List<Validator<T?>> validators,
    required bool forceError,
    ValidityChanged? onValidity,
    ValueChanged<T?>? onChanged,
  }) {
    _options = options;
    _validators = validators;
    _forceError = forceError;
    _onValidity = onValidity;
    _onChanged = onChanged;
  }

  /// Reports the current validity once — call after the first frame so a host
  /// `onValidity` that calls setState never runs during build.
  void reportInitialValidity() => _reportValidity();

  // ── menu ──
  void open() {
    if (_open) return;
    _open = true;
    notifyListeners();
  }

  /// Close the menu (resets the search query and marks the field touched).
  void close() {
    if (!_open) return;
    _open = false;
    _touched = true;
    searchText.clear();
    notifyListeners();
  }

  void toggle() => _open ? close() : open();

  // ── selection ──
  /// Choose [option] (no-op when disabled); closes the menu.
  void select(SuperOption<T> option) {
    if (option.disabled) return;
    _value = option.value;
    _open = false;
    _touched = true;
    searchText.clear();
    _emit();
    notifyListeners();
  }

  /// Programmatically set the value (external reset / the × affordance).
  void setValue(T? v) {
    _value = v;
    _emit();
    notifyListeners();
  }

  /// Clear the selection.
  void clear() => setValue(null);

  /// Force the touched state (e.g. on a submit sweep).
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
    searchText.removeListener(_onQuery);
    searchText.dispose();
    searchFocus.dispose();
    super.dispose();
  }
}
