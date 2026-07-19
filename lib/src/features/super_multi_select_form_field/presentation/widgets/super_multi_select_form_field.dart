// ============================================================
// features/super_multi_select_form_field/presentation/widgets/super_multi_select_form_field.dart
// ------------------------------------------------------------
// The View for the GeniusLink multi-select field. A tappable FieldBox shows the
// chosen values as removable SuperChips (or the placeholder when empty) and a
// label-right count pill; tapping opens a FieldPopover → OptionMenu of checkable
// OptionTiles that stays open across toggles. Optionally searchable. Drives a
// [SuperMultiSelectFieldController] (the Model) and builds the validator chain
// from the domain usecase. Validation surfaces only through the suffix
// ErrorBadge. Light/dark + LTR/RTL.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
import '../../domain/usecases/multi_select_logic.dart';
import '../controllers/super_multi_select_field_controller.dart';

/// A themeable, validated multi-select dropdown on the GeniusLink foundation.
class SuperMultiSelectFormField<T> extends StatefulWidget {
  const SuperMultiSelectFormField({
    super.key,
    required this.options,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onValidity,
    this.decoration = const InputDecoration(),
    this.required = false,
    this.density = FieldDensity.comfortable,
    this.disabled = false,
    this.readOnly = false,
    this.searchable = false,
    this.searchHint = 'Search…',
    this.minSelections,
    this.maxSelections,
    this.showCount = true,
    this.emptyLabel = 'No matches',
    this.validators = const [],
    this.forceError = false,
    this.arabic = false,
  });

  /// The choosable options.
  final List<SuperOption<T>> options;

  final SuperMultiSelectFieldController<T>? controller;
  final List<T>? initialValue;

  final ValueChanged<List<T>>? onChanged;
  final ValidityChanged? onValidity;

  /// Canonical source for label, helper, hint, and adornment chrome.
  final InputDecoration decoration;

  // ── chrome ──
  final bool required;
  final FieldDensity density;
  final bool disabled;
  final bool readOnly;

  // ── behaviour ──
  final bool searchable;
  final String searchHint;

  /// Lower bound on the selection count (a validator).
  final int? minSelections;

  /// Hard cap on the selection count — further picks are blocked.
  final int? maxSelections;

  /// Show the `n selected` count pill in the label-right slot.
  final bool showCount;

  final String emptyLabel;

  final List<Validator<List<T>>> validators;
  final bool forceError;
  final bool arabic;

  @override
  State<SuperMultiSelectFormField<T>> createState() =>
      _SuperMultiSelectFormFieldState<T>();
}

class _SuperMultiSelectFormFieldState<T>
    extends State<SuperMultiSelectFormField<T>> {
  late SuperMultiSelectFieldController<T> _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        SuperMultiSelectFieldController<T>(initialValue: widget.initialValue);
    _ownsController = widget.controller == null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperMultiSelectFormField<T> old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      if (_ownsController) _controller.dispose();
      _controller =
          widget.controller ??
          SuperMultiSelectFieldController<T>(initialValue: widget.initialValue);
      _ownsController = widget.controller == null;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  bool get _editable => !widget.disabled && !widget.readOnly;

  Widget _menu(SuperThemeData t) {
    final filtered = _controller.filtered;
    return OptionMenu(
      header: widget.searchable
          ? MenuSearchField(
              controller: _controller.searchText,
              focusNode: _controller.searchFocus,
              hintText: widget.searchHint,
              arabic: widget.arabic,
            )
          : null,
      empty: Text(
        widget.emptyLabel,
        textAlign: TextAlign.center,
        style: SuperText.caption.copyWith(color: t.fg4),
      ),
      children: [
        for (final o in filtered)
          OptionTile(
            label: o.label,
            description: o.description,
            icon: o.icon,
            checkbox: true,
            selected: _controller.isSelected(o.value),
            // Block un-selected rows once the cap is hit.
            disabled:
                o.disabled ||
                (!_controller.isSelected(o.value) && _controller.atCapacity),
            arabic: widget.arabic,
            onTap: () => _controller.toggle(o),
          ),
      ],
    );
  }

  Widget _triggerContent(SuperThemeData t) {
    final chosen = _controller.selectedOptions;
    if (chosen.isEmpty) {
      return SffDecoration.buildHint(
        context,
        widget.decoration,
        fallback: 'Select…',
        arabic: widget.arabic,
        baseStyle: SuperText.body.copyWith(
          color: t.fg4,
          fontFamily: widget.arabic
              ? SuperThemeData.of(context).tokens.arabicFont
              : SuperThemeData.of(context).tokens.bodyFont,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Wrap(
        spacing: SuperThemeData.of(context).tokens.space1,
        runSpacing: SuperThemeData.of(context).tokens.space1,
        children: [
          for (final o in chosen)
            SuperChip(
              label: o.label,
              arabic: widget.arabic,
              onRemove: _editable
                  ? () => _controller.removeValue(o.value)
                  : null,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _controller.configure(
      options: widget.options,
      maxSelections: widget.maxSelections,
      validators: MultiSelectLogic.buildValidators<T>(
        required: widget.required,
        minSelections: widget.minSelections,
        maxSelections: widget.maxSelections,
        extra: widget.validators,
      ),
      forceError: widget.forceError,
      onValidity: widget.onValidity,
      onChanged: widget.onChanged,
    );

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final t = context.sffTheme;
        final error = widget.disabled
            ? null
            : SffDecoration.resolveError(
                widget.decoration,
                _controller.visibleError,
              );

        final hasDecorationCounter =
            widget.decoration.counter != null ||
            widget.decoration.counterText != null;
        final countPill = (!hasDecorationCounter &&
                widget.showCount &&
                _controller.count > 0)
            ? CountPill(label: '${_controller.count} selected')
            : null;

        final trailing = <Widget>[
          ...SffDecoration.buildTrailing(context, widget.decoration),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              _controller.isOpen ? SffIcons.chevronUp : SffIcons.chevronDown,
              size: 18,
              color: t.fg3,
            ),
          ),
        ];

        return FieldShell(
          decoration: widget.decoration,
          required: widget.required,
          hasError: error != null,
          arabic: widget.arabic,
          labelRight: countPill,
          child: FieldPopover(
            open: _controller.isOpen,
            onDismiss: _controller.close,
            overlayBuilder: (context) => _menu(t),
            child: MouseRegion(
              cursor: _editable
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _editable ? _controller.toggleMenu : null,
                child: FieldBox(
                  focused: _controller.isOpen,
                  error: error,
                  disabled: widget.disabled,
                  density: widget.density,
                  leading: SffDecoration.buildLeading(
                    context,
                    widget.decoration,
                  ),
                  trailing: trailing,
                  child: _triggerContent(t),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
