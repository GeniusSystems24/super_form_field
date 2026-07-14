// ============================================================
// core/foundation/field_box.dart
// ------------------------------------------------------------
// The bordered control shell used by numeric, attachment and other fields that
// cannot express their trailing adornments (stepper, unit label, error badge)
// as standard InputDecoration suffix widgets.
//
// To eliminate the double-border issue, the child is wrapped in a Theme
// override that neutralises all inputDecorationTheme borders — FieldBox is the
// sole owner of the field border.
//
// Text fields (SuperTextFormField) use InputDecoration directly and do NOT
// go through FieldBox.
// ============================================================

import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import 'package:super_core/super_core.dart' hide FieldShell, FieldDensity;
import 'error_badge.dart';
import 'field_shell.dart';

/// Bordered shell for fields that compose trailing adornments (stepper, units,
/// error badge) outside of Material's InputDecoration. Owns the border,
/// background, error halo and disabled opacity.
///
/// Wrap the inner [TextField] with `InputDecoration.collapsed` or explicit
/// `border: InputBorder.none` — FieldBox neutralises the theme's borders
/// automatically via a [Theme] override so no double border appears.
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

  /// Error message — when non-null paints the danger frame + halo + error badge.
  final String? error;
  final bool disabled;
  final FieldDensity density;

  /// Leading icon slot (tints to primary on focus, fg4 at rest).
  final Widget? leading;

  /// Trailing adornments (stepper / unit). The [ErrorBadge] is appended
  /// automatically after these.
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = context.sffColorScheme;
    final hasError = error != null;
    final h = density == FieldDensity.compact
        ? SuperTokens.fieldCompact
        : SuperTokens.fieldComfortable;

    final borderColor = hasError
        ? cs.error
        : focused
            ? cs.primary
            : t.borderStrong;

    final bgColor = disabled
        ? Colors.transparent
        : focused
            ? t.surface
            : t.inputBg;

    // A no-border InputDecorationTheme so any TextField child does not render
    // its own border on top of FieldBox's border.
    final innerTheme = Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
    );

    return Opacity(
      opacity: disabled ? 0.55 : 1.0,
      child: AnimatedContainer(
        duration: SuperTokens.durBase,
        curve: SuperTokens.curveStandard,
        constraints: BoxConstraints(minHeight: h),
        padding: const EdgeInsetsDirectional.only(
          start: SuperTokens.space3,
          end: SuperTokens.space1,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.4),
          borderRadius: BorderRadius.circular(SuperTokens.radiusControl),
          boxShadow: hasError
              ? [BoxShadow(
                  color: cs.error.withOpacity(0.14),
                  blurRadius: 0,
                  spreadRadius: 3,
                )]
              : null,
        ),
        child: Theme(
          data: innerTheme,
          child: Row(
            children: [
              if (leading != null) ...[
                IconTheme.merge(
                  data: IconThemeData(
                    size: 16,
                    color: focused ? cs.primary : t.fg4,
                  ),
                  child: leading!,
                ),
                const SizedBox(width: SuperTokens.space2),
              ],
              Expanded(child: child),
              for (final w in trailing) ...[
                const SizedBox(width: SuperTokens.space1),
                w,
              ],
              if (hasError) ...[
                const SizedBox(width: SuperTokens.space1),
                ErrorBadge(error: error),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
