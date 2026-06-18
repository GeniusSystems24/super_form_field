// ============================================================
// features/super_date_form_field/presentation/widgets/super_date_form_field.dart
// ------------------------------------------------------------
// The View for the GeniusLink date field — the same input chrome the web uses:
// a masked, mono `YYYY-MM-DD` text input with a trailing calendar trigger that
// opens a MiniCalendar popover. A thin Flutter wrapper that builds the validator
// chain (domain usecase), drives a [SuperDateFieldController] (the Model), and
// renders the FieldShell + FieldBox chrome. The date stays Western-digit mono
// and LTR even in RTL. Validation surfaces only through the suffix ErrorBadge.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../domain/usecases/date_logic.dart';
import '../controllers/super_date_field_controller.dart';
import 'mini_calendar.dart';

/// A themeable, validated date field on the GeniusLink field foundation. Edit by
/// typing a masked `YYYY-MM-DD` value or by picking from the calendar popover.
class SuperDateFormField extends StatefulWidget {
  const SuperDateFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onValidity,
    this.label,
    this.required = false,
    this.placeholder = 'YYYY-MM-DD',
    this.hint,
    this.density = FieldDensity.comfortable,
    this.disabled = false,
    this.readOnly = false,
    this.minDate,
    this.maxDate,
    this.calendar = true,
    this.clearable = false,
    this.keyboardShortcuts = true,
    this.leadingIcon = SffIcons.calendar,
    this.validators = const [],
    this.invalidMessage = 'Enter a valid date (YYYY-MM-DD)',
    this.forceError = false,
    this.arabic = false,
  });

  /// External controller — when null, the field manages its own.
  final SuperDateFieldController? controller;

  /// Seed value, used only when [controller] is null.
  final DateTime? initialValue;

  final ValueChanged<DateTime?>? onChanged;
  final ValidityChanged? onValidity;

  // ── chrome ──
  final String? label;
  final bool required;
  final String? placeholder;
  final String? hint;
  final FieldDensity density;
  final bool disabled;
  final bool readOnly;

  // ── date constraints ──
  final DateTime? minDate;
  final DateTime? maxDate;

  /// Show the trailing calendar trigger + popover (off → typed entry only).
  final bool calendar;

  /// Show a × clear button while non-empty, enabled & editable.
  final bool clearable;

  /// Enable arrow-key segment stepping while focused: ↑/↓ increment or decrement
  /// the year, month, or day the cursor is currently on.
  final bool keyboardShortcuts;

  /// Leading icon. Defaults to the calendar glyph; pass `null` to hide.
  final IconData? leadingIcon;

  /// Extra custom validators, appended to the built-in chain.
  final List<Validator<DateTime?>> validators;

  /// Error shown when the typed text is non-empty but not a complete date.
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

  final _link = LayerLink();
  final _overlay = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SuperDateFieldController(initialValue: widget.initialValue);
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
      _controller = widget.controller ?? SuperDateFieldController(initialValue: widget.initialValue);
      _ownsController = widget.controller == null;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  bool get _editable => !widget.disabled && !widget.readOnly;

  void _toggleCalendar() {
    if (!_editable) return;
    if (_overlay.isShowing) {
      _overlay.hide();
    } else {
      _overlay.show();
    }
    setState(() {});
  }

  void _onPick(DateTime d) {
    _controller.pick(d);
    _overlay.hide();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _controller.configure(
      validators: DateLogic.buildValidators(
        required: widget.required,
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        extra: widget.validators,
      ),
      forceError: widget.forceError,
      malformedMessage: widget.invalidMessage,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      keyboardEnabled: widget.keyboardShortcuts,
      readOnly: widget.readOnly,
      onValidity: widget.onValidity,
      onChanged: widget.onChanged,
    );

    final rtl = context.isRtl;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final t = context.sffTheme;
        final error = widget.disabled ? null : _controller.visibleError;

        final trailing = <Widget>[
          if (widget.clearable && _controller.text.text.isNotEmpty && _editable)
            FieldIconButton(
              icon: SffIcons.clear,
              tooltip: 'Clear',
              onPressed: _controller.clear,
            ),
          if (widget.calendar)
            FieldIconButton(
              icon: SffIcons.calendarDays,
              tooltip: 'Open calendar',
              bordered: true,
              size: SuperTokens.trailingIcon,
              iconSize: 15,
              onPressed: _editable ? _toggleCalendar : null,
            ),
        ];

        return OverlayPortal(
          controller: _overlay,
          overlayChildBuilder: (context) {
            return Stack(
              children: [
                // Dismiss barrier.
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
                  link: _link,
                  showWhenUnlinked: false,
                  targetAnchor: rtl ? Alignment.bottomRight : Alignment.bottomLeft,
                  followerAnchor: rtl ? Alignment.topRight : Alignment.topLeft,
                  offset: const Offset(0, 6),
                  child: Align(
                    alignment: rtl ? Alignment.topRight : Alignment.topLeft,
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
                ),
              ],
            );
          },
          child: CompositedTransformTarget(
            link: _link,
            child: FieldShell(
              label: widget.label,
              required: widget.required,
              hint: widget.hint,
              hasError: error != null,
              arabic: widget.arabic,
              child: FieldBox(
                focused: _controller.focused || _overlay.isShowing,
                error: error,
                disabled: widget.disabled,
                density: widget.density,
                leading: widget.leadingIcon != null ? Icon(widget.leadingIcon) : null,
                trailing: trailing,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    controller: _controller.text,
                    focusNode: _controller.focusNode,
                    enabled: !widget.disabled,
                    readOnly: widget.readOnly,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.datetime,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                    cursorColor: SuperTokens.accent,
                    style: SuperText.mono.copyWith(color: t.fg1),
                    decoration: InputDecoration.collapsed(
                      hintText: widget.placeholder,
                      hintStyle: SuperText.mono.copyWith(color: t.fg4),
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
