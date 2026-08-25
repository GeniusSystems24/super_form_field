// ============================================================
// example/lib/demos/bool_field_demo.dart
// ------------------------------------------------------------
// SuperBoolFormField in realistic ERP context: an Active status toggle, a
// posting-allowed toggle, a bilingual pair, and a checkbox acknowledgement with
// a mustBeTrue gate — plus a "Validate" sweep.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart'
    hide SuperSectionCard1, SuperMarker;

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
        SuperSectionCard1(
          title: 'Status Flags',
          subtitle: 'Toggle account behaviour',
          accentColor: SuperMarker.identity.resolve(context.superTheme.tokens),
          child: Column(
            children: [
              const BilingualRow(
                english: SuperBoolFormField(
                  allowFixed: true,
                  decoration: InputDecoration(labelText: 'Account Status'),
                  initialValue: true,
                  enabledLabel: 'Active',
                  disabledLabel: 'Inactive',
                ),
                arabic: SuperBoolFormField(
                  decoration: InputDecoration(labelText: 'حالة الحساب'),
                  initialValue: true,
                  arabic: true,
                  enabledLabel: 'مفعّل',
                  disabledLabel: 'متوقف',
                ),
              ),
              SizedBox(height: SuperThemeData.of(context).spacing.space6),
              const SuperBoolFormField(
                decoration: InputDecoration(
                  labelText: 'Allow Manual Posting',
                  helperText:
                      'When off, only automated integrations may post to this account.',
                ),
                enabledLabel: 'Manual journals allowed',
                disabledLabel: 'System postings only',
              ),
              SizedBox(height: SuperThemeData.of(context).spacing.space6),
              const SuperBoolFormField(
                decoration: InputDecoration(
                  labelText: 'Reconciliation Required',
                  hintText: 'Require monthly reconciliation for this account',
                ),
                style: SuperBoolStyle.checkbox,
              ),
            ],
          ),
        ),
        SuperSectionCard1(
          title: 'Compliance',
          subtitle: 'A required acknowledgement gate',
          accentColor: SuperMarker.notes.resolve(context.superTheme.tokens),
          child: SuperBoolFormField(
            decoration: const InputDecoration(
              labelText: 'Confirmation',
              hintText:
                  'I confirm these account details are accurate and approved.',
            ),
            required: true,
            style: SuperBoolStyle.checkbox,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    SuperThemeData.of(context).spacing.radiusControl,
                  ),
                ),
              ),
              onPressed: () => setState(() => _force = true),
              child: const Text('Validate'),
            ),
            SizedBox(width: SuperThemeData.of(context).spacing.space3),
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
