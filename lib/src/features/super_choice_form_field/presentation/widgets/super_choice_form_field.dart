// ============================================================
// features/super_choice_form_field/presentation/widgets/super_choice_form_field.dart
// ------------------------------------------------------------
// The View for the GeniusLink inline choice group — all options visible at once
// (no popover), drawn as a segmented control, a radio list, or a checkbox list.
// Best for small, fixed option sets (status, type, payment method, permissions).
// Drives a [SuperChoiceFieldController] (the Model) and builds the validator
// chain from the domain usecase. The error surfaces through the ErrorBadge in
// the FieldShell label-right slot. Light/dark + LTR/RTL.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/entities/choice_field_config.dart';
import '../../domain/usecases/choice_logic.dart';
import '../controllers/super_choice_field_controller.dart';

/// A themeable, validated inline choice group (segmented / radio / checkbox).
class SuperChoiceFormField<T> extends StatefulWidget {
  const SuperChoiceFormField({
    super.key,
    required this.options,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onValidity,
    this.label,
    this.required = false,
    this.hint,
    this.style = SuperChoiceStyle.segmented,
    this.multiple = false,
    this.minSelections,
    this.maxSelections,
    this.disabled = false,
    this.readOnly = false,
    this.validators = const [],
    this.forceError = false,
    this.arabic = false,
  });

  /// The choosable options (kept small — all are rendered inline).
  final List<SuperOption<T>> options;

  final SuperChoiceFieldController<T>? controller;

  /// Seed selection. For single-pick use, pass a single-element list.
  final List<T>? initialValue;

  final ValueChanged<List<T>>? onChanged;
  final ValidityChanged? onValidity;

  // ── chrome ──
  final String? label;
  final bool required;
  final String? hint;

  // ── behaviour ──
  final SuperChoiceStyle style;

  /// Allow more than one selection. `segmented`/`radio` default to single;
  /// `checkbox` is typically [multiple].
  final bool multiple;

  final int? minSelections;
  final int? maxSelections;

  final bool disabled;
  final bool readOnly;

  final List<Validator<List<T>>> validators;
  final bool forceError;
  final bool arabic;

  @override
  State<SuperChoiceFormField<T>> createState() => _SuperChoiceFormFieldState<T>();
}

class _SuperChoiceFormFieldState<T> extends State<SuperChoiceFormField<T>> {
  late SuperChoiceFieldController<T> _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SuperChoiceFieldController<T>(initialValue: widget.initialValue);
    _ownsController = widget.controller == null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperChoiceFormField<T> old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      if (_ownsController) _controller.dispose();
      _controller = widget.controller ?? SuperChoiceFieldController<T>(initialValue: widget.initialValue);
      _ownsController = widget.controller == null;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  bool get _editable => !widget.disabled && !widget.readOnly;

  void _pick(SuperOption<T> o) {
    if (!_editable || o.disabled) return;
    _controller.pick(o.value);
  }

  @override
  Widget build(BuildContext context) {
    _controller.configure(
      multiple: widget.multiple || widget.style == SuperChoiceStyle.checkbox,
      maxSelections: widget.maxSelections,
      validators: ChoiceLogic.buildValidators<T>(
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
        final error = widget.disabled ? null : _controller.visibleError;

        return FieldShell(
          label: widget.label,
          required: widget.required,
          hint: widget.hint,
          hasError: error != null,
          arabic: widget.arabic,
          labelRight: error != null ? ErrorBadge(error: error) : null,
          child: Opacity(
            opacity: widget.disabled ? 0.55 : 1,
            child: switch (widget.style) {
              SuperChoiceStyle.segmented => _Segmented<T>(
                  options: widget.options,
                  controller: _controller,
                  arabic: widget.arabic,
                  onPick: _pick,
                ),
              SuperChoiceStyle.radio => _OptionList<T>(
                  options: widget.options,
                  controller: _controller,
                  checkbox: false,
                  arabic: widget.arabic,
                  onPick: _pick,
                ),
              SuperChoiceStyle.checkbox => _OptionList<T>(
                  options: widget.options,
                  controller: _controller,
                  checkbox: true,
                  arabic: widget.arabic,
                  onPick: _pick,
                ),
            },
          ),
        );
      },
    );
  }
}

