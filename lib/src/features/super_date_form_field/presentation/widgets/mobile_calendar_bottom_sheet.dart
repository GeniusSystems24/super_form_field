import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/foundation/field_icon_button.dart';
import '../../../../core/foundation/sff_icon.dart';
import '../../domain/usecases/date_logic.dart';
import 'mini_calendar.dart';

/// A polished mobile-only bottom sheet surface for picking a date.
///
/// The desktop/tablet experience keeps the anchored popover. On mobile we use
/// a dedicated bottom sheet that owns its own card surface, spacing, header,
/// drag handle, and responsive calendar sizing so the picker feels intentional
/// rather than a popover dropped into a generic sheet scaffold.
class MobileCalendarBottomSheet extends StatelessWidget {
  const MobileCalendarBottomSheet({
    super.key,
    required this.value,
    required this.onPick,
    this.minDate,
    this.maxDate,
  });

  final DateTime? value;
  final DateTime? minDate;
  final DateTime? maxDate;
  final ValueChanged<DateTime> onPick;

  String get _selectionLabel =>
      value == null ? 'Pick a date from the calendar' : DateLogic.format(value);

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final tokens = t.tokens;
    final insets = MediaQuery.viewInsetsOf(context);
    final padding = MediaQuery.paddingOf(context);

    return AnimatedPadding(
      duration: tokens.durBase,
      curve: tokens.curveStandard,
      padding: EdgeInsets.fromLTRB(
        tokens.space3,
        tokens.space3,
        tokens.space3,
        math.max(tokens.space3, padding.bottom) + tokens.space3 + insets.bottom,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(tokens.radiusCard * 2),
              border: Border.all(color: t.borderStrong),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x59000000),
                  blurRadius: 30,
                  spreadRadius: -8,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    tokens.space4,
                    tokens.space2,
                    tokens.space4,
                    tokens.space4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: t.borderStrong,
                          borderRadius: BorderRadius.circular(tokens.radiusPill),
                        ),
                      ),
                      SizedBox(height: tokens.space3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select date',
                                  style: SuperText.body.copyWith(
                                    color: t.fg1,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: tokens.space1),
                                Text(
                                  _selectionLabel,
                                  style: SuperText.caption.copyWith(
                                    color: t.fg3,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FieldIconButton(
                            icon: SffIcons.clear,
                            tooltip: 'Close',
                            bordered: true,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                      SizedBox(height: tokens.space3),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            Colors.white.withOpacity(0.02),
                            t.surface,
                          ),
                          borderRadius: BorderRadius.circular(tokens.radiusCard + 4),
                          border: Border.all(color: t.border),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(tokens.space3),
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: MiniCalendar(
                              value: value,
                              minDate: minDate,
                              maxDate: maxDate,
                              expanded: true,
                              onPick: onPick,
                            ),
                          ),
                        ),
                      ),
                    ],
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
