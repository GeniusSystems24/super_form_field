// ============================================================
// core/theme/sff_tokens.dart — facade over the shared `super_core` foundation.
// ------------------------------------------------------------
// The brand constants (accent + semantic palette, font families, radii, the 4px
// spacing scale, control + FIELD sizes, motion) now live in `super_core` so the
// whole Super toolkit shares one identity. This file re-exports them so the
// form-field kit's existing `SuperTokens.*` / `SuperMarker` call sites keep
// working unchanged.
// ============================================================

export 'package:super_core/super_core.dart' show SuperTokens, SuperMarker;
