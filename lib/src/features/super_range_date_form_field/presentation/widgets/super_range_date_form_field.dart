import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';

import '../../../../core/core.dart';
import '../../../../core/foundation/field_decoration.dart';

import '../../../../../localization/super_form_localizations.dart';

import '../../../super_date_form_field/super_date_form_field.dart';

import '../../domain/entities/super_date_range.dart';

import '../../domain/entities/super_date_range_suggestion.dart';

import '../../domain/usecases/range_date_logic.dart';

import '../controllers/super_range_date_field_controller.dart';

import 'super_range_date_picker.dart';

// SUPER_RANGE_DATE_PICKER_FIRST_DAY_OF_WEEK_V1

/// A validated start/end date range composed from two editable date inputs.

///

/// Both boundaries reuse [SuperDateFormField], so keyboard parsing, segmented

/// editing, formatting, min/max validation, focus behavior, and malformed-date

/// handling stay identical to the package's single-date field. The range picker

/// is deliberately disconnected from text-field taps/focus and opens only from

/// the explicit calendar action rendered with the end-date input.

class SuperRangeDateFormField extends StatefulWidget {
  SuperRangeDateFormField({
    super.key,

    this.controller,

    this.initialValue,

    this.onChanged,

    this.onValidity,

    this.decoration = const InputDecoration(),

    this.startDecoration = const InputDecoration(labelText: 'Start date'),

    this.endDecoration = const InputDecoration(labelText: 'End date'),

    this.required = false,

    this.density = FieldDensity.comfortable,

    this.disabled = false,

    this.readOnly = false,

    this.isStartFixed = false,

    this.isEndFixed = false,

    this.minDate,

    this.maxDate,

    this.firstDayOfWeek = DateTime.sunday,

    this.suggestions,

    this.clearable = false,

    this.keyboardShortcuts = true,

    this.validators = const [],

    this.invalidMessage = 'Enter a valid date',

    this.incompleteMessage = 'Select both a start date and an end date',

    this.orderMessage = 'Start date must not be after end date',

    this.forceError = false,

    this.validationPosition,

    this.helpIcon,

    this.arabic = false,

    this.separator = ' → ',

    this.onSaved,

    this.onSave,

    this.autovalidateMode = AutovalidateMode.disabled,
  }) : assert(
         onSaved == null || onSave == null,

         'Provide either onSaved or onSave, not both.',
       ),

       assert(
         minDate == null || maxDate == null || !minDate.isAfter(maxDate),

         'minDate must not be after maxDate.',
       ),

       assert(
         firstDayOfWeek >= DateTime.monday && firstDayOfWeek <= DateTime.sunday,

         'firstDayOfWeek must use DateTime.monday through DateTime.sunday.',
       );

  final SuperRangeDateFieldController? controller;

  final SuperDateRange? initialValue;

  final ValueChanged<SuperDateRange?>? onChanged;

  final FormValidityChanged? onValidity;

  /// Group label/helper/counter metadata for the complete range control.

  final InputDecoration decoration;

  /// Decoration for the independent editable start-date field.

  final InputDecoration startDecoration;

  /// Decoration for the independent editable end-date field.

  ///

  /// The range calendar action is appended to this field's suffix area.

  final InputDecoration endDecoration;

  final bool required;

  final FieldDensity density;

  final bool disabled;

  final bool readOnly;

  /// Prevents keyboard edits, picker changes, suggestions, clear actions, and

  /// controller mutations from changing the start boundary.

  final bool isStartFixed;

  /// Prevents keyboard edits, picker changes, suggestions, clear actions, and

  /// controller mutations from changing the end boundary.

  final bool isEndFixed;

  final DateTime? minDate;

  final DateTime? maxDate;

  /// First weekday displayed by the range picker calendars.

  ///

  /// Use [DateTime.monday] ... [DateTime.sunday]. This only changes

  /// calendar layout; typed date parsing/formatting is unaffected.

  final int firstDayOfWeek;

  /// Presets shown in the picker.

  ///

  /// `null` uses [SuperDateRangeSuggestion.defaults]. An empty list removes

