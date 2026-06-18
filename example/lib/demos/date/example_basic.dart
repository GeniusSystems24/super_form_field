// ============================================================
// example/lib/demos/date/example_basic.dart
// ------------------------------------------------------------
// EXAMPLE 1 — Basic (uncontrolled).
// The simplest way to use SuperDateFormField: declare a label, optional bounds,
// and read the value through onChanged. The field owns its own state; type a
// masked YYYY-MM-DD value or pick from the calendar popover.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart';

import '../demo_scaffold.dart';

class DateBasicExample extends StatefulWidget {
  const DateBasicExample({super.key});

  @override
  State<DateBasicExample> createState() => _DateBasicExampleState();
}

class _DateBasicExampleState extends State<DateBasicExample> {
  DateTime? _value = DateTime(2024, 1, 1);

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return SectionCard(
      title: '1 · Basic',
      subtitle: 'Uncontrolled — type a masked date or pick from the calendar',
      marker: Marker.identity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SuperDateFormField(
            label: 'Posting Date',
            initialValue: _value,
            hint: 'Click a segment and type (year→month→day), or step with ↑/↓ · ←/→ moves segments.',
            onChanged: (v) => setState(() => _value = v),
          ),
          const SizedBox(height: SuperTokens.space3),
          Text(
            'VALUE  ${DateLogic.format(_value).isEmpty ? '—' : DateLogic.format(_value)}',
            style: SuperText.mono.copyWith(color: t.fg3, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
