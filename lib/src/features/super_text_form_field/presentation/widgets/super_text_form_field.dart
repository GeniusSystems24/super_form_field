// ============================================================
// features/super_text_form_field/presentation/widgets/super_text_form_field.dart
// ------------------------------------------------------------
// The View for the GeniusLink text field. Uses a single TextField with a
// fully-specified InputDecoration — border states (enabled / focused / error /
// disabled) are driven by the field's own state rather than the ambient
// inputDecorationTheme, eliminating any double-border artefact.
//
// Validation errors surface ONLY through the suffix ErrorBadge, never inline.
// Supports leading icon, prefix / suffix adornments, clear, password reveal,
// character counter, multiline, email, disabled & read-only, and LTR/RTL.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
import '../../domain/entities/text_field_config.dart';
import '../../domain/usecases/build_text_validators.dart';
import '../controllers/super_text_field_controller.dart';

/// A themeable, validated text field on the GeniusLink field foundation.
class SuperTextFormField extends StatefulWidget {
  const SuperTextFormField({
    super.key,
    this.controller,
    this.initialValue = '',
    this.onChanged,
    this.onValidity,
    this.decoration = const InputDecoration(),
    this.required = false,
    this.density = FieldDensity.comfortable,
    this.disabled = false,
    this.readOnly = false,
    this.clearable = false,
    this.multiline = false,
    this.rows = 3,
    this.type = SuperTextType.text,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.patternMessage,
    this.validators = const [],
    this.showCounter = false,
    this.arabic = false,
    this.forceError = false,
    this.autofocus = false,
  });

  final SuperTextFieldController? controller;
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final ValidityChanged? onValidity;

  /// Canonical source for label, helper, hint, and adornment chrome.
  final InputDecoration decoration;

  // ── chrome ──
  final bool required;
  final FieldDensity density;
  final bool disabled;
  final bool readOnly;
  final bool clearable;

  // ── multiline ──
  final bool multiline;
  final int rows;

  // ── type + constraints ──
  final SuperTextType type;
  final int? minLength;
  final int? maxLength;
  final RegExp? pattern;
  final String? patternMessage;
  final List<Validator<String>> validators;
  final bool showCounter;
  final bool arabic;
  final bool forceError;
  final bool autofocus;

  @override
  State<SuperTextFormField> createState() => _SuperTextFormFieldState();
}

