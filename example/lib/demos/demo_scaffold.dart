// ============================================================
// example/lib/demos/demo_scaffold.dart
// ------------------------------------------------------------
// Shared gallery page chrome. The app bar and section surfaces come directly
// from super_core (`SuperAppBar`, `SuperSectionCard1`, and `SuperMarker`) so
// the example exercises the same design-system components used by production
// applications.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:super_form_field/super_form_field.dart' show SuperFieldContextX;
import 'package:super_form_field_example/main.dart';

export 'package:super_core/super_core.dart' show SuperSectionCard1, SuperMarker;

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
    return Scaffold(
      appBar: appBarBuild(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 64),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: SuperThemeData.of(context).sizing.contentColumn,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    eyebrow.toUpperCase(),
                    style: context.superTextTheme.eyebrow.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: SuperThemeData.of(context).spacing.space2),
                  Text(
                    title,
                    style: context.superTextTheme.h1.copyWith(color: t.fg1),
                  ),
                  SizedBox(height: SuperThemeData.of(context).spacing.space8),
                  for (var index = 0; index < children.length; index++) ...[
                    children[index],
                    if (index < children.length - 1)
                      SizedBox(
                        height: SuperThemeData.of(context).spacing.space8,
                      ),
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
        SizedBox(width: SuperThemeData.of(context).spacing.space6),
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

/// Gallery note used where fixed-state behavior needs contextual explanation.
class FixedFeatureCallout extends StatelessWidget {
  const FixedFeatureCallout({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final spacing = SuperThemeData.of(context).spacing;
    final t = context.sffTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(spacing.radiusControl),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.space3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline_rounded, size: 18, color: t.fg3),
            SizedBox(width: spacing.space2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.superTextTheme.body.copyWith(color: t.fg1),
                  ),
                  SizedBox(height: spacing.space1),
                  Text(
                    message,
                    style: context.superTextTheme.caption.copyWith(
                      color: t.fg3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
