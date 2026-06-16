// ============================================================
// core/foundation/field_box.dart
// ------------------------------------------------------------
// The bordered control row used by the text + numeric fields: an optional
// leading icon · the control (any child) · trailing adornments · the suffix
// ErrorBadge. Owns the rest / focus / error / disabled visual states and the
// 150ms color+background transition. RTL-safe via logical padding.
// ============================================================

import 'package:flutter/widgets.dart';

import '../extensions/context_extensions.dart';
import '../theme/sff_tokens.dart';
import 'error_badge.dart';
import 'field_shell.dart';

/// The bordered, single-line control shell. The concrete field supplies [child]
/// (its `EditableText`/input); FieldBox owns only the frame around it.
class FieldBox extends StatelessWidget {
  const FieldBox({
    super.key,
    required this.child,
    this.focused = false,
    this.error,
    this.disabled = false,
    this.density = FieldDensity.comfortable,
    this.leading,
    this.trailing = const [],
  });

  final Widget child;
  final bool focused;

  /// Error message — when non-null, paints the danger frame + halo + badge.
  final String? error;
  final bool disabled;
  final FieldDensity density;

  /// Leading icon slot (tints to accent on focus, fg4 at rest).
  final Widget? leading;

  /// Trailing adornments (clear / reveal / stepper / unit). The ErrorBadge is
  /// appended automatically after these.
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final hasError = error != null;
    final h = density == FieldDensity.compact
        ? SuperTokens.fieldCompact
        : SuperTokens.fieldComfortable;

    final border = hasError
        ? SuperTokens.danger
        : focused
            ? SuperTokens.accent
            : t.borderStrong;
    final bg = disabled
        ? const Color(0x00000000)
        : focused
            ? t.surface
            : t.inputBg;

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: AnimatedContainer(
        duration: SuperTokens.durBase,
        curve: SuperTokens.curveStandard,
        constraints: BoxConstraints(minHeight: h),
        padding: const EdgeInsetsDirectional.only(start: SuperTokens.space3, end: SuperTokens.space1),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 1.4),
          borderRadius: BorderRadius.circular(SuperTokens.radiusControl),
          boxShadow: hasError
              ? [BoxShadow(color: SuperTokens.danger.withOpacity(0.14), blurRadius: 0, spreadRadius: 3)]
              : null,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              IconTheme.merge(
                data: IconThemeData(
                  size: 16,
                  color: focused ? SuperTokens.accent : t.fg4,
                ),
                child: leading!,
              ),
              const SizedBox(width: SuperTokens.space2),
            ],
            Expanded(child: child),
            for (final w in trailing) ...[const SizedBox(width: SuperTokens.space1), w],
            if (hasError) ...[const SizedBox(width: SuperTokens.space1), ErrorBadge(error: error)],
          ],
        ),
      ),
    );
  }
}
