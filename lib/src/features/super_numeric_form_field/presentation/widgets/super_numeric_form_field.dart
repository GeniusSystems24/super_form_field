// ============================================================
// features/super_numeric_form_field/presentation/widgets/super_numeric_form_field.dart
// ------------------------------------------------------------
// The View for the GeniusLink numeric field. A thin Flutter wrapper that builds
// the validator chain (domain usecase), drives a [SuperNumericFieldController]
// (the Model), and renders the FieldShell + FieldBox chrome. Numbers stay
// Western digits and right-aligned mono even in RTL. Validation surfaces only
// through the suffix ErrorBadge. Includes a +/- stepper and prefix/suffix units.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/usecases/numeric_logic.dart';
import '../controllers/super_numeric_field_controller.dart';

/// A themeable, validated numeric field on the GeniusLink field foundation.
class SuperNumericFormField extends StatefulWidget {
  const SuperNumericFormField({
    super.key,
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
    this.min,
    this.max,
    this.decimals = 0,
    this.grouping = true,
    this.step = 1,
    this.largeStep,
    this.stepper = true,
    this.keyboardShortcuts = true,
    this.prefix,
    this.suffix,
    this.allowNegative = true,
    this.validators = const [],
    this.leadingIcon,
    this.forceError = false,
    this.arabic = false,
  });

  final SuperNumericFieldController? controller;
  final num? initialValue;
  final ValueChanged<num?>? onChanged;
  final ValidityChanged? onValidity;

  // ── chrome ──
  final String? label;
  final bool required;
  final String? placeholder;
  final String? hint;
  final FieldDensity density;
  final bool disabled;
  final bool readOnly;

  // ── numeric constraints ──
  final num? min;
  final num? max;
  final int decimals;
  final bool grouping;
  final num step;

  /// The increment applied by PageUp / PageDown. Defaults to `step * 10`.
  final num? largeStep;

  /// Show the +/- stepper buttons.
  final bool stepper;

  /// Enable keyboard stepping while focused: ↑/↓ by [step], PageUp/PageDown by
  /// [largeStep].
  final bool keyboardShortcuts;

  /// Mono unit before the number (`SAR`, `$`).
  final String? prefix;

  /// Mono unit after the number (`%`, `kg`).
  final String? suffix;

  /// Allow negative values; when false, the lower bound becomes 0.
  final bool allowNegative;

  final List<Validator<num?>> validators;
  final IconData? leadingIcon;
  final bool forceError;
  final bool arabic;

  @override
  State<SuperNumericFormField> createState() => _SuperNumericFormFieldState();
}

class _SuperNumericFormFieldState extends State<SuperNumericFormField> {
  late SuperNumericFieldController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SuperNumericFieldController(initialValue: widget.initialValue);
    _ownsController = widget.controller == null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperNumericFormField old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      if (_ownsController) _controller.dispose();
      _controller = widget.controller ?? SuperNumericFieldController(initialValue: widget.initialValue);
      _ownsController = widget.controller == null;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.configure(
      min: widget.min,
      max: widget.max,
      decimals: widget.decimals,
      grouping: widget.grouping,
      allowNegative: widget.allowNegative,
      step: widget.step,
      largeStep: widget.largeStep,
      readOnly: widget.readOnly,
      keyboardEnabled: widget.keyboardShortcuts,
      validators: NumericLogic.buildValidators(
        required: widget.required,
        min: widget.min,
        max: widget.max,
        decimals: widget.decimals,
        grouping: widget.grouping,
        allowNegative: widget.allowNegative,
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
    final cs = context.sffColorScheme;
        final error = widget.disabled ? null : _controller.visibleError;

        final trailing = <Widget>[
          if (widget.suffix != null) _unit(t, widget.suffix!),
          if (widget.stepper && !widget.disabled) ...[
            FieldIconButton(
              icon: SffIcons.minus,
              tooltip: 'Decrement',
              bordered: true,
              size: SuperTokensData.defaultStepperSize,
              iconSize: 14,
              onPressed: widget.readOnly ? null : () => _controller.bump(-1),
            ),
            FieldIconButton(
              icon: SffIcons.plus,
              tooltip: 'Increment',
              bordered: true,
              size: SuperTokensData.defaultStepperSize,
              iconSize: 14,
              onPressed: widget.readOnly ? null : () => _controller.bump(1),
            ),
          ],
        ];

        return FieldShell(
          label: widget.label,
          required: widget.required,
          hint: widget.hint,
          hasError: error != null,
          arabic: widget.arabic,
          child: FieldBox(
            focused: _controller.focused,
            error: error,
            disabled: widget.disabled,
            density: widget.density,
            leading: widget.leadingIcon != null
                ? Icon(widget.leadingIcon)
                : (widget.prefix != null ? _unit(t, widget.prefix!) : null),
            trailing: trailing,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: _controller.text,
                focusNode: _controller.focusNode,
                enabled: !widget.disabled,
                readOnly: widget.readOnly,
                textAlign: TextAlign.right,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                cursorColor: cs.primary,
                style: SuperText.mono.copyWith(color: t.fg1),
                // All borders are suppressed — FieldBox owns the single border.
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: SuperText.mono.copyWith(color: t.fg4),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _unit(SuperThemeData t, String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: Text(
          text,
          style: SuperText.mono.copyWith(
            color: t.fg3,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      );
}
