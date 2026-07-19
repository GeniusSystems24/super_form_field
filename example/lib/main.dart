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
import 'demos/bool_field_demo.dart';
import 'demos/choice_field_demo.dart';
import 'demos/date_field_demo.dart';
import 'demos/multi_select_field_demo.dart';
import 'demos/numeric_field_demo.dart';
import 'demos/select_field_demo.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Super Form Field',
      themeMode: _mode,
      theme: SuperMaterialThemeData.light(),
      darkTheme: SuperMaterialThemeData.dark(),
      builder: (context, child) =>
          Directionality(textDirection: _dir, child: child!),
      home: _Launcher(
        mode: _mode,
        dir: _dir,
        onToggleTheme: () => setState(
          () => _mode = _mode == ThemeMode.dark
              ? ThemeMode.light
              : ThemeMode.dark,
        ),
        onToggleDir: () => setState(
          () => _dir = _dir == TextDirection.ltr
              ? TextDirection.rtl
              : TextDirection.ltr,
        ),
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
    _DemoItem(
      'Super Text Field',
      'Text · email · password · multiline · counter',
      Icons.text_fields_rounded,
      (_) => const TextFieldDemo(),
    ),
    _DemoItem(
      'Super Numeric Field',
      'Grouping · clamp · round · stepper · units',
      Icons.pin_rounded,
      (_) => const NumericFieldDemo(),
    ),
    _DemoItem(
      'Super Attachment Field',
      'Drop zone · typed file list · validation',
      Icons.attach_file_rounded,
      (_) => const AttachmentFieldDemo(),
    ),
    _DemoItem(
      'Super Date Field',
      'Masked date · mobile sheet · desktop popover · min/max',
      Icons.event_rounded,
      (_) => const DateFieldDemo(),
    ),
    _DemoItem(
      'Super Select Field',
      'Searchable single-select dropdown · options',
      Icons.arrow_drop_down_circle_outlined,
      (_) => const SelectFieldDemo(),
    ),
    _DemoItem(
      'Super Multi-Select Field',
      'Chips · checkable popover · min/max',
      Icons.checklist_rounded,
      (_) => const MultiSelectFieldDemo(),
    ),
    _DemoItem(
      'Super Bool Field',
      'Toggle · checkbox · active flags · mustBeTrue',
      Icons.toggle_on_outlined,
      (_) => const BoolFieldDemo(),
    ),
    _DemoItem(
      'Super Choice Field',
      'Segmented · radio · checkbox group',
      Icons.tune_rounded,
      (_) => const ChoiceFieldDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return Scaffold(
      appBar: SuperAppBar(
        title: const Text('Super Form Field'),
        actions: [
          IconButton(
            tooltip: mode == ThemeMode.dark ? 'Light Theme' : 'Dark Theme',
            icon: Icon(
              mode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: onToggleTheme,
          ),
          IconButton(
            tooltip: dir == TextDirection.ltr
                ? 'Switch to RTL'
                : 'Switch to LTR',
            icon: Icon(
              dir == TextDirection.ltr
                  ? Icons.format_textdirection_r_to_l_rounded
                  : Icons.format_textdirection_l_to_r_rounded,
            ),
            onPressed: onToggleDir,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(SuperThemeData.of(context).tokens.space10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'SUPER FORM FIELD • GALLERY',
                    style: SuperText.eyebrow.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space2),
                  Text(
                    'Form Fields حقول النماذج',
                    style: SuperText.h1.copyWith(color: t.fg1),
                  ),
                  SizedBox(height: SuperThemeData.of(context).tokens.space8),
                  for (final d in _demos) ...[
                    _Card(item: d),
                    SizedBox(height: SuperThemeData.of(context).tokens.space3),
                  ],
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
        borderRadius: BorderRadius.circular(
          SuperThemeData.of(context).tokens.radiusCard,
        ),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: item.builder)),
        child: Container(
          padding: EdgeInsets.all(SuperThemeData.of(context).tokens.space4),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(
              SuperThemeData.of(context).tokens.radiusCard,
            ),
            border: Border.all(color: t.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    Theme.of(context).colorScheme.primary.withOpacity(0.14),
                    t.surface,
                  ),
                  borderRadius: BorderRadius.circular(
                    SuperThemeData.of(context).tokens.radiusControl,
                  ),
                ),
                child: Icon(
                  item.icon,
                  size: 22,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(width: SuperThemeData.of(context).tokens.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: SuperText.heading.copyWith(color: t.fg1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: SuperText.caption.copyWith(color: t.fg3),
                    ),
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
