// ============================================================
// features/super_otp_form_field/presentation/widgets/
// super_otp_form_field.dart
// ------------------------------------------------------------
// A segmented one-time-password field backed by one real TextField. This
// preserves paste, SMS autofill, IME, keyboard, and Form behavior while the
// visible value is rendered in separate GeniusLink design-system cells.
// ============================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
import '../../../../../localization/super_form_localizations.dart';
import '../../domain/usecases/build_otp_validators.dart';
import '../controllers/super_otp_field_controller.dart';

/// A segmented verification-code field with paste and one-time-code autofill.
class SuperOTPFormField extends StatefulWidget {
  const SuperOTPFormField({
    super.key,
    this.controller,
    this.allowFixed = false,
    this.initialValue = '',
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.onValidity,
    this.decoration = const InputDecoration(),
    this.required = false,
    this.showCounter = false,
    this.validators = const [],
    this.forceError = false,
    this.density = FieldDensity.comfortable,
    this.disabled = false,
    this.readOnly = false,
    this.digitsOnly = true,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.arabic = false,
    this.autofocus = false,
    this.keyboardType,
    this.inputFormatters,
    this.textDirection = TextDirection.ltr,
    this.textInputAction = TextInputAction.done,
    this.textCapitalization = TextCapitalization.characters,
    this.onFieldSubmitted,
    this.onTap,
    this.onTapOutside,
    this.onTapUpOutside,
    this.onEditingComplete,
    this.onSaved,
    this.onSave,
    this.keyboardAppearance,
    this.autofillHints = const [AutofillHints.oneTimeCode],
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.scrollPadding = const EdgeInsets.all(20),
    this.mouseCursor,
    this.contextMenuBuilder,
    this.restorationId,
    this.enableIMEPersonalizedLearning = false,
    this.maxLengthEnforcement = MaxLengthEnforcement.enforced,
    this.canRequestFocus = true,
    this.clipBehavior = Clip.hardEdge,
    this.showCursor = true,
    this.cursorWidth = 2,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.textStyle,
    this.boxWidth,
    this.boxHeight,
    this.spacing,
    this.borderRadius,
    this.autovalidateMode = AutovalidateMode.disabled,
  }) : assert(length > 0),
       assert(obscuringCharacter.length == 1),
       assert(boxWidth == null || boxWidth > 0),
       assert(boxHeight == null || boxHeight > 0),
       assert(spacing == null || spacing >= 0),
       assert(cursorWidth > 0),
       assert(
         onSaved == null || onSave == null,
         'Provide either onSaved or onSave, not both.',
       );

  /// Controller for the code, focus, and touched state.
  final SuperOTPFieldController? controller;

  /// Shows a compact lock/unlock action on the label row.
  ///
  /// The action toggles the controller's `isFixed` notifier. Fixed fields keep
  /// normal contrast while blocking user and controller-driven mutations.
  final bool allowFixed;

  /// Initial code when the widget creates its own controller.
  final String initialValue;

  /// Exact number of characters required for completion.
  final int length;

  /// Called whenever the code changes.
  final ValueChanged<String>? onChanged;

  /// Called once for each newly completed code value.
  final ValueChanged<String>? onCompleted;

  /// Reports the current validation error, or null when valid.
  final FormValidityChanged? onValidity;

  /// Label, helper, icon, adornment, counter, and external error source.
  final InputDecoration decoration;

  /// Whether an empty code is invalid.
  final bool required;

  /// Shows the current code length beside the field label.
  final bool showCounter;

  /// Additional validators run after built-in required and length validation.
  final List<Validator<String>> validators;

  /// Shows validation immediately instead of waiting for blur/touch.
  final bool forceError;

  final FieldDensity density;
  final bool disabled;
  final bool readOnly;

  /// Applies a digits-only formatter and numeric keyboard by default.
  final bool digitsOnly;

  /// Replaces entered characters with [obscuringCharacter] in the visual cells.
  final bool obscureText;
  final String obscuringCharacter;
  final bool arabic;
  final bool autofocus;

  // ── Material text-input behavior ──────────────────────────────────────────
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection textDirection;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onFieldSubmitted;
  final GestureTapCallback? onTap;
  final void Function(PointerDownEvent event)? onTapOutside;
  final void Function(PointerUpEvent event)? onTapUpOutside;
  final VoidCallback? onEditingComplete;

  /// Called by an ancestor [Form] with the completed or partial code.
  final FormFieldSetter<String>? onSaved;

  /// Backward-compatible alias for [onSaved].
  final FormFieldSetter<String>? onSave;

