// ============================================================
// example/lib/demos/date_field_demo.dart
// ------------------------------------------------------------
// SuperDateFormField gallery page — collects the three usage examples
// (basic · controlled range · validated bilingual) into one scrolling page.
// Each example lives in its own file under demos/date/.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:super_form_field/super_form_field.dart';

import 'date/example_basic.dart';
import 'date/example_controlled_range.dart';
import 'date/example_formats.dart';
import 'date/example_validated_form.dart';
import 'demo_scaffold.dart';

class DateFieldDemo extends StatelessWidget {
  const DateFieldDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoPage(
      eyebrow: 'Ledger • Financial Operation Details',
      title: 'Super Date Field',
      children: [
        DateBasicExample(),
        _DateFixedExample(),
        DateControlledRangeExample(),
        DateValidatedFormExample(),
        DateFormatsExample(),
      ],
    );
  }
}

class _DateFixedExample extends StatelessWidget {
  const _DateFixedExample();

  @override
  Widget build(BuildContext context) {
    return SuperSectionCard1(
      title: 'Fixed date',
      subtitle: 'Use the label lock to guard the value without dimming it',
      accentColor: SuperMarker.identity.resolve(context.superTheme.tokens),
      child: const SuperDateFormField(
        allowFixed: true,
        decoration: InputDecoration(
          labelText: 'Posting date',
          helperText: 'Lock/unlock from the label action.',
          prefixIcon: Icon(Icons.event_outlined),
        ),
      ),
    );
  }
}
