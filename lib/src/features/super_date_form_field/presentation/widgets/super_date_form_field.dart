// ============================================================
// features/super_date_form_field/presentation/widgets/super_date_form_field.dart
// ------------------------------------------------------------
// The View for the GeniusLink date field — the same input chrome the web uses:
// a fixed-width, zero-padded segmented buffer with a trailing calendar trigger.
// Mobile opens MiniCalendar in a bottom sheet; tablet and desktop keep the
// anchored popover, flipping above when there is not room below. A thin Flutter
// wrapper that builds the validator chain (domain
// usecase), drives a [SuperDateFieldController] (the Model), and renders the
// FieldShell + FieldBox chrome. The buffer stays Western-digit mono and LTR even
// in RTL. The format is configurable (year-month-day, year-month, …). Validation
// surfaces only through the suffix ErrorBadge.
// ============================================================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
import '../../../../../localization/super_form_localizations.dart';
import '../../domain/usecases/date_input_intent.dart';
import '../../domain/usecases/date_logic.dart';
import '../controllers/super_date_field_controller.dart';
import '../formatters/mobile_date_input_formatter.dart';
import 'mini_calendar.dart';
import 'mobile_calendar_bottom_sheet.dart';

/// A themeable, validated date field on the GeniusLink field foundation. Edit by
/// typing into the segment the cursor is on, stepping with the arrows, or
/// picking from the responsive calendar surface.
class SuperDateFormField extends StatefulWidget {
  const SuperDateFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onValidity,
    this.decoration = const InputDecoration(),
    this.required = false,
    this.format = SuperDateFormat.yearMonthDay,
    this.density = FieldDensity.comfortable,
    this.disabled = false,
    this.readOnly = false,
    this.minDate,
    this.maxDate,
    this.calendar = true,
    this.clearable = false,
    this.keyboardShortcuts = true,
    this.validators = const [],
    this.invalidMessage = 'Enter a valid date',
    this.forceError = false,
    this.arabic = false,
    this.autofocus = false,
    this.keyboardType,
    this.inputFormatters = const [],
    this.textDirection,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.left,
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

  /// External controller — when null, the field manages its own.
  final SuperDateFieldController? controller;

  /// Seed value, used only when [controller] is null.
  final DateTime? initialValue;

  final ValueChanged<DateTime?>? onChanged;
  final ValidityChanged? onValidity;

  /// Canonical source for label, helper, hint, and adornment chrome.
  ///
  /// When `hintText` is null, the active date-format template is used. A
  /// calendar glyph is the leading fallback; provide `prefixIcon` to replace it
  /// or `prefixIcon: SizedBox.shrink()` to suppress it.
  final InputDecoration decoration;

  // ── chrome ──
  final bool required;

  /// Which segments to show, in order (full date, year-month, year, …).
  final SuperDateFormat format;

  final FieldDensity density;
  final bool disabled;
  final bool readOnly;

  // ── date constraints ──
  final DateTime? minDate;
  final DateTime? maxDate;

  /// Show the trailing calendar trigger and responsive picker. Only applies
  /// when the format includes a day segment.
  final bool calendar;

  /// Show a × clear button while non-empty, enabled & editable.
  final bool clearable;

  /// Enable arrow-key segment stepping while focused: ↑/↓ step the segment the
  /// cursor is on; ←/→ move between segments.
  final bool keyboardShortcuts;

  /// Extra custom validators, appended to the built-in chain.
  final List<Validator<DateTime?>> validators;

  /// Error shown when the buffer holds text but no complete value.
  final String invalidMessage;

  /// Force the error to display even before the field is touched.
  final bool forceError;

  final bool arabic;

  // ── Material text-input behaviour ──
  final bool autofocus;
  final TextInputType? keyboardType;

  /// Additional formatters applied after the field's date formatter.
  final List<TextInputFormatter> inputFormatters;

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

  /// Called with the parsed value by an ancestor [Form].
  final FormFieldSetter<DateTime?>? onSaved;

  /// Backward-compatible alias for [onSaved].
  final FormFieldSetter<DateTime?>? onSave;

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
  State<SuperDateFormField> createState() => _SuperDateFormFieldState();
}

class _SuperDateFormFieldState extends State<SuperDateFormField> {
  late SuperDateFieldController _controller;
  bool _ownsController = false;

  final _btnLink = LayerLink();
  final _btnKey = GlobalKey();
  final _overlay = OverlayPortalController();
  bool _above = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        SuperDateFieldController(initialValue: widget.initialValue);
    _ownsController = widget.controller == null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperDateFormField old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      if (_ownsController) _controller.dispose();
      _controller =
          widget.controller ??
          SuperDateFieldController(initialValue: widget.initialValue);
      _ownsController = widget.controller == null;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  bool get _editable => !widget.disabled && !widget.readOnly;
  bool get _showCalendar => widget.calendar && widget.format.hasDay;

  Future<void> _toggleCalendar() async {
    if (!_editable) return;

    // The calendar action must never leave the software keyboard covering the
    // picker. This also commits the current segment through the controller's
    // normal focus lifecycle.
    FocusManager.instance.primaryFocus?.unfocus();

    if (SuperDeviceMode.of(context) == SuperDeviceMode.mobile) {
      if (_overlay.isShowing) _overlay.hide();
      await _showMobileCalendar();
      return;
    }

    if (_overlay.isShowing) {
      _overlay.hide();
      setState(() {});
      return;
    }

    // Desktop/tablet keep the anchored popover, flipping above when needed.
    const estHeight = 330.0;
    final box = _btnKey.currentContext?.findRenderObject() as RenderBox?;
    final screenH = MediaQuery.sizeOf(context).height;
    if (box != null) {
      final top = box.localToGlobal(Offset.zero).dy;
      final below = screenH - (top + box.size.height);
      _above = below < estHeight + 12 && top > below;
    } else {
      _above = false;
    }
    _overlay.show();
    setState(() {});
  }

