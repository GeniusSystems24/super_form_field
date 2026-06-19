// ============================================================
// core/theme/sff_theme.dart — facade over `super_core`.
// ------------------------------------------------------------
// The swappable light/dark `ThemeExtension` now lives in `super_core` as
// `SuperThemeData` so the whole Super toolkit themes from one source. It is
// re-exported here, and `SuperFieldTheme` is kept as a back-compat alias so the
// form-field kit's existing `SuperFieldTheme.{light,dark,of,popShadow}` and
// `SuperFieldTheme t` call sites keep working unchanged.
// ============================================================

import 'package:super_core/super_core.dart';

export 'package:super_core/super_core.dart';

/// Back-compat alias: the form-field theme is the shared [SuperThemeData].
typedef SuperFieldTheme = SuperThemeData;
