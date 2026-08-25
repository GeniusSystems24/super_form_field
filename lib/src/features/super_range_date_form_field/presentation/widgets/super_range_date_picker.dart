import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';

import '../../../../core/core.dart';
import '../../../../../localization/super_form_localizations.dart';
import '../../domain/entities/super_date_range.dart';
import '../../domain/entities/super_date_range_suggestion.dart';
import '../../domain/usecases/range_date_logic.dart';

enum _RangeBoundary { start, end }

enum _PickerLayout { compact, medium, wide }

// SUPER_RANGE_DATE_PICKER_COMPACT_DESKTOP_LAYOUT_V4

// SUPER_RANGE_DATE_PICKER_FIRST_DAY_OF_WEEK_V1
/// Responsive date-range selection surface used by [SuperRangeDateFormField].
///
/// The visual language intentionally follows the proven interaction patterns of
/// enterprise range pickers: a clean month header, compact weekday row,
/// continuous range band with circular endpoints, multi-month desktop/tablet
/// view, a single-month mobile view, presets, and explicit action buttons.
/// Selection rules remain owned by [RangeDateLogic].
class SuperRangeDatePicker extends StatefulWidget {
  const SuperRangeDatePicker({
    super.key,
    this.startDate,
    this.endDate,
    this.isStartFixed = false,
    this.isEndFixed = false,
    this.minDate,
    this.maxDate,
    this.firstDayOfWeek = DateTime.sunday,
    this.suggestions = const [],
    this.onCancel,
    required this.onApply,
  }) : assert(
         firstDayOfWeek >= DateTime.monday && firstDayOfWeek <= DateTime.sunday,
         'firstDayOfWeek must use DateTime.monday through DateTime.sunday.',
       );

  final DateTime? startDate;
  final DateTime? endDate;
  final bool isStartFixed;
  final bool isEndFixed;
  final DateTime? minDate;
  final DateTime? maxDate;

  /// First weekday displayed by every calendar grid.
  ///
  /// Use the standard Dart constants [DateTime.monday] through
  /// [DateTime.sunday]. The default is [DateTime.sunday] to preserve
  /// the range picker's existing layout.
  final int firstDayOfWeek;

  final List<SuperDateRangeSuggestion> suggestions;
  final VoidCallback? onCancel;
  final ValueChanged<SuperDateRange> onApply;

  @override
  State<SuperRangeDatePicker> createState() => _SuperRangeDatePickerState();
}

class _SuperRangeDatePickerState extends State<SuperRangeDatePicker> {
  DateTime? _start;
  DateTime? _end;
  late DateTime _visibleMonth;
  _RangeBoundary? _activeBoundary;

  @override
  void initState() {
    super.initState();
    _start = _normalized(widget.startDate);
    _end = _normalized(widget.endDate);
    _visibleMonth = _initialVisibleMonth();
    _activeBoundary = _initialBoundary();
  }

  DateTime? _normalized(DateTime? value) =>
      value == null ? null : RangeDateLogic.dateOnly(value);

  _RangeBoundary? _initialBoundary() {
    if (widget.isStartFixed && widget.isEndFixed) return null;
    if (widget.isStartFixed) return _RangeBoundary.end;
    return _RangeBoundary.start;
  }

  DateTime _initialVisibleMonth() {
    final seed = _start ?? _end ?? RangeDateLogic.dateOnly(DateTime.now());
    return DateTime(seed.year, seed.month);
  }


  void _pick(DateTime date) {
    final value = RangeDateLogic.dateOnly(date);
    if (!RangeDateLogic.isWithinBounds(
      value,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
    )) {
      return;
    }
    if (widget.isStartFixed && widget.isEndFixed) return;

    setState(() {
      final choosingEnd =
          _activeBoundary == _RangeBoundary.end || widget.isStartFixed;

      if (choosingEnd) {
        if (widget.isEndFixed) return;

        if (_start != null && value.isBefore(_start!)) {
          if (widget.isStartFixed) return;
          _start = value;
          _end = null;
          _activeBoundary = _RangeBoundary.end;
          return;
        }

        _end = value;
        if (!widget.isStartFixed) {
          _activeBoundary = _RangeBoundary.start;
        }
        return;
      }

      if (widget.isStartFixed) return;
      if (_end != null && value.isAfter(_end!)) {
        if (widget.isEndFixed) return;
        _start = value;
        _end = null;
      } else {
        _start = value;
      }
      if (!widget.isEndFixed) {
        _activeBoundary = _RangeBoundary.end;
      }
    });
  }

