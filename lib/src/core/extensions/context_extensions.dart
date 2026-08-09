// ============================================================
// core/extensions/context_extensions.dart
// ------------------------------------------------------------
// Form-field-specific BuildContext accessor. The shared `superTheme` / `isRtl`
// / `direction` getters come from `super_core`'s `SuperContextX`; this adds the
// terse `context.sffTheme` and `context.sffTextTheme` aliases used internally.
// ============================================================

import 'package:flutter/material.dart';

import 'package:super_core/super_core.dart';

extension SuperFieldContextX on BuildContext {
  /// The registered [SuperThemeData] (falls back to the dark preset).
  SuperThemeData get sffTheme => SuperThemeData.of(this);

  /// The required typography ramp from the active [SuperMaterialThemeData].
  ///
  /// `super_core` 3.3.0 moved typography ownership out of [SuperThemeData].
  /// Form-field internals should use this accessor instead of reading
  /// `sffTheme.textTheme`.
  SuperTextTheme get sffTextTheme => SuperMaterialThemeData.of(this).textTheme;

  /// The active Material [ColorScheme] — primary, error and other semantic
  /// roles reflect the active [SuperPalette] when using [SuperMaterialThemeData].
  ColorScheme get sffColorScheme => Theme.of(this).colorScheme;
}
