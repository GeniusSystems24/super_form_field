// ============================================================
// features/super_date_form_field/presentation/widgets/mini_calendar.dart
// ------------------------------------------------------------
// The month-grid calendar shown in the date field's popover — a faithful port
// of the web DateColumn's `MiniCalendar`: a header with prev/next month chevrons,
// a Su–Sa day-of-week row, a 7-column day grid (today outlined, selection filled
// accent, hover tint), and a "Today" shortcut. Mono day numerals, themed via
// SuperFieldTheme. Out-of-range days (min/max) render disabled.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/foundation/sff_icon.dart';
import '../../../../core/theme/sff_text_styles.dart';
import '../../../../core/theme/sff_tokens.dart';
import '../../domain/usecases/date_logic.dart';

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December' //
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
  });

  /// The currently-selected date (highlighted), or null.
  final DateTime? value;
  final ValueChanged<DateTime> onPick;
  final DateTime? minDate;
  final DateTime? maxDate;

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
    final lo = widget.minDate == null ? null : DateLogic.dateOnly(widget.minDate!);
    final hi = widget.maxDate == null ? null : DateLogic.dateOnly(widget.maxDate!);
    if (lo != null && d.isBefore(lo)) return true;
    if (hi != null && d.isAfter(hi)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final daysInMonth = DateTime(_y, _m + 2, 0).day;
    final startDow = DateTime(_y, _m + 1, 1).weekday % 7; // Sun=0
    final today = DateLogic.dateOnly(DateTime.now());

    final cells = <int?>[];
    for (var i = 0; i < startDow; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(d);
    }

    return Container(
      width: 248,
      padding: const EdgeInsets.all(SuperTokens.space3),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(SuperTokens.radiusCard),
        border: Border.all(color: t.borderStrong),
        boxShadow: const [
          BoxShadow(color: Color(0x59000000), blurRadius: 24, spreadRadius: -6, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── header: month nav ──
          Padding(
            padding: const EdgeInsets.only(bottom: SuperTokens.space2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavButton(icon: SffIcons.chevronLeft, onTap: () => _step(-1)),
                Text('${_months[_m]} $_y',
                    style: SuperText.body.copyWith(color: t.fg1, fontWeight: FontWeight.w700, fontSize: 13.5)),
                _NavButton(icon: SffIcons.chevronRight, onTap: () => _step(1)),
              ],
            ),
          ),
          // ── day-of-week labels ──
          Row(
            children: [
              for (final d in _dow)
                Expanded(
                  child: Center(
                    child: Text(d,
                        style: SuperText.label.copyWith(color: t.fg4, fontSize: 10, letterSpacing: 0.2)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SuperTokens.space1),
          // ── day grid ──
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            childAspectRatio: 1.05,
            children: [
              for (final d in cells)
                if (d == null)
                  const SizedBox.shrink()
                else
                  _DayCell(
                    day: d,
                    date: DateTime(_y, _m + 1, d),
                    selected: DateLogic.sameDay(widget.value, DateTime(_y, _m + 1, d)),
                    isToday: DateLogic.sameDay(today, DateTime(_y, _m + 1, d)),
                    disabled: _outOfRange(DateTime(_y, _m + 1, d)),
                    onTap: widget.onPick,
                  ),
            ],
          ),
          const SizedBox(height: SuperTokens.space1),
          // ── Today shortcut ──
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: _outOfRange(today) ? null : () => widget.onPick(today),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Today',
                  style: SuperText.caption.copyWith(color: SuperTokens.accent, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SuperTokens.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: t.fg2),
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
  });

  final int day;
  final DateTime date;
  final bool selected;
  final bool isToday;
  final bool disabled;
  final ValueChanged<DateTime> onTap;

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final Color bg = widget.selected
        ? SuperTokens.accent
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
      cursor: widget.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.disabled ? null : () => widget.onTap(DateLogic.dateOnly(widget.date)),
        child: Opacity(
          opacity: widget.disabled ? 0.35 : 1,
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              border: border,
              borderRadius: BorderRadius.circular(SuperTokens.radiusMd),
            ),
            alignment: Alignment.center,
            child: Text(
              '${widget.day}',
              style: SuperText.mono.copyWith(color: fg, fontSize: 12.5),
            ),
          ),
        ),
      ),
    );
  }
}
