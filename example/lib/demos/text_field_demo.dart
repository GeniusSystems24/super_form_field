// ============================================================
// example/lib/demos/text_field_demo.dart
// ------------------------------------------------------------
// SuperTextFormField in realistic GeniusLink form context: a bilingual account
// name row, reference + email + phone + password, a multiline note with a
// counter, and a "Validate" sweep that force-shows every error badge.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart'
    hide SuperSectionCard, SuperMarker;

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
        SuperSectionCard(
          title: 'Identity',
          subtitle: 'Define the account name in both languages',
          marker: SuperMarker.identity,
          child: Column(
            children: [
              BilingualRow(
                english: SuperTextFormField(
                  allowFixed: true,
                  decoration: const InputDecoration(
                    labelText: 'Name English',
                    hintText: 'e.g. Current Assets',
                    prefixIcon: Icon(SffIcons.user),
                  ),
                  required: true,
                  clearable: true,
                  minLength: 3,
                  forceError: _force,
                ),
                arabic: SuperTextFormField(
                  allowFixed: true,
                  decoration: const InputDecoration(
                    labelText: 'الاسم بالعربية',
                    hintText: 'مثال: الأصول المتداولة',
                  ),
                  required: true,
                  arabic: true,
                  forceError: _force,
                ),
              ),
              SizedBox(height: SuperThemeData.of(context).spacing.space6),
              SuperTextFormField(
                decoration: InputDecoration(
                  labelText: 'Reference',
                  hintText: 'e.g. ACC-0042',
                  prefixText: 'ACC-',
                  helperText: 'Optional internal reference code.',
                ),
              ),
            ],
          ),
        ),
        SuperSectionCard(
          title: 'Contact & Access',
          subtitle: 'Email, phone, and password input patterns',
          marker: SuperMarker.identity,
          child: Column(
            children: [
              SuperTextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'e.g. accounts@company.com',
                  prefixIcon: Icon(SffIcons.mail),
                ),
                type: SuperTextType.email,
                required: true,
                forceError: _force,
              ),
              SizedBox(height: SuperThemeData.of(context).spacing.space6),
              SuperTextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: 'e.g. +967 7XX XXX XXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                type: SuperTextType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
              ),
              SizedBox(height: SuperThemeData.of(context).spacing.space6),
              SuperTextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'At least 8 characters',
                  prefixIcon: Icon(SffIcons.lock),
                ),
                type: SuperTextType.password,
                required: true,
                minLength: 8,
                forceError: _force,
              ),
            ],
          ),
        ),
        SuperSectionCard(
          title: 'Notes',
          subtitle: 'Add any notes about this account',
          marker: SuperMarker.notes,
          child: SuperTextFormField(
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Add internal notes about this account…',
            ),
            multiline: true,
            rows: 4,
            maxLength: 200,
            showCounter: true,
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
