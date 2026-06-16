// ============================================================
// core/foundation/sff_icon.dart
// ------------------------------------------------------------
// The icon vocabulary used by the form fields, named to mirror the React
// `GLIcon` set. GeniusLink ships outlined line icons (1.5px stroke, rounded
// caps); here they map to Flutter's bundled Material *_outlined glyphs, which
// match the stroke style closely.
//
// FLAGGED (per the design system): when the in-house SVG icon set lands,
// swap these `IconData` entries for the production marks.
// ============================================================

import 'package:flutter/material.dart';

/// Named icons for the kit. `SffIcons.alertCircle`, etc.
abstract final class SffIcons {
  static const IconData alertCircle = Icons.error_outline;
  static const IconData clear = Icons.close_rounded;
  static const IconData eye = Icons.visibility_outlined;
  static const IconData eyeOff = Icons.visibility_off_outlined;
  static const IconData plus = Icons.add_rounded;
  static const IconData minus = Icons.remove_rounded;
  static const IconData uploadCloud = Icons.cloud_upload_outlined;
  static const IconData trash = Icons.delete_outline_rounded;

  // ── file-type glyphs ──
  static const IconData image = Icons.image_outlined;
  static const IconData fileText = Icons.description_outlined;
  static const IconData sheet = Icons.table_chart_outlined;
  static const IconData file = Icons.insert_drive_file_outlined;

  // ── common leading icons ──
  static const IconData search = Icons.search_rounded;
  static const IconData mail = Icons.mail_outline_rounded;
  static const IconData lock = Icons.lock_outline_rounded;
  static const IconData user = Icons.person_outline_rounded;
  static const IconData hash = Icons.tag_rounded;
}