  SuperDateRange? _resolvedSuggestion(SuperDateRangeSuggestion suggestion) {
    final raw = suggestion.resolve(RangeDateLogic.dateOnly(DateTime.now()));
    return RangeDateLogic.constrainSuggestion(
      suggestion: raw,
      currentStart: _start,
      currentEnd: _end,
      isStartFixed: widget.isStartFixed,
      isEndFixed: widget.isEndFixed,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
    );
  }

  bool _isSuggestionSelected(SuperDateRangeSuggestion suggestion) {
    final resolved = _resolvedSuggestion(suggestion);
    if (resolved == null || _start == null || _end == null) return false;
    return RangeDateLogic.sameDay(resolved.start, _start) &&
        RangeDateLogic.sameDay(resolved.end, _end);
  }

  void _applySuggestion(SuperDateRangeSuggestion suggestion) {
    final resolved = _resolvedSuggestion(suggestion);
    if (resolved == null) return;

    final endMonth = DateTime(resolved.end.year, resolved.end.month);
    final previousEndMonth = _addMonths(endMonth, -1);
    final startMonth = DateTime(resolved.start.year, resolved.start.month);

    final compact = MediaQuery.sizeOf(context).width < 620;

    setState(() {
      _start = resolved.start;
      _end = resolved.end;
      _visibleMonth = compact
          ? endMonth
          : startMonth.isBefore(previousEndMonth)
          ? previousEndMonth
          : startMonth;
      _activeBoundary = widget.isStartFixed
          ? widget.isEndFixed
                ? null
                : _RangeBoundary.end
          : _RangeBoundary.start;
    });
  }

  void _reset() {
    setState(() {
      _start = _normalized(widget.startDate);
      _end = _normalized(widget.endDate);
      _visibleMonth = _initialVisibleMonth();
      _activeBoundary = _initialBoundary();
    });
  }

  bool get _canApply {
    final start = _start;
    final end = _end;
    if (start == null || end == null || start.isAfter(end)) return false;
    return RangeDateLogic.isWithinBounds(
          start,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
        ) &&
        RangeDateLogic.isWithinBounds(
          end,
          minDate: widget.minDate,
          maxDate: widget.maxDate,
        );
  }

  void _apply() {
    if (!_canApply) return;
    widget.onApply(SuperDateRange(start: _start!, end: _end!));
  }