  final Brightness? keyboardAppearance;
  final Iterable<String>? autofillHints;
  final bool enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final EdgeInsets scrollPadding;
  final MouseCursor? mouseCursor;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final MaxLengthEnforcement maxLengthEnforcement;
  final bool canRequestFocus;
  final Clip clipBehavior;

  // ── Visual cell configuration ─────────────────────────────────────────────
  final bool showCursor;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final TextStyle? textStyle;
  final double? boxWidth;
  final double? boxHeight;
  final double? spacing;
  final BorderRadius? borderRadius;
  final AutovalidateMode autovalidateMode;

  @override
  State<SuperOTPFormField> createState() => _SuperOTPFormFieldState();
}

class _SuperOTPFormFieldState extends State<SuperOTPFormField> {
  late SuperOTPFieldController _controller;
  bool _ownsController = false;
  FormFieldState<String>? _formState;
  String? _lastCompletedValue;
  late String _resetValue;
  bool _resetting = false;

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperOTPFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _detachController();
      _formState = null;
      _lastCompletedValue = null;
      _attachController(widget.controller);
    }
    if (widget.length != oldWidget.length) {
      _lastCompletedValue = null;
    }
  }

  void _attachController(SuperOTPFieldController? externalController) {
    _controller =
        externalController ??
        SuperOTPFieldController(initialValue: widget.initialValue);
    _ownsController = externalController == null;
    _resetValue = _controller.value;
    _controller.text.addListener(_handleValueChanged);
  }

  void _detachController() {
    _controller.text.removeListener(_handleValueChanged);
    if (_ownsController) _controller.dispose();
  }

  void _handleValueChanged() {
    if (_resetting) return;
    final value = _controller.value;
    _formState?.didChange(value);
    widget.onChanged?.call(value);

    if (value.length == widget.length) {
      if (_lastCompletedValue != value) {
        _lastCompletedValue = value;
        widget.onCompleted?.call(value);
      }
    } else {
      _lastCompletedValue = null;
    }
  }

  @override
  void dispose() {
    _formState = null;
    _detachController();
    super.dispose();
  }

  List<Validator<String>> _buildValidators() {
    final l10n = SuperFormTranslation.of(context);
    return buildOTPValidators(
      required: widget.required,
      length: widget.length,
      extra: widget.validators,
      requiredMessage: l10n.requiredMessage,
      lengthMessage: l10n.otpLength(widget.length),
    );
  }

  List<TextInputFormatter> _buildInputFormatters() {
    return <TextInputFormatter>[
      ...?widget.inputFormatters,
      if (widget.digitsOnly) FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(
        widget.length,
        maxLengthEnforcement: widget.maxLengthEnforcement,
      ),
    ];
  }

  void _requestFocus() {
    if (widget.disabled || widget.readOnly || _controller.isFixed.value) return;
    if (widget.canRequestFocus) _controller.requestFocus();
    widget.onTap?.call();
  }

  void _reset() {
    _resetting = true;
    try {
      _controller.setValue(_resetValue);
      _controller.resetTouched();
      _lastCompletedValue = null;
    } finally {
      _resetting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isHiden) return const SizedBox.shrink();
    return _OTPFormField(
      key: _controller.formFieldKey ?? ObjectKey(_controller),
      initialValue: _controller.value,
      enabled: !widget.disabled,
      onSaved: widget.onSaved ?? widget.onSave,
      onResetValue: _reset,
      autovalidateMode: widget.autovalidateMode,
      validator: (_) => _controller.error,
      builder: (formState) {
        _formState = formState;
        _controller.configure(
          validators: _buildValidators(),
          forceError: widget.forceError || formState.hasError,
          onValidity: widget.onValidity,
        );

        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final error = widget.disabled
                ? null
                : SffDecoration.resolveError(
                    widget.decoration,
                    _controller.visibleError,
                  );
            final counter =
                widget.showCounter &&
                    widget.decoration.counter == null &&
                    widget.decoration.counterText == null
                ? _OTPCount(
                    current: _controller.value.length,
                    length: widget.length,
                  )
                : null;

            return FormFieldShell(
              allowFixed: widget.allowFixed,
              isFixed: _controller.isFixed,
              decoration: widget.decoration,
              required: widget.required,
              hasError: error != null,
              arabic: widget.arabic,
              labelRight: counter,
              child: _buildControl(context, error),
            );
          },
        );
      },
    );
  }

  Widget _buildControl(BuildContext context, String? error) {
    final theme = context.sffTheme;
    final spacing = SuperThemeData.of(context).spacing;
    final adornStyle = context.sffTextTheme.body.copyWith(
      color: theme.fg3,
      fontSize: 13,
    );
    final leading = SffDecoration.buildLeading(
      context,
      widget.decoration,
      textStyle: adornStyle,
    );
    final trailing = SffDecoration.buildTrailing(
      context,
      widget.decoration,
      textStyle: adornStyle,
    );

    final hasHint =
        widget.decoration.hint != null || widget.decoration.hintText != null;

    return Opacity(
      opacity: widget.disabled ? 0.55 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasHint) ...[
            SffDecoration.buildHint(
              context,
              widget.decoration,
              fallback: '',
              arabic: widget.arabic,
              textDirection:
                  widget.decoration.hintTextDirection ?? widget.textDirection,
              maxLines: widget.decoration.hintMaxLines ?? 1,
            ),
            SizedBox(height: spacing.space2),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading,
                SizedBox(width: spacing.space3),
              ],
              Expanded(child: _buildOTPInput(context, error)),
              if (trailing.isNotEmpty) ...[
                SizedBox(width: spacing.space3),
                ..._withSpacing(trailing, spacing.space2),
              ],
              if (error != null) ...[
                SizedBox(width: spacing.space2),
                ErrorBadge(error: error),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOTPInput(BuildContext context, String? error) {
    final label = widget.decoration.labelText;
    final semanticValue = widget.obscureText
        ? List.filled(
            _controller.value.length,
            widget.obscuringCharacter,
          ).join()
        : _controller.value;

    return Semantics(
      excludeSemantics: true,
      textField: true,
      enabled: !widget.disabled,
      readOnly: widget.readOnly || _controller.isFixed.value,
      obscured: widget.obscureText,
      focusable: widget.canRequestFocus && !widget.disabled,
      focused: _controller.focused,
      label: label,
      hint: widget.decoration.hintText,
      value: semanticValue,
      onTap: widget.disabled ? null : _requestFocus,
      child: MouseRegion(
        cursor:
            widget.mouseCursor ??
            (widget.disabled
                ? SystemMouseCursors.basic
                : SystemMouseCursors.text),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.disabled ? null : _requestFocus,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: _controller.text,
                    focusNode: _controller.focusNode,
                    enabled: !widget.disabled,
                    readOnly: widget.readOnly || _controller.isFixed.value,
                    autofocus: widget.autofocus,
                    keyboardType:
                        widget.keyboardType ??
                        (widget.digitsOnly
                            ? TextInputType.number
                            : TextInputType.text),
                    inputFormatters: _buildInputFormatters(),
                    textDirection: widget.textDirection,
                    textInputAction: widget.textInputAction,
                    textCapitalization: widget.textCapitalization,
                    onSubmitted: widget.onFieldSubmitted,
                    onTapOutside: widget.onTapOutside,
                    onTapUpOutside: widget.onTapUpOutside,
                    onEditingComplete: widget.onEditingComplete,
                    keyboardAppearance: widget.keyboardAppearance,
                    autocorrect: false,
                    enableSuggestions: false,
                    smartDashesType: SmartDashesType.disabled,
                    smartQuotesType: SmartQuotesType.disabled,
                    enableInteractiveSelection:
                        widget.enableInteractiveSelection,
                    selectionControls: widget.selectionControls,
                    scrollPadding: widget.scrollPadding,
                    autofillHints: widget.autofillHints,
                    contextMenuBuilder: widget.contextMenuBuilder,
                    restorationId: widget.restorationId,
                    enableIMEPersonalizedLearning:
                        widget.enableIMEPersonalizedLearning,
                    canRequestFocus: widget.canRequestFocus,
                    clipBehavior: widget.clipBehavior,
                    showCursor: false,
                    style: const TextStyle(color: Colors.transparent),
                    cursorColor: Colors.transparent,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                    ),
                  ),
                ),
              ),
              ExcludeSemantics(child: _buildCells(context, error)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCells(BuildContext context, String? error) {
    final sizing = SuperThemeData.of(context).sizing;
    final defaultHeight = widget.density == FieldDensity.compact
        ? sizing.fieldCompact
        : sizing.fieldComfortable;
    final height = widget.boxHeight ?? defaultHeight;
    final preferredWidth = widget.boxWidth ?? height;
    final gap = widget.spacing ?? SuperThemeData.of(context).spacing.space2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final totalGap = gap * math.max(0, widget.length - 1).toDouble();
        final fittedWidth = availableWidth.isFinite
            ? (availableWidth - totalGap) / widget.length
            : preferredWidth;
        final cellWidth = availableWidth.isFinite
            ? math
                  .min(preferredWidth, math.max(32.0, fittedWidth).toDouble())
                  .toDouble()
            : preferredWidth;
        final contentWidth = (cellWidth * widget.length) + totalGap;
        final shouldScroll =
            availableWidth.isFinite && contentWidth > availableWidth;

        final cells = Directionality(
          textDirection: widget.textDirection,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < widget.length; index++) ...[
                if (index > 0) SizedBox(width: gap),
                _OTPCell(
                  index: index,
                  value: _controller.value,
                  active:
                      !widget.disabled &&
                      _controller.focused &&
                      index ==
                          (_controller.value.length < widget.length
                              ? _controller.value.length
                              : widget.length - 1),
                  hasError: error != null,
                  disabled: widget.disabled,
                  obscureText: widget.obscureText,
                  obscuringCharacter: widget.obscuringCharacter,
                  width: cellWidth,
                  height: height,
                  borderRadius:
                      widget.borderRadius ??
                      BorderRadius.circular(
                        SuperThemeData.of(context).spacing.radiusControl,
                      ),
                  textStyle: widget.textStyle,
                  showCursor: widget.showCursor,
                  cursorWidth: widget.cursorWidth,
                  cursorHeight: widget.cursorHeight,
                  cursorRadius: widget.cursorRadius,
                  cursorColor: widget.cursorColor,
                ),
              ],
            ],
          ),
        );

        if (!shouldScroll) {
          return Align(
            alignment: AlignmentDirectional.centerStart,
            child: cells,
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: cells,
        );
      },
    );
  }

  List<Widget> _withSpacing(List<Widget> widgets, double gap) {
    return <Widget>[
      for (var index = 0; index < widgets.length; index++) ...[
        if (index > 0) SizedBox(width: gap),
        widgets[index],
      ],
    ];
  }
}

