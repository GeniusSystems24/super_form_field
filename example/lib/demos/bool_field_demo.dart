// ============================================================
// example/lib/demos/bool_field_demo.dart
// ------------------------------------------------------------
// SuperBoolFormField in realistic ERP context: an Active status toggle, a
// posting-allowed toggle, a bilingual pair, and a checkbox acknowledgement with
// a mustBeTrue gate — plus a "Validate" sweep.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart' hide SectionCard;

import 'demo_scaffold.dart';

class BoolFieldDemo extends StatefulWidget {
  const BoolFieldDemo({super.key});

  @override
  State<BoolFieldDemo> createState() => _BoolFieldDemoState();
}

class _BoolFieldDemoState extends State<BoolFieldDemo> {
  bool _force = false;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return DemoPage(
      eyebrow: 'Accounts • Status & Flags',
      title: 'Super Bool Field',
      children: [
        SectionCard(
          title: 'Status Flags',
          subtitle: 'Toggle account behaviour',
          marker: Marker.identity,
          child: Column(
            children: [
              const BilingualRow(
                english: SuperBoolFormField(
                  label: 'Account Status',
                  initialValue: true,
                  enabledLabel: 'Active',
                  disabledLabel: 'Inactive',
                ),
                arabic: SuperBoolFormField(
                  label: 'حالة الحساب',
                  initialValue: true,
                  arabic: true,
                  enabledLabel: 'مفعّل',
                  disabledLabel: 'متوقف',
                ),
              ),
              SizedBox(height: SuperThemeData.of(context).tokens.space6),
              const SuperBoolFormField(
                label: 'Allow Manual Posting',
                enabledLabel: 'Manual journals allowed',
                disabledLabel: 'System postings only',
                hint: 'When off, only automated integrations may post to this account.',
              ),
              SizedBox(height: SuperThemeData.of(context).tokens.space6),
              const SuperBoolFormField(
                label: 'Reconciliation Required',
                style: SuperBoolStyle.checkbox,
                title: 'Require monthly reconciliation for this account',
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Compliance',
          subtitle: 'A required acknowledgement gate',
          marker: Marker.notes,
          child: SuperBoolFormField(
            label: 'Confirmation',
            required: true,
            style: SuperBoolStyle.checkbox,
            title: 'I confirm these account details are accurate and approved.',
            mustBeTrue: true,
            mustBeTrueMessage: 'You must confirm before saving.',
            forceError: _force,
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
