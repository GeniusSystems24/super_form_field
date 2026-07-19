// ============================================================
// core/foundation/field_shell.dart
// ------------------------------------------------------------
// The labelled wrapper shared by every Super…Field. InputDecoration is the
// canonical source for label/helper/counter chrome; errors remain badge-only.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart' hide FieldDensity, FieldShell;

import 'field_decoration.dart';

/// Vertical density of a field.
enum FieldDensity { comfortable, compact }

/// The label + control + helper chrome around any form control.
class FieldShell extends StatelessWidget {
  const FieldShell({
    super.key,
    this.decoration = const InputDecoration(),
    this.required = false,
    required this.child,
    this.hasError = false,
    this.labelRight,
    this.arabic = false,
    @Deprecated('Use decoration: InputDecoration(labelText: ...)') this.label,
    @Deprecated('Use decoration: InputDecoration(helperText: ...)') this.hint,
  });

  /// Canonical Material decoration mapped onto the GeniusLink field shell.
  final InputDecoration decoration;

  /// Appends a red required asterisk to the decoration label.
  final bool required;

  /// The control (an input row, a drop zone, or an option group).
  final Widget child;

  /// True when the field is showing an error (suppresses helper content).
  final bool hasError;

  /// Optional trailing slot on the label row (counter / count pill / badge).
  final Widget? labelRight;

  /// Use the Arabic display face for label and helper content.
  final bool arabic;

  /// Compatibility bridge for callers that use FieldShell directly.
  final String? label;

  /// Compatibility bridge for callers that use FieldShell directly.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final labelWidget = SffDecoration.buildLabel(
      context,
      decoration,
      required: required,
      arabic: arabic,
      legacyLabel: label,
    );
    final helperWidget = SffDecoration.buildHelper(
      context,
      decoration,
      arabic: arabic,
      legacyHint: hint,
    );
    final effectiveRight = labelRight ??
        SffDecoration.buildCounter(
          context,
          decoration,
          arabic: arabic,
        );
    final tokens = SuperThemeData.of(context).tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelWidget != null || effectiveRight != null) ...[
          Row(
            children: [
              if (labelWidget != null) Expanded(child: labelWidget),
              if (labelWidget == null) const Spacer(),
              if (effectiveRight != null) effectiveRight,
            ],
          ),
          SizedBox(height: tokens.space2),
        ],
        child,
        if (helperWidget != null && !hasError) ...[
          SizedBox(height: tokens.space2),
          helperWidget,
        ],
      ],
    );
  }
}
