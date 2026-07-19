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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';
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
  });

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
    final isMobile = SuperDeviceMode.of(context).isMobile;
    _controller.configure(
      validators: DateLogic.buildValidators(
        required: widget.required,
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        extra: widget.validators,
      ),
      forceError: widget.forceError,
      segments: widget.format.segments,
      malformedMessage: widget.invalidMessage,
      keyboardEnabled: widget.keyboardShortcuts,
      readOnly: widget.readOnly,
      interactionMode: isMobile
          ? DateInputInteractionMode.mobile
          : DateInputInteractionMode.desktop,
      onValidity: widget.onValidity,
      onChanged: widget.onChanged,
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

        final adornStyle = SuperText.mono.copyWith(
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
          if (widget.clearable && _controller.text.text.isNotEmpty && _editable)
            FieldIconButton(
              icon: SffIcons.clear,
              tooltip: 'Clear',
              onPressed: _controller.clear,
            ),
          if (_showCalendar)
            CompositedTransformTarget(
              link: _btnLink,
              child: FieldIconButton(
                key: _btnKey,
                icon: SffIcons.calendarDays,
                tooltip: 'Open calendar',
                bordered: true,
                size: SuperThemeData.of(context).tokens.trailingIcon,
                iconSize: 15,
                onPressed: _editable ? () => _toggleCalendar() : null,
              ),
            ),
        ];

        return OverlayPortal(
          controller: _overlay,
          overlayChildBuilder: (context) {
            final alignEnd =
                !rtl; // LTR: icon at end (right) → align right edges
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
                      : (alignEnd ? Alignment.topRight : Alignment.topLeft),
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
              leading: SffDecoration.buildLeading(
                context,
                widget.decoration,
                fallback: const Icon(SffIcons.calendar),
                textStyle: adornStyle,
              ),
              trailing: trailing,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: _controller.text,
                  focusNode: _controller.focusNode,
                  enabled: !widget.disabled,
                  readOnly: widget.readOnly,
                  textAlign: TextAlign.left,
                  keyboardType: isMobile
                      ? TextInputType.number
                      : TextInputType.datetime,
                  inputFormatters: isMobile
                      ? [MobileDateInputFormatter(_controller)]
                      : [LengthLimitingTextInputFormatter(10)],
                  autocorrect: false,
                  enableSuggestions: false,
                  smartDashesType: SmartDashesType.disabled,
                  smartQuotesType: SmartQuotesType.disabled,
                  cursorColor: cs.primary,
                  style: SuperText.mono.copyWith(color: t.fg1),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hint: widget.decoration.hint,
                    hintText:
                        widget.decoration.hintText ?? widget.format.placeholder,
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
        );
      },
    );
  }
}
