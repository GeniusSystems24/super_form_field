// ============================================================
// example/lib/demos/demo_scaffold.dart
// ------------------------------------------------------------
// Shared chrome for the demo pages: a GeniusLink-style centered page (eyebrow +
// H1 + section cards with the signature 4px marker bar). Kept in the EXAMPLE,
// not the package — super_form_field ships only the form fields themselves.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart';

/// The three section-marker intents.
enum Marker { identity, ledger, notes }

extension on Marker {
  Color  color(BuildContext context) => switch (this) {
        Marker.identity => Theme.of(context).colorScheme.primary,
        Marker.ledger => SuperTokens.success,
        Marker.notes => SuperTokens.warning,
      };
}

/// A centered GeniusLink page with an eyebrow + title and a list of children.
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
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 64),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(eyebrow.toUpperCase(),
                      style: SuperText.eyebrow.copyWith(color: Theme.of(context).colorScheme.primary)),
                  const SizedBox(height: SuperTokens.space2),
                  Text(title, style: SuperText.h1.copyWith(color: t.fg1)),
                  const SizedBox(height: SuperTokens.space8),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A GeniusLink section card: 4px marker bar + heading + subtitle + body.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.marker = Marker.identity,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Marker marker;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.sffTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: SuperTokens.space8),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(SuperTokens.radiusCard),
        border: Border.all(color: t.border),
        boxShadow: t.brightness == Brightness.dark
            ? const [BoxShadow(color: Color(0x40000000), blurRadius: 50, spreadRadius: -12, offset: Offset(0, 25))]
            : const [
                BoxShadow(color: Color(0x0F000000), blurRadius: 2, offset: Offset(0, 1)),
                BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 40,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: marker.color(context),
                  borderRadius: BorderRadius.circular(SuperTokens.radiusPill),
                ),
              ),
              const SizedBox(width: SuperTokens.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: SuperText.heading.copyWith(color: t.fg1)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!, style: SuperText.caption.copyWith(color: t.fg3)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SuperTokens.space8),
          child,
        ],
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
        const SizedBox(width: SuperTokens.space6),
        Expanded(
          child: Directionality(textDirection: TextDirection.rtl, child: arabic),
        ),
      ],
    );
  }
}
