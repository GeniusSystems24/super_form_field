// ============================================================
// core/utils/sff_format.dart — facade over `super_core`.
// ------------------------------------------------------------
// The intl-free number / byte formatters now live in `super_core` so the whole
// Super toolkit formats numerics identically. Re-exported here so the kit's
// existing `SuperFormat.{number,bytes}` call sites keep working unchanged.
// ============================================================

export 'package:super_core/super_core.dart' show SuperFormat;
