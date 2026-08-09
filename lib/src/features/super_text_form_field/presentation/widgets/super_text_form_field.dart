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
// character counter, multiline, email, phone, declarative masks, disabled &
// read-only, and LTR/RTL.
// ============================================================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
import '../../../../../localization/super_form_localizations.dart';
import '../../domain/entities/text_field_config.dart';
import '../../domain/usecases/build_text_validators.dart';
import '../controllers/super_text_field_controller.dart';

/// A themeable, validated text field on the GeniusLink field foundation.
class SuperTextFormField extends StatefulWidget {
  SuperTextFormField({
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
    this.keyboardType,
    this.inputFormatters,
    this.mask,
    this.maskFilter,
    this.maskAutoCompletionType = MaskAutoCompletionType.lazy,
    this.onUnmaskedChanged,
    this.onUnmaskedSaved,
    this.textDirection,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscuringCharacter = '•',
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.onFieldSubmitted,
    this.onTap,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.onTapUpOutside,
    this.onEditingComplete,
    this.onSaved,
    this.onSave,
    this.keyboardAppearance,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.showCursor,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.scrollPadding = const EdgeInsets.all(20),
    this.scrollPhysics,
    this.scrollController,
    this.autofillHints,
    this.mouseCursor,
    this.contextMenuBuilder,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.canRequestFocus = true,
    this.clipBehavior = Clip.hardEdge,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.cursorErrorColor,
    this.style,
    this.strutStyle,
    this.maxLengthEnforcement,
    this.minLines,
    this.maxLines,
    this.autovalidateMode = AutovalidateMode.disabled,
  }) : assert(
         onSaved == null || onSave == null,
         'Provide either onSaved or onSave, not both.',
       ),
       assert(obscuringCharacter.length == 1),
       assert(mask == null || mask.isNotEmpty),
       assert(rows > 0),
       assert(minLines == null || minLines > 0),
       assert(maxLines == null || maxLines > 0),
       assert(
         minLines == null || maxLines == null || minLines <= maxLines,
         'minLines must be less than or equal to maxLines.',
       );

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

  // ── Material text-input behaviour ──
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  /// Optional input mask powered by `mask_text_input_formatter`.
  ///
  /// The default placeholders are:
  ///
  /// - `#` for digits.
  /// - `A` for Latin letters.
  /// - `N` for Latin letters or digits.
  ///
  /// Custom [inputFormatters] run first and the mask formatter runs last, so
  /// the configured mask remains authoritative.
  final String? mask;

  /// Optional placeholder rules used by [mask].
  ///
  /// When omitted, the package uses the built-in `#`, `A`, and `N` rules
  /// documented on [mask].
  final Map<String, RegExp>? maskFilter;

  /// Controls whether literal mask characters are inserted lazily or eagerly.
  final MaskAutoCompletionType maskAutoCompletionType;

  /// Reports the value without mask literals whenever the field changes.
  ///
  /// When [mask] is null, this receives the same value as [onChanged].
  final ValueChanged<String>? onUnmaskedChanged;

  /// Reports the value without mask literals when an ancestor [Form] is saved.
  ///
  /// When [mask] is null, this receives the same value as [onSaved].
  final FormFieldSetter<String>? onUnmaskedSaved;

  final TextDirection? textDirection;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  /// Character used while [type] is [SuperTextType.password].
  final String obscuringCharacter;

  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final ValueChanged<String>? onFieldSubmitted;
  final GestureTapCallback? onTap;
  final bool onTapAlwaysCalled;
  final void Function(PointerDownEvent event)? onTapOutside;
  final void Function(PointerUpEvent event)? onTapUpOutside;
  final VoidCallback? onEditingComplete;

  /// Called by an ancestor [Form] when [FormState.save] is invoked.
  final FormFieldSetter<String>? onSaved;

  /// Backward-compatible alias for [onSaved].
  final FormFieldSetter<String>? onSave;

  final Brightness? keyboardAppearance;
  final bool autocorrect;
  final bool enableSuggestions;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool? showCursor;
  final bool enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final EdgeInsets scrollPadding;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final Iterable<String>? autofillHints;
  final MouseCursor? mouseCursor;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final bool canRequestFocus;
  final Clip clipBehavior;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final Color? cursorErrorColor;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// Overrides [rows] for multiline fields when provided.
  final int? minLines;
  final int? maxLines;

  /// Controls when the field participates in an ancestor [Form] validation.
  final AutovalidateMode autovalidateMode;

  @override
  State<SuperTextFormField> createState() => _SuperTextFormFieldState();
}

class _SuperTextFormFieldState extends State<SuperTextFormField> {
  late SuperTextFieldController _controller;
  MaskTextInputFormatter? _maskFormatter;
  FormFieldState<String>? _formState;
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
    _configureMaskFormatter();
    _controller.text.addListener(_emitChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperTextFormField old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      _formState = null;
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
      _configureMaskFormatter();
    }

