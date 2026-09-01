// ============================================================
// features/super_dropdown_button/presentation/widgets/super_dropdown_button.dart
// ------------------------------------------------------------
// Typed dropdown controls that use the package FieldBox + FieldPopover +
// OptionMenu foundation instead of Material's DropdownButton visuals.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
import '../controllers/super_dropdown_editing_controller.dart';

/// A typed dropdown button rendered with the Super Form Field design system.
///
/// Supply [options] and [onChanged], then control the selected value with either
/// [value] or [controller]. A controller is useful when the selection must be
/// changed programmatically without rebuilding the parent widget.
///
/// When [controller] is provided, its value is the source of truth and [value]
/// should be left null.
///
/// When [onChanged] is null, or when [disabled] is true, the button is disabled.
class SuperDropdownButton<T> extends StatefulWidget {
  const SuperDropdownButton({
    super.key,
    required this.options,
    required this.onChanged,
    this.controller,
    this.value,
    this.decoration = const InputDecoration(),
    this.density = FieldDensity.comfortable,
    this.disabled = false,
    this.focusNode,
    this.autofocus = false,
    this.menuMaxHeight = 280,
    this.menuWidth,
    this.icon,
    this.style,
    this.validationPosition,
    this.arabic = false,
    this.onTap,
  }) : assert(
         controller == null || value == null,
         'value must be null when a controller is provided.',
       );

  /// The values displayed in the dropdown menu.
  final List<SuperOption<T>> options;

  /// Controls the selected value programmatically.
  ///
  /// When non-null, [controller] is the source of truth and [value] must be
  /// null. The widget listens to the controller and rebuilds when its value
  /// changes.
  final SuperDropdownEditingController<T>? controller;

  /// The currently selected value when [controller] is not used.
  final T? value;

  /// Called after the user chooses an enabled option.
  ///
  /// Set this to null to disable the control.
  final ValueChanged<T?>? onChanged;

  /// Supplies hint, prefix, suffix, and external error decoration.
  final InputDecoration decoration;

  /// Controls the height of the design-system field box.
  final FieldDensity density;

  /// Forces the control into its disabled state.
  final bool disabled;

  /// Optional focus node used for keyboard interaction.
  final FocusNode? focusNode;

  /// Whether this control requests focus when first built.
  final bool autofocus;

  /// Maximum height of the floating option menu.
  final double menuMaxHeight;

  /// Optional explicit menu width. By default the menu matches the button.
  final double? menuWidth;

  /// Dropdown affordance. Defaults to [Icons.keyboard_arrow_down_rounded].
  final Widget? icon;

  /// Optional text style merged over the package body style.
  final TextStyle? style;

  /// Controls whether the decoration error badge is rendered in the suffix.
  ///
  /// Bare dropdown buttons do not own a label row or under-box area, so
  /// non-suffix values only keep the error border.
  final ValidationPosition? validationPosition;

  /// Uses the package Arabic font fallback for generated text.
  final bool arabic;

  /// Called when the enabled trigger is tapped, before the menu toggles.
  final VoidCallback? onTap;

  @override
  State<SuperDropdownButton<T>> createState() => _SuperDropdownButtonState<T>();
}

class _SuperDropdownButtonState<T> extends State<SuperDropdownButton<T>> {
  late FocusNode _focusNode;
  bool _ownsFocusNode = false;
  bool _open = false;

  bool get _enabled =>
      !widget.disabled &&
      !(widget.controller?.isFixed.value ?? false) &&
      widget.onChanged != null;

  T? get _effectiveValue => widget.controller?.value ?? widget.value;

  SuperOption<T>? get _selected {
    final selectedValue = _effectiveValue;
    for (final option in widget.options) {
      if (option.value == selectedValue) return option;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _attachFocusNode();
    widget.controller?.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant SuperDropdownButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      widget.controller?.addListener(_handleControllerChanged);
    }

    if (oldWidget.focusNode != widget.focusNode ||
        oldWidget.controller?.focusNode != widget.controller?.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _attachFocusNode();
    }

    if (!_enabled && _open) {
      _open = false;
    }
  }

  void _attachFocusNode() {
    final controllerFocus = widget.controller?.focusNode;
    _ownsFocusNode = widget.focusNode == null && controllerFocus == null;
    _focusNode = widget.focusNode ?? controllerFocus ?? FocusNode();
  }

  void _handleControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!_enabled) return;
    widget.onTap?.call();
    _focusNode.requestFocus();
    setState(() => _open = !_open);
  }

  void _dismiss() {
    if (_open) setState(() => _open = false);
  }

  void _select(SuperOption<T> option) {
    if (option.disabled || !_enabled) return;

    final controller = widget.controller;
    if (controller != null && controller.value != option.value) {
      controller.value = option.value;
    }

    widget.onChanged?.call(option.value);
    _dismiss();
    _focusNode.requestFocus();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !_enabled) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _dismiss();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (!_open) setState(() => _open = true);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _menu(BuildContext context) {
    final selectedValue = _effectiveValue;
    final menu = OptionMenu(
      maxHeight: widget.menuMaxHeight,
      children: [
        for (final option in widget.options)
          OptionTile(
            label: option.label,
            description: option.description,
            icon: option.icon,
            selected: option.value == selectedValue,
            disabled: option.disabled,
            arabic: widget.arabic,
            onTap: option.disabled ? null : () => _select(option),
          ),
      ],
    );

    if (widget.menuWidth != null) {
      return SizedBox(width: widget.menuWidth, child: menu);
    }
    return menu;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller?.isHiden ?? false) return const SizedBox.shrink();
    final t = context.sffTheme;
    final tokens = SuperThemeData.of(context).tokens;
    final selected = _selected;
    final error = widget.decoration.errorText;
    final validationPosition =
        widget.validationPosition ?? ValidationPosition.suffixIcon;
    final selectedStyle = SffDecoration.mergeStyle(
      context.sffTextTheme.body.copyWith(
        color: t.fg1,
        fontFamily: widget.arabic ? tokens.arabicFont : null,
      ),
      widget.style,
    );

    final explicitLeading = SffDecoration.buildLeading(
      context,
      widget.decoration,
      textStyle: selectedStyle,
    );
    final leading =
        explicitLeading ??
        (selected?.icon == null ? null : Icon(selected!.icon));
    final trailing = <Widget>[
      ...SffDecoration.buildTrailing(
        context,
        widget.decoration,
        textStyle: selectedStyle,
      ),
      AnimatedRotation(
        duration: SuperThemeData.of(context).tokens.durFast,
        turns: _open ? 0.5 : 0,
        child:
            widget.icon ??
            Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: t.fg3),
      ),
    ];

    final content = selected == null
        ? SffDecoration.buildHint(
            context,
            widget.decoration,
            fallback: 'Select…',
            arabic: widget.arabic,
            baseStyle: widget.style,
          )
        : Text(
            selected.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: selectedStyle,
          );

    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      canRequestFocus: _enabled,
      onKeyEvent: _handleKey,
      child: FieldPopover(
        open: _open,
        onDismiss: _dismiss,
        estimatedHeight: widget.menuMaxHeight,
        matchWidth: widget.menuWidth == null,
        overlayBuilder: _menu,
        child: MouseRegion(
          cursor: _enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _enabled ? _toggle : null,
            child: FieldBox(
              focused: _open || _focusNode.hasFocus,
              error: error,
              disabled: !_enabled,
              density: widget.density,
              showErrorBadge:
                  validationPosition == ValidationPosition.suffixIcon,
              leading: leading,
              trailing: trailing,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