  bool _canShowMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final min = _normalized(widget.minDate);
    final max = _normalized(widget.maxDate);
    if (min != null && last.isBefore(min)) return false;
    if (max != null && first.isAfter(max)) return false;
    return true;
  }

  void _moveMonths(int delta) {
    final candidate = _addMonths(_visibleMonth, delta);
    if (!_canShowMonth(candidate)) return;
    setState(() => _visibleMonth = candidate);
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 180) return;
    final forward = context.isRtl ? velocity > 0 : velocity < 0;
    _moveMonths(forward ? 1 : -1);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;
    final t = context.sffTheme;

    return Material(
      key: const ValueKey('super-range-date-picker'),
      color: t.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final layout = width >= 740
              ? _PickerLayout.wide
              : width >= 620
              ? _PickerLayout.medium
              : _PickerLayout.compact;

          return SingleChildScrollView(
            padding: EdgeInsets.all(
              layout == _PickerLayout.compact ? spacing.space3 : spacing.space4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _mainBody(context, layout),
                SizedBox(height: spacing.space4),
                Divider(height: 1, color: t.border),
                SizedBox(height: spacing.space3),
                _footer(context, layout),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _mainBody(BuildContext context, _PickerLayout layout) {
    final spacing = SuperThemeData.of(context).spacing;

    if (layout == _PickerLayout.wide) {
      return KeyedSubtree(
        key: const ValueKey('super-range-date-picker-wide'),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.suggestions.isNotEmpty) ...[
                SizedBox(
                  width: 176,
                  child: _PresetRail(
                    suggestions: widget.suggestions,
                    enabledFor: (item) => _resolvedSuggestion(item) != null,
                    selectedFor: _isSuggestionSelected,
                    onTap: _applySuggestion,
                  ),
                ),
                SizedBox(width: spacing.space3),
                VerticalDivider(width: 1, color: context.sffTheme.border),
                SizedBox(width: spacing.space3),
              ],
              Expanded(
                child: _multiMonthView(
                  context,
                  useMiniCalendarDesktopMetrics: true,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (layout == _PickerLayout.medium) {
      return KeyedSubtree(
        key: const ValueKey('super-range-date-picker-medium'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.suggestions.isNotEmpty) ...[
              _PresetStrip(
                suggestions: widget.suggestions,
                enabledFor: (item) => _resolvedSuggestion(item) != null,
                selectedFor: _isSuggestionSelected,
                onTap: _applySuggestion,
              ),
              SizedBox(height: spacing.space3),
            ],
            _multiMonthView(context, useMiniCalendarDesktopMetrics: false),
          ],
        ),
      );
    }

    return KeyedSubtree(
      key: const ValueKey('super-range-date-picker-compact'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.suggestions.isNotEmpty) ...[
            _PresetStrip(
              suggestions: widget.suggestions,
              enabledFor: (item) => _resolvedSuggestion(item) != null,
              selectedFor: _isSuggestionSelected,
              onTap: _applySuggestion,
            ),
            SizedBox(height: spacing.space3),
          ],
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: _handleHorizontalSwipe,
            child: _RangeMonthCalendar(
              month: _visibleMonth,
              startDate: _start,
              endDate: _end,
              minDate: widget.minDate,
              maxDate: widget.maxDate,
              firstDayOfWeek: widget.firstDayOfWeek,
              suppressDuplicateAdjacentRangeDecoration: false,
              useMiniCalendarDesktopMetrics: false,
              showPrevious: true,
              showNext: true,
              canPrevious: _canShowMonth(_addMonths(_visibleMonth, -1)),
              canNext: _canShowMonth(_addMonths(_visibleMonth, 1)),
              onPrevious: () => _moveMonths(-1),
              onNext: () => _moveMonths(1),
              onPick: _pick,
            ),
          ),
        ],
      ),
    );
  }

  // SUPER_RANGE_DATE_PICKER_MINI_CALENDAR_DESKTOP_METRICS_V2
  Widget _multiMonthView(
    BuildContext context, {
    required bool useMiniCalendarDesktopMetrics,
  }) {
    final spacing = SuperThemeData.of(context).spacing;
    final secondMonth = _addMonths(_visibleMonth, 1);

    Widget monthCalendar({
      required DateTime month,
      required bool showPrevious,
      required bool showNext,
      required bool canPrevious,
      required bool canNext,
      required VoidCallback? onPrevious,
      required VoidCallback? onNext,
    }) {
      return _RangeMonthCalendar(
        month: month,
        startDate: _start,
        endDate: _end,
        minDate: widget.minDate,
        maxDate: widget.maxDate,
        firstDayOfWeek: widget.firstDayOfWeek,
        suppressDuplicateAdjacentRangeDecoration: true,
        useMiniCalendarDesktopMetrics: useMiniCalendarDesktopMetrics,
        showPrevious: showPrevious,
        showNext: showNext,
        canPrevious: canPrevious,
        canNext: canNext,
        onPrevious: onPrevious,
        onNext: onNext,
        onPick: _pick,
      );
    }

    final firstCalendar = monthCalendar(
      month: _visibleMonth,
      showPrevious: true,
      showNext: false,
      canPrevious: _canShowMonth(_addMonths(_visibleMonth, -1)),
      canNext: false,
      onPrevious: () => _moveMonths(-1),
      onNext: null,
    );
    final secondCalendar = monthCalendar(
      month: secondMonth,
      showPrevious: false,
      showNext: true,
      canPrevious: false,
      canNext: _canShowMonth(_addMonths(secondMonth, 1)),
      onPrevious: null,
      onNext: () => _moveMonths(1),
    );

    if (useMiniCalendarDesktopMetrics) {
      // MiniCalendar compact mode is 248px wide and applies spacing.space3
      // around its grid. SuperRangeDatePicker already owns the outer panel
      // padding, so each desktop month uses the same inner content width.
      final miniCalendarContentWidth = 248.0 - (spacing.space3 * 2);
      return KeyedSubtree(
        key: const ValueKey('super-range-date-picker-multi-view'),
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: miniCalendarContentWidth, child: firstCalendar),
                SizedBox(width: spacing.space3),
                VerticalDivider(width: 1, color: context.sffTheme.border),
                SizedBox(width: spacing.space3),
                SizedBox(
                  width: miniCalendarContentWidth,
                  child: secondCalendar,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return KeyedSubtree(
      key: const ValueKey('super-range-date-picker-multi-view'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: firstCalendar),
          SizedBox(width: spacing.space3),
          SizedBox(
            height: 358,
            child: VerticalDivider(width: 1, color: context.sffTheme.border),
          ),
          SizedBox(width: spacing.space3),
          Expanded(child: secondCalendar),
        ],
      ),
    );
  }

  // SUPER_RANGE_DATE_PICKER_RESPONSIVE_FOOTER_V2
  // SUPER_RANGE_DATE_PICKER_ACTIONS_ONLY_FOOTER_V1
  Widget _footer(BuildContext context, _PickerLayout layout) {
    final compact = layout == _PickerLayout.compact;

    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: _PickerActions(
        compact: compact,
        canApply: _canApply,
        onCancel: widget.onCancel,
        onReset: _reset,
        onApply: _apply,
        dense: true,
      ),
    );
  }
}

