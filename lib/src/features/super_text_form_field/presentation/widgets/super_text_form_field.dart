// ============================================================
// features/super_text_form_field/presentation/widgets/super_text_form_field.dart
// ------------------------------------------------------------
// The View for the GeniusLink text field. A thin Flutter wrapper that builds
// the validator chain (domain usecase), drives a [SuperTextFieldController]
// (the Model), and renders the FieldShell + FieldBox chrome. Validation errors
// surface ONLY through the suffix ErrorBadge — never inline. Supports leading
// icon, prefix / suffix adornments, clear, password reveal, character counter,
// multiline, email, disabled & read-only, and full LTR/RTL.
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

  /// External controller — when null, the field manages its own.
  final SuperTextFieldController? controller;

  /// Seed value, used only when [controller] is null.
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

  /// Leading icon (tints to accent on focus).
  final IconData? leadingIcon;

  /// Static text before the value (`www.`).
  final String? prefix;

  /// Static text after the value (`@company.com`).
  final String? suffix;

  /// Show a × button (while non-empty, enabled & editable).
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

  /// Extra custom validators, appended to the built-in chain.
  final List<Validator<String>> validators;

  /// Show an `n/max` counter in the label-right slot ([maxLength] required).
  final bool showCounter;

  final bool arabic;

  /// Force the error to display even before the field is touched.
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
        (SuperTextFieldController(
          initialValue: widget.initialValue,
          obscured: widget.type == SuperTextType.password,
        ));
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
    // Configure the Model from the View's declarative props each build.
    _controller.configure(
      validators: _buildValidators(),
      forceError: widget.forceError,
      onValidity: widget.onValidity,
    );

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final t = context.sffTheme;
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
          child: widget.multiline ? _buildMultiline(t, error) : _buildSingleLine(t, error),
        );
      },
    );
  }

  // ── the editable text, sans chrome ──
  Widget _input(SuperFieldTheme t, {int? maxLines, int? minLines}) {
    return TextField(
      controller: _controller.text,
      focusNode: _controller.focusNode,
      enabled: !widget.disabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      obscureText: widget.type == SuperTextType.password && _controller.obscured,
      maxLines: widget.multiline ? maxLines : 1,
      minLines: minLines,
      maxLength: widget.maxLength,
      maxLengthEnforcement:
          widget.maxLength != null ? MaxLengthEnforcement.enforced : MaxLengthEnforcement.none,
      buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
      keyboardType: widget.multiline
          ? TextInputType.multiline
          : widget.type == SuperTextType.email
              ? TextInputType.emailAddress
              : TextInputType.text,
      cursorColor: SuperTokens.accent,
      style: SuperText.body.copyWith(
        color: t.fg1,
        fontFamily: widget.arabic ? SuperTokens.arabicFont : SuperTokens.bodyFont,
      ),
      textAlign: widget.arabic ? TextAlign.right : TextAlign.left,
      decoration: InputDecoration.collapsed(
        hintText: widget.placeholder,
        hintStyle: SuperText.body.copyWith(
          color: t.fg4,
          fontFamily: widget.arabic ? SuperTokens.arabicFont : SuperTokens.bodyFont,
        ),
      ),
    );
  }

  Widget _adorn(SuperFieldTheme t, String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(text, style: SuperText.body.copyWith(color: t.fg3, fontSize: 13)),
      );

  Widget _buildSingleLine(SuperFieldTheme t, String? error) {
    final editable = !widget.disabled && !widget.readOnly;
    final trailing = <Widget>[
      if (widget.clearable && _controller.value.isNotEmpty && editable)
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
    ];

    return FieldBox(
      focused: _controller.focused,
      error: error,
      disabled: widget.disabled,
      density: widget.density,
      leading: widget.leadingIcon != null ? Icon(widget.leadingIcon) : null,
      trailing: trailing,
      child: Row(
        children: [
          if (widget.prefix != null) _adorn(t, widget.prefix!),
          Expanded(child: _input(t)),
          if (widget.suffix != null) _adorn(t, widget.suffix!),
        ],
      ),
    );
  }

  Widget _buildMultiline(SuperFieldTheme t, String? error) {
    final hasError = error != null;
    final border = hasError
        ? SuperTokens.danger
        : _controller.focused
            ? SuperTokens.accent
            : t.borderStrong;
    return Opacity(
      opacity: widget.disabled ? 0.55 : 1,
      child: AnimatedContainer(
        duration: SuperTokens.durBase,
        curve: SuperTokens.curveStandard,
        padding: const EdgeInsets.fromLTRB(12, 9, 6, 9),
        decoration: BoxDecoration(
          color: widget.disabled ? const Color(0x00000000) : (_controller.focused ? t.surface : t.inputBg),
          border: Border.all(color: border, width: 1.4),
          borderRadius: BorderRadius.circular(SuperTokens.radiusControl),
          boxShadow: hasError
              ? [BoxShadow(color: SuperTokens.danger.withOpacity(0.14), spreadRadius: 3)]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _input(t, maxLines: widget.rows, minLines: widget.rows)),
            if (hasError) Padding(padding: const EdgeInsets.only(top: 2), child: ErrorBadge(error: error)),
          ],
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.length, required this.max});
  final int length;
  final int max;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final over = length > max;
    return Text(
      '$length/$max',
      style: SuperText.mono.copyWith(
        fontSize: 11,
        color: over ? SuperTokens.danger : t.fg4,
      ),
    );
  }
}
