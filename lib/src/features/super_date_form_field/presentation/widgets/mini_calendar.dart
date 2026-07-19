// ============================================================
// features/super_date_form_field/presentation/widgets/mini_calendar.dart
// ------------------------------------------------------------
// The month-grid calendar shown in the date field's popover — a faithful port
// of the web DateColumn's `MiniCalendar`: a header with prev/next month chevrons,
// a Su–Sa day-of-week row, a 7-column day grid (today outlined, selection filled
// accent, hover tint), and a "Today" shortcut. Mono day numerals, themed via
// SuperThemeData. Out-of-range days (min/max) render disabled.
//
// The same calendar widget now supports two density profiles:
// - compact: anchored desktop/tablet popover
// - expanded: mobile bottom sheet presentation
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/foundation/sff_icon.dart';
import 'package:super_core/super_core.dart';
import '../../domain/usecases/date_logic.dart';

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December', //
];
const _dow = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

/// A compact month calendar. Calls [onPick] with a midnight-anchored date when a
/// day (or "Today") is tapped.
class MiniCalendar extends StatefulWidget {
  const MiniCalendar({
    super.key,
    required this.value,
    required this.onPick,
    this.minDate,
    this.maxDate,
    this.expanded = false,
  });

  /// The currently-selected date (highlighted), or null.
  final DateTime? value;
  final ValueChanged<DateTime> onPick;
  final DateTime? minDate;
  final DateTime? maxDate;

  /// Uses the larger bottom-sheet presentation metrics.
  final bool expanded;

  @override
  State<MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<MiniCalendar> {
  late int _y;
  late int _m; // 0-based month

  @override
  void initState() {
    super.initState();
    final init = widget.value ?? DateTime.now();
    _y = init.year;
    _m = init.month - 1;
  }

  void _step(int delta) => setState(() {
    var m = _m + delta;
    var y = _y;
    if (m < 0) {
      m = 11;
      y--;
    } else if (m > 11) {
      m = 0;
      y++;
    }
    _m = m;
    _y = y;
  });

  bool _outOfRange(DateTime d) {
    final lo = widget.minDate == null
        ? null
        : DateLogic.dateOnly(widget.minDate!);
    final hi = widget.maxDate == null
        ? null
        : DateLogic.dateOnly(widget.maxDate!);
    if (lo != null && d.isBefore(lo)) return true;
    if (hi != null && d.isAfter(hi)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    final tokens = SuperThemeData.of(context).tokens;
    final daysInMonth = DateTime(_y, _m + 2, 0).day;
    final startDow = DateTime(_y, _m + 1, 1).weekday % 7; // Sun=0
    final today = DateLogic.dateOnly(DateTime.now());
    final expanded = widget.expanded;

    final outerPadding = expanded ? tokens.space2 : tokens.space3;
    final headerFontSize = expanded ? 16.0 : 13.5;
    final dowFontSize = expanded ? 11.0 : 10.0;
    final dayFontSize = expanded ? 14.0 : 12.5;
    final cellRadius = expanded ? tokens.radiusCard : tokens.radiusMd;
    final cellMinHeight = expanded ? 40.0 : 28.0;
    final gridSpacing = expanded ? 6.0 : 2.0;
    final calendarWidth = expanded ? double.infinity : 248.0;

    final cells = <int?>[];
    for (var i = 0; i < startDow; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(d);
    }

    return Container(
      width: calendarWidth,
      padding: EdgeInsets.all(outerPadding),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(
          expanded ? tokens.radiusCard + 4 : tokens.radiusCard,
        ),
        border: Border.all(color: expanded ? t.border : t.borderStrong),
        boxShadow: expanded
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x59000000),
                  blurRadius: 24,
                  spreadRadius: -6,
                  offset: Offset(0, 10),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── header: month nav ──
          Padding(
            padding: EdgeInsets.only(
              bottom: expanded ? tokens.space3 : tokens.space2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavButton(
                  icon: SffIcons.chevronLeft,
                  expanded: expanded,
                  onTap: () => _step(-1),
                ),
                Text(
                  '${_months[_m]} $_y',
                  style: SuperText.body.copyWith(
                    color: t.fg1,
                    fontWeight: FontWeight.w700,
                    fontSize: headerFontSize,
                  ),
                ),
                _NavButton(
                  icon: SffIcons.chevronRight,
                  expanded: expanded,
                  onTap: () => _step(1),
                ),
              ],
            ),
          ),
          // ── day-of-week labels ──
          Row(
            children: [
              for (final d in _dow)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: expanded ? 2 : 0),
                    child: Center(
                      child: Text(
                        d,
                        style: SuperText.label.copyWith(
                          color: t.fg4,
                          fontSize: dowFontSize,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: expanded ? tokens.space2 : tokens.space1),
          // ── day grid ──
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: gridSpacing,
            crossAxisSpacing: gridSpacing,
            childAspectRatio: expanded ? 1.0 : 1.05,
            children: [
              for (final d in cells)
                if (d == null)
                  const SizedBox.shrink()
                else
                  _DayCell(
                    day: d,
                    date: DateTime(_y, _m + 1, d),
                    selected: DateLogic.sameDay(
                      widget.value,
                      DateTime(_y, _m + 1, d),
                    ),
                    isToday: DateLogic.sameDay(today, DateTime(_y, _m + 1, d)),
                    disabled: _outOfRange(DateTime(_y, _m + 1, d)),
                    expanded: expanded,
                    minHeight: cellMinHeight,
                    radius: cellRadius,
                    fontSize: dayFontSize,
                    onTap: widget.onPick,
                  ),
            ],
          ),
          SizedBox(height: expanded ? tokens.space2 : tokens.space1),
          // ── Today shortcut ──
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: _outOfRange(today) ? null : () => widget.onPick(today),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: expanded ? 12 : 8,
                  vertical: expanded ? 8 : 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                ),
              ),
              child: Text(
                'Today',
                style: SuperText.caption.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: expanded ? 13 : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.expanded,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final tokens = SuperThemeData.of(context).tokens;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(expanded ? 8 : 4),
          child: Icon(icon, size: expanded ? 20 : 18, color: t.fg2),
        ),
      ),
    );
  }
}

