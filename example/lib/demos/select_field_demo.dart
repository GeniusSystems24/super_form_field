// ============================================================
// example/lib/demos/select_field_demo.dart
// ------------------------------------------------------------
// SuperSelectFormField in realistic ERP context: a required account-type
// picker, a searchable currency picker, a cost-center picker with descriptions
// and a disabled option, plus a "Validate" sweep that force-shows every error.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart';

import 'demo_scaffold.dart';

class SelectFieldDemo extends StatefulWidget {
  const SelectFieldDemo({super.key});

  @override
  State<SelectFieldDemo> createState() => _SelectFieldDemoState();
}

class _SelectFieldDemoState extends State<SelectFieldDemo> {
  bool _force = false;

  static const _accountTypes = [
    SuperOption(value: 'asset', label: 'Asset', icon: SffIcons.hash),
    SuperOption(value: 'liability', label: 'Liability', icon: SffIcons.hash),
    SuperOption(value: 'equity', label: 'Equity', icon: SffIcons.hash),
    SuperOption(value: 'revenue', label: 'Revenue', icon: SffIcons.hash),
    SuperOption(value: 'expense', label: 'Expense', icon: SffIcons.hash),
  ];

  static const _currencies = [
    SuperOption(value: 'SAR', label: 'SAR — Saudi Riyal', description: 'ر.س'),
    SuperOption(value: 'USD', label: 'USD — US Dollar', description: r'$'),
    SuperOption(value: 'EUR', label: 'EUR — Euro', description: '€'),
    SuperOption(value: 'GBP', label: 'GBP — British Pound', description: '£'),
    SuperOption(value: 'AED', label: 'AED — UAE Dirham', description: 'د.إ'),
    SuperOption(value: 'EGP', label: 'EGP — Egyptian Pound', description: 'ج.م'),
    SuperOption(value: 'JPY', label: 'JPY — Japanese Yen', description: '¥'),
  ];

  static const _costCenters = [
    SuperOption(value: 'cc-100', label: 'Operations', description: 'CC-100'),
    SuperOption(value: 'cc-200', label: 'Sales & Marketing', description: 'CC-200'),
    SuperOption(value: 'cc-300', label: 'Research', description: 'CC-300'),
    SuperOption(value: 'cc-900', label: 'Archived (locked)', description: 'CC-900', disabled: true),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return DemoPage(
      eyebrow: 'Accounts • Classification',
      title: 'Super Select Field',
      children: [
        SectionCard(
          title: 'Classification',
          subtitle: 'Pick the account type and reporting currency',
          marker: SuperMarker.identity,
          child: Column(
            children: [
              BilingualRow(
                english: SuperSelectFormField<String>(
                  label: 'Account Type',
                  required: true,
                  placeholder: 'Choose a type…',
                  leadingIcon: SffIcons.hash,
                  options: _accountTypes,
                  forceError: _force,
                ),
                arabic: SuperSelectFormField<String>(
                  label: 'نوع الحساب',
                  required: true,
                  placeholder: 'اختر النوع…',
                  arabic: true,
                  options: const [
                    SuperOption(value: 'asset', label: 'أصول'),
                    SuperOption(value: 'liability', label: 'التزامات'),
                    SuperOption(value: 'equity', label: 'حقوق ملكية'),
                    SuperOption(value: 'revenue', label: 'إيرادات'),
                    SuperOption(value: 'expense', label: 'مصروفات'),
                  ],
                  forceError: _force,
                ),
              ),
              const SizedBox(height: SuperTokens.space6),
              SuperSelectFormField<String>(
                label: 'Reporting Currency',
                required: true,
                placeholder: 'Search currencies…',
                searchable: true,
                searchHint: 'Type a code or name…',
                clearable: true,
                initialValue: 'SAR',
                options: _currencies,
                forceError: _force,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Allocation',
          subtitle: 'Assign a cost center (some are locked)',
          marker: SuperMarker.ledger,
          child: const SuperSelectFormField<String>(
            label: 'Cost Center',
            placeholder: 'Optional…',
            clearable: true,
            options: _costCenters,
            hint: 'Locked centers cannot be selected.',
          ),
        ),
        Row(
          children: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: SuperTokens.accent,
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