// ── segmented control ────────────────────────────────────────────────────────
class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.options,
    required this.controller,
    required this.arabic,
    required this.onPick,
  });

  final List<SuperOption<T>> options;
  final SuperChoiceFieldController<T> controller;
  final bool arabic;
  final ValueChanged<SuperOption<T>> onPick;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.inputBg,
        border: Border.all(color: t.borderStrong),
        borderRadius: BorderRadius.circular(SuperTokens.radiusMd),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(child: _Segment<T>(option: o, controller: controller, arabic: arabic, onPick: onPick)),
        ],
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.option,
    required this.controller,
    required this.arabic,
    required this.onPick,
  });

  final SuperOption<T> option;
  final SuperChoiceFieldController<T> controller;
  final bool arabic;
  final ValueChanged<SuperOption<T>> onPick;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    final selected = controller.isSelected(option.value);
    return MouseRegion(
      cursor: option.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: option.disabled ? null : () => onPick(option),
        child: AnimatedContainer(
          duration: SuperTokens.durFast,
          curve: SuperTokens.curveStandard,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? cs.primary : const Color(0x00000000),
            borderRadius: BorderRadius.circular(SuperTokens.radiusControl),
          ),
          child: Opacity(
            opacity: option.disabled ? 0.4 : 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (option.icon != null) ...[
                  Icon(option.icon, size: 15, color: selected ? const Color(0xFFFFFFFF) : t.fg3),
                  const SizedBox(width: SuperTokens.space2),
                ],
                Flexible(
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: SuperText.button.copyWith(
                      color: selected ? const Color(0xFFFFFFFF) : t.fg3,
                      fontSize: 13,
                      fontFamily: arabic ? SuperTokens.arabicFont : SuperTokens.bodyFont,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── radio / checkbox list ────────────────────────────────────────────────────
class _OptionList<T> extends StatelessWidget {
  const _OptionList({
    required this.options,
    required this.controller,
    required this.checkbox,
    required this.arabic,
    required this.onPick,
  });

  final List<SuperOption<T>> options;
  final SuperChoiceFieldController<T> controller;
  final bool checkbox;
  final bool arabic;
  final ValueChanged<SuperOption<T>> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: SuperTokens.space1),
          _OptionRow<T>(
            option: options[i],
            selected: controller.isSelected(options[i].value),
            checkbox: checkbox,
            arabic: arabic,
            onPick: onPick,
          ),
        ],
      ],
    );
  }
}

class _OptionRow<T> extends StatefulWidget {
  const _OptionRow({
    required this.option,
    required this.selected,
    required this.checkbox,
    required this.arabic,
    required this.onPick,
  });

  final SuperOption<T> option;
  final bool selected;
  final bool checkbox;
  final bool arabic;
  final ValueChanged<SuperOption<T>> onPick;

  @override
  State<_OptionRow<T>> createState() => _OptionRowState<T>();
}

class _OptionRowState<T> extends State<_OptionRow<T>> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    final o = widget.option;
    final sel = widget.selected;
    final enabled = !o.disabled;
    final fontFamily = widget.arabic ? SuperTokens.arabicFont : SuperTokens.bodyFont;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: enabled ? () => widget.onPick(o) : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: AnimatedContainer(
            duration: SuperTokens.durFast,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: sel ? t.selectionFill(0.10) : (_hover && enabled ? t.hover : t.inputBg),
              border: Border.all(color: sel ? cs.primary : t.borderStrong, width: sel ? 1.4 : 1),
              borderRadius: BorderRadius.circular(SuperTokens.radiusControl),
            ),
            child: Row(
              children: [
                widget.checkbox ? _Square(checked: sel) : _Circle(checked: sel),
                const SizedBox(width: SuperTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.label,
                        style: SuperText.body.copyWith(
                          color: t.fg1,
                          fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                          fontFamily: fontFamily,
                        ),
                      ),
                      if (o.description != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          o.description!,
                          style: SuperText.caption.copyWith(color: t.fg4, fontFamily: fontFamily),
                        ),
                      ],
                    ],
                  ),
                ),
                if (o.icon != null) Icon(o.icon, size: 16, color: sel ? cs.primary : t.fg3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Square extends StatelessWidget {
  const _Square({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    return AnimatedContainer(
      duration: SuperTokens.durFast,
      width: 19,
      height: 19,
      decoration: BoxDecoration(
        color: checked ? cs.primary : const Color(0x00000000),
        border: Border.all(color: checked ? cs.primary : t.borderStrong, width: 1.5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: checked ? const Icon(SffIcons.check, size: 13, color: Color(0xFFFFFFFF)) : null,
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    return Container(
      width: 19,
      height: 19,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: checked ? cs.primary : t.borderStrong, width: checked ? 5.5 : 1.5),
      ),
    );
  }
}