class _PresetRail extends StatelessWidget {
  const _PresetRail({
    required this.suggestions,
    required this.enabledFor,
    required this.selectedFor,
    required this.onTap,
  });

  final List<SuperDateRangeSuggestion> suggestions;
  final bool Function(SuperDateRangeSuggestion suggestion) enabledFor;
  final bool Function(SuperDateRangeSuggestion suggestion) selectedFor;
  final ValueChanged<SuperDateRangeSuggestion> onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;
    final t = context.sffTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: spacing.space2,
            bottom: spacing.space2,
          ),
          child: Text(
            'Quick ranges',
            style: context.sffTextTheme.label.copyWith(
              color: t.fg4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final suggestion in suggestions)
          _PresetTile(
            suggestion: suggestion,
            enabled: enabledFor(suggestion),
            selected: selectedFor(suggestion),
            onTap: () => onTap(suggestion),
          ),
      ],
    );
  }
}

class _PresetStrip extends StatelessWidget {
  const _PresetStrip({
    required this.suggestions,
    required this.enabledFor,
    required this.selectedFor,
    required this.onTap,
  });

  final List<SuperDateRangeSuggestion> suggestions;
  final bool Function(SuperDateRangeSuggestion suggestion) enabledFor;
  final bool Function(SuperDateRangeSuggestion suggestion) selectedFor;
  final ValueChanged<SuperDateRangeSuggestion> onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < suggestions.length; index++) ...[
            if (index > 0) SizedBox(width: spacing.space2),
            _PresetChip(
              suggestion: suggestions[index],
              enabled: enabledFor(suggestions[index]),
              selected: selectedFor(suggestions[index]),
              onTap: () => onTap(suggestions[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.suggestion,
    required this.enabled,
    required this.selected,
    required this.onTap,
  });

  final SuperDateRangeSuggestion suggestion;
  final bool enabled;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;
    final t = context.sffTheme;
    final cs = context.sffColorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.space1),
      child: Material(
        color: selected
            ? cs.primary.withValues(alpha: 0.11)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(spacing.radiusControl),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(spacing.radiusControl),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.space3,
              vertical: spacing.space2 + 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    suggestion.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.sffTextTheme.body.copyWith(
                      color: enabled
                          ? selected
                                ? cs.primary
                                : t.fg2
                          : t.fg4,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_rounded, size: 17, color: cs.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.suggestion,
    required this.enabled,
    required this.selected,
    required this.onTap,
  });

  final SuperDateRangeSuggestion suggestion;
  final bool enabled;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    return ActionChip(
      onPressed: enabled ? onTap : null,
      avatar: selected
          ? Icon(Icons.check_rounded, size: 16, color: cs.primary)
          : null,
      label: Text(suggestion.label),
      backgroundColor: selected
          ? cs.primary.withValues(alpha: 0.11)
          : t.inputBg,
      side: BorderSide(color: selected ? cs.primary : t.border),
      labelStyle: context.sffTextTheme.label.copyWith(
        color: enabled
            ? selected
                  ? cs.primary
                  : t.fg2
            : t.fg4,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: const StadiumBorder(),
    );
  }
}

