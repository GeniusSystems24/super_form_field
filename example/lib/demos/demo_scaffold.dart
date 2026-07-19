// ============================================================
// example/lib/demos/demo_scaffold.dart
// ------------------------------------------------------------
// Shared gallery page chrome. Section surfaces come directly from super_core
// (`SectionCard`, `SectionHeader`, and `SuperMarker`) so the example exercises
// the same design-system components used by production applications.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:super_form_field/super_form_field.dart' show SuperFieldContextX;

export 'package:super_core/super_core.dart' show SectionCard, SuperMarker;

/// A centered GeniusLink page with an eyebrow + title and spaced sections.
class DemoPage extends StatelessWidget {
  const DemoPage({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.children,
  });

  final String eyebrow;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    final tokens = SuperThemeData.of(context).tokens;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: t.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: t.fg2),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 64),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: tokens.contentColumn),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    eyebrow.toUpperCase(),
                    style: SuperText.eyebrow.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: tokens.space2),
                  Text(title, style: SuperText.h1.copyWith(color: t.fg1)),
                  SizedBox(height: tokens.space8),
                  for (var index = 0; index < children.length; index++) ...[
                    children[index],
                    if (index < children.length - 1)
                      SizedBox(height: tokens.space8),
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

/// A 2-column English-left / Arabic-right form row (the bilingual grid).
class BilingualRow extends StatelessWidget {
  const BilingualRow({super.key, required this.english, required this.arabic});

  final Widget english;
  final Widget arabic;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: english),
        SizedBox(width: SuperThemeData.of(context).tokens.space6),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: arabic,
          ),
        ),
      ],
    );
  }
}
