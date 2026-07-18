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
    this.label,
    this.required = false,
    this.placeholder,
    this.hint,
    this.density = FieldDensity.comfortable,
    this.disabled = false,
    this.readOnly = false,
    this.leadingIcon,
    this.prefix,
    this.suffix,
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

  // ── chrome ──
  final String? label;
  final bool required;
  final String? placeholder;
  final String? hint;
  final FieldDensity density;
  final bool disabled;
  final bool readOnly;
  final IconData? leadingIcon;
  final String? prefix;
  final String? suffix;
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
    _controller = widget.controller ??
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
      _controller = widget.controller ??
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
        final error = widget.disabled ? null : _controller.visibleError;
        final counter = (widget.showCounter && widget.maxLength != null)
            ? _Counter(length: _controller.value.length, max: widget.maxLength!)
            : null;

        return FieldShell(
          label: widget.label,
          required: widget.required,
          hint: widget.hint,
          hasError: error != null,
          arabic: widget.arabic,
          labelRight: counter,
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
    final enabledBorderColor  = hasError ? cs.error : t.borderStrong;
    final focusedBorderColor  = hasError ? cs.error : cs.primary;
    final disabledBorderColor = t.border;

    OutlineInputBorder border(Color color, {double width = 1.4}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(SuperTokensData.defaultRadiusControl),
          borderSide: BorderSide(color: color, width: width),
        );

    // ── Fill ──
    final fillColor = focused && !widget.disabled ? t.surface : t.inputBg;

    // ── Suffix icon row ──
    final trailingWidgets = <Widget>[
      if (!multiline && widget.clearable && _controller.value.isNotEmpty && editable)
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
        padding: const EdgeInsets.only(right: 4),
        child: Row(mainAxisSize: MainAxisSize.min, children: trailingWidgets),
      );
    }

    // ── Leading icon ──
    Widget? prefixIconWidget;
    if (widget.leadingIcon != null) {
      prefixIconWidget = Icon(
        widget.leadingIcon,
        size: 18,
        color: focused ? cs.primary : t.fg4,
      );
    }

    // ── Density ──
    final minH = widget.density == FieldDensity.compact
        ? SuperTokensData.defaultFieldCompact
        : SuperTokensData.defaultFieldComfortable;

    // ── Prefix / suffix text adornments ──
    final adornStyle = SuperText.body.copyWith(color: t.fg3, fontSize: 13);

    final decoration = InputDecoration(
      // Hint
      hintText: widget.placeholder,
      hintStyle: SuperText.body.copyWith(
        color: t.fg4,
        fontFamily: widget.arabic ? SuperTokensData.defaultArabicFont : SuperTokensData.defaultBodyFont,
      ),
      // Leading / trailing
      prefixIcon: prefixIconWidget,
      prefixIconConstraints: prefixIconWidget != null
          ? const BoxConstraints(minWidth: 36, minHeight: 36)
          : null,
      prefixText: widget.prefix,
      prefixStyle: adornStyle,
      suffixIcon: suffixWidget,
      suffixIconConstraints: suffixWidget != null
          ? BoxConstraints(minHeight: minH, maxHeight: minH, minWidth: 0)
          : null,
      suffixText: widget.suffix,
      suffixStyle: adornStyle,
      // Fill
      filled: true,
      fillColor: widget.disabled ? Colors.transparent : fillColor,
      // Sizing — tight height for single-line; unconstrained for multiline
      
      constraints: multiline
          ? BoxConstraints(minHeight: minH)
          : BoxConstraints.tightFor(height: minH),
      contentPadding: EdgeInsets.symmetric(
        horizontal: SuperTokensData.defaultSpace3,
        vertical: widget.density == FieldDensity.compact
            ? SuperTokensData.defaultSpace1
            : SuperTokensData.defaultSpace2,
      ),
      // Borders — fully specified; overrides inputDecorationTheme
      border: border(enabledBorderColor),
      enabledBorder: border(enabledBorderColor),
      focusedBorder: border(focusedBorderColor),
      disabledBorder: border(disabledBorderColor),
      errorBorder: border(cs.error),
      focusedErrorBorder: border(cs.error),
      // Error shadow via container — NOT via errorText (that would show inline text)
      // No errorText: error UX is the suffix ErrorBadge + border color change only.
    );

    final textStyle = SuperText.body.copyWith(
      color: t.fg1,
      fontFamily: widget.arabic ? SuperTokensData.defaultArabicFont : SuperTokensData.defaultBodyFont,
    );

    final field = TextField(
      controller: _controller.text,
      focusNode: _controller.focusNode,
      enabled: !widget.disabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      obscureText: widget.type == SuperTextType.password && _controller.obscured,
      maxLines: multiline ? widget.rows : 1,
      minLines: multiline ? widget.rows : 1,
      maxLength: widget.maxLength,
      maxLengthEnforcement: widget.maxLength != null
          ? MaxLengthEnforcement.enforced
          : MaxLengthEnforcement.none,
      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
      keyboardType: multiline
          ? TextInputType.multiline
          : widget.type == SuperTextType.email
              ? TextInputType.emailAddress
              : TextInputType.text,
      cursorColor: cs.primary,
      style: textStyle,
      textAlign: widget.arabic ? TextAlign.right : TextAlign.left,
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