class _DayCell extends StatefulWidget {
  const _DayCell({
    required this.day,
    required this.date,
    required this.selected,
    required this.isToday,
    required this.disabled,
    required this.onTap,
    required this.expanded,
    required this.minHeight,
    required this.radius,
    required this.fontSize,
  });

  final int day;
  final DateTime date;
  final bool selected;
  final bool isToday;
  final bool disabled;
  final bool expanded;
  final double minHeight;
  final double radius;
  final double fontSize;
  final ValueChanged<DateTime> onTap;

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    final Color bg = widget.selected
        ? cs.primary
        : (_hover && !widget.disabled ? t.hover : const Color(0x00000000));
    final Color fg = widget.disabled
        ? t.fg4
        : widget.selected
            ? const Color(0xFFFFFFFF)
            : t.fg1;
    final border = widget.isToday && !widget.selected
        ? Border.all(color: t.borderStrong)
        : Border.all(color: const Color(0x00000000));

    return MouseRegion(
      cursor: widget.disabled
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Opacity(
        opacity: widget.disabled ? 0.35 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.disabled
                ? null
                : () => widget.onTap(DateLogic.dateOnly(widget.date)),
            borderRadius: BorderRadius.circular(widget.radius),
            child: Ink(
              decoration: BoxDecoration(
                color: bg,
                border: border,
                borderRadius: BorderRadius.circular(widget.radius),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: widget.minHeight),
                child: Center(
                  child: Text(
                    '${widget.day}',
                    style: SuperText.mono.copyWith(
                      color: fg,
                      fontSize: widget.fontSize,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
