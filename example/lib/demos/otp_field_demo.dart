// ============================================================
// example/lib/demos/otp_field_demo.dart
// ------------------------------------------------------------
// Dedicated SuperOTPFormField examples covering SMS autofill, completion,
// secure PIN display, alphanumeric codes, custom formatters, validation, and
// typed FormState.save integration.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_form_field/super_form_field.dart'
    hide SuperMarker, SuperSectionCard1;

import 'demo_scaffold.dart';

class OTPFieldDemo extends StatefulWidget {
  const OTPFieldDemo({super.key});

  @override
  State<OTPFieldDemo> createState() => _OTPFieldDemoState();
}

class _OTPFieldDemoState extends State<OTPFieldDemo> {
  final _formKey = GlobalKey<FormState>();
  final _smsController = SuperOTPFieldController();
  final _pinController = SuperOTPFieldController();
  final _backupController = SuperOTPFieldController();

  bool _forceError = false;
  String? _completedCode;
  String? _savedSMSCode;
  String? _savedPIN;
  String? _savedBackupCode;

  static final _backupCharacters = RegExp(r'[A-Za-z0-9]');

  @override
  void dispose() {
    _smsController.dispose();
    _pinController.dispose();
    _backupController.dispose();
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
      const SnackBar(content: Text('Verification codes saved successfully.')),
    );
  }

  void _fillExamples() {
    _smsController.setValue('482731');
    _pinController.setValue('9074');
    _backupController.setValue('GL24A7X9');
    setState(() => _forceError = false);
  }

  void _reset() {
    _formKey.currentState?.reset();
    setState(() {
      _forceError = false;
      _completedCode = null;
      _savedSMSCode = null;
      _savedPIN = null;
      _savedBackupCode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;
    final theme = context.sffTheme;

    return DemoPage(
      eyebrow: 'OTP Field • Verification Codes',
      title: 'OTP Field Examples',
      children: [
        AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SuperSectionCard1(
                  title: 'SMS verification code',
                  subtitle: 'Paste and one-time-code autofill with completion',
                  accentColor: SuperMarker.identity.resolve(context.superTheme.tokens),
                  child: SuperOTPFormField(
                    allowFixed: true,
                    controller: _smsController,
                    decoration: const InputDecoration(
                      labelText: 'Verification code',
                      hintText: 'Enter the code sent by SMS',
                      helperText: 'A six-digit code was sent to your phone.',
                      prefixIcon: Icon(Icons.sms_outlined),
                    ),
                    length: 6,
                    required: true,
                    showCounter: true,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    keyboardAppearance: Theme.of(context).brightness,
                    onCompleted: (value) {
                      setState(() => _completedCode = value);
                    },
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    onSaved: (value) => _savedSMSCode = value,
                    forceError: _forceError,
                  ),
                ),
                SizedBox(height: spacing.space8),
                SuperSectionCard1(
                  title: 'Secure transaction PIN',
                  subtitle: 'Four digits displayed with an obscuring character',
                  accentColor: SuperMarker.identity.resolve(context.superTheme.tokens),
                  child: SuperOTPFormField(
                    controller: _pinController,
                    decoration: const InputDecoration(
                      labelText: 'Transaction PIN',
                      helperText: 'The actual digits remain available to save.',
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    length: 4,
                    required: true,
                    obscureText: true,
                    autofillHints: null,
                    textInputAction: TextInputAction.next,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    onSaved: (value) => _savedPIN = value,
                    forceError: _forceError,
                  ),
                ),
                SizedBox(height: spacing.space8),
                SuperSectionCard1(
                  title: 'Alphanumeric backup code',
                  subtitle: 'Custom keyboard and formatter composition',
                  accentColor: SuperMarker.notes.resolve(context.superTheme.tokens),
                  child: SuperOTPFormField(
                    controller: _backupController,
                    decoration: const InputDecoration(
                      labelText: 'Backup code',
                      helperText: 'Letters are normalized to uppercase.',
                      prefixIcon: Icon(Icons.key_outlined),
                    ),
                    length: 8,
                    required: true,
                    digitsOnly: false,
                    keyboardType: TextInputType.text,
                    autofillHints: null,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(_backupCharacters),
                      TextInputFormatter.withFunction((_, newValue) {
                        return newValue.copyWith(
                          text: newValue.text.toUpperCase(),
                        );
                      }),
                    ],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    onSaved: (value) => _savedBackupCode = value,
                    forceError: _forceError,
                  ),
                ),
                SizedBox(height: spacing.space8),
                SuperSectionCard1(
                  title: 'Form result',
                  subtitle: 'Completion and FormState.save() values',
                  accentColor: SuperMarker.notes.resolve(context.superTheme.tokens),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SavedValue(
                        label: 'Last completed',
                        value: _completedCode,
                      ),
                      SizedBox(height: spacing.space3),
                      _SavedValue(label: 'SMS code', value: _savedSMSCode),
                      SizedBox(height: spacing.space3),
                      _SavedValue(label: 'PIN', value: _savedPIN),
                      SizedBox(height: spacing.space3),
                      _SavedValue(
                        label: 'Backup code',
                        value: _savedBackupCode,
                      ),
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
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Validate & save'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _fillExamples,
                      icon: const Icon(Icons.auto_fix_high_outlined),
                      label: const Text('Fill examples'),
                    ),
                    TextButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: Text('Reset', style: TextStyle(color: theme.fg2)),
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
          width: 128,
          child: Text(
            label,
            style: context.superTextTheme.caption.copyWith(color: theme.fg3),
          ),
        ),
        Expanded(
          child: Text(
            value ?? 'Not saved',
            style: context.superTextTheme.mono.copyWith(color: theme.fg1),
          ),
        ),
      ],
    );
  }
}