class _OTPFormField extends FormField<String> {
  const _OTPFormField({
    required super.builder,
    required this.onResetValue,
    super.key,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.enabled,
    super.autovalidateMode,
  });

  final VoidCallback onResetValue;

  @override
  FormFieldState<String> createState() => _OTPFormFieldState();
}

class _OTPFormFieldState extends FormFieldState<String> {
  @override
  void reset() {
    super.reset();
    (widget as _OTPFormField).onResetValue();
  }
}

class _OTPCell extends StatelessWidget {
  const _OTPCell({
    required this.index,
    required this.value,
    required this.active,
    required this.hasError,
    required this.disabled,
    required this.obscureText,
    required this.obscuringCharacter,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.textStyle,
    required this.showCursor,
    required this.cursorWidth,
    required this.cursorHeight,
    required this.cursorRadius,
    required this.cursorColor,
  });

  final int index;
  final String value;
  final bool active;
  final bool hasError;
  final bool disabled;
  final bool obscureText;
  final String obscuringCharacter;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final TextStyle? textStyle;
  final bool showCursor;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.sffTheme;
    final colorScheme = context.sffColorScheme;
    final hasCharacter = index < value.length;
    final character = hasCharacter
        ? (obscureText ? obscuringCharacter : value[index])
        : '';

