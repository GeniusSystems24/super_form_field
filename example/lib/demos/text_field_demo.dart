// ============================================================
// example/lib/demos/text_field_demo.dart
// ------------------------------------------------------------
// SuperTextFormField in realistic GeniusLink form context: a bilingual account
// name row, reference + email + password, a multiline note with counter, and a
// "Validate" sweep that force-shows every error badge.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart' hide SectionCard;

import 'demo_scaffold.dart';

class TextFieldDemo extends StatefulWidget {
  const TextFieldDemo({super.key});

  @override
  State<TextFieldDemo> createState() => _TextFieldDemoState();
}

class _TextFieldDemoState extends State<TextFieldDemo> {
  bool _force = false;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return DemoPage(
      eyebrow: 'Accounts • Create Account',
      title: 'Super Text Field',
      children: [
        SectionCard(
          title: 'Identity',
          subtitle: 'Define the account name in both languages',
          marker: Marker.identity,
          child: Column(
            children: [
              BilingualRow(
                english: SuperTextFormField(
                  label: 'Name English',
                  required: true,
                  placeholder: 'e.g. Current Assets',
                  leadingIcon: SffIcons.user,
                  clearable: true,
                  minLength: 3,
                  forceError: _force,
                ),
                arabic: SuperTextFormField(
                  label: 'الاسم بالعربية',
                  required: true,
                  placeholder: 'مثال: الأصول المتداولة',
                  arabic: true,
                  forceError: _force,
                ),
              ),
              SizedBox(height: SuperThemeData.of(context).tokens.space6),
              const SuperTextFormField(
                label: 'Reference',
                placeholder: 'e.g. ACC-0042',
                prefix: 'ACC-',
                hint: 'Optional internal reference code.',
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Contact & Access',
          subtitle: 'Email and password validation patterns',
          marker: Marker.identity,
          child: Column(
            children: [
              SuperTextFormField(
                label: 'Email',
                type: SuperTextType.email,
                required: true,
                placeholder: 'e.g. accounts@company.com',
                leadingIcon: SffIcons.mail,
                forceError: _force,
              ),
              SizedBox(height: SuperThemeData.of(context).tokens.space6),
              SuperTextFormField(
                label: 'Password',
                type: SuperTextType.password,
                required: true,
                minLength: 8,
                placeholder: 'At least 8 characters',
                leadingIcon: SffIcons.lock,
                forceError: _force,
              ),
            ],
          ),
        ),
        const SectionCard(
          title: 'Notes',
          subtitle: 'Add any notes about this account',
          marker: Marker.notes,
          child: SuperTextFormField(
            label: 'Description',
            multiline: true,
            rows: 4,
            maxLength: 200,
            showCounter: true,
            placeholder: 'Add internal notes about this account…',
          ),
        ),
        Row(
          children: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SuperThemeData.of(context).tokens.radiusControl)),
              ),
              onPressed: () => setState(() => _force = true),
              child: const Text('Validate'),
            ),
            SizedBox(width: SuperThemeData.of(context).tokens.space3),
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
