// ============================================================
// core/theme/sff_tokens.dart
// ------------------------------------------------------------
// Theme-INDEPENDENT brand constants for the GeniusLink form fields — the values
// that never change between light and dark: the accent + semantic palette,
// font families, radii, the 4px spacing scale, control metrics, and motion
// curves. Swappable surfaces (the colors that flip dark <-> light) live in
// `SuperFieldTheme`.
//
// Ported from the GeniusLink design system `colors_and_type.css`.
// ============================================================

import 'package:flutter/widgets.dart';

/// Immutable brand constants for the form-field kit. Never instantiated —
/// `SuperTokens.accent`, etc.
abstract final class SuperTokens {
  // ── Brand + semantic palette ────────────────────────────────────────────
  /// The single dominant electric-royal-blue accent.
  static const Color accent = Color(0xFF4A7CFF);
  static const Color accentHover = Color(0xFF5E8DFF); // +6% lightness on hover
  static const Color accentPressed = Color(0xFF3D6DEB); // darkens on press

  static const Color success = Color(0xFF1DB88A); // green — image / sheet files
  static const Color warning = Color(0xFFF97316); // orange — notes / docs
  static const Color danger = Color(0xFFEF4444); // red — validation errors

  // ── Typography ───────────────────────────────────────────────────────────
  static const String displayFont = 'Manrope'; // H1 page titles
  static const String bodyFont = 'Inter'; // headings, body, labels, captions
  static const String monoFont = 'JetBrainsMono'; // numerics, serials, sizes
  static const String arabicFont = 'NotoNaskhArabic'; // Arabic glyphs

  // ── Radii ──────────────────────────────────────────────────────────────────
  static const double radiusControl = 4; // inputs, buttons
  static const double radiusMd = 6; // drop zone, file cards
  static const double radiusCard = 8; // section cards
  static const double radiusPill = 12; // status pills

  // ── Spacing scale (4px base unit) ────────────────────────────────────────────
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;

  // ── Control metrics ──────────────────────────────────────────────────────────
  static const double fieldComfortable = 42; // comfortable field height
  static const double fieldCompact = 36; // compact field height
  static const double stepperSize = 24; // +/- stepper button
  static const double trailingIcon = 26; // clear / reveal / error icon button

  // ── Motion ───────────────────────────────────────────────────────────────────
  static const Duration durFast = Duration(milliseconds: 120);
  static const Duration durBase = Duration(milliseconds: 150); // color/bg
  static const Curve curveStandard = Cubic(0.4, 0, 0.2, 1); // ease
  static const Curve curveOut = Cubic(0, 0, 0.2, 1); // ease-out
}