    final borderColor = disabled
        ? theme.border
        : hasError
        ? colorScheme.error
        : active
        ? colorScheme.primary
        : hasCharacter
        ? theme.borderStrong
        : theme.border;
    final fillColor = disabled
        ? Colors.transparent
        : active
        ? theme.surface
        : theme.inputBg;
    final baseStyle = context.sffTextTheme.mono.copyWith(
      color: theme.fg1,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    );

    return AnimatedContainer(
      duration: SuperThemeData.of(context).tokens.durBase,
      curve: SuperThemeData.of(context).tokens.curveStandard,
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: active ? 1.8 : 1.4),
        boxShadow: hasError
            ? [
                BoxShadow(
                  color: colorScheme.error.withValues(alpha: 0.12),
                  blurRadius: 0,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            character,
            style: SffDecoration.mergeStyle(baseStyle, textStyle),
          ),
          if (showCursor && active && !hasCharacter)
            Container(
              width: cursorWidth,
              height: cursorHeight ?? math.min(22.0, height * 0.46).toDouble(),
              decoration: BoxDecoration(
                color: cursorColor ?? colorScheme.primary,
                borderRadius: BorderRadius.all(
                  cursorRadius ?? Radius.circular(cursorWidth),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OTPCount extends StatelessWidget {
  const _OTPCount({required this.current, required this.length});

  final int current;
  final int length;

  @override
  Widget build(BuildContext context) {
    final theme = context.sffTheme;
    return Text(
      '$current/$length',
      style: context.sffTextTheme.mono.copyWith(color: theme.fg4, fontSize: 11),
    );
  }
}