class _PickerActions extends StatelessWidget {
  const _PickerActions({
    required this.compact,
    required this.dense,
    required this.canApply,
    required this.onCancel,
    required this.onReset,
    required this.onApply,
  });

  final bool compact;
  final bool dense;
  final bool canApply;
  final VoidCallback? onCancel;
  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;
    final t = context.sffTheme;
    final cs = context.sffColorScheme;

    final height = dense
        ? 32.0
        : compact
        ? 44.0
        : 36.0;
    final horizontalPadding = dense ? 12.0 : 14.0;
    final textStyle = context.sffTextTheme.label.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: dense ? 12.0 : null,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(spacing.radiusControl),
    );

    final cancel = onCancel == null
        ? null
        : OutlinedButton(
            key: const ValueKey('range-date-cancel'),
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(0, height),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              tapTargetSize: dense
                  ? MaterialTapTargetSize.shrinkWrap
                  : MaterialTapTargetSize.padded,
              visualDensity: dense
                  ? VisualDensity.compact
                  : VisualDensity.standard,
              foregroundColor: t.fg2,
              side: BorderSide(color: t.borderStrong),
              textStyle: textStyle,
              shape: shape,
            ),
            child: const Text('Cancel'),
          );

    final reset = TextButton(
      key: const ValueKey('range-date-reset'),
      onPressed: onReset,
      style: TextButton.styleFrom(
        minimumSize: Size(0, height),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        tapTargetSize: dense
            ? MaterialTapTargetSize.shrinkWrap
            : MaterialTapTargetSize.padded,
        visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
        foregroundColor: cs.primary,
        textStyle: textStyle,
        shape: shape,
      ),
      child: const Text('Reset'),
    );

    final apply = FilledButton(
      key: const ValueKey('range-date-apply'),
      onPressed: canApply ? onApply : null,
      style: FilledButton.styleFrom(
        minimumSize: Size(0, height),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding + 2),
        tapTargetSize: dense
            ? MaterialTapTargetSize.shrinkWrap
            : MaterialTapTargetSize.padded,
        visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        disabledBackgroundColor: t.inputBg,
        disabledForegroundColor: t.fg4,
        textStyle: textStyle,
        shape: shape,
      ),
      child: const Text('Apply'),
    );

    if (compact) {
      return Row(
        children: [
          if (cancel != null) ...[
            Expanded(child: cancel),
            SizedBox(width: spacing.space2),
          ],
          Expanded(child: reset),
          SizedBox(width: spacing.space2),
          Expanded(child: apply),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (cancel != null) ...[
          cancel,
          SizedBox(width: dense ? spacing.space1 : spacing.space2),
        ],
        reset,
        SizedBox(width: dense ? spacing.space1 : spacing.space2),
        apply,
      ],
    );
  }
}

// SUPER_RANGE_DATE_PICKER_NO_DUPLICATE_RANGE_DECORATION_V1
class _RangeMonthCalendar extends StatelessWidget {
  const _RangeMonthCalendar({
    required this.month,
    required this.startDate,
    required this.endDate,
    required this.minDate,
    required this.maxDate,
    required this.firstDayOfWeek,
    required this.suppressDuplicateAdjacentRangeDecoration,
    required this.useMiniCalendarDesktopMetrics,
    required this.showPrevious,
    required this.showNext,
    required this.canPrevious,
    required this.canNext,
    required this.onPrevious,
    required this.onNext,
    required this.onPick,
  });

  final DateTime month;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final int firstDayOfWeek;
  final bool suppressDuplicateAdjacentRangeDecoration;
  final bool useMiniCalendarDesktopMetrics;
  final bool showPrevious;
  final bool showNext;
  final bool canPrevious;
  final bool canNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;
    final t = context.sffTheme;
    final l10n = SuperFormTranslation.of(context);
    final first = DateTime(month.year, month.month, 1);
    final leading = (first.weekday - firstDayOfWeek) % 7;
    final gridStart = first.subtract(Duration(days: leading));
    final weekdayLabels = List<String>.generate(
      7,
      (index) => l10n.narrowWeekdays[(firstDayOfWeek % 7 + index) % 7],
      growable: false,
    );
    final days = List<DateTime>.generate(
      42,
      (index) => RangeDateLogic.dateOnly(gridStart.add(Duration(days: index))),
    );

