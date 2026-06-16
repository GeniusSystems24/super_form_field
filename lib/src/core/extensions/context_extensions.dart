// ============================================================
// core/extensions/context_extensions.dart
// ------------------------------------------------------------
// Ergonomic BuildContext accessors for theme + direction. Keeps call sites
// terse: `context.sffTheme.fg1`, `context.isRtl`.
// ============================================================

import 'package:flutter/widgets.dart';

import '../theme/sff_theme.dart';

extension SuperFieldContextX on BuildContext {
  /// The registered [SuperFieldTheme] (falls back to the dark preset).
  SuperFieldTheme get sffTheme => SuperFieldTheme.of(this);

  /// The ambient text direction.
  TextDirection get direction => Directionality.of(this);

  /// True when laid out right-to-left (Arabic).
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
