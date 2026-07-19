// ============================================================
// features/super_bool_form_field/presentation/widgets/super_bool_form_field.dart
// ------------------------------------------------------------
// The View for the GeniusLink boolean field — a labelled on/off control drawn as
// either a sliding toggle (default) or a checkbox. The FieldShell renders the
// field label; the control row shows the toggle/checkbox plus a state caption
// (enabledLabel / disabledLabel) and, when invalid, the suffix ErrorBadge. Drives
// a [SuperBoolFieldController] (the Model) and builds the validator chain from
// the domain usecase. The whole row is tappable. Light/dark + LTR/RTL.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
import '../../domain/entities/bool_field_config.dart';
import '../../domain/usecases/build_bool_validators.dart';
import '../controllers/super_bool_field_controller.dart';

/// A themeable, validated boolean field (toggle or checkbox).
class SuperBoolFormField extends StatefulWidget {
  const SuperBoolFormField({
    super.key,
    this.controller,
    this.initialValue = false,
    this.onChanged,
    this.onValidity,
    this.decoration = const InputDecoration(),
    this.required = false,
    this.style = SuperBoolStyle.toggle,
    this.enabledLabel = 'Enabled',
    this.disabledLabel = 'Disabled',
    this.mustBeTrue = false,
    this.mustBeTrueMessage = 'This must be enabled to continue',
    this.disabled = false,
    this.readOnly = false,
    this.validators = const [],
    this.forceError = false,
    this.arabic = false,
  });

  final SuperBoolFieldController? controller;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;
  final ValidityChanged? onValidity;

  /// Canonical source for label, helper, hint, and adornment chrome.
  final InputDecoration decoration;

  // ── chrome ──
  final bool required;

  // ── behaviour ──
  final SuperBoolStyle style;

  /// State caption when on (used when decoration.hintText is null).
  final String enabledLabel;

  /// State caption when off (used when decoration.hintText is null).
  final String disabledLabel;

  /// Require the value to be true (e.g. an acknowledgement gate).
  final bool mustBeTrue;
  final String mustBeTrueMessage;

  final bool disabled;
  final bool readOnly;

  final List<Validator<bool>> validators;
  final bool forceError;
  final bool arabic;

  @override
  State<SuperBoolFormField> createState() => _SuperBoolFormFieldState();
}

class _SuperBoolFormFieldState extends State<SuperBoolFormField> {
  late SuperBoolFieldController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        SuperBoolFieldController(initialValue: widget.initialValue);
    _ownsController = widget.controller == null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperBoolFormField old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      if (_ownsController) _controller.dispose();
      _controller =
          widget.controller ??
          SuperBoolFieldController(initialValue: widget.initialValue);
      _ownsController = widget.controller == null;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  bool get _editable => !widget.disabled && !widget.readOnly;

  @override
  Widget build(BuildContext context) {
    _controller.configure(
      validators: buildBoolValidators(
        mustBeTrue: widget.mustBeTrue,
        mustBeTrueMessage: widget.mustBeTrueMessage,
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
        final on = _controller.value;
        final error = widget.disabled
            ? null
            : SffDecoration.resolveError(
                widget.decoration,
                _controller.visibleError,
              );
        final fontFamily = widget.arabic
            ? SuperThemeData.of(context).tokens.arabicFont
            : SuperThemeData.of(context).tokens.bodyFont;

        final hasCustomCaption =
            widget.decoration.hint != null ||
            widget.decoration.hintText != null;
        final captionStyle = SffDecoration.mergeStyle(
          SuperText.body.copyWith(
            color: on ? t.fg1 : t.fg3,
            fontFamily: fontFamily,
            fontWeight: hasCustomCaption ? FontWeight.w400 : FontWeight.w500,
          ),
          widget.decoration.hintStyle,
        );
        final caption = widget.decoration.hint != null
            ? DefaultTextStyle.merge(
                style: captionStyle,
                child: widget.decoration.hint!,
              )
            : Text(
                widget.decoration.hintText ??
                    (on ? widget.enabledLabel : widget.disabledLabel),
                style: captionStyle,
                textAlign: widget.arabic ? TextAlign.right : TextAlign.left,
              );

        final control = widget.style == SuperBoolStyle.checkbox
            ? _CheckBox(value: on, disabled: widget.disabled)
            : _Toggle(value: on, disabled: widget.disabled);
        final leading = SffDecoration.buildLeading(
          context,
          widget.decoration,
        );
        final trailing = SffDecoration.buildTrailing(
          context,
          widget.decoration,
        );

        final row = Row(
          children: [
            if (leading != null) ...[
              leading,
              SizedBox(width: SuperThemeData.of(context).tokens.space2),
            ],
            control,
            SizedBox(width: SuperThemeData.of(context).tokens.space3),
            Expanded(child: caption),
            for (final item in trailing) ...[
              SizedBox(width: SuperThemeData.of(context).tokens.space1),
              item,
            ],
            if (error != null) ...[
              SizedBox(width: SuperThemeData.of(context).tokens.space1),
              ErrorBadge(error: error),
            ],
          ],
        );

        return FieldShell(
          decoration: widget.decoration,
          required: widget.required,
          hasError: error != null,
          arabic: widget.arabic,
          child: Opacity(
            opacity: widget.disabled ? 0.55 : 1,
            child: MouseRegion(
              cursor: _editable
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _editable ? _controller.toggle : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: SuperThemeData.of(context).tokens.space1,
                  ),
                  child: row,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The sliding toggle track + thumb.
class _Toggle extends StatelessWidget {
  const _Toggle({required this.value, required this.disabled});
  final bool value;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    return AnimatedContainer(
      duration: SuperThemeData.of(context).tokens.durBase,
      curve: SuperThemeData.of(context).tokens.curveStandard,
      width: 40,
      height: 23,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: value ? cs.primary : t.inputBg,
        border: Border.all(
          color: value ? cs.primary : t.borderStrong,
          width: 1.4,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: AnimatedAlign(
        duration: SuperThemeData.of(context).tokens.durBase,
        curve: SuperThemeData.of(context).tokens.curveStandard,
        alignment: value
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: value ? const Color(0xFFFFFFFF) : t.fg3,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// The checkbox square variant.
class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.value, required this.disabled});
  final bool value;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    return AnimatedContainer(
      duration: SuperThemeData.of(context).tokens.durFast,
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: value ? cs.primary : const Color(0x00000000),
        border: Border.all(
          color: value ? cs.primary : t.borderStrong,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(
          SuperThemeData.of(context).tokens.radiusControl,
        ),
      ),
      child: value
          ? const Icon(SffIcons.check, size: 14, color: Color(0xFFFFFFFF))
          : const SizedBox.shrink(),
    );
  }
}