    if (widget.mask != old.mask ||
        widget.maskFilter != old.maskFilter ||
        widget.maskAutoCompletionType != old.maskAutoCompletionType) {
      _configureMaskFormatter();
    }
  }

  void _emitChange() {
    _formState?.didChange(_controller.value);
    widget.onChanged?.call(_controller.value);
    widget.onUnmaskedChanged?.call(_unmaskedValue);
  }

  String get _unmaskedValue {
    final mask = widget.mask;
    if (mask == null) return _controller.value;

    return _removeMaskLiterals(
      value: _controller.value,
      mask: mask,
      filter: widget.maskFilter ?? _defaultMaskFilter(),
    );
  }

  void _configureMaskFormatter() {
    final mask = widget.mask;
    if (mask == null) {
      _maskFormatter = null;
      return;
    }

    _maskFormatter = MaskTextInputFormatter(
      mask: mask,
      filter: widget.maskFilter ?? _defaultMaskFilter(),
      type: widget.maskAutoCompletionType,
    );
  }

  @override
  void dispose() {
    _formState = null;
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
    requiredMessage: SuperFormTranslation.of(context).requiredMessage,
    minLengthMessage: SuperFormTranslation.of(context).minCharacters,
    maxLengthMessage: SuperFormTranslation.of(context).maxCharacters,
    emailMessage: SuperFormTranslation.of(context).validEmail,
    invalidFormatMessage: SuperFormTranslation.of(context).invalidFormat,
  );

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: ObjectKey(_controller),
      initialValue: _controller.value,
      enabled: !widget.disabled,
      onSaved: (value) {
        (widget.onSaved ?? widget.onSave)?.call(value);
        widget.onUnmaskedSaved?.call(_unmaskedValue);
      },
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
            final t = context.sffTheme;
            final cs = context.sffColorScheme;
            final error = widget.disabled
                ? null
                : SffDecoration.resolveError(
                    widget.decoration,
                    _controller.visibleError,
                  );
            final counter = (widget.showCounter && widget.maxLength != null)
                ? _Counter(
                    length: _controller.value.length,
                    max: widget.maxLength!,
                  )
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
            SuperThemeData.of(context).spacing.radiusControl,
          ),
          borderSide: BorderSide(color: color, width: width),
        );

    // ── Fill ──
    final fillColor = focused && !widget.disabled ? t.surface : t.inputBg;

    final source = widget.decoration;
    final l10n = SuperFormTranslation.of(context);
    final textDirection =
        widget.textDirection ?? Directionality.of(context);

    // ── Suffix icon row ──
    final trailingWidgets = <Widget>[
      if (source.suffixIcon != null) source.suffixIcon!,
      if (!multiline &&
          widget.clearable &&
          _controller.value.isNotEmpty &&
          editable)
        FieldIconButton(
          icon: SffIcons.clear,
          tooltip: l10n.clear,
          onPressed: _controller.clear,
        ),
      if (widget.type == SuperTextType.password && !widget.disabled)
        FieldIconButton(
          icon: _controller.obscured ? SffIcons.eye : SffIcons.eyeOff,
          tooltip: _controller.obscured ? l10n.show : l10n.hide,
          onPressed: _controller.toggleObscure,
        ),
      if (hasError) ErrorBadge(error: error),
    ];

    Widget? suffixWidget;
    if (trailingWidgets.isNotEmpty) {
      suffixWidget = Padding(
        padding: const EdgeInsetsDirectional.only(end: 4),
        child: Row(mainAxisSize: MainAxisSize.min, children: trailingWidgets),
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
              SizedBox(width: SuperThemeData.of(context).spacing.space1),
            leadingIcons[i],
          ],
        ],
      ),
    };

    // ── Density ──
    final minH = widget.density == FieldDensity.compact
        ? SuperThemeData.of(context).sizing.fieldCompact
        : SuperThemeData.of(context).sizing.fieldComfortable;

    // ── Prefix / suffix text adornments ──
    final adornStyle = context.sffTextTheme.body.copyWith(color: t.fg3, fontSize: 13);

    final decoration = InputDecoration(
      // The external FieldShell owns label/helper/counter/error presentation.
      hint: source.hint,
      hintText: source.hintText,
      hintStyle: SffDecoration.mergeStyle(
        context.sffTextTheme.body.copyWith(
          color: t.fg4,
          fontFamily: widget.arabic
              ? SuperThemeData.of(context).tokens.arabicFont
              : null,
        ),
        source.hintStyle,
      ),
      hintTextDirection: source.hintTextDirection ?? textDirection,
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
        horizontal: SuperThemeData.of(context).spacing.space3,
        vertical: widget.density == FieldDensity.compact
            ? SuperThemeData.of(context).spacing.space1
            : SuperThemeData.of(context).spacing.space2,
      ),
      border: border(enabledBorderColor),
      enabledBorder: border(enabledBorderColor),
      focusedBorder: border(focusedBorderColor),
      disabledBorder: border(disabledBorderColor),
      errorBorder: border(cs.error),
      focusedErrorBorder: border(cs.error),
    );

    final textStyle = SffDecoration.mergeStyle(
      context.sffTextTheme.body.copyWith(
        color: t.fg1,
        fontFamily: widget.arabic
            ? SuperThemeData.of(context).tokens.arabicFont
            : null,
      ),
      widget.style,
    );
    final effectiveKeyboardType =
        widget.keyboardType ??
        (multiline
            ? TextInputType.multiline
            : switch (widget.type) {
                SuperTextType.text => TextInputType.text,
                SuperTextType.email => TextInputType.emailAddress,
                SuperTextType.phone => TextInputType.phone,
                SuperTextType.password => TextInputType.text,
              });
    final effectiveMinLines = multiline
        ? (widget.minLines ?? widget.rows)
        : 1;
    final effectiveMaxLines = multiline
        ? (widget.maxLines ?? widget.rows)
        : 1;
    final effectiveInputFormatters = <TextInputFormatter>[
      ...?widget.inputFormatters,
      if (_maskFormatter != null) _maskFormatter!,
    ];

    final field = TextField(
      controller: _controller.text,
      focusNode: _controller.focusNode,
      enabled: !widget.disabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      keyboardType: effectiveKeyboardType,
      inputFormatters:
          effectiveInputFormatters.isEmpty ? null : effectiveInputFormatters,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      obscureText:
          widget.type == SuperTextType.password && _controller.obscured,
      obscuringCharacter: widget.obscuringCharacter,
      maxLines: effectiveMaxLines,
      minLines: effectiveMinLines,
      maxLength: widget.maxLength,
      maxLengthEnforcement:
          widget.maxLengthEnforcement ??
          (widget.maxLength != null
              ? MaxLengthEnforcement.enforced
              : MaxLengthEnforcement.none),
      buildCounter:
          (_, {required currentLength, required isFocused, maxLength}) => null,
      onSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      onTapAlwaysCalled: widget.onTapAlwaysCalled,
      onTapOutside: widget.onTapOutside,
      onTapUpOutside: widget.onTapUpOutside,
      onEditingComplete: widget.onEditingComplete,
      keyboardAppearance: widget.keyboardAppearance,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      smartDashesType: widget.smartDashesType,
      smartQuotesType: widget.smartQuotesType,
      showCursor: widget.showCursor,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectionControls: widget.selectionControls,
      scrollPadding: widget.scrollPadding,
      scrollPhysics: widget.scrollPhysics,
      scrollController: widget.scrollController,
      autofillHints: widget.autofillHints,
      mouseCursor: widget.mouseCursor,
      contextMenuBuilder: widget.contextMenuBuilder,
      restorationId: widget.restorationId,
      enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
      canRequestFocus: widget.canRequestFocus,
      clipBehavior: widget.clipBehavior,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorColor: widget.cursorColor ?? cs.primary,
      cursorErrorColor: widget.cursorErrorColor ?? cs.error,
      style: textStyle,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textDirection: textDirection,
      textAlignVertical:
          widget.textAlignVertical ??
          (multiline ? null : TextAlignVertical.center),
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

Map<String, RegExp> _defaultMaskFilter() => <String, RegExp>{
  '#': RegExp(r'[0-9]'),
  'A': RegExp(r'[A-Za-z]'),
  'N': RegExp(r'[A-Za-z0-9]'),
};

String _removeMaskLiterals({
  required String value,
  required String mask,
  required Map<String, RegExp> filter,
}) {
  final unmasked = StringBuffer();
  var valueIndex = 0;

  for (var maskIndex = 0;
      maskIndex < mask.length && valueIndex < value.length;
      maskIndex++) {
    final maskCharacter = mask[maskIndex];
    final placeholderPattern = filter[maskCharacter];

    if (placeholderPattern == null) {
      if (value[valueIndex] == maskCharacter) valueIndex++;
      continue;
    }

    while (valueIndex < value.length &&
        !placeholderPattern.hasMatch(value[valueIndex])) {
      valueIndex++;
    }

    if (valueIndex < value.length) {
      unmasked.write(value[valueIndex]);
      valueIndex++;
    }
  }

  return unmasked.toString();
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
      style: context.sffTextTheme.mono.copyWith(
        fontSize: 11,
        color: length > max ? cs.error : t.fg4,
      ),
    );
  }
}
