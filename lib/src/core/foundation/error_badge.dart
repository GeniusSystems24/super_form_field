// ============================================================
// core/foundation/error_badge.dart
// ------------------------------------------------------------
// The validator-error affordance shared by every Super…Field: a danger-tinted
// SUFFIX ICON whose hover / long-press TOOLTIP carries the full error text.
// This is the ONLY way the fields surface validation — never inline text under
// the control (a hard rule of the GeniusLink form system).
// ============================================================

import 'package:flutter/material.dart';

import 'package:super_core/super_core.dart';
import 'sff_icon.dart';

/// A danger alert-circle icon that reveals [error] in a tooltip on hover /
/// long-press. Renders nothing when [error] is null.
class ErrorBadge extends StatelessWidget {
  const ErrorBadge({super.key, required this.error, this.size = 17});

  /// The message to surface. Null hides the badge entirely.
  final String? error;

  /// Glyph size in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    final err = error;
    if (err == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: err,
      preferBelow: false,
      waitDuration: const Duration(milliseconds: 120),
      padding: const EdgeInsets.symmetric(
        horizontal: SuperTokens.space3,
        vertical: SuperTokens.space2,
      ),
      margin: const EdgeInsets.symmetric(horizontal: SuperTokens.space4),
      decoration: BoxDecoration(
        color: cs.error,
        borderRadius: BorderRadius.circular(SuperTokens.radiusMd),
        boxShadow: SuperThemeData.popShadow,
      ),
      textStyle: SuperText.caption.copyWith(
        color: const Color(0xFFFFFFFF),
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      child: SizedBox(
        width: SuperTokens.trailingIcon,
        height: SuperTokens.trailingIcon,
        child: Icon(SffIcons.alertCircle, size: size, color: cs.error),
      ),
    );
  }
}
