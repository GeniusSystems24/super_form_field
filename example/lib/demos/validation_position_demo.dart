// ============================================================
// example/lib/demos/validation_position_demo.dart
// ------------------------------------------------------------
// Demonstrates validation placement across suffix icons, under-box text,
// label-trailing icons, and responsive/package defaults.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:super_form_field/super_form_field.dart';

import 'demo_scaffold.dart';

class ValidationPositionDemo extends StatefulWidget {
  const ValidationPositionDemo({super.key});

  @override
  State<ValidationPositionDemo> createState() => _ValidationPositionDemoState();
}

class _ValidationPositionDemoState extends State<ValidationPositionDemo> {
  bool _force = true;
  ValidationPosition? _globalPosition;
  ValidationPosition _position = ValidationPosition.labelTrailing;

  @override
  void dispose() {
    if (SuperFormField.validationPosition == _globalPosition) {
      SuperFormField.validationPosition = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return DemoPage(
      eyebrow: 'Validation',
      title: 'Validation Position',
      children: [
        SuperSectionCard1(
          title: 'Global default',
          subtitle:
              'Leave it responsive, or set one package-wide validation position.',
          accentColor: SuperMarker.identity.resolve(context.superTheme.tokens),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: SuperThemeData.of(context).spacing.space2,
                runSpacing: SuperThemeData.of(context).spacing.space2,
                children: [
                  ChoiceChip(
                    label: const Text('Responsive'),
                    selected: _globalPosition == null,
                    onSelected: (_) => _setGlobalPosition(null),
                  ),
                  ChoiceChip(
                    label: const Text('Suffix'),
                    selected: _globalPosition == ValidationPosition.suffixIcon,
                    onSelected: (_) =>
                        _setGlobalPosition(ValidationPosition.suffixIcon),
                  ),
                  ChoiceChip(
                    label: const Text('Under'),
                    selected: _globalPosition == ValidationPosition.underBox,
                    onSelected: (_) =>
                        _setGlobalPosition(ValidationPosition.underBox),
                  ),
                  ChoiceChip(
                    label: const Text('Label'),
                    selected:
                        _globalPosition == ValidationPosition.labelTrailing,
                    onSelected: (_) =>
                        _setGlobalPosition(ValidationPosition.labelTrailing),
                  ),
                ],
              ),
              SizedBox(height: SuperThemeData.of(context).spacing.space6),
              SuperTextFormField(
                decoration: const InputDecoration(
                  labelText: 'Uses package default',
                  hintText: 'Leave empty and validate',
                  prefixIcon: Icon(SffIcons.user),
                ),
                required: true,
                forceError: _force,
              ),
            ],
          ),
        ),
        SuperSectionCard1(
          title: 'Explicit placement',
          subtitle:
              'Switch the validation surface without changing validators.',
          accentColor: SuperMarker.ledger.resolve(context.superTheme.tokens),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<ValidationPosition>(
                segments: const [
                  ButtonSegment(
                    value: ValidationPosition.suffixIcon,
                    icon: Icon(Icons.input_rounded),
                    label: Text('Suffix'),
                  ),
                  ButtonSegment(
                    value: ValidationPosition.underBox,
                    icon: Icon(Icons.short_text_rounded),
                    label: Text('Under'),
                  ),
                  ButtonSegment(
                    value: ValidationPosition.labelTrailing,
                    icon: Icon(Icons.label_important_outline_rounded),
                    label: Text('Label'),
                  ),
                ],
                selected: {_position},
                onSelectionChanged: (value) =>
                    setState(() => _position = value.single),
              ),
              SizedBox(height: SuperThemeData.of(context).spacing.space6),
              SuperTextFormField(
                decoration: const InputDecoration(
                  labelText: 'Account name',
                  hintText: 'Required field',
                  helperText: 'The selected placement controls this error.',
                  prefixIcon: Icon(SffIcons.user),
                  counterText: '0/40',
                ),
                required: true,
                minLength: 3,
                forceError: _force,
                validationPosition: _position,
                helpIcon: Tooltip(
                  message: 'Used in account reports and lookup lists.',
                  child: Icon(
                    Icons.help_outline_rounded,
                    size: 18,
                    color: t.fg4,
                  ),
                ),
              ),
            ],
          ),
        ),
        SuperSectionCard1(
          title: 'All modes',
          subtitle: 'Three text fields with the same validation rule.',
          accentColor: SuperMarker.notes.resolve(context.superTheme.tokens),
          child: Column(
            children: [
              _ExampleField(
                label: 'Suffix icon',
                icon: Icons.input_rounded,
                position: ValidationPosition.suffixIcon,
                force: _force,
              ),
              SizedBox(height: SuperThemeData.of(context).spacing.space6),
              _ExampleField(
                label: 'Under box',
                icon: Icons.short_text_rounded,
                position: ValidationPosition.underBox,
                force: _force,
              ),
              SizedBox(height: SuperThemeData.of(context).spacing.space6),
              _ExampleField(
                label: 'Label trailing',
                icon: Icons.label_important_outline_rounded,
                position: ValidationPosition.labelTrailing,
                force: _force,
              ),
            ],
          ),
        ),
        SuperSectionCard1(
          title: 'Other fields',
          subtitle: 'The same placement API across form controls.',
          accentColor: SuperMarker.ledger.resolve(context.superTheme.tokens),
          child: _OtherFieldsPreview(position: _position, force: _force),
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

  void _setGlobalPosition(ValidationPosition? position) {
    setState(() => _globalPosition = position);
    SuperFormField.validationPosition = position;
  }
}

