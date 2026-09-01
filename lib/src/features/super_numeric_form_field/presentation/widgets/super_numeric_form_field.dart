// ============================================================
// features/super_numeric_form_field/presentation/widgets/super_numeric_form_field.dart
// ------------------------------------------------------------
// The View for the GeniusLink numeric field. A thin Flutter wrapper that builds
// the validator chain (domain usecase), drives a [SuperNumericFieldController]
// (the Model), and renders the return FormFieldShell( + FieldBox chrome. Numbers stay
// Western digits and right-aligned mono even in RTL. Validation surfaces only
// through the suffix ErrorBadge. Includes a +/- stepper and prefix/suffix units.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
import '../../../../../localization/super_form_localizations.dart';
import '../../domain/usecases/numeric_logic.dart';
import '../controllers/super_numeric_field_controller.dart';

/// A themeable, validated numeric field on the GeniusLink field foundation.
class SuperNumericFormField extends StatefulWidget {
  const SuperNumericFormField({
    super.key,
    this.controller,
    this.allowFixed = false,
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
    this.validationPosition,
    this.helpIcon,
    this.arabic = false,
    this.autofocus = false,
    this.keyboardType,
    this.inputFormatters,
    this.textDirection,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.right,
    this.textAlignVertical = TextAlignVertical.center,
    this.onFieldSubmitted,
    this.onTap,
    this.onTapAlwaysCalled = false,
    this.onTapOutside,
    this.onTapUpOutside,
    this.onEditingComplete,
    this.onSaved,
    this.onSave,
    this.keyboardAppearance,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.smartDashesType = SmartDashesType.disabled,
    this.smartQuotesType = SmartQuotesType.disabled,
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
    this.autovalidateMode = AutovalidateMode.disabled,
  }) : assert(
         onSaved == null || onSave == null,
         'Provide either onSaved or onSave, not both.',
       );

  final SuperNumericFieldController? controller;

  /// Shows a compact lock/unlock action on the label row.
  ///
  /// The action toggles the controller's `isFixed` notifier. Fixed fields keep
  /// normal contrast while blocking user and controller-driven mutations.
  final bool allowFixed;
  final num? initialValue;
  final ValueChanged<num?>? onChanged;
  final FormValidityChanged? onValidity;

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

  /// Controls where validation feedback is rendered.
  ///
  /// When null, the field uses [ValidationPosition.underBox] on mobile and
  /// [ValidationPosition.labelTrailing] on tablet/desktop.
  final ValidationPosition? validationPosition;

  /// Optional widget displayed at the end of the label row.
  final Widget? helpIcon;

  final bool arabic;

  // ── Material text-input behaviour ──
  final bool autofocus;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final ValueChanged<String>? onFieldSubmitted;
  final GestureTapCallback? onTap;
  final bool onTapAlwaysCalled;
  final void Function(PointerDownEvent event)? onTapOutside;
  final void Function(PointerUpEvent event)? onTapUpOutside;
  final VoidCallback? onEditingComplete;

  /// Called with the parsed numeric value by an ancestor [Form].
  final FormFieldSetter<num?>? onSaved;

  /// Backward-compatible alias for [onSaved].
  final FormFieldSetter<num?>? onSave;

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
  final AutovalidateMode autovalidateMode;

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
    if (_controller.isHiden) return const SizedBox.shrink();
    final l10n = SuperFormTranslation.of(context);

