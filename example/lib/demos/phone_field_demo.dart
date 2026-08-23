// ============================================================
// example/lib/demos/phone_field_demo.dart
// ------------------------------------------------------------
// Dedicated SuperTextType.phone examples. Demonstrates the semantic phone
// keyboard, international characters, country-specific formatting and
// validation, autofill, submission, and FormState.save integration.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_form_field/super_form_field.dart'
    hide SuperSectionCard, SuperMarker;

import 'demo_scaffold.dart';

class PhoneFieldDemo extends StatefulWidget {
  const PhoneFieldDemo({super.key});

  @override
  State<PhoneFieldDemo> createState() => _PhoneFieldDemoState();
}

class _PhoneFieldDemoState extends State<PhoneFieldDemo> {
  final _formKey = GlobalKey<FormState>();
  final _internationalController = SuperTextFieldController();
  final _localController = SuperTextFieldController();

  String? _savedInternationalNumber;
  String? _savedYemenNumber;
  bool _forceError = false;

  static final _internationalPhoneCharacters = RegExp(r'[0-9+()\-\s]');
  static final _yemenMobilePattern = RegExp(
    r'^(?:70|71|73|77|78) \d{3} \d{4}$',
  );

  @override
  void dispose() {
    _internationalController.dispose();
    _localController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;
    setState(() => _forceError = !isValid);
    if (!isValid) return;

    _formKey.currentState?.save();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Phone numbers saved successfully.')),
    );
  }

  void _fillExamples() {
    _internationalController.setValue('+1 (415) 555-0132');
    _localController.setValue('77 123 4567');
    setState(() => _forceError = false);
  }

  void _clear() {
    _formKey.currentState?.reset();
    _internationalController.clear();
    _localController.clear();
    setState(() {
      _savedInternationalNumber = null;
      _savedYemenNumber = null;
      _forceError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;
    final theme = context.sffTheme;

    return DemoPage(
      eyebrow: 'Text Field • Phone Input',
      title: 'Phone Field Examples',
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SuperSectionCard(
                title: 'International number',
                subtitle: 'Phone keyboard with common international characters',
                marker: SuperMarker.identity,
                child: SuperTextFormField(
                  allowFixed: true,
                  controller: _internationalController,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    hintText: 'e.g. +1 (415) 555-0132',
                    helperText:
                        'Accepts digits, spaces, parentheses, +, and hyphens.',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  type: SuperTextType.phone,
                  required: true,
                  clearable: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      _internationalPhoneCharacters,
                    ),
                  ],
                  autofillHints: const [AutofillHints.telephoneNumber],
                  textInputAction: TextInputAction.next,
                  keyboardAppearance: Theme.of(context).brightness,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  onSaved: (value) => _savedInternationalNumber = value,
                  forceError: _forceError,
                ),
              ),
              SizedBox(height: spacing.space8),
              SuperSectionCard(
                title: 'Country-specific rules',
                subtitle:
                    'Compose the phone type with a prefix, mask, and pattern',
                marker: SuperMarker.identity,
                child: SuperTextFormField(
                  controller: _localController,
                  decoration: const InputDecoration(
                    labelText: 'Yemen mobile number',
                    hintText: '7XX XXX XXX',
                    helperText: 'Valid prefixes: 70, 71, 73, 77, or 78.',
                    prefixText: '+967 ',
                    prefixIcon: Icon(Icons.phone_android_rounded),
                  ),
                  type: SuperTextType.phone,
                  required: true,
                  clearable: true,
                  mask: '## ### ####',
                  pattern: _yemenMobilePattern,
                  patternMessage: 'Enter a valid Yemeni mobile number.',
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  textInputAction: TextInputAction.done,
                  keyboardAppearance: Theme.of(context).brightness,
                  onFieldSubmitted: (_) => _submit(),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  onUnmaskedSaved: (value) =>
                      _savedYemenNumber = value == null ? null : '+967$value',
                  forceError: _forceError,
                ),
              ),
              SizedBox(height: spacing.space8),
              SuperSectionCard(
                title: 'Form result',
                subtitle: 'Values received through FormState.save()',
                marker: SuperMarker.notes,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SavedValue(
                      label: 'International',
                      value: _savedInternationalNumber,
                    ),
                    SizedBox(height: spacing.space3),
                    _SavedValue(label: 'Yemen', value: _savedYemenNumber),
                  ],
                ),
              ),
              SizedBox(height: spacing.space6),
              Wrap(
                spacing: spacing.space3,
                runSpacing: spacing.space3,
                children: [
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Validate & save'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _fillExamples,
                    icon: const Icon(Icons.auto_fix_high_outlined),
                    label: const Text('Fill examples'),
                  ),
                  TextButton.icon(
                    onPressed: _clear,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text('Reset', style: TextStyle(color: theme.fg2)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SavedValue extends StatelessWidget {
  const _SavedValue({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = context.sffTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(
            label,
            style: context.superTextTheme.caption.copyWith(color: theme.fg3),
          ),
        ),
        Expanded(
          child: SelectableText(
            value?.isNotEmpty == true ? value! : 'Not saved yet',
            style: context.superTextTheme.body.copyWith(
              color: value?.isNotEmpty == true ? theme.fg1 : theme.fg4,
            ),
          ),
        ),
      ],
    );
  }
}
