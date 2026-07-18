// ============================================================
// core/foundation/count_pill.dart
// ------------------------------------------------------------
// A small rounded count pill — a semantic-colored tint behind colored text,
// used in the attachment field's label-right slot to show the file count.
// ============================================================

import 'package:flutter/widgets.dart';

import '../extensions/context_extensions.dart';
import 'package:super_core/super_core.dart';

/// A rounded pill: [color]-tinted background behind [color] text.
class CountPill extends StatelessWidget {
  const CountPill({super.key, required this.label, this.color = SuperTokensData.defaultAccent});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withOpacity(0.15), t.surface),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label.toUpperCase(), style: SuperText.pill.copyWith(color: color)),
    );
  }
}
