// ============================================================
// example/lib/demos/multi_select_field_demo.dart
// ------------------------------------------------------------
// SuperMultiSelectFormField in realistic ERP context: a required tags picker
// (chips + searchable menu), a capped permissions picker (max 3), and a
// "Validate" sweep that force-shows every error badge.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart' hide SectionCard;

import 'demo_scaffold.dart';

class MultiSelectFieldDemo extends StatefulWidget {
  const MultiSelectFieldDemo({super.key});

  @override
  State<MultiSelectFieldDemo> createState() => _MultiSelectFieldDemoState();
}

class _MultiSelectFieldDemoState extends State<MultiSelectFieldDemo> {
  bool _force = false;

  static const _tags = [
    SuperOption(value: 'recurring', label: 'Recurring'),
    SuperOption(value: 'intercompany', label: 'Intercompany'),
    SuperOption(value: 'reconciled', label: 'Reconciled'),
    SuperOption(value: 'audited', label: 'Audited'),
    SuperOption(value: 'fx', label: 'FX Adjustment'),
    SuperOption(value: 'accrual', label: 'Accrual'),
    SuperOption(value: 'deferred', label: 'Deferred'),
  ];

  static const _permissions = [
    SuperOption(value: 'post', label: 'Post entries', description: 'Create & submit journals'),
    SuperOption(value: 'approve', label: 'Approve', description: 'Approve pending entries'),
    SuperOption(value: 'reverse', label: 'Reverse', description: 'Reverse posted entries'),
    SuperOption(value: 'export', label: 'Export', description: 'Download ledgers'),
    SuperOption(value: 'admin', label: 'Administer', description: 'Manage the chart of accounts'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final cs = Theme.of(context).colorScheme;
    return DemoPage(
      eyebrow: 'Journal • Tagging & Access',
      title: 'Super Multi-Select Field',
      children: [
        SectionCard(
          title: 'Tags',
          subtitle: 'Classify this entry — pick one or more',
          marker: Marker.notes,
          child: SuperMultiSelectFormField<String>(
            label: 'Entry Tags',
            required: true,
            placeholder: 'Add tags…',
            searchable: true,
            initialValue: const ['recurring'],
            options: _tags,
            forceError: _force,
          ),
        ),
        SectionCard(
          title: 'Role Permissions',
          subtitle: 'Grant up to three permissions for this role',
          marker: Marker.identity,
          child: SuperMultiSelectFormField<String>(
            label: 'Permissions',
            required: true,
            placeholder: 'Select permissions…',
            minSelections: 1,
            maxSelections: 3,
            options: _permissions,
            hint: 'A role may hold at most three permissions.',
            forceError: _force,
          ),
        ),
        Row(
          children: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SuperTokens.radiusControl)),
              ),
              onPressed: () => setState(() => _force = true),
              child: const Text('Validate'),
            ),
            const SizedBox(width: SuperTokens.space3),
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
