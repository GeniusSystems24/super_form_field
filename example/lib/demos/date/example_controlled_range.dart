// ============================================================
// example/lib/demos/date/example_controlled_range.dart
// ------------------------------------------------------------
// EXAMPLE 2 — Controlled, with a linked min/max range.
// Two fields driven by external SuperDateFieldControllers. Picking a Start Date
// raises the End Date's minDate (and clears an end that falls before it); the
// End Date likewise caps the Start Date's maxDate. Shows controller.value,
// controller.setValue, and dynamic bounds.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart' hide SectionCard;

import '../demo_scaffold.dart';

class DateControlledRangeExample extends StatefulWidget {
  const DateControlledRangeExample({super.key});

  @override
  State<DateControlledRangeExample> createState() => _DateControlledRangeExampleState();
}

class _DateControlledRangeExampleState extends State<DateControlledRangeExample> {
  final _start = SuperDateFieldController(initialValue: DateTime(2024, 1, 1));
  final _end = SuperDateFieldController(initialValue: DateTime(2024, 3, 31));

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  void _onStartChanged(DateTime? v) {
    // Keep the end on/after the start.
    final end = _end.value;
    if (v != null && end != null && end.isBefore(v)) _end.setValue(v);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return SectionCard(
      title: '2 · Controlled range',
      subtitle: 'Linked controllers — Start caps End, and vice-versa',
      marker: Marker.ledger,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SuperDateFormField(
                  controller: _start,
                  label: 'Period Start',
                  required: true,
                  maxDate: _end.value,
                  onChanged: _onStartChanged,
                ),
              ),
              SizedBox(width: SuperThemeData.of(context).tokens.space4),
              Expanded(
                child: SuperDateFormField(
                  controller: _end,
                  label: 'Period End',
                  required: true,
                  minDate: _start.value,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          SizedBox(height: SuperThemeData.of(context).tokens.space4),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: t.fg1,
                side: BorderSide(color: t.borderStrong),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SuperThemeData.of(context).tokens.radiusControl)),
              ),
              onPressed: () {
                final now = DateTime.now();
                _start.setValue(DateTime(now.year, now.month, 1));
                _end.setValue(DateTime(now.year, now.month + 1, 0));
                setState(() {});
              },
              child: const Text('Set to this month'),
            ),
          ),
        ],
      ),
    );
  }
}
