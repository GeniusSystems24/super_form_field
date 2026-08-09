// ============================================================
// core/foundation/count_pill.dart
// ------------------------------------------------------------
// A small rounded count pill — a semantic-colored tint behind colored text,
// used in the attachment field's label-right slot to show the file count.
// ============================================================

import 'package:flutter/widgets.dart';

import '../extensions/context_extensions.dart';

/// A rounded pill: [color]-tinted background behind [color] text.
class CountPill extends StatelessWidget {
  const CountPill({
    super.key,
    required this.label,
    this.color = const Color(0xFF4A7CFF),
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: 0.15), t.surface),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: context.sffTextTheme.pill.copyWith(color: color),
      ),
    );
  }
}
