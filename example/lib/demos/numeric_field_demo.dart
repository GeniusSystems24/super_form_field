// ============================================================
// example/lib/demos/numeric_field_demo.dart
// ------------------------------------------------------------
// SuperNumericFormField in a Journal-Entry style context: a debit amount with a
// SAR unit, a stock quantity with a stepper and min/max, an exchange rate with
// decimals, and a percentage. Shows grouped-while-idle / raw-while-editing.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart'
    hide SectionCard, SuperMarker;

import 'demo_scaffold.dart';

class NumericFieldDemo extends StatefulWidget {
  const NumericFieldDemo({super.key});

  @override
  State<NumericFieldDemo> createState() => _NumericFieldDemoState();
}

class _NumericFieldDemoState extends State<NumericFieldDemo> {
  bool _force = false;
  num? _amount = 5240;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return DemoPage(
      eyebrow: 'Ledger • Opening Journal Entry',
      title: 'Super Numeric Field',
      children: [
        SectionCard(
          title: 'Amounts',
          subtitle: 'Currency and quantity with mathematical constraints',
          marker: SuperMarker.ledger,
          child: Column(
            children: [
              SuperNumericFormField(
                decoration: const InputDecoration(
                  labelText: 'Debit Amount',
                  prefixText: 'SAR',
                  helperText: '↑/↓ step by 1 · PageUp/PageDown step by 100 · grouped while idle.',
                ),
                required: true,
                decimals: 2,
                min: 0,
                allowNegative: false,
                initialValue: _amount,
                onChanged: (v) => _amount = v,
                largeStep: 100,
                forceError: _force,
              ),
              SizedBox(height: SuperThemeData.of(context).tokens.space6),
              SuperNumericFormField(
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  helperText: 'Focus and press ↑/↓ (±1) or PageUp/PageDown (±10).',
                ),
                required: true,
                min: 1,
                max: 9999,
                step: 1,
                largeStep: 10,
                initialValue: 12,
                forceError: _force,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Rates',
          subtitle: 'Decimal precision and percentage units',
          marker: SuperMarker.ledger,
          child: Column(
            children: [
              const SuperNumericFormField(
                decoration: InputDecoration(
                  labelText: 'Exchange Rate',
                  prefixText: r'$',
                ),
                decimals: 4,
                step: 0.0001,
                min: 0,
                allowNegative: false,
                initialValue: 3.7512,
              ),
              SizedBox(height: SuperThemeData.of(context).tokens.space6),
              const SuperNumericFormField(
                decoration: InputDecoration(
                  labelText: 'Tax Rate',
                  suffixText: '%',
                ),
                decimals: 1,
                min: 0,
                max: 100,
                step: 0.5,
                initialValue: 15,
              ),
            ],
          ),
        ),
        Row(
          children: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SuperThemeData.of(context).tokens.radiusControl)),
              ),
              onPressed: () => setState(() => _force = true),
              child: const Text('Validate'),
            ),
            SizedBox(width: SuperThemeData.of(context).tokens.space3),
            TextButton(
              onPressed: () => setState(() => _force = false),
              child: Text('Reset', style: TextStyle(color: t.fg2)),
            ),
          ],
        ),
      ],
    );
  }
}
