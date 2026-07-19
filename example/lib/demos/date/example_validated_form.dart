// ============================================================
// example/lib/demos/date/example_validated_form.dart
// ------------------------------------------------------------
// EXAMPLE 3 — Validated, bilingual, submit-sweep.
// A required date with a minDate bound plus a custom validator (no weekends),
// shown next to an Arabic-faced mirror. Validation stays silent until first blur
// or the Validate button forces every badge on via forceError; onValidity
// aggregates the field error for the submit gate.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart' hide SectionCard;

import '../demo_scaffold.dart';

class DateValidatedFormExample extends StatefulWidget {
  const DateValidatedFormExample({super.key});

  @override
  State<DateValidatedFormExample> createState() => _DateValidatedFormExampleState();
}

class _DateValidatedFormExampleState extends State<DateValidatedFormExample> {
  bool _force = false;
  String? _error;

  // Custom validator: reject weekends (Fri/Sat in the GeniusLink locale).
  String? _noWeekend(DateTime? v) {
    if (v == null) return null;
    if (v.weekday == DateTime.friday || v.weekday == DateTime.saturday) {
      return 'Pick a working day (Sun–Thu)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final valid = _error == null;
    return SectionCard(
      title: '3 · Validated',
      subtitle: 'Required + min bound + custom rule, silent until blur or submit',
      marker: Marker.notes,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BilingualRow(
            english: SuperDateFormField(
              label: 'Value Date',
              required: true,
              minDate: DateTime(2024, 1, 1),
              validators: [_noWeekend],
              forceError: _force,
              onValidity: (e) => setState(() => _error = e),
            ),
            arabic: const SuperDateFormField(
              label: 'تاريخ القيمة',
              arabic: true,
            ),
          ),
          SizedBox(height: SuperThemeData.of(context).tokens.space6),
          Row(
            children: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SuperThemeData.of(context).tokens.radiusControl)),
                ),
                onPressed: () => setState(() => _force = true),
                child: const Text('Validate'),
              ),
              SizedBox(width: SuperThemeData.of(context).tokens.space3),
              TextButton(
                onPressed: () => setState(() => _force = false),
                child: Text('Reset', style: TextStyle(color: t.fg2)),
              ),
              SizedBox(width: SuperThemeData.of(context).tokens.space4),
              if (_force)
                Text(
                  valid ? 'READY TO POST' : 'FIX 1 FIELD',
                  style: SuperText.label.copyWith(
                    color: valid ? SuperThemeData.of(context).tokens.success : Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
