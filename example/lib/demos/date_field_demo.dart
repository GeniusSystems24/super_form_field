// ============================================================
// example/lib/demos/date_field_demo.dart
// ------------------------------------------------------------
// SuperDateFormField gallery page — collects the three usage examples
// (basic · controlled range · validated bilingual) into one scrolling page.
// Each example lives in its own file under demos/date/.
// ============================================================

import 'package:flutter/material.dart';

import 'date/example_basic.dart';
import 'date/example_controlled_range.dart';
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
        DateControlledRangeExample(),
        DateValidatedFormExample(),
      ],
    );
  }
}
