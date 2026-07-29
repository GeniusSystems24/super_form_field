import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../../../../localization/super_form_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final l10n = SuperFormTranslation.of(context);
    final tokens = t.tokens;
    final spacing = t.spacing;
    final insets = MediaQuery.viewInsetsOf(context);
    final padding = MediaQuery.paddingOf(context);
    final selectionLabel = value == null
        ? l10n.pickDateFromCalendar
        : DateLogic.format(value);

    return AnimatedPadding(
      duration: tokens.durBase,
      curve: tokens.curveStandard,
      padding: EdgeInsets.fromLTRB(
        spacing.space3,
        spacing.space3,
        spacing.space3,
        math.max(spacing.space3, padding.bottom) +
            spacing.space3 +
            insets.bottom,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(spacing.radiusCard * 2),
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
                    spacing.space4,
                    spacing.space2,
                    spacing.space4,
                    spacing.space4,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: t.borderStrong,
                          borderRadius: BorderRadius.circular(
                            spacing.radiusPill,
                          ),
                        ),
                      ),
                      SizedBox(height: spacing.space3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.selectDate,
                                  style: t.textTheme.body.copyWith(
                                    color: t.fg1,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: spacing.space1),
                                Text(
                                  selectionLabel,
                                  style: t.textTheme.caption.copyWith(
                                    color: t.fg3,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FieldIconButton(
                            icon: SffIcons.clear,
                            tooltip: l10n.close,
                            bordered: true,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing.space3),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            Colors.white.withValues(alpha: 0.02),
                            t.surface,
                          ),
                          borderRadius: BorderRadius.circular(
                            spacing.radiusCard + 4,
                          ),
                          border: Border.all(color: t.border),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(spacing.space3),
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
