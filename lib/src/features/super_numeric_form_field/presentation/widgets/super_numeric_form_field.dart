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
import '../../../../core/foundation/field_decoration.dart';
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
    this.decoration = const InputDecoration(),
    this.required = false,
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
    this.allowNegative = true,
    this.validators = const [],
    this.forceError = false,
    this.arabic = false,
  });

  final SuperNumericFieldController? controller;
  final num? initialValue;
  final ValueChanged<num?>? onChanged;
  final ValidityChanged? onValidity;

  /// Canonical source for label, helper, hint, and adornment chrome.
  /// Use `prefixText` and `suffixText` for units and currencies.
  final InputDecoration decoration;

  // ── chrome ──
  final bool required;
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

  /// Allow negative values; when false, the lower bound becomes 0.
  final bool allowNegative;

  final List<Validator<num?>> validators;
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
    _controller =
        widget.controller ??
        SuperNumericFieldController(initialValue: widget.initialValue);
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
      _controller =
          widget.controller ??
          SuperNumericFieldController(initialValue: widget.initialValue);
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
        final error = widget.disabled
            ? null
            : SffDecoration.resolveError(
                widget.decoration,
                _controller.visibleError,
              );

        final tokens = SuperThemeData.of(context).tokens;
        final controlHeight = widget.density == FieldDensity.compact
            ? tokens.fieldCompact
            : tokens.fieldComfortable;
        final unitStyle = SuperText.mono.copyWith(
          color: t.fg3,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        );
        final stepperBorderRadius = BorderRadius.circular(
          tokens.radiusControl,
        );
        final stepperBorderSide = BorderSide(color: t.borderStrong);
        final trailing = <Widget>[
          ...SffDecoration.buildTrailing(
            context,
            widget.decoration,
            textStyle: unitStyle,
          ),
          if (widget.stepper && !widget.disabled)
            Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                height: controlHeight,
                decoration: BoxDecoration(
                  color: t.inputBg,
                  borderRadius: stepperBorderRadius,
                ),
                foregroundDecoration: BoxDecoration(
                  border: Border.fromBorderSide(stepperBorderSide),
                  borderRadius: stepperBorderRadius,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FieldIconButton(
                          key: const ValueKey('super_numeric_decrement'),
                          icon: SffIcons.minus,
                          tooltip: 'Decrement',
                          bordered: true,
                          size: controlHeight,
                          border: const Border(),
                          borderRadius: BorderRadius.zero,
                          iconSize: 14,
                          onPressed: widget.readOnly
                              ? null
                              : () => _controller.bump(-1),
                        ),
                        FieldIconButton(
                          key: const ValueKey('super_numeric_increment'),
                          icon: SffIcons.plus,
                          tooltip: 'Increment',
                          bordered: true,
                          size: controlHeight,
                          border: const Border(),
                          borderRadius: BorderRadius.zero,
                          iconSize: 14,
                          onPressed: widget.readOnly
                              ? null
                              : () => _controller.bump(1),
                        ),
                      ],
                    ),
                    IgnorePointer(
                      child: SizedBox(
                        width: stepperBorderSide.width,
                        height: controlHeight,
                        child: ColoredBox(color: stepperBorderSide.color),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ];

        return FieldShell(
          decoration: widget.decoration,
          required: widget.required,
          hasError: error != null,
          arabic: widget.arabic,
          child: FieldBox(
            focused: _controller.focused,
            error: error,
            disabled: widget.disabled,
            density: widget.density,
            flushTrailing:
                widget.stepper && !widget.disabled && error == null,
            leading: SffDecoration.buildLeading(
              context,
              widget.decoration,
              textStyle: unitStyle,
            ),
            trailing: trailing,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: widget.disabled
                    ? null
                    : (_) => _controller.focusNode.requestFocus(),
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: TextField(
                      controller: _controller.text,
                      focusNode: _controller.focusNode,
                      enabled: !widget.disabled,
                      readOnly: widget.readOnly,
                      textAlign: TextAlign.right,
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      cursorColor: cs.primary,
                      style: SuperText.mono.copyWith(color: t.fg1),
                      // FieldBox owns the border and height. Keep this editor at
                      // its natural single-line height, then center that actual
                      // render box in the available control height.
                      decoration: InputDecoration(
                        hint: widget.decoration.hint,
                        hintText: widget.decoration.hintText,
                        hintStyle: SffDecoration.mergeStyle(
                          SuperText.mono.copyWith(color: t.fg4),
                          widget.decoration.hintStyle,
                        ),
                        hintTextDirection: TextDirection.ltr,
                        hintMaxLines: widget.decoration.hintMaxLines,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: false,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
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
