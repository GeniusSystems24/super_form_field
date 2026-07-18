// ============================================================
// example/lib/demos/choice_field_demo.dart
// ------------------------------------------------------------
// SuperChoiceFormField in realistic ERP context: a segmented status picker, a
// radio list for posting period, and a checkbox group for document types
// (min/max selections) — plus a "Validate" sweep.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart' hide SectionCard;

import 'demo_scaffold.dart';

class ChoiceFieldDemo extends StatefulWidget {
  const ChoiceFieldDemo({super.key});

  @override
  State<ChoiceFieldDemo> createState() => _ChoiceFieldDemoState();
}

class _ChoiceFieldDemoState extends State<ChoiceFieldDemo> {
  bool _force = false;

  static const _status = [
    SuperOption(value: 'draft', label: 'Draft'),
    SuperOption(value: 'posted', label: 'Posted'),
    SuperOption(value: 'void', label: 'Void'),
  ];

  static const _period = [
    SuperOption(value: 'current', label: 'Current period', description: 'Jun 2026 — open'),
    SuperOption(value: 'prior', label: 'Prior period', description: 'May 2026 — open'),
    SuperOption(value: 'adjust', label: 'Adjustment period', description: 'Year-end only'),
  ];

  static const _docs = [
    SuperOption(value: 'invoice', label: 'Invoice', description: 'Supplier or customer invoice'),
    SuperOption(value: 'receipt', label: 'Receipt', description: 'Proof of payment'),
    SuperOption(value: 'contract', label: 'Contract', description: 'Signed agreement'),
    SuperOption(value: 'memo', label: 'Internal memo', description: 'Approval note'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return DemoPage(
      eyebrow: 'Journal • Entry Options',
      title: 'Super Choice Field',
      children: [
        SectionCard(
          title: 'Entry State',
          subtitle: 'A segmented single-pick control',
          marker: Marker.identity,
          child: Column(
            children: [
              const SuperChoiceFormField<String>(
                label: 'Status',
                required: true,
                initialValue: ['draft'],
                options: _status,
              ),
              const SizedBox(height: SuperTokensData.defaultSpace6),
              SuperChoiceFormField<String>(
                label: 'Posting Period',
                required: true,
                style: SuperChoiceStyle.radio,
                options: _period,
                forceError: _force,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Supporting Documents',
          subtitle: 'Attach at least one document type (multi-pick)',
          marker: Marker.notes,
          child: SuperChoiceFormField<String>(
            label: 'Document Types',
            required: true,
            style: SuperChoiceStyle.checkbox,
            minSelections: 1,
            maxSelections: 3,
            options: _docs,
            hint: 'Pick one to three document types.',
            forceError: _force,
          ),
        ),
        Row(
          children: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SuperTokensData.defaultRadiusControl)),
              ),
              onPressed: () => setState(() => _force = true),
              child: const Text('Validate'),
            ),
            const SizedBox(width: SuperTokensData.defaultSpace3),
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
