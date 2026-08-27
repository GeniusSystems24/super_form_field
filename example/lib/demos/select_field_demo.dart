// ============================================================
// example/lib/demos/select_field_demo.dart
// ------------------------------------------------------------
// SuperSelectFormField in realistic ERP context: a required account-type
// picker, a searchable currency picker, a cost-center picker with descriptions
// and a disabled option, plus a "Validate" sweep that force-shows every error.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
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
    'asset',
    'liability',
    'equity',
    'revenue',
    'expense',
  ];

  static const _arabicAccountTypes = [
    'asset',
    'liability',
    'equity',
    'revenue',
    'expense',
  ];

  static const _currencies = ['SAR', 'USD', 'EUR', 'GBP', 'AED', 'EGP', 'JPY'];

  static const _costCenters = ['cc-100', 'cc-200', 'cc-300', 'cc-900'];

  static SuperOption<String> _accountTypeOption(
    List<String> items,
    int index,
    String item,
  ) => SuperOption(value: item, label: _titleCase(item), icon: SffIcons.hash);

  static SuperOption<String> _arabicAccountTypeOption(
    List<String> items,
    int index,
    String item,
  ) {
    final label = switch (item) {
      'asset' => 'أصول',
      'liability' => 'التزامات',
      'equity' => 'حقوق ملكية',
      'revenue' => 'إيرادات',
      'expense' => 'مصروفات',
      _ => item,
    };
    return SuperOption(value: item, label: label);
  }

  static SuperOption<String> _currencyOption(
    List<String> items,
    int index,
    String item,
  ) {
    return switch (item) {
      'SAR' => const SuperOption(
        value: 'SAR',
        label: 'SAR — Saudi Riyal',
        description: 'ر.س',
      ),
      'USD' => const SuperOption(
        value: 'USD',
        label: 'USD — US Dollar',
        description: r'$',
      ),
      'EUR' => const SuperOption(
        value: 'EUR',
        label: 'EUR — Euro',
        description: '€',
      ),
      'GBP' => const SuperOption(
        value: 'GBP',
        label: 'GBP — British Pound',
        description: '£',
      ),
      'AED' => const SuperOption(
        value: 'AED',
        label: 'AED — UAE Dirham',
        description: 'د.إ',
      ),
      'EGP' => const SuperOption(
        value: 'EGP',
        label: 'EGP — Egyptian Pound',
        description: 'ج.م',
      ),
      'JPY' => const SuperOption(
        value: 'JPY',
        label: 'JPY — Japanese Yen',
        description: '¥',
      ),
      _ => SuperOption(value: item, label: item),
    };
  }

  static SuperOption<String> _costCenterOption(
    List<String> items,
    int index,
    String item,
  ) {
    return switch (item) {
      'cc-100' => const SuperOption(
        value: 'cc-100',
        label: 'Operations',
        description: 'CC-100',
      ),
      'cc-200' => const SuperOption(
        value: 'cc-200',
        label: 'Sales & Marketing',
        description: 'CC-200',
      ),
      'cc-300' => const SuperOption(
        value: 'cc-300',
        label: 'Research',
        description: 'CC-300',
      ),
      'cc-900' => const SuperOption(
        value: 'cc-900',
        label: 'Archived (locked)',
        description: 'CC-900',
        disabled: true,
      ),
      _ => SuperOption(value: item, label: item),
    };
  }

  static String _titleCase(String value) =>
      value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return DemoPage(
      eyebrow: 'Accounts • Classification',
      title: 'Super Select Field',
      children: [
        SuperSectionCard1(
          title: 'Classification',
          subtitle: 'Pick the account type and reporting currency',
          accentColor: SuperMarker.identity.resolve(context.superTheme.tokens),
          child: Column(
            children: [
              BilingualRow(
                english: SuperSelectFormField<String>(
                  allowFixed: true,
                  decoration: const InputDecoration(
                    labelText: 'Account Type',
                    hintText: 'Choose a type…',
                    prefixIcon: Icon(SffIcons.hash),
                  ),
                  required: true,
                  sources: const [
                    SuperSelectListSource<String>(items: _accountTypes),
                  ],
                  optionBuilder: _accountTypeOption,
                  forceError: _force,
                ),
                arabic: SuperSelectFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'نوع الحساب',
                    hintText: 'اختر النوع…',
                  ),
                  required: true,
                  arabic: true,
                  sources: const [
                    SuperSelectListSource<String>(items: _arabicAccountTypes),
                  ],
                  optionBuilder: _arabicAccountTypeOption,
                  forceError: _force,
                ),
              ),
              SizedBox(height: SuperThemeData.of(context).spacing.space6),
              SuperSelectFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Reporting Currency',
                  hintText: 'Search currencies…',
                ),
                required: true,
                searchable: true,
                searchHint: 'Type a code or name…',
                clearable: true,
                initialValue: 'SAR',
                sources: const [
                  SuperSelectListSource<String>(items: _currencies),
                ],
                optionBuilder: _currencyOption,
                forceError: _force,
              ),
            ],
          ),
        ),
        SuperSectionCard1(
          title: 'Allocation',
          subtitle: 'Assign a cost center (some are locked)',
          accentColor: SuperMarker.ledger.resolve(context.superTheme.tokens),
          child: const SuperSelectFormField<String>(
            decoration: InputDecoration(
              labelText: 'Cost Center',
              hintText: 'Optional…',
              helperText: 'Locked centers cannot be selected.',
            ),
            clearable: true,
            sources: [SuperSelectListSource<String>(items: _costCenters)],
            optionBuilder: _costCenterOption,
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