    // Desktop mirrors MiniCalendar(expanded: false). Tablet/mobile keep the
    // larger range-picker metrics designed for touch/responsive layouts.
    final miniCalendarMetrics = useMiniCalendarDesktopMetrics;
    final headerHeight = miniCalendarMetrics ? 30.0 : 42.0;
    final headerFontSize = miniCalendarMetrics ? 13.5 : 14.0;
    final navigationSlotWidth = miniCalendarMetrics ? 26.0 : 40.0;
    final weekdayHeight = miniCalendarMetrics ? 24.0 : 30.0;
    final weekdayFontSize = miniCalendarMetrics ? 10.0 : 11.0;
    final dayFontSize = miniCalendarMetrics ? 12.5 : 14.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: headerHeight,
          child: Row(
            children: [
              SizedBox(
                width: navigationSlotWidth,
                child: showPrevious
                    ? _CalendarNavButton(
                        tooltip: 'Previous month',
                        icon: context.isRtl
                            ? Icons.chevron_right_rounded
                            : Icons.chevron_left_rounded,
                        enabled: canPrevious,
                        compactMetrics: miniCalendarMetrics,
                        onTap: onPrevious,
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '${l10n.monthNames[month.month - 1]} ${month.year}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.sffTextTheme.body.copyWith(
                      color: t.fg1,
                      fontWeight: FontWeight.w700,
                      fontSize: headerFontSize,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: navigationSlotWidth,
                child: showNext
                    ? _CalendarNavButton(
                        tooltip: 'Next month',
                        icon: context.isRtl
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        enabled: canNext,
                        compactMetrics: miniCalendarMetrics,
                        onTap: onNext,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.space2),
        Container(
          height: weekdayHeight,
          decoration: BoxDecoration(
            color: t.inputBg.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(spacing.radiusControl),
          ),
          child: Row(
            children: [
              for (final day in weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: context.sffTextTheme.label.copyWith(
                        color: t.fg4,
                        fontWeight: FontWeight.w700,
                        fontSize: weekdayFontSize,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: spacing.space2),
        for (var week = 0; week < 6; week++)
          Row(
            children: [
              for (var weekday = 0; weekday < 7; weekday++)
                Expanded(
                  child: _RangeDayCell(
                    date: days[(week * 7) + weekday],
                    inDisplayedMonth:
                        days[(week * 7) + weekday].month == month.month &&
                        days[(week * 7) + weekday].year == month.year,
                    selectedStart: RangeDateLogic.sameDay(
                      days[(week * 7) + weekday],
                      startDate,
                    ),
                    selectedEnd: RangeDateLogic.sameDay(
                      days[(week * 7) + weekday],
                      endDate,
                    ),
                    inRange: _isInRange(
                      days[(week * 7) + weekday],
                      startDate,
                      endDate,
                    ),
                    hasCompleteRange: startDate != null && endDate != null,
                    isToday: RangeDateLogic.sameDay(
                      days[(week * 7) + weekday],
                      DateTime.now(),
                    ),
                    disabled: !RangeDateLogic.isWithinBounds(
                      days[(week * 7) + weekday],
                      minDate: minDate,
                      maxDate: maxDate,
                    ),
                    suppressDuplicateAdjacentRangeDecoration:
                        suppressDuplicateAdjacentRangeDecoration,
                    compactMetrics: miniCalendarMetrics,
                    dayFontSize: dayFontSize,
                    onTap: onPick,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _CalendarNavButton extends StatelessWidget {
  const _CalendarNavButton({
    required this.tooltip,
    required this.icon,
    required this.enabled,
    required this.compactMetrics,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final bool enabled;
  final bool compactMetrics;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return IconButton(
      tooltip: tooltip,
      onPressed: enabled ? onTap : null,
      icon: Icon(icon),
      iconSize: compactMetrics ? 18 : 21,
      color: t.fg2,
      disabledColor: t.fg4.withValues(alpha: 0.45),
      visualDensity: VisualDensity.compact,
      constraints: BoxConstraints.tightFor(
        width: compactMetrics ? 26 : 34,
        height: compactMetrics ? 26 : 34,
      ),
      padding: EdgeInsets.zero,
    );
  }
}

class _RangeDayCell extends StatefulWidget {
  const _RangeDayCell({
    required this.date,
    required this.inDisplayedMonth,
    required this.selectedStart,
    required this.selectedEnd,
    required this.inRange,
    required this.hasCompleteRange,
    required this.isToday,
    required this.disabled,
    required this.suppressDuplicateAdjacentRangeDecoration,
    required this.compactMetrics,
    required this.dayFontSize,
    required this.onTap,
  });

  final DateTime date;
  final bool inDisplayedMonth;
  final bool selectedStart;
  final bool selectedEnd;
  final bool inRange;
  final bool hasCompleteRange;
  final bool isToday;
  final bool disabled;
  final bool suppressDuplicateAdjacentRangeDecoration;
  final bool compactMetrics;
  final double dayFontSize;
  final ValueChanged<DateTime> onTap;

  @override
  State<_RangeDayCell> createState() => _RangeDayCellState();
}

class _RangeDayCellState extends State<_RangeDayCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    final canPaintRangeDecoration =
        !widget.suppressDuplicateAdjacentRangeDecoration ||
        widget.inDisplayedMonth;
    final selected =
        canPaintRangeDecoration && (widget.selectedStart || widget.selectedEnd);
    final inRange = canPaintRangeDecoration && widget.inRange;
    final rangeColor = cs.primary.withValues(alpha: 0.14);
    final interactive = widget.inDisplayedMonth && !widget.disabled;
    final dayCircleSize = widget.compactMetrics ? 28.0 : 34.0;
    final todayCircleSize = widget.compactMetrics ? 28.0 : 33.0;

    final foreground = widget.disabled
        ? t.fg4
        : selected
        ? cs.onPrimary
        : widget.inDisplayedMonth
        ? t.fg1
        : t.fg4;

    return MouseRegion(
      cursor: !interactive
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: interactive ? (_) => setState(() => _hovered = true) : null,
      onExit: (_) => setState(() => _hovered = false),
      child: Semantics(
        button: interactive,
        selected: selected || inRange,
        label: RangeDateLogic.formatDate(widget.date),
        child: Opacity(
          opacity: !interactive ? 0.42 : 1,
          child: InkWell(
            onTap: interactive ? () => widget.onTap(widget.date) : null,
            customBorder: const CircleBorder(),
            child: AspectRatio(
              aspectRatio: widget.compactMetrics ? 1.05 : 1.08,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.hasCompleteRange && (inRange || selected))
                    _RangeBand(
                      color: rangeColor,
                      selectedStart: widget.selectedStart,
                      selectedEnd: widget.selectedEnd,
                    ),
                  if (_hovered && interactive && !selected)
                    Container(
                      width: dayCircleSize,
                      height: dayCircleSize,
                      decoration: BoxDecoration(
                        color: t.hover,
                        shape: BoxShape.circle,
                      ),
                    ),
                  if (selected)
                    Container(
                      width: dayCircleSize,
                      height: dayCircleSize,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  else if (widget.isToday)
                    Container(
                      width: todayCircleSize,
                      height: todayCircleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.72),
                          width: 1.2,
                        ),
                      ),
                    ),
                  Text(
                    '${widget.date.day}',
                    style: context.sffTextTheme.body.copyWith(
                      color: foreground,
                      fontSize: widget.dayFontSize,
                      fontWeight: selected || widget.isToday
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RangeBand extends StatelessWidget {
  const _RangeBand({
    required this.color,
    required this.selectedStart,
    required this.selectedEnd,
  });

  final Color color;
  final bool selectedStart;
  final bool selectedEnd;

  @override
  Widget build(BuildContext context) {
    if (selectedStart && selectedEnd) return const SizedBox.shrink();

    if (selectedStart) {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: Container(height: 28, color: color),
        ),
      );
    }

    if (selectedEnd) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: 0.5,
          child: Container(height: 28, color: color),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 28,
      child: ColoredBox(color: color),
    );
  }
}

bool _isInRange(DateTime value, DateTime? start, DateTime? end) {
  if (start == null || end == null) return false;
  final date = RangeDateLogic.dateOnly(value);
  final startOnly = RangeDateLogic.dateOnly(start);
  final endOnly = RangeDateLogic.dateOnly(end);
  return date.isAfter(startOnly) && date.isBefore(endOnly);
}

DateTime _addMonths(DateTime value, int delta) {
  final raw = value.year * 12 + value.month - 1 + delta;
  return DateTime(raw ~/ 12, raw % 12 + 1);
}
