// ============================================================
// core/foundation/field_shell.dart
// ------------------------------------------------------------
// The labelled wrapper shared by every Super…Field. Renders the uppercase label
// (with optional required asterisk) and an optional right-aligned slot
// (character counter / file count / field-level error badge), then the control,
// then an optional hint line beneath — but ONLY when there is no error, since
// errors surface through the suffix ErrorBadge, never as inline text.
// ============================================================

import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import 'package:super_core/super_core.dart' hide FieldShell, FieldDensity;

/// Vertical density of a field.
enum FieldDensity { comfortable, compact }

/// The label + control + hint chrome around any form control.
class FieldShell extends StatelessWidget {
  const FieldShell({
    super.key,
    this.label,
    this.required = false,
    required this.child,
    this.hint,
    this.hasError = false,
    this.labelRight,
    this.arabic = false,
  });

  /// Uppercase field label. Null hides the label row (unless [labelRight] set).
  final String? label;

  /// Appends a red required asterisk to the label.
  final bool required;

  /// The control (an input row, a drop zone…).
  final Widget child;

  /// Helper text under the control. Hidden whenever [hasError] is true.
  final String? hint;

  /// True when the field is showing an error (suppresses the hint line).
  final bool hasError;

  /// Optional trailing slot on the label row (counter / count pill / badge).
  final Widget? labelRight;

  /// Use the Arabic display face for the label + hint.
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final fontFamily = arabic ? SuperTokensData.defaultArabicFont : SuperTokensData.defaultBodyFont;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || labelRight != null) ...[
          Row(
            children: [
              if (label != null)
                _Label(text: label!, required: required, color: t.fg2, fontFamily: fontFamily),
              const Spacer(),
              if (labelRight != null) labelRight!,
            ],
          ),
          const SizedBox(height: SuperTokensData.defaultSpace2),
        ],
        child,
        if (hint != null && !hasError) ...[
          const SizedBox(height: SuperTokensData.defaultSpace2),
          Text(
            hint!,
            style: SuperText.caption.copyWith(color: t.fg4, fontFamily: fontFamily),
          ),
        ],
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.text,
    required this.required,
    required this.color,
    required this.fontFamily,
  });

  final String text;
  final bool required;
  final Color color;
  final String fontFamily;

  @override
  Widget build(BuildContext context) {
    final style = SuperText.label.copyWith(color: color, fontFamily: fontFamily);
    if (!required) return Text(text.toUpperCase(), style: style);
    return Text.rich(
      TextSpan(
        text: text.toUpperCase(),
        style: style,
        children: [
          TextSpan(text: ' *', style: style.copyWith(color: Theme.of(context).colorScheme.error)),
        ],
      ),
    );
  }
}
