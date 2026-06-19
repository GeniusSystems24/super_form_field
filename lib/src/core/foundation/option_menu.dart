// ============================================================
// core/foundation/option_menu.dart
// ------------------------------------------------------------
// The floating panel shown by the option fields: a themed surface (popover
// shadow, hairline border, 6px radius) holding an optional [header] (a search
// box), a scrollable run of option rows, and an [empty] fallback. Heights cap at
// [maxHeight] and scroll; the panel sizes to its content otherwise. Pairs with
// FieldPopover (placement) and OptionTile (rows).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../extensions/context_extensions.dart';
import 'package:super_core/super_core.dart' hide FieldShell, FieldDensity;

/// The dropdown surface: optional [header] + scrollable [children] (+ [empty]).
class OptionMenu extends StatelessWidget {
  const OptionMenu({
    super.key,
    required this.children,
    this.header,
    this.empty,
    this.maxHeight = 280,
  });

  /// The option rows (typically [OptionTile]s).
  final List<Widget> children;

  /// A pinned widget above the scroll area (e.g. a search field).
  final Widget? header;

  /// Shown instead of the list when [children] is empty (e.g. "No matches").
  final Widget? empty;

  /// The list scrolls once it would exceed this height.
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final isEmpty = children.isEmpty;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(SuperTokens.radiusMd),
          border: Border.all(color: t.borderStrong),
          boxShadow: SuperThemeData.popShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null) header!,
            if (isEmpty && empty != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SuperTokens.space3,
                  vertical: SuperTokens.space4,
                ),
                child: empty!,
              )
            else
              Flexible(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(SuperTokens.space1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