  Future<void> _showMobileCalendar() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return MobileCalendarBottomSheet(
          value: _controller.value,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
          onPick: (date) {
            _controller.pick(date);
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
  }

  void _onPick(DateTime d) {
    _controller.pick(d);
    _overlay.hide();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SuperFormTranslation.of(context);
    final isMobile = SuperDeviceMode.of(context).isMobile;

    return FormField<DateTime?>(
      key: ObjectKey(_controller),
      initialValue: _controller.value,
      enabled: !widget.disabled,
      onSaved: widget.onSaved ?? widget.onSave,
      autovalidateMode: widget.autovalidateMode,
      validator: (_) => _controller.error,
      builder: (formState) {
        _controller.configure(
          validators: DateLogic.buildValidators(
            required: widget.required,
            minDate: widget.minDate,
            maxDate: widget.maxDate,
            extra: widget.validators,
            requiredMessage: l10n.requiredMessage,
            minDateMessage: l10n.minDate,
            maxDateMessage: l10n.maxDate,
          ),
          forceError: widget.forceError || formState.hasError,
          segments: widget.format.segments,
          malformedMessage: widget.invalidMessage == 'Enter a valid date'
              ? l10n.validDate
              : widget.invalidMessage,
          keyboardEnabled: widget.keyboardShortcuts,
          readOnly: widget.readOnly,
          interactionMode: isMobile
              ? DateInputInteractionMode.mobile
              : DateInputInteractionMode.desktop,
          onValidity: widget.onValidity,
          onChanged: (value) {
            formState.didChange(value);
            widget.onChanged?.call(value);
          },
        );

        final rtl = context.isRtl;

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

            final adornStyle = t.textTheme.mono.copyWith(
              color: t.fg3,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            );
            final trailing = <Widget>[
              ...SffDecoration.buildTrailing(
                context,
                widget.decoration,
                textStyle: adornStyle,
              ),
              if (widget.clearable &&
                  _controller.text.text.isNotEmpty &&
                  _editable)
                FieldIconButton(
                  icon: SffIcons.clear,
                  tooltip: l10n.clear,
                  onPressed: _controller.clear,
                ),
              if (_showCalendar)
                CompositedTransformTarget(
                  link: _btnLink,
                  child: FieldIconButton(
                    key: _btnKey,
                    icon: SffIcons.calendarDays,
                    tooltip: l10n.openCalendar,
                    bordered: false,
                    size: SuperThemeData.of(context).sizing.iconButton,
                    borderRadius: BorderRadius.circular(0),
                    iconSize: 15,
                    onPressed: _editable ? () => _toggleCalendar() : null,
                  ),
                ),
            ];

            return OverlayPortal(
              controller: _overlay,
              overlayChildBuilder: (context) {
                final alignEnd = !rtl;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          _overlay.hide();
                          setState(() {});
                        },
                      ),
                    ),
                    CompositedTransformFollower(
                      link: _btnLink,
                      showWhenUnlinked: false,
                      targetAnchor: _above
                          ? (alignEnd ? Alignment.topRight : Alignment.topLeft)
                          : (alignEnd
                                ? Alignment.bottomRight
                                : Alignment.bottomLeft),
                      followerAnchor: _above
                          ? (alignEnd
                                ? Alignment.bottomRight
                                : Alignment.bottomLeft)
                          : (alignEnd
                                ? Alignment.topRight
                                : Alignment.topLeft),
                      offset: Offset(0, _above ? -6 : 6),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: MiniCalendar(
                          value: _controller.value,
                          minDate: widget.minDate,
                          maxDate: widget.maxDate,
                          onPick: _onPick,
                        ),
                      ),
                    ),
                  ],
                );
              },
              child: FieldShell(
                decoration: widget.decoration,
                required: widget.required,
                hasError: error != null,
                arabic: widget.arabic,
                child: FieldBox(
                  focused: _controller.focused || _overlay.isShowing,
                  error: error,
                  disabled: widget.disabled,
                  density: widget.density,
                  flushTrailing: _showCalendar && error == null,
                  leading: SffDecoration.buildLeading(
                    context,
                    widget.decoration,
                    fallback: const Icon(SffIcons.calendar),
                    textStyle: adornStyle,
                  ),
                  trailing: trailing,
                  child: Directionality(
                    textDirection: widget.textDirection ?? TextDirection.ltr,
                    child: TextField(
                      controller: _controller.text,
                      focusNode: _controller.focusNode,
                      enabled: !widget.disabled,
                      readOnly: widget.readOnly,
                      autofocus: widget.autofocus,
                      keyboardType:
                          widget.keyboardType ??
                          (isMobile
                              ? TextInputType.number
                              : TextInputType.datetime),
                      inputFormatters: [
                        ...widget.inputFormatters,
                        if (isMobile)
                          MobileDateInputFormatter(_controller)
                        else
                          LengthLimitingTextInputFormatter(10),
                      ],
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
                        t.textTheme.mono.copyWith(color: t.fg1),
                        widget.style,
                      ),
                      strutStyle: widget.strutStyle,
                      decoration: InputDecoration(
                        hint: widget.decoration.hint,
                        hintText:
                            widget.decoration.hintText ??
                            widget.format.placeholder,
                        hintStyle: SffDecoration.mergeStyle(
                          t.textTheme.mono.copyWith(color: t.fg4),
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
            );
          },
        );
      },
    );
  }
}