  /// all defaults. To keep defaults and add custom entries, pass

  /// `[...SuperDateRangeSuggestion.defaults, customSuggestion]`.

  final List<SuperDateRangeSuggestion>? suggestions;

  /// Shows one range-level clear action beside the calendar trigger.

  /// Fixed boundaries are preserved when clearing.

  final bool clearable;

  /// Enables the same arrow-key segment navigation as [SuperDateFormField].

  final bool keyboardShortcuts;

  final List<Validator<SuperDateRange?>> validators;

  final String invalidMessage;

  final String incompleteMessage;

  final String orderMessage;

  final bool forceError;

  /// Controls where validation feedback is rendered.
  ///
  /// When null, the field uses [ValidationPosition.underBox] on mobile and
  /// [ValidationPosition.labelTrailing] on tablet/desktop.
  final ValidationPosition? validationPosition;

  /// Optional widget displayed at the end of the label row.
  final Widget? helpIcon;

  final bool arabic;

  /// Retained for compatibility with the old combined-text representation and

  /// the controller's read-only [SuperRangeDateFieldController.text] mirror.

  /// It does not join the two visible input fields.

  final String separator;

  final FormFieldSetter<SuperDateRange?>? onSaved;

  final FormFieldSetter<SuperDateRange?>? onSave;

  final AutovalidateMode autovalidateMode;

  @override
  State<SuperRangeDateFormField> createState() =>
      _SuperRangeDateFormFieldState();
}

class _SuperRangeDateFormFieldState extends State<SuperRangeDateFormField> {
  late SuperRangeDateFieldController _controller;

  bool _ownsController = false;

  bool _pickerOpen = false;

  // SUPER_RANGE_DATE_FORM_FIELD_COMPACT_OVERLAY_V4

  // RANGE_DATE_PICKER_ANCHORED_OVERLAY_V2

  // Keep the same presentation contract as SuperDateFormField: mobile opens

  // a bottom sheet, while tablet/desktop use an OverlayPortal anchored to the

  // explicit calendar button. The text fields themselves never own this link.

  final _pickerLink = LayerLink();

  final _pickerButtonKey = GlobalKey();

  final _pickerOverlay = OverlayPortalController();

  bool _pickerAbove = false;

  double _pickerHorizontalOffset = 0;

  List<SuperDateRangeSuggestion> get _suggestions =>
      widget.suggestions ?? SuperDateRangeSuggestion.defaults;

  bool get _canOpen => !widget.disabled && !widget.readOnly;

  bool get _canClear =>
      !widget.disabled &&
      !widget.readOnly &&
      !_controller.isFullyFixed &&
      (_controller.startDate != null || _controller.endDate != null);

