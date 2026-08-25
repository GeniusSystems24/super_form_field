// ============================================================
// core/foundation/field_shell.dart
// ------------------------------------------------------------
// The labelled wrapper shared by every Super…Field. InputDecoration is the
// canonical source for label/helper/counter chrome; errors remain badge-only.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';

import 'field_decoration.dart';

/// The label + control + helper chrome around any form control.
class FormFieldShell extends StatelessWidget {
  const FormFieldShell({
    super.key,
    this.decoration = const InputDecoration(),
    this.required = false,
    required this.child,
    this.hasError = false,
    this.labelRight,
    this.allowFixed = false,
    this.isFixed,
    this.arabic = false,
    @Deprecated('Use decoration: InputDecoration(labelText: ...)') this.label,
    @Deprecated('Use decoration: InputDecoration(helperText: ...)') this.hint,
  }) : assert(
         !allowFixed || isFixed != null,
         'isFixed is required when allowFixed is true.',
       );

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

  /// Shows a compact lock/unlock action at the trailing edge of the label row.
  ///
  /// [isFixed] must be supplied when this is true. The button mirrors the
  /// fixed-state affordance used by `AutoSuggestionsBox`.
  final bool allowFixed;

  /// Fixed-state notifier controlled by the label action.
  final ValueNotifier<bool>? isFixed;

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
    final baseRight =
        labelRight ??
        SffDecoration.buildCounter(context, decoration, arabic: arabic);
    final fixedButton = allowFixed
        ? _FixedButton(
            isFixed: isFixed!,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )
        : null;
    Widget? effectiveRight;
    if (baseRight != null && fixedButton != null) {
      effectiveRight = Row(
        mainAxisSize: MainAxisSize.min,
        children: [baseRight, const SizedBox(width: 4), fixedButton],
      );
    } else {
      effectiveRight = baseRight ?? fixedButton;
    }
    final spacing = SuperThemeData.of(context).spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelWidget != null || effectiveRight != null) ...[
          SizedBox(
            height: 26,
            child: Row(
              children: [
                if (labelWidget != null) Expanded(child: labelWidget),
                if (labelWidget == null) const Spacer(),
                if (effectiveRight != null) effectiveRight,
              ],
            ),
          ),
          // SizedBox(height: spacing.space2),
        ],
        child,
        if (helperWidget != null && !hasError) ...[
          SizedBox(height: spacing.space2),
          helperWidget,
        ],
      ],
    );
  }
}

class _FixedButton extends StatelessWidget {
  const _FixedButton({required this.isFixed, required this.color});

  final ValueNotifier<bool> isFixed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isFixed,
      builder: (context, fixed, _) => Tooltip(
        message: fixed ? 'Unfix' : 'Fix',
        child: IconButton(
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 26, height: 26),
          padding: EdgeInsets.zero,
          iconSize: 14,
          color: fixed ? Theme.of(context).colorScheme.primary : color,
          onPressed: () => isFixed.value = !fixed,
          icon: Icon(fixed ? Icons.lock_rounded : Icons.lock_open_rounded),
        ),
      ),
    );
  }
}