class _SuperTextFormFieldState extends State<SuperTextFormField> {
  late SuperTextFieldController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        SuperTextFieldController(
          initialValue: widget.initialValue,
          obscured: widget.type == SuperTextType.password,
        );
    _ownsController = widget.controller == null;
    _controller.text.addListener(_emitChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperTextFormField old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      if (_ownsController) {
        _controller.text.removeListener(_emitChange);
        _controller.dispose();
      } else {
        _controller.text.removeListener(_emitChange);
      }
      _controller =
          widget.controller ??
          SuperTextFieldController(
            initialValue: widget.initialValue,
            obscured: widget.type == SuperTextType.password,
          );
      _ownsController = widget.controller == null;
      _controller.text.addListener(_emitChange);
    }
  }

  void _emitChange() => widget.onChanged?.call(_controller.value);

  @override
  void dispose() {
    _controller.text.removeListener(_emitChange);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  List<Validator<String>> _buildValidators() => buildTextValidators(
    required: widget.required,
    minLength: widget.minLength,
    maxLength: widget.maxLength,
    type: widget.type,
    pattern: widget.pattern,
    patternMessage: widget.patternMessage,
    extra: widget.validators,
  );

  @override
  Widget build(BuildContext context) {
    _controller.configure(
      validators: _buildValidators(),
      forceError: widget.forceError,
      onValidity: widget.onValidity,
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
        final counter = (widget.showCounter && widget.maxLength != null)
            ? _Counter(length: _controller.value.length, max: widget.maxLength!)
            : null;

        final hasDecorationCounter =
            widget.decoration.counter != null ||
            widget.decoration.counterText != null;

        return FieldShell(
          decoration: widget.decoration,
          required: widget.required,
          hasError: error != null,
          arabic: widget.arabic,
          labelRight: hasDecorationCounter ? null : counter,
          child: widget.multiline
              ? _buildField(context, t, cs, error, multiline: true)
              : _buildField(context, t, cs, error, multiline: false),
        );
      },
    );
  }

  // ── Single InputDecoration field — no FieldBox, no double border ─────────────

  Widget _buildField(
    BuildContext context,
    SuperThemeData t,
    ColorScheme cs,
    String? error, {
    required bool multiline,
  }) {
    final hasError = error != null;
    final editable = !widget.disabled && !widget.readOnly;
    final focused = _controller.focused;

    // ── Border states ──
    final enabledBorderColor = hasError ? cs.error : t.borderStrong;
    final focusedBorderColor = hasError ? cs.error : cs.primary;
    final disabledBorderColor = t.border;

    OutlineInputBorder border(Color color, {double width = 1.4}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            SuperThemeData.of(context).tokens.radiusControl,
          ),
          borderSide: BorderSide(color: color, width: width),
        );

    // ── Fill ──
    final fillColor = focused && !widget.disabled ? t.surface : t.inputBg;

    final source = widget.decoration;

    // ── Suffix icon row ──
    final trailingWidgets = <Widget>[
      if (source.suffixIcon != null) source.suffixIcon!,
      if (!multiline &&
          widget.clearable &&
          _controller.value.isNotEmpty &&
          editable)
        FieldIconButton(
          icon: SffIcons.clear,
          tooltip: 'Clear',
          onPressed: _controller.clear,
        ),
      if (widget.type == SuperTextType.password && !widget.disabled)
        FieldIconButton(
          icon: _controller.obscured ? SffIcons.eye : SffIcons.eyeOff,
          tooltip: _controller.obscured ? 'Show' : 'Hide',
          onPressed: _controller.toggleObscure,
        ),
      if (hasError) ErrorBadge(error: error),
    ];

    Widget? suffixWidget;
    if (trailingWidgets.isNotEmpty) {
      suffixWidget = Padding(
        padding: const EdgeInsetsDirectional.only(end: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: trailingWidgets,
        ),
      );
    }

    final defaultIconColor = focused ? cs.primary : t.fg4;
    final leadingIcons = <Widget>[
      if (source.icon != null)
        IconTheme.merge(
          data: IconThemeData(color: source.iconColor ?? defaultIconColor),
          child: source.icon!,
        ),
      if (source.prefixIcon != null)
        IconTheme.merge(
          data: IconThemeData(
            color: source.prefixIconColor ?? defaultIconColor,
          ),
          child: source.prefixIcon!,
        ),
    ];
    final Widget? prefixIconWidget = switch (leadingIcons.length) {
      0 => null,
      1 => leadingIcons.single,
      _ => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < leadingIcons.length; i++) ...[
              if (i > 0)
                SizedBox(width: SuperThemeData.of(context).tokens.space1),
              leadingIcons[i],
            ],
          ],
        ),
    };

    // ── Density ──
    final minH = widget.density == FieldDensity.compact
        ? SuperThemeData.of(context).tokens.fieldCompact
        : SuperThemeData.of(context).tokens.fieldComfortable;

    // ── Prefix / suffix text adornments ──
    final adornStyle = SuperText.body.copyWith(color: t.fg3, fontSize: 13);

    final decoration = InputDecoration(
      // The external FieldShell owns label/helper/counter/error presentation.
      hint: source.hint,
      hintText: source.hintText,
      hintStyle: SffDecoration.mergeStyle(
        SuperText.body.copyWith(
          color: t.fg4,
          fontFamily: widget.arabic
              ? SuperThemeData.of(context).tokens.arabicFont
              : SuperThemeData.of(context).tokens.bodyFont,
        ),
        source.hintStyle,
      ),
      hintTextDirection: source.hintTextDirection,
      hintMaxLines: source.hintMaxLines,

      // Caller adornments are retained; package controls are appended.
      prefix: source.prefix,
      prefixIcon: prefixIconWidget,
      prefixIconColor: defaultIconColor,
      prefixIconConstraints:
          source.prefixIconConstraints ??
          (prefixIconWidget != null
              ? const BoxConstraints(minWidth: 36, minHeight: 36)
              : null),
      prefixText: source.prefixText,
      prefixStyle: SffDecoration.mergeStyle(adornStyle, source.prefixStyle),
      suffix: source.suffix,
      suffixIcon: suffixWidget,
      suffixIconColor: source.suffixIconColor ?? t.fg4,
      suffixIconConstraints:
          source.suffixIconConstraints ??
          (suffixWidget != null
              ? BoxConstraints(minHeight: minH, maxHeight: minH, minWidth: 0)
              : null),
      suffixText: source.suffixText,
      suffixStyle: SffDecoration.mergeStyle(adornStyle, source.suffixStyle),

      // GeniusLink owns fill, sizing, and border states.
      filled: true,
      fillColor: widget.disabled ? Colors.transparent : fillColor,
      constraints: multiline
          ? BoxConstraints(minHeight: minH)
          : BoxConstraints.tightFor(height: minH),
      contentPadding: EdgeInsets.symmetric(
        horizontal: SuperThemeData.of(context).tokens.space3,
        vertical: widget.density == FieldDensity.compact
            ? SuperThemeData.of(context).tokens.space1
            : SuperThemeData.of(context).tokens.space2,
      ),
      border: border(enabledBorderColor),
      enabledBorder: border(enabledBorderColor),
      focusedBorder: border(focusedBorderColor),
      disabledBorder: border(disabledBorderColor),
      errorBorder: border(cs.error),
      focusedErrorBorder: border(cs.error),
    );

    final textStyle = SuperText.body.copyWith(
      color: t.fg1,
      fontFamily: widget.arabic
          ? SuperThemeData.of(context).tokens.arabicFont
          : SuperThemeData.of(context).tokens.bodyFont,
    );

    final field = TextField(
      controller: _controller.text,
      focusNode: _controller.focusNode,
      enabled: !widget.disabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      obscureText:
          widget.type == SuperTextType.password && _controller.obscured,
      maxLines: multiline ? widget.rows : 1,
      minLines: multiline ? widget.rows : 1,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLength != null
          ? MaxLengthEnforcement.enforced
          : MaxLengthEnforcement.none,
      buildCounter:
          (_, {required currentLength, required isFocused, maxLength}) => null,
      keyboardType: multiline
          ? TextInputType.multiline
          : widget.type == SuperTextType.email
          ? TextInputType.emailAddress
          : TextInputType.text,
      cursorColor: cs.primary,
      style: textStyle,
      textAlign: widget.arabic ? TextAlign.right : TextAlign.left,
      textAlignVertical: multiline ? null : TextAlignVertical.center,
      decoration: decoration,
    );

    // ── Wrap in fixed-height SizedBox for single-line fields ─────────────────
    // This is the final, authoritative height constraint. InputDecoration's
    // own `constraints` can be overridden by suffix/prefix intrinsics in some
    // Flutter versions; wrapping guarantees a consistent visual height.
    if (!multiline) {
      return SizedBox(height: minH, child: field);
    }

    return field;
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Counter extends StatelessWidget {
  const _Counter({required this.length, required this.max});
  final int length;
  final int max;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    return Text(
      '$length/$max',
      style: SuperText.mono.copyWith(
        fontSize: 11,
        color: length > max ? cs.error : t.fg4,
      ),
    );
  }
}
