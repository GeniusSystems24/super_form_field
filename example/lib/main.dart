// ============================================================
// example/lib/main.dart
// ------------------------------------------------------------
// Gallery launcher for Super Form Field. Registers the SuperThemeData
// extension (light + dark parity), exposes a global Light/Dark + LTR/RTL
// toggle, and lists the three field demos.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart';

import 'demos/attachment_field_demo.dart';
import 'demos/date_field_demo.dart';
import 'demos/demo_scaffold.dart';
import 'demos/numeric_field_demo.dart';
import 'demos/text_field_demo.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.dark;
  TextDirection _dir = TextDirection.ltr;

  ThemeData _theme(SuperThemeData s) => ThemeData(
        brightness: s.brightness,
        scaffoldBackgroundColor: s.bg,
        fontFamily: SuperTokens.bodyFont,
        extensions: [s],
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Super Form Field',
      themeMode: _mode,
      theme: _theme(SuperThemeData.light),
      darkTheme: _theme(SuperThemeData.dark),
      builder: (context, child) => Directionality(textDirection: _dir, child: child!),
      home: _Launcher(
        mode: _mode,
        dir: _dir,
        onToggleTheme: () =>
            setState(() => _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark),
        onToggleDir: () =>
            setState(() => _dir = _dir == TextDirection.ltr ? TextDirection.rtl : TextDirection.ltr),
      ),
    );
  }
}

class _DemoItem {
  const _DemoItem(this.title, this.subtitle, this.icon, this.builder);
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}

class _Launcher extends StatelessWidget {
  const _Launcher({
    required this.mode,
    required this.dir,
    required this.onToggleTheme,
    required this.onToggleDir,
  });

  final ThemeMode mode;
  final TextDirection dir;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleDir;

  static final _demos = <_DemoItem>[
    _DemoItem('Super Text Field', 'Text · email · password · multiline · counter',
        Icons.text_fields_rounded, (_) => const TextFieldDemo()),
    _DemoItem('Super Numeric Field', 'Grouping · clamp · round · stepper · units',
        Icons.pin_rounded, (_) => const NumericFieldDemo()),
    _DemoItem('Super Attachment Field', 'Drop zone · typed file list · validation',
        Icons.attach_file_rounded, (_) => const AttachmentFieldDemo()),
    _DemoItem('Super Date Field', 'Masked YYYY-MM-DD · calendar popover · min/max',
        Icons.event_rounded, (_) => const DateFieldDemo()),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SuperTokens.space10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('SUPER FORM FIELD • GALLERY',
                      style: SuperText.eyebrow.copyWith(color: SuperTokens.accent)),
                  const SizedBox(height: SuperTokens.space2),
                  Text('Form Fields حقول النماذج', style: SuperText.h1.copyWith(color: t.fg1)),
                  const SizedBox(height: SuperTokens.space8),
                  for (final d in _demos) ...[
                    _Card(item: d),
                    const SizedBox(height: SuperTokens.space3),
                  ],
                  const SizedBox(height: SuperTokens.space6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: t.fg1,
                          side: BorderSide(color: t.borderStrong),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(SuperTokens.radiusControl)),
                        ),
                        onPressed: onToggleTheme,
                        child: Text(mode == ThemeMode.dark ? 'Light Theme' : 'Dark Theme'),
                      ),
                      const SizedBox(width: SuperTokens.space3),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: t.fg1,
                          side: BorderSide(color: t.borderStrong),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(SuperTokens.radiusControl)),
                        ),
                        onPressed: onToggleDir,
                        child: Text(dir == TextDirection.ltr ? 'العربية (RTL)' : 'English (LTR)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.item});
  final _DemoItem item;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(SuperTokens.radiusCard),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: item.builder)),
        child: Container(
          padding: const EdgeInsets.all(SuperTokens.space4),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(SuperTokens.radiusCard),
            border: Border.all(color: t.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color.alphaBlend(SuperTokens.accent.withOpacity(0.14), t.surface),
                  borderRadius: BorderRadius.circular(SuperTokens.radiusControl),
                ),
                child: Icon(item.icon, size: 22, color: SuperTokens.accent),
              ),
              const SizedBox(width: SuperTokens.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: SuperText.heading.copyWith(color: t.fg1)),
                    const SizedBox(height: 2),
                    Text(item.subtitle, style: SuperText.caption.copyWith(color: t.fg3)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: t.fg4),
            ],
          ),
        ),
      ),
    );
  }
}
