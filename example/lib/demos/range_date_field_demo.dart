import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
import 'package:super_form_field/super_form_field.dart';

import 'demo_scaffold.dart';

class RangeDateFieldDemo extends StatelessWidget {
  const RangeDateFieldDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const DemoPage(
      eyebrow: 'Reports • Date Filters',
      title: 'Super Range Date Field',
      children: [
        _DefaultSuggestionsExample(),
        _WeekStartExample(),
        _FixedBoundaryExample(),
        _CustomSuggestionsExample(),
        _FullyFixedExample(),
      ],
    );
  }
}

class _DefaultSuggestionsExample extends StatefulWidget {
  const _DefaultSuggestionsExample();

  @override
  State<_DefaultSuggestionsExample> createState() =>
      _DefaultSuggestionsExampleState();
}

class _DefaultSuggestionsExampleState
    extends State<_DefaultSuggestionsExample> {
  SuperDateRange? _value = SuperDateRange(
    start: DateTime(2026, 8, 1),
    end: DateTime(2026, 8, 23),
  );

  @override
  Widget build(BuildContext context) {
    return SuperSectionCard1(
      title: 'Default range picker',
      subtitle:
          'Two keyboard-editable dates; calendar icon opens the range picker',
      accentColor: SuperMarker.identity.resolve(context.superTheme.tokens),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SuperRangeDateFormField(
            initialValue: _value,
            required: true,
            clearable: true,
            minDate: DateTime(2025, 1, 1),
            maxDate: DateTime(2027, 12, 31),
            decoration: const InputDecoration(
              labelText: 'Reporting period',
              helperText:
                  'Type either date directly, or use the calendar icon for range selection.',
            ),
            onChanged: (value) => setState(() => _value = value),
          ),
          const SizedBox(height: 12),
          Text(
            _value == null
                ? 'No range selected'
                : '${RangeDateLogic.formatDate(_value!.start)} → ${RangeDateLogic.formatDate(_value!.end)}',
          ),
        ],
      ),
    );
  }
}

// SUPER_RANGE_DATE_PICKER_FIRST_DAY_OF_WEEK_V1
class _WeekStartExample extends StatelessWidget {
  const _WeekStartExample();

  @override
  Widget build(BuildContext context) {
    return SuperSectionCard1(
      title: 'Monday-first calendar',
      subtitle:
          'The week-start can be configured independently of date parsing',
      accentColor: SuperMarker.identity.resolve(context.superTheme.tokens),
      child: SuperRangeDateFormField(
        initialValue: SuperDateRange(
          start: DateTime(2026, 8, 3),
          end: DateTime(2026, 8, 23),
        ),
        firstDayOfWeek: DateTime.monday,
        decoration: const InputDecoration(
          labelText: 'Monday-first reporting period',
          helperText: 'The picker headers and date grid both start on Monday.',
        ),
      ),
    );
  }
}

class _FixedBoundaryExample extends StatelessWidget {
  const _FixedBoundaryExample();

  @override
  Widget build(BuildContext context) {
    return SuperSectionCard1(
      title: 'Fixed start + bounded range',
      subtitle:
          'The fixed start input is read-only; the end date stays keyboard-editable',
      accentColor: SuperMarker.identity.resolve(context.superTheme.tokens),
      child: SuperRangeDateFormField(
        initialValue: SuperDateRange(
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 3, 31),
        ),
        isStartFixed: true,
        minDate: DateTime(2026, 1, 1),
        maxDate: DateTime(2026, 12, 31),
        decoration: const InputDecoration(
          labelText: 'Fiscal window',
          helperText: 'The start is locked at the fiscal-year boundary.',
        ),
      ),
    );
  }
}

class _CustomSuggestionsExample extends StatelessWidget {
  const _CustomSuggestionsExample();

  static SuperDateRange _monthToDate(DateTime now) => SuperDateRange(
    start: DateTime(now.year, now.month, 1),
    end: DateTime(now.year, now.month, now.day),
  );

  static SuperDateRange _quarterToDate(DateTime now) {
    final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
    return SuperDateRange(
      start: DateTime(now.year, quarterStartMonth, 1),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SuperSectionCard1(
      title: 'Custom suggestions only',
      subtitle:
          'Passing a list replaces the package defaults; [] removes all presets',
      accentColor: SuperMarker.identity.resolve(context.superTheme.tokens),
      child: SuperRangeDateFormField(
        initialValue: SuperDateRange(
          start: DateTime(2026, 8, 1),
          end: DateTime(2026, 8, 23),
        ),
        suggestions: const [
          SuperDateRangeSuggestion(
            label: 'Month to date',
            resolve: _monthToDate,
          ),
          SuperDateRangeSuggestion(
            label: 'Quarter to date',
            resolve: _quarterToDate,
          ),
        ],
        decoration: const InputDecoration(
          labelText: 'Custom reporting range',
          helperText: 'Only product-specific suggestions are shown.',
        ),
      ),
    );
  }
}

class _FullyFixedExample extends StatelessWidget {
  const _FullyFixedExample();

  @override
  Widget build(BuildContext context) {
    return SuperSectionCard1(
      title: 'Both boundaries fixed',
      subtitle: 'The picker remains inspectable, but neither date can change',
      accentColor: SuperMarker.identity.resolve(context.superTheme.tokens),
      child: SuperRangeDateFormField(
        initialValue: SuperDateRange(
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 12, 31),
        ),
        isStartFixed: true,
        isEndFixed: true,
        decoration: const InputDecoration(
          labelText: 'Closed fiscal year',
          helperText: 'Both boundaries are locked.',
        ),
      ),
    );
  }
}
