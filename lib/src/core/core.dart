// ============================================================
// core/core.dart — barrel for the form-field foundation.
// ------------------------------------------------------------
// Re-exports the shared GeniusLink foundation from `super_core` (theme tokens,
// `SuperThemeData`, `SuperText`, `SuperFormat`, design-system widgets) so the
// form fields read as one identity with the rest of the Super toolkit, plus the
// form-field-specific utils + foundation widgets that live in this package.
//
// `super_core`'s own `FieldShell` / `FieldDensity` are hidden here: the kit
// ships its own (counter / labelRight / arabic-aware) `FieldShell` below.
// Features import from here, never from each other.
// ============================================================

// Shared foundation (from super_core). The kit ships its own `FieldShell` /
// `FieldDensity` (below) and its own `Validator` / `ValidityChanged` (in
// validators.dart, whose `ValidityChanged` reports an error string, not a
// bool), so those four names are hidden here to avoid an ambiguous re-export.
export 'package:super_core/super_core.dart'
    hide FieldShell, FieldDensity, Validator, ValidityChanged;

// Utils (form-field-specific)
export 'utils/validators.dart';

// Extensions
export 'extensions/context_extensions.dart';

// Entities (shared, cross-feature)
export 'entities/super_option.dart';

// Foundation widgets (form-field-specific)
export 'foundation/sff_icon.dart';
export 'foundation/error_badge.dart';
export 'foundation/field_shell.dart';
export 'foundation/field_box.dart';
export 'foundation/field_icon_button.dart';
export 'foundation/count_pill.dart';
export 'foundation/super_chip.dart';
export 'foundation/field_popover.dart';
export 'foundation/option_menu.dart';
export 'foundation/option_tile.dart';
export 'foundation/menu_search_field.dart';
