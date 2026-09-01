// ============================================================
// example/lib/demos/autovalidate_mode_demo.dart
// ------------------------------------------------------------
// Demonstrates how Super fields inherit Form.autovalidateMode unless a field
// supplies its own autovalidateMode.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:super_form_field/super_form_field.dart';

import 'demo_scaffold.dart';

class AutovalidateModeDemo extends StatefulWidget {
  const AutovalidateModeDemo({super.key});

  @override
  State<AutovalidateModeDemo> createState() => _AutovalidateModeDemoState();
}

class _AutovalidateModeDemoState extends State<AutovalidateModeDemo> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _mode = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;
    final t = context.sffTheme;
    return DemoPage(
      eyebrow: 'Validation',
      title: 'Autovalidate Mode',
      children: [
        SuperSectionCard1(
          title: 'Form default',
          subtitle: 'Fields below inherit the selected Form autovalidate mode.',
          accentColor: SuperMarker.identity.resolve(context.superTheme.tokens),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<AutovalidateMode>(
                segments: const [
                  ButtonSegment(
                    value: AutovalidateMode.disabled,
                    icon: Icon(Icons.pause_circle_outline_rounded),
                    label: Text('Disabled'),
                  ),
                  ButtonSegment(
                    value: AutovalidateMode.always,
                    icon: Icon(Icons.running_with_errors_rounded),
                    label: Text('Always'),
                  ),
                  ButtonSegment(
                    value: AutovalidateMode.onUserInteraction,
                    icon: Icon(Icons.touch_app_rounded),
                    label: Text('On change'),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (value) =>
                    setState(() => _mode = value.single),
              ),
              SizedBox(height: spacing.space6),
              Form(
                key: _formKey,
                autovalidateMode: _mode,
                child: Column(
                  children: [
                    SuperTextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Account name',
                        hintText: 'Required with at least 3 characters',
                        prefixIcon: Icon(SffIcons.user),
                      ),
                      required: true,
                      minLength: 3,
                      validationPosition: ValidationPosition.underBox,
                    ),
                    SizedBox(height: spacing.space6),
                    const SuperNumericFormField(
                      decoration: InputDecoration(
                        labelText: 'Opening balance',
                        prefixText: 'SAR',
                      ),
                      required: true,
                      min: 1,
                      validationPosition: ValidationPosition.underBox,
                    ),
                    SizedBox(height: spacing.space6),
                    const SuperSelectFormField<String>(
                      decoration: InputDecoration(labelText: 'Account type'),
                      sources: [
                        SuperSelectListSource<String>(
                          items: ['asset', 'liability', 'revenue'],
                        ),
                      ],
                      optionBuilder: _optionBuilder,
                      required: true,
                      validationPosition: ValidationPosition.underBox,
                    ),
                    SizedBox(height: spacing.space6),
                    const SuperBoolFormField(
                      decoration: InputDecoration(
                        labelText: 'Approval',
                        hintText: 'I confirm the record is ready to post.',
                      ),
                      style: SuperBoolStyle.checkbox,
                      mustBeTrue: true,
                      mustBeTrueMessage: 'Approval is required.',
                      validationPosition: ValidationPosition.underBox,
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.space6),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => _formKey.currentState?.validate(),
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('Validate'),
                  ),
                  SizedBox(width: spacing.space3),
                  TextButton.icon(
                    onPressed: () => _formKey.currentState?.reset(),
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text('Reset', style: TextStyle(color: t.fg2)),
                  ),
                ],
              ),
            ],
          ),
        ),
        SuperSectionCard1(
          title: 'Field override',
          subtitle:
              'This field validates always, independent of the Form mode.',
          accentColor: SuperMarker.ledger.resolve(context.superTheme.tokens),
          child: SuperTextFormField(
            decoration: const InputDecoration(
              labelText: 'Immediate validation',
              hintText: 'This field sets autovalidateMode itself',
              helperText: 'Field-level values take precedence over the Form.',
            ),
            required: true,
            autovalidateMode: AutovalidateMode.always,
            validationPosition: ValidationPosition.underBox,
          ),
        ),
      ],
    );
  }
}

SuperOption<String> _optionBuilder(List<String> items, int index, String item) {
  final label = switch (item) {
    'asset' => 'Asset',
    'liability' => 'Liability',
    'revenue' => 'Revenue',
    _ => item,
  };
  return SuperOption(value: item, label: label);
}