    return FormField<num?>(
      key: _controller.formFieldKey ?? ObjectKey(_controller),
      initialValue: _controller.value,
      enabled: !widget.disabled,
      onSaved: widget.onSaved ?? widget.onSave,
      autovalidateMode: widget.autovalidateMode,
      validator: (_) => _controller.error,
      builder: (formState) {
        _controller.configure(
          min: widget.min,
          max: widget.max,
          decimals: widget.decimals,
          grouping: widget.grouping,
          allowNegative: widget.allowNegative,
          step: widget.step,
          largeStep: widget.largeStep,
          readOnly: widget.readOnly || _controller.isFixed.value,
          keyboardEnabled: widget.keyboardShortcuts,
          validators: NumericLogic.buildValidators(
            required: widget.required,
            min: widget.min,
            max: widget.max,
            decimals: widget.decimals,
            grouping: widget.grouping,
            allowNegative: widget.allowNegative,
            extra: widget.validators,
            requiredMessage: l10n.requiredMessage,
            cannotBeNegativeMessage: l10n.cannotBeNegative,
            minMessage: l10n.minNumber,
            maxMessage: l10n.maxNumber,
          ),
          forceError: widget.forceError || formState.hasError,
          onValidity: widget.onValidity,
          onChanged: (value) {
            formState.didChange(value);
            widget.onChanged?.call(value);
          },
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
            final validationPosition =
                SffDecoration.effectiveValidationPosition(
                  context,
                  widget.validationPosition,
                );
            final labelRight = SffDecoration.buildLabelRight(
              context,
              widget.decoration,
              arabic: widget.arabic,
              error: error,
              validationPosition: validationPosition,
              helpIcon: widget.helpIcon,
            );
            final underBoxError =
                validationPosition == ValidationPosition.underBox
                ? error
                : null;

            final sizing = SuperThemeData.of(context).sizing;
            final spacing = SuperThemeData.of(context).spacing;
            final controlHeight = widget.density == FieldDensity.compact
                ? sizing.fieldCompact
                : sizing.fieldComfortable;
            final unitStyle = context.sffTextTheme.mono.copyWith(
              color: t.fg3,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            );
            final stepperBorderRadius = BorderRadius.circular(
              spacing.radiusControl,
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
                              tooltip: l10n.decrement,
                              bordered: true,
                              size: controlHeight,
                              border: Border.all(color: Colors.transparent),
                              borderRadius: BorderRadius.zero,
                              iconSize: 14,
                              onPressed: widget.readOnly
                                  ? null
                                  : () => _controller.bump(-1),
                            ),
                            FieldIconButton(
                              key: const ValueKey('super_numeric_increment'),
                              icon: SffIcons.plus,
                              tooltip: l10n.increment,
                              bordered: true,
                              size: controlHeight,
                              border: Border.all(color: Colors.transparent),
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

            return FormFieldShell(
              allowFixed: widget.allowFixed,
              isFixed: _controller.isFixed,
              decoration: widget.decoration,
              required: widget.required,
              hasError: error != null,
              errorText: underBoxError,
              arabic: widget.arabic,
              labelRight: labelRight,
              child: FieldBox(
                focused: _controller.focused,
                error: error,
                disabled: widget.disabled,
                density: widget.density,
                flushTrailing:
                    widget.stepper && !widget.disabled && error == null,
                showErrorBadge:
                    validationPosition == ValidationPosition.suffixIcon,
                leading: SffDecoration.buildLeading(
                  context,
                  widget.decoration,
                  textStyle: unitStyle,
                ),
                trailing: trailing,
                child: Directionality(
                  textDirection: widget.textDirection ?? TextDirection.ltr,
                  child: Listener(
                    behavior: HitTestBehavior.translucent,
                    onPointerDown: widget.disabled
                        ? null
                        : (_) => _controller.focusNode?.requestFocus(),
                    child: Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: TextField(
                          controller: _controller.text,
                          focusNode: _controller.focusNode,
                          enabled: !widget.disabled,
                          readOnly:
                              widget.readOnly || _controller.isFixed.value,
                          autofocus: widget.autofocus,
                          keyboardType:
                              widget.keyboardType ??
                              TextInputType.numberWithOptions(
                                decimal: widget.decimals > 0,
                                signed: widget.allowNegative,
                              ),
                          inputFormatters: widget.inputFormatters,
                          textDirection:
                              widget.textDirection ?? TextDirection.ltr,
                          textInputAction: widget.textInputAction,
                          textCapitalization: widget.textCapitalization,
                          textAlign: widget.textAlign,
                          textAlignVertical: widget.textAlignVertical,
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
                          enableInteractiveSelection:
                              widget.enableInteractiveSelection,
                          selectionControls: widget.selectionControls,
                          scrollPadding: widget.scrollPadding,
                          scrollPhysics: widget.scrollPhysics,
                          scrollController: widget.scrollController,
                          autofillHints: widget.autofillHints,
                          mouseCursor: widget.mouseCursor,
                          contextMenuBuilder: widget.contextMenuBuilder,
                          restorationId: widget.restorationId,
                          enableIMEPersonalizedLearning:
                              widget.enableIMEPersonalizedLearning,
                          canRequestFocus: widget.canRequestFocus,
                          clipBehavior: widget.clipBehavior,
                          cursorWidth: widget.cursorWidth,
                          cursorHeight: widget.cursorHeight,
                          cursorRadius: widget.cursorRadius,
                          cursorColor: widget.cursorColor ?? cs.primary,
                          cursorErrorColor: widget.cursorErrorColor ?? cs.error,
                          style: SffDecoration.mergeStyle(
                            context.sffTextTheme.mono.copyWith(color: t.fg1),
                            widget.style,
                          ),
                          strutStyle: widget.strutStyle,
                          // FieldBox owns border and height. The editor keeps its
                          // natural single-line size and is centered by layout.
                          decoration: InputDecoration(
                            hint: widget.decoration.hint,
                            hintText: widget.decoration.hintText,
                            hintStyle: SffDecoration.mergeStyle(
                              context.sffTextTheme.mono.copyWith(color: t.fg4),
                              widget.decoration.hintStyle,
                            ),
                            hintTextDirection:
                                widget.textDirection ?? TextDirection.ltr,
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
      },
    );
  }
}
