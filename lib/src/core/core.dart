// ============================================================
// core/core.dart — barrel for the shared form-field foundation.
// Re-exports theme, utils, extensions and the field foundation widgets.
// Features import from here, never from each other.
// ============================================================

// Theme
export 'theme/sff_tokens.dart';
export 'theme/sff_theme.dart';
export 'theme/sff_text_styles.dart';

// Utils
export 'utils/validators.dart';
export 'utils/sff_format.dart';

// Extensions
export 'extensions/context_extensions.dart';

// Foundation widgets
export 'foundation/sff_icon.dart';
export 'foundation/error_badge.dart';
export 'foundation/field_shell.dart';
export 'foundation/field_box.dart';
export 'foundation/field_icon_button.dart';
export 'foundation/count_pill.dart';
