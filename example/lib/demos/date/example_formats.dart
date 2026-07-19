// ============================================================
// example/lib/demos/date/example_formats.dart
// ------------------------------------------------------------
// EXAMPLE 4 — Configurable formats.
// The same field rendered with different `format`s: full date, year-month,
// year-only, and month-day. Editing stays segment-aware and zero-padded; the
// calendar trigger only appears when the format includes a day.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart' hide SectionCard;

import '../demo_scaffold.dart';

class DateFormatsExample extends StatelessWidget {
  const DateFormatsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: '4 · Formats',
      subtitle: 'Year-month-day · year-month · year · month-day',
      marker: Marker.identity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SuperDateFormField(
                  label: 'Posting Date',
                  format: SuperDateFormat.yearMonthDay,
                  initialValue: DateTime(2024, 1, 31),
                ),
              ),
              SizedBox(width: SuperThemeData.of(context).tokens.space4),
              Expanded(
                child: SuperDateFormField(
                  label: 'Period',
                  format: SuperDateFormat.yearMonth,
                  initialValue: DateTime(2024, 3, 1),
                ),
              ),
            ],
          ),
          SizedBox(height: SuperThemeData.of(context).tokens.space6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SuperDateFormField(
                  label: 'Fiscal Year',
                  format: SuperDateFormat.year,
                  initialValue: DateTime(2024, 1, 1),
                ),
              ),
              SizedBox(width: SuperThemeData.of(context).tokens.space4),
              Expanded(
                child: SuperDateFormField(
                  label: 'Recurring (Month-Day)',
                  format: SuperDateFormat.monthDay,
                  initialValue: DateTime(2024, 12, 25),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
