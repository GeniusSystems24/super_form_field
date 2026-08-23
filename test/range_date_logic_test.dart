import 'package:flutter_test/flutter_test.dart';
import 'package:super_form_field/super_form_field.dart';

void main() {
  group('RangeDateLogic', () {
    test('preset constraints clamp mutable boundaries to min/max', () {
      final result = RangeDateLogic.constrainSuggestion(
        suggestion: SuperDateRange(
          start: DateTime(2025, 1, 1),
          end: DateTime(2027, 1, 1),
        ),
        currentStart: null,
        currentEnd: null,
        isStartFixed: false,
        isEndFixed: false,
        minDate: DateTime(2026, 1, 1),
        maxDate: DateTime(2026, 12, 31),
      );

      expect(result?.start, DateTime(2026, 1, 1));
      expect(result?.end, DateTime(2026, 12, 31));
    });

    test('preset preserves a fixed start boundary', () {
      final result = RangeDateLogic.constrainSuggestion(
        suggestion: SuperDateRange(
          start: DateTime(2026, 8, 1),
          end: DateTime(2026, 8, 20),
        ),
        currentStart: DateTime(2026, 7, 15),
        currentEnd: DateTime(2026, 7, 20),
        isStartFixed: true,
        isEndFixed: false,
      );

      expect(result?.start, DateTime(2026, 7, 15));
      expect(result?.end, DateTime(2026, 8, 20));
    });

    test('preset is rejected when fixed boundaries make it invalid', () {
      final result = RangeDateLogic.constrainSuggestion(
        suggestion: SuperDateRange(
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 2, 1),
        ),
        currentStart: DateTime(2026, 3, 1),
        currentEnd: DateTime(2026, 3, 10),
        isStartFixed: true,
        isEndFixed: false,
      );

      expect(result, isNull);
    });
  });

  group('SuperRangeDateFieldController', () {
    test('fixed start cannot be changed', () {
      final controller = SuperRangeDateFieldController(
        initialValue: SuperDateRange(
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 1, 31),
        ),
        isStartFixed: true,
      );
      addTearDown(controller.dispose);

      controller.setStartDate(DateTime(2026, 1, 5));
      expect(controller.startDate, DateTime(2026, 1, 1));

      controller.setEndDate(DateTime(2026, 2, 1));
      expect(controller.endDate, DateTime(2026, 2, 1));
    });

    test('both fixed boundaries make clear a no-op', () {
      final initial = SuperDateRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      );
      final controller = SuperRangeDateFieldController(
        initialValue: initial,
        isStartFixed: true,
        isEndFixed: true,
      );
      addTearDown(controller.dispose);

      controller.clear();
      expect(controller.value, initial);
    });
    test('boundary date controllers synchronize the aggregate range', () {
      final controller = SuperRangeDateFieldController(
        initialValue: SuperDateRange(
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 1, 31),
        ),
      );
      addTearDown(controller.dispose);

      controller.startController.setValue(DateTime(2026, 1, 5));
      controller.endController.setValue(DateTime(2026, 2, 5));

      expect(controller.startDate, DateTime(2026, 1, 5));
      expect(controller.endDate, DateTime(2026, 2, 5));
      expect(
        controller.value,
        SuperDateRange(start: DateTime(2026, 1, 5), end: DateTime(2026, 2, 5)),
      );
      expect(controller.startText.text, '2026-01-05');
      expect(controller.endText.text, '2026-02-05');
    });

    test('fixed start blocks edits through its date controller', () {
      final controller = SuperRangeDateFieldController(
        initialValue: SuperDateRange(
          start: DateTime(2026, 1, 1),
          end: DateTime(2026, 1, 31),
        ),
        isStartFixed: true,
      );
      addTearDown(controller.dispose);

      controller.startController.setValue(DateTime(2026, 1, 9));
      controller.endController.setValue(DateTime(2026, 2, 9));

      expect(controller.startDate, DateTime(2026, 1, 1));
      expect(controller.endDate, DateTime(2026, 2, 9));
    });
  });
}
