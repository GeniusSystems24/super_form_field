// ============================================================
// example/lib/demos/select_sources_demo.dart
// ------------------------------------------------------------
// SuperSelectFormField source examples for 1.15.0:
//   1) local raw values through SuperSelectSources.list
//   2) query-aware raw values through SuperSelectSources.async
//   3) optionBuilder maps raw values to SuperOption metadata
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:super_form_field/super_form_field.dart';

import 'demo_scaffold.dart';

class SelectSourcesDemo extends StatelessWidget {
  const SelectSourcesDemo({super.key});

  static final _localSource = SuperSelectSources.list<String>(
    ['retail', 'wholesale', 'internal'],
  );

  static SuperOption<String> _customerTypeOption(
    List<String> items,
    int index,
    String item,
  ) {
    return switch (item) {
      'retail' => const SuperOption(
        value: 'retail',
        label: 'Retail customer',
        description: 'Immediate counter sales',
        icon: SffIcons.user,
      ),
      'wholesale' => const SuperOption(
        value: 'wholesale',
        label: 'Wholesale customer',
        description: 'Bulk and contract pricing',
        icon: SffIcons.hash,
      ),
      'internal' => const SuperOption(
        value: 'internal',
        label: 'Internal account',
        description: 'Company departments',
        icon: SffIcons.fileText,
      ),
      _ => SuperOption(value: item, label: item),
    };
  }

  static Future<List<String>> _loadWarehouses(
    BuildContext context,
    String query,
  ) async {
    // Replace this delay with a repository/API request in production.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return const ['sanaa-main', 'aden-port', 'taiz-east'];
  }

  static final _remoteSource = SuperSelectSources.async<String>(
    _loadWarehouses,
  );

  static SuperOption<String> _warehouseOption(
    List<String> items,
    int index,
    String item,
  ) {
    return switch (item) {
      'sanaa-main' => const SuperOption(
        value: 'sanaa-main',
        label: 'Sana’a Main Warehouse',
        description: 'WH-001',
        icon: SffIcons.hash,
      ),
      'aden-port' => const SuperOption(
        value: 'aden-port',
        label: 'Aden Port Warehouse',
        description: 'WH-002',
        icon: SffIcons.hash,
      ),
      'taiz-east' => const SuperOption(
        value: 'taiz-east',
        label: 'Taiz East Warehouse',
        description: 'WH-003',
        icon: SffIcons.hash,
      ),
      _ => SuperOption(value: item, label: item),
    };
  }

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      eyebrow: 'Data • Sources',
      title: 'Select Sources',
      children: [
        SuperSectionCard1(
          title: 'List source',
          subtitle: 'Map local raw values with optionBuilder',
          accentColor: SuperMarker.identity.resolve(context.superTheme.tokens),
          child: SuperSelectFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Customer type',
              hintText: 'Choose a customer type…',
              helperText: 'Loaded from an in-memory raw-value source.',
            ),
            searchable: false,
            clearable: true,
            source: _localSource,
            optionBuilder: _customerTypeOption,
          ),
        ),
        SuperSectionCard1(
          title: 'Remote source',
          subtitle: 'Load raw values asynchronously, then map metadata',
          accentColor: SuperMarker.ledger.resolve(context.superTheme.tokens),
          child: SuperSelectFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Warehouse',
              hintText: 'Choose a warehouse…',
              helperText: 'The example simulates a remote request.',
            ),
            searchable: true,
            clearable: true,
            source: _remoteSource,
            optionBuilder: _warehouseOption,
          ),
        ),
      ],
    );
  }
}
