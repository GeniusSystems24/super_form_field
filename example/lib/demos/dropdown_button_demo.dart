import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart'
    hide SuperSectionCard, SuperMarker;

import 'demo_scaffold.dart';

/// Gallery examples for [SuperDropdownButton],
/// [SuperDropdownButtonFormField], and [SuperDropdownEditingController].
class DropdownButtonDemo extends StatefulWidget {
  const DropdownButtonDemo({super.key});

  @override
  State<DropdownButtonDemo> createState() => _DropdownButtonDemoState();
}

class _DropdownButtonDemoState extends State<DropdownButtonDemo> {
  final _formKey = GlobalKey<FormState>();
  final _statusController = SuperDropdownEditingController<String>(
    initialValue: 'active',
  );
  final _warehouseController = SuperDropdownEditingController<String>();
  String? _warehouse;

  static const _statusOptions = [
    SuperOption(
      value: 'active',
      label: 'Active',
      icon: Icons.check_circle_outline,
    ),
    SuperOption(
      value: 'hold',
      label: 'On hold',
      icon: Icons.pause_circle_outline,
    ),
    SuperOption(value: 'closed', label: 'Closed', icon: Icons.archive_outlined),
  ];

  static const _warehouseOptions = [
    SuperOption(value: 'riyadh', label: 'Riyadh Central', description: 'WH-01'),
    SuperOption(value: 'jeddah', label: 'Jeddah', description: 'WH-02'),
    SuperOption(
      value: 'legacy',
      label: 'Legacy warehouse',
      description: 'Unavailable',
      disabled: true,
    ),
  ];

  @override
  void dispose() {
    _statusController.dispose();
    _warehouseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      eyebrow: 'Controls • Selection',
      title: 'Dropdown Buttons',
      children: [
        SuperSectionCard(
          title: 'Editing controller',
          subtitle: 'Typed selection with programmatic value changes',
          marker: SuperMarker.identity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SuperDropdownButton<String>(
                controller: _statusController,
                options: _statusOptions,
                decoration: const InputDecoration(
                  hintText: 'Select status…',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                onChanged: (_) {},
              ),
              SizedBox(height: SuperThemeData.of(context).spacing.space3),
              Wrap(
                spacing: SuperThemeData.of(context).spacing.space2,
                runSpacing: SuperThemeData.of(context).spacing.space2,
                children: [
                  OutlinedButton(
                    onPressed: () => _statusController.setValue('hold'),
                    child: const Text('Set On hold'),
                  ),
                  OutlinedButton(
                    onPressed: _statusController.clear,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
        SuperSectionCard(
          title: 'Form field',
          subtitle: 'Controller, validation, save, reset, and disabled options',
          marker: SuperMarker.ledger,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SuperDropdownButtonFormField<String>(
                  allowFixed: true,
                  controller: _warehouseController,
                  options: _warehouseOptions,
                  required: true,
                  decoration: const InputDecoration(
                    labelText: 'Warehouse',
                    hintText: 'Choose a warehouse…',
                    helperText: 'Legacy locations remain visible but disabled.',
                  ),
                  onChanged: (value) => _warehouse = value,
                  onSaved: (value) => _warehouse = value,
                ),
                SizedBox(height: SuperThemeData.of(context).spacing.space4),
                Wrap(
                  spacing: SuperThemeData.of(context).spacing.space2,
                  runSpacing: SuperThemeData.of(context).spacing.space2,
                  children: [
                    FilledButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Saved: ${_warehouse ?? '-'}'),
                            ),
                          );
                        }
                      },
                      child: const Text('Validate and save'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        _formKey.currentState!.reset();
                        _warehouse = null;
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
