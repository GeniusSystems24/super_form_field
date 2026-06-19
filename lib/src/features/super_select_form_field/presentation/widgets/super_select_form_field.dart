// ============================================================
// features/super_select_form_field/presentation/widgets/super_select_form_field.dart
// ------------------------------------------------------------
// The View for the GeniusLink single-select field. A thin Flutter wrapper that
// builds the validator chain (domain usecase), drives a
// [SuperSelectFieldController] (the Model), and renders the FieldShell + a
// tappable FieldBox trigger that opens a FieldPopover → OptionMenu of
// OptionTiles. Optionally searchable (a MenuSearchField filters the list).
// Validation surfaces only through the suffix ErrorBadge. Light/dark + LTR/RTL.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/usecases/select_logic.dart';
import '../controllers/super_select_field_controller.dart';

/// A themeable, validated single-select dropdown on the GeniusLink foundation.
class SuperSelectFormField<T> extends StatefulWidget {
  const SuperSelectFormField({
    super.key,
    required this.options,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onValidity,
    this.label,
    this.required = false,
    this.placeholder,
    this.hint,
    this.density = FieldDensity.comfortable,
    this.disabled = false,
    this.readOnly = false,
    this.leadingIcon,
    this.searchable = false,
    this.searchHint = 'Search…',
    this.clearable = false,
    this.emptyLabel = 'No matches',
    this.validators = const [],
    this.forceError = false,
    this.arabic = false,
  });

  /// The choosable options.
  final List<SuperOption<T>> options;

  /// External controller — when null, the field manages its own.
  final SuperSelectFieldController<T>? controller;

  /// Seed value, used only when [controller] is null.
  final T? initialValue;

  final ValueChanged<T?>? onChanged;
  final ValidityChanged? onValidity;

  // ── chrome ──
  final String? label;
  final bool required;
  final String? placeholder;
  final String? hint;
  final FieldDensity density;
  final bool disabled;
  final bool readOnly;
  final IconData? leadingIcon;

  // ── behaviour ──
  /// Show a search box at the top of the menu that filters the options.
  final bool searchable;
  final String searchHint;

  /// Show a × to clear the selection while non-empty, enabled & editable.
  final bool clearable;

  /// Shown in the menu when the search filters everything out.
  final String emptyLabel;

  /// Extra custom validators, appended to the built-in chain.
  final List<Validator<T?>> validators;

  /// Force the error to display even before the field is touched.
  final bool forceError;
  final bool arabic;

  @override
  State<SuperSelectFormField<T>> createState() => _SuperSelectFormFieldState<T>();
}

class _SuperSelectFormFieldState<T> extends State<SuperSelectFormField<T>> {
  late SuperSelectFieldController<T> _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SuperSelectFieldController<T>(initialValue: widget.initialValue);
    _ownsController = widget.controller == null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperSelectFormField<T> old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      if (_ownsController) _controller.dispose();
      _controller = widget.controller ?? SuperSelectFieldController<T>(initialValue: widget.initialValue);
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
            selected: o.value == _controller.value,
            disabled: o.disabled,
            arabic: widget.arabic,
            onTap: () => _controller.select(o),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _controller.configure(
      options: widget.options,
      validators: SelectLogic.buildValidators<T>(
        required: widget.required,
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
        final error = widget.disabled ? null : _controller.visibleError;
        final selected = _controller.selectedOption;

        final trailing = <Widget>[
          if (widget.clearable && selected != null && _editable)
            FieldIconButton(
              icon: SffIcons.clear,
              tooltip: 'Clear',
              onPressed: _controller.clear,
            ),
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
          label: widget.label,
          required: widget.required,
          hint: widget.hint,
          hasError: error != null,
          arabic: widget.arabic,
          child: FieldPopover(
            open: _controller.isOpen,
            onDismiss: _controller.close,
            overlayBuilder: (context) => _menu(t),
            child: MouseRegion(
              cursor: _editable ? SystemMouseCursors.click : SystemMouseCursors.basic,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _editable ? _controller.toggle : null,
                child: FieldBox(
                  focused: _controller.isOpen,
                  error: error,
                  disabled: widget.disabled,
                  density: widget.density,
                  leading: widget.leadingIcon != null
                      ? Icon(widget.leadingIcon)
                      : (selected?.icon != null ? Icon(selected!.icon) : null),
                  trailing: trailing,
                  child: Text(
                    selected?.label ?? widget.placeholder ?? 'Select…',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SuperText.body.copyWith(
                      color: selected != null ? t.fg1 : t.fg4,
                      fontFamily: widget.arabic ? SuperTokens.arabicFont : SuperTokens.bodyFont,
                    ),
                    textAlign: widget.arabic ? TextAlign.right : TextAlign.left,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