class _OtherFieldsPreview extends StatelessWidget {
  const _OtherFieldsPreview({required this.position, required this.force});

  final ValidationPosition position;
  final bool force;

  static const _options = [
    SuperOption(value: 'cash', label: 'Cash'),
    SuperOption(value: 'bank', label: 'Bank'),
  ];

  Widget _help(BuildContext context) {
    return Tooltip(
      message: 'Configured by the shared validation placement API.',
      child: Icon(
        Icons.help_outline_rounded,
        size: 18,
        color: context.sffTheme.fg4,
      ),
    );
  }

  InputDecoration _decoration(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      hintText: 'Required',
      prefixIcon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;
    return Column(
      children: [
        SuperNumericFormField(
          decoration: _decoration(context, 'Amount', Icons.pin_rounded),
          required: true,
          forceError: force,
          validationPosition: position,
          helpIcon: _help(context),
        ),
        SizedBox(height: spacing.space6),
        SuperDateFormField(
          decoration: _decoration(context, 'Posting date', Icons.event_rounded),
          required: true,
          forceError: force,
          validationPosition: position,
          helpIcon: _help(context),
        ),
        SizedBox(height: spacing.space6),
        SuperSelectFormField<String>(
          decoration: _decoration(
            context,
            'Account type',
            Icons.account_balance_outlined,
          ),
          sources: const [
            SuperSelectListSource(items: ['cash', 'bank']),
          ],
          optionBuilder: (items, index, item) =>
              SuperOption(value: item, label: item == 'cash' ? 'Cash' : 'Bank'),
          required: true,
          forceError: force,
          validationPosition: position,
          helpIcon: _help(context),
        ),
        SizedBox(height: spacing.space6),
        SuperMultiSelectFormField<String>(
          decoration: _decoration(
            context,
            'Permissions',
            Icons.checklist_rounded,
          ),
          options: _options,
          required: true,
          forceError: force,
          validationPosition: position,
          helpIcon: _help(context),
        ),
        SizedBox(height: spacing.space6),
        SuperOTPFormField(
          decoration: _decoration(
            context,
            'Approval code',
            Icons.password_rounded,
          ),
          required: true,
          forceError: force,
          validationPosition: position,
          helpIcon: _help(context),
        ),
        SizedBox(height: spacing.space6),
        SuperAttachmentFormField(
          decoration: _decoration(
            context,
            'Supporting files',
            Icons.attach_file_rounded,
          ),
          required: true,
          forceError: force,
          validationPosition: position,
          helpIcon: _help(context),
        ),
        SizedBox(height: spacing.space6),
        SuperBoolFormField(
          decoration: const InputDecoration(labelText: 'Confirmed'),
          mustBeTrue: true,
          forceError: force,
          validationPosition: position,
          helpIcon: _help(context),
        ),
        SizedBox(height: spacing.space6),
        SuperChoiceFormField<String>(
          decoration: const InputDecoration(labelText: 'Payment method'),
          options: _options,
          required: true,
          forceError: force,
          validationPosition: position,
          helpIcon: _help(context),
        ),
        SizedBox(height: spacing.space6),
        SuperRangeDateFormField(
          decoration: const InputDecoration(labelText: 'Reporting range'),
          required: true,
          forceError: force,
          validationPosition: position,
          helpIcon: _help(context),
        ),
        SizedBox(height: spacing.space6),
        SuperDropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Dropdown status'),
          options: _options,
          onChanged: (_) {},
          required: true,
          autovalidateMode: force
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          validationPosition: position,
          helpIcon: _help(context),
        ),
        SizedBox(height: spacing.space6),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SuperPopupMenuButton<String>(
            decoration: InputDecoration(
              labelText: 'Popup actions',
              errorText: force ? 'Choose an action' : null,
            ),
            options: _options,
            tooltip: 'Open actions',
            validationPosition: position,
            helpIcon: _help(context),
          ),
        ),
      ],
    );
  }
}

class _ExampleField extends StatelessWidget {
  const _ExampleField({
    required this.label,
    required this.icon,
    required this.position,
    required this.force,
  });

  final String label;
  final IconData icon;
  final ValidationPosition position;
  final bool force;

  @override
  Widget build(BuildContext context) {
    return SuperTextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter at least 3 characters',
        prefixIcon: Icon(icon),
      ),
      required: true,
      minLength: 3,
      forceError: force,
      validationPosition: position,
    );
  }
}