  @override
  void initState() {
    super.initState();

    _controller =
        widget.controller ??
        SuperRangeDateFieldController(
          initialValue: widget.initialValue,

          isStartFixed: widget.isStartFixed,

          isEndFixed: widget.isEndFixed,
        );

    _ownsController = widget.controller == null;

    _syncFixedConfiguration();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.reportInitialValidity();
    });
  }

  @override
  void didUpdateWidget(SuperRangeDateFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (_ownsController) _controller.dispose();

      _controller =
          widget.controller ??
          SuperRangeDateFieldController(
            initialValue: widget.initialValue,

            isStartFixed: widget.isStartFixed,

            isEndFixed: widget.isEndFixed,
          );

      _ownsController = widget.controller == null;
    }

    if (widget.isStartFixed != oldWidget.isStartFixed ||
        widget.isEndFixed != oldWidget.isEndFixed ||
        widget.controller != oldWidget.controller) {
      _syncFixedConfiguration();
    }
  }

  void _syncFixedConfiguration() {
    _controller.isStartFixed = widget.isStartFixed;

    _controller.isEndFixed = widget.isEndFixed;
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();

    super.dispose();
  }

  Future<void> _openPicker() async {
    if (!_canOpen) return;

    // Exactly like SuperDateFormField, the calendar action commits/unfocuses

    // current keyboard editing before presenting the picker. Text-field taps

    // and focus never call this method.

    FocusManager.instance.primaryFocus?.unfocus();

    if (SuperDeviceMode.of(context).isMobile) {
      if (_pickerOverlay.isShowing) _dismissDesktopPicker();

      if (_pickerOpen) return;

      setState(() => _pickerOpen = true);

      final picked = await _showMobilePicker();

      if (!mounted) return;

      if (picked != null) _controller.pickRange(picked);

      setState(() => _pickerOpen = false);

      return;
    }

    if (_pickerOverlay.isShowing) {
      _dismissDesktopPicker();

      return;
    }

    _placeDesktopPicker();

    _pickerOverlay.show();

    setState(() => _pickerOpen = true);
  }

  Future<SuperDateRange?> _showMobilePicker() {
    return showModalBottomSheet<SuperDateRange>(
      context: context,

      useSafeArea: true,

      isScrollControlled: true,

      backgroundColor: Colors.transparent,

      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.94,

        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),

          child: SuperRangeDatePicker(
            startDate: _controller.startDate,

            endDate: _controller.endDate,

            isStartFixed: _controller.isStartFixed,

            isEndFixed: _controller.isEndFixed,

            minDate: widget.minDate,

            maxDate: widget.maxDate,

            firstDayOfWeek: widget.firstDayOfWeek,

            suggestions: _suggestions,

            onCancel: () => Navigator.of(sheetContext).pop(),

            onApply: (range) => Navigator.of(sheetContext).pop(range),
          ),
        ),
      ),
    );
  }

  void _placeDesktopPicker() {
    // Range picker is larger than MiniCalendar, but placement follows the same

    // above/below rule used by SuperDateFormField.

    const estimatedHeight = 420.0;

    final box =
        _pickerButtonKey.currentContext?.findRenderObject() as RenderBox?;

    final screenHeight = MediaQuery.sizeOf(context).height;

    if (box == null) {
      _pickerAbove = false;

      return;
    }

    final origin = box.localToGlobal(Offset.zero);

    final top = origin.dy;

    final below = screenHeight - (top + box.size.height);

    _pickerAbove = below < estimatedHeight + 12 && top > below;

    // MiniCalendar can simply align to the button edge because it is narrow.

    // The range picker is much wider, so keep the same anchor semantics but

    // clamp the resulting panel inside the viewport.

    final screenWidth = MediaQuery.sizeOf(context).width;

    final panelWidth = screenWidth > 784 ? 760.0 : screenWidth - 24.0;

    final rtl = context.isRtl;

    final desiredLeft = rtl
        ? origin.dx
        : origin.dx + box.size.width - panelWidth;

    final maxLeft = screenWidth - 12.0 - panelWidth;

    final clampedLeft = desiredLeft.clamp(12.0, maxLeft).toDouble();

    _pickerHorizontalOffset = clampedLeft - desiredLeft;
  }

  void _dismissDesktopPicker() {
    if (_pickerOverlay.isShowing) _pickerOverlay.hide();

    if (_pickerOpen && mounted) setState(() => _pickerOpen = false);
  }

  void _applyDesktopRange(SuperDateRange range) {
    _controller.pickRange(range);

    _dismissDesktopPicker();
  }

  Widget _desktopPickerOverlayHost({required Widget child}) {
    return OverlayPortal(
      controller: _pickerOverlay,

      overlayChildBuilder: (overlayContext) {
        final rtl = context.isRtl;

        final alignEnd = !rtl;

        final screen = MediaQuery.sizeOf(overlayContext);

        final panelWidth = screen.width > 784 ? 760.0 : screen.width - 24.0;

        final panelMaxHeight = screen.height > 544
            ? 520.0
            : screen.height - 24.0;

        final spacing = SuperThemeData.of(overlayContext).spacing;

        final theme = overlayContext.sffTheme;

        final radius = BorderRadius.circular(spacing.radiusCard);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,

                onTap: _dismissDesktopPicker,
              ),
            ),

            CompositedTransformFollower(
              link: _pickerLink,

              showWhenUnlinked: false,

              targetAnchor: _pickerAbove
                  ? (alignEnd ? Alignment.topRight : Alignment.topLeft)
                  : (alignEnd ? Alignment.bottomRight : Alignment.bottomLeft),

              followerAnchor: _pickerAbove
                  ? (alignEnd ? Alignment.bottomRight : Alignment.bottomLeft)
                  : (alignEnd ? Alignment.topRight : Alignment.topLeft),

              offset: Offset(_pickerHorizontalOffset, _pickerAbove ? -6 : 6),

              child: Directionality(
                textDirection: Directionality.of(context),

                child: SizedBox(
                  width: panelWidth,

                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: panelMaxHeight),

                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.surface,

                        borderRadius: radius,

                        border: Border.all(color: theme.borderStrong),

                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),

                            blurRadius: 28,

                            spreadRadius: -7,

                            offset: Offset(0, 12),
                          ),
                        ],
                      ),

                      child: ClipRRect(
                        borderRadius: radius,

                        child: SuperRangeDatePicker(
                          startDate: _controller.startDate,

                          endDate: _controller.endDate,

                          isStartFixed: _controller.isStartFixed,

                          isEndFixed: _controller.isEndFixed,

                          minDate: widget.minDate,

                          maxDate: widget.maxDate,

                          firstDayOfWeek: widget.firstDayOfWeek,

                          suggestions: _suggestions,

                          onCancel: _dismissDesktopPicker,

                          onApply: _applyDesktopRange,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },

      child: child,
    );
  }

  InputDecoration _withoutFallbackCalendar(InputDecoration source) {
    final hasLeading =
        source.icon != null ||
        source.prefixIcon != null ||
        source.prefix != null ||
        source.prefixText != null;

    if (hasLeading) return source;

    return source.copyWith(prefixIcon: const SizedBox.shrink());
  }

  Widget _rangeActions(SuperFormTranslation l10n, Widget? callerSuffix) {
    return Row(
      mainAxisSize: MainAxisSize.min,

      children: [
        if (callerSuffix != null) callerSuffix,

        if (widget.clearable && _canClear)
          FieldIconButton(
            icon: SffIcons.clear,

            tooltip: l10n.clear,

            onPressed: _controller.clear,
          ),

        _desktopPickerOverlayHost(
          child: CompositedTransformTarget(
            link: _pickerLink,

            child: FieldIconButton(
              key: _pickerButtonKey,

              icon: SffIcons.calendarDays,

              tooltip: l10n.openCalendar,

              bordered: false,

              size: SuperThemeData.of(context).sizing.iconButton,

              borderRadius: BorderRadius.circular(0),

              iconSize: 15,

              onPressed: _canOpen ? _openPicker : null,
            ),
          ),
        ),
      ],
    );
  }

  // SUPER_RANGE_DATE_BOUNDARY_FIELDS_RESPONSIVE_V3_FIXED
  Widget _buildBoundaryFields({
    required SuperFormTranslation l10n,
    required String? rangeError,
    required ValidationPosition validationPosition,
  }) {
    final startDecoration = _withoutFallbackCalendar(widget.startDecoration);

    final endOwnError = _controller.endController.visibleError;
    final inheritedError = validationPosition == ValidationPosition.suffixIcon
        ? (widget.decoration.errorText ??
              (endOwnError == null ? rangeError : null))
        : null;
    final baseEndDecoration = _withoutFallbackCalendar(widget.endDecoration);
    final endDecoration = baseEndDecoration.copyWith(
      errorText: widget.endDecoration.errorText ?? inheritedError,
      suffixIcon: _rangeActions(l10n, widget.endDecoration.suffixIcon),
    );

    final startField = SuperDateFormField(
      controller: _controller.startController,
      decoration: startDecoration,
      density: widget.density,
      disabled: widget.disabled,
      readOnly: widget.readOnly || widget.isStartFixed,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      calendar: false,
      clearable: false,
      keyboardShortcuts: widget.keyboardShortcuts,
      invalidMessage: widget.invalidMessage,
      forceError: widget.forceError,
      validationPosition: validationPosition,
      arabic: widget.arabic,
      autovalidateMode: widget.autovalidateMode,
    );

    final endField = SuperDateFormField(
      controller: _controller.endController,
      decoration: endDecoration,
      density: widget.density,
      disabled: widget.disabled,
      readOnly: widget.readOnly || widget.isEndFixed,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      calendar: false,
      clearable: false,
      keyboardShortcuts: widget.keyboardShortcuts,
      invalidMessage: widget.invalidMessage,
      forceError: widget.forceError,
      validationPosition: validationPosition,
      arabic: widget.arabic,
      autovalidateMode: widget.autovalidateMode,
    );

    final gap = SuperThemeData.of(context).spacing.space3;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Base the layout on the space actually given to this field. This
        // behaves correctly in desktop sidebars, dialogs, filters and mobile.
        const minUsableFieldWidth = 240.0;
        final requiredInlineWidth = (minUsableFieldWidth * 2) + gap;
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : requiredInlineWidth;
        final useSingleRow = availableWidth >= requiredInlineWidth;

        if (!useSingleRow) {
          return Column(
            key: const ValueKey('super-range-date-fields-two-rows'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              startField,
              SizedBox(height: gap),
              endField,
            ],
          );
        }

        return Row(
          key: const ValueKey('super-range-date-fields-one-row'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: startField),
            SizedBox(width: gap),
            Expanded(child: endField),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isHiden) return const SizedBox.shrink();

    final l10n = SuperFormTranslation.of(context);

    return FormField<SuperDateRange?>(
      key: _controller.formFieldKey ?? ObjectKey(_controller),

      initialValue: _controller.value,

      enabled: !widget.disabled,

      onSaved: widget.onSaved ?? widget.onSave,

      autovalidateMode: widget.autovalidateMode,

      validator: (_) => _controller.error,

      builder: (formState) {
        _controller.configure(
          validators: RangeDateLogic.buildValidators(
            required: widget.required,

            minDate: widget.minDate,

            maxDate: widget.maxDate,

            extra: widget.validators,

            requiredMessage: l10n.requiredMessage,

            orderMessage: widget.orderMessage,

            minDateMessage: l10n.minDate,

            maxDateMessage: l10n.maxDate,
          ),

          forceError: widget.forceError || formState.hasError,

          minDate: widget.minDate,

          maxDate: widget.maxDate,

          incompleteMessage: widget.incompleteMessage,

          invalidMessage: widget.invalidMessage == 'Enter a valid date'
              ? l10n.validDate
              : widget.invalidMessage,

          separator: widget.separator,

          onValidity: widget.onValidity,

          onChanged: (value) {
            formState.didChange(value);

            widget.onChanged?.call(value);
          },
        );

        return ListenableBuilder(
          listenable: _controller,

          builder: (context, _) {
            final rangeError = widget.disabled
                ? null
                : _controller.visibleError;

            final effectiveRangeError = widget.disabled
                ? null
                : SffDecoration.resolveError(widget.decoration, rangeError);

            final validationPosition =
                SffDecoration.effectiveValidationPosition(
                  context,
                  widget.validationPosition,
                );

            final labelRight = SffDecoration.buildLabelRight(
              context,
              widget.decoration,
              arabic: widget.arabic,
              error: effectiveRangeError,
              validationPosition: validationPosition,
              helpIcon: widget.helpIcon,
            );

            final underBoxError =
                validationPosition == ValidationPosition.underBox
                ? effectiveRangeError
                : null;

            final hasError =
                effectiveRangeError != null ||
                rangeError != null ||
                _controller.startController.visibleError != null ||
                _controller.endController.visibleError != null;

            return FormFieldShell(
              decoration: widget.decoration,

              required: widget.required,

              hasError: hasError,

              errorText: underBoxError,

              arabic: widget.arabic,

              labelRight: labelRight,

              child: _buildBoundaryFields(
                l10n: l10n,
                rangeError: rangeError,
                validationPosition: validationPosition,
              ),
            );
          },
        );
      },
    );
  }
}
