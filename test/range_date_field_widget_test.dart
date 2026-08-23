import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form_field/super_form_field.dart';

SuperMaterialThemeData _testTheme() {
  final textTheme = SuperTextTheme();
  return SuperMaterialThemeData.light(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
  );
}

void main() {
  testWidgets('range date renders two keyboard-editable date fields', (
    tester,
  ) async {
    final controller = SuperRangeDateFieldController(
      initialValue: SuperDateRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: _testTheme(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SuperRangeDateFormField(controller: controller),
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(2));
    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[0].readOnly, isFalse);
    expect(fields[1].readOnly, isFalse);
    expect(fields[0].controller, same(controller.startText));
    expect(fields[1].controller, same(controller.endText));
  });

  testWidgets('text-field taps never open the range picker', (tester) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: _testTheme(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SuperRangeDateFormField(),
          ),
        ),
      ),
    );

    final fields = find.byType(TextField);
    await tester.tap(fields.first);
    await tester.pump();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(Dialog), findsNothing);

    await tester.tap(fields.last);
    await tester.pump();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('calendar action alone opens the range picker', (tester) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: _testTheme(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SuperRangeDateFormField(),
          ),
        ),
      ),
    );

    expect(find.byIcon(SffIcons.calendarDays), findsOneWidget);
    await tester.tap(find.byIcon(SffIcons.calendarDays));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(SuperRangeDatePicker), findsOneWidget);
  });

  testWidgets('fixed boundaries become read-only independently', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: _testTheme(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SuperRangeDateFormField(
              isStartFixed: true,
              isEndFixed: false,
            ),
          ),
        ),
      ),
    );

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields[0].readOnly, isTrue);
    expect(fields[1].readOnly, isFalse);
  });

  testWidgets('manual keyboard values stay synchronized with the range', (
    tester,
  ) async {
    final controller = SuperRangeDateFieldController(
      initialValue: SuperDateRange(
        start: DateTime(2026, 1, 1),
        end: DateTime(2026, 1, 31),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: _testTheme(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SuperRangeDateFormField(controller: controller),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, '2026-01-05');
    await tester.pump();

    expect(controller.startDate, DateTime(2026, 1, 5));
    expect(controller.endDate, DateTime(2026, 1, 31));
    expect(
      controller.value,
      SuperDateRange(start: DateTime(2026, 1, 5), end: DateTime(2026, 1, 31)),
    );
  });

  // SUPER_RANGE_DATE_PICKER_SYNCFUSION_INSPIRED_V1
  testWidgets(
    'range picker adapts from single-month mobile to multi-view desktop',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      tester.view.physicalSize = const Size(390, 820);
      await tester.pumpWidget(
        MaterialApp(
          theme: _testTheme(),
          home: Scaffold(
            body: SizedBox(
              width: 390,
              child: SuperRangeDatePicker(
                startDate: DateTime(2026, 1, 10),
                endDate: DateTime(2026, 1, 20),
                suggestions: SuperDateRangeSuggestion.defaults,
                onApply: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('super-range-date-picker-compact')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('super-range-date-picker-multi-view')),
        findsNothing,
      );

      tester.view.physicalSize = const Size(1280, 900);
      await tester.pumpWidget(
        MaterialApp(
          theme: _testTheme(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 980,
                child: SuperRangeDatePicker(
                  startDate: DateTime(2026, 1, 10),
                  endDate: DateTime(2026, 2, 20),
                  suggestions: SuperDateRangeSuggestion.defaults,
                  onApply: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('super-range-date-picker-wide')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('super-range-date-picker-multi-view')),
        findsOneWidget,
      );
    },
  );
  // SUPER_RANGE_DATE_PICKER_FIRST_DAY_OF_WEEK_V1
  testWidgets('range picker supports a configurable first day of week', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: _testTheme(),
        home: Scaffold(
          body: SizedBox(
            width: 390,
            child: SuperRangeDatePicker(
              startDate: DateTime(2026, 1, 10),
              endDate: DateTime(2026, 1, 20),
              firstDayOfWeek: DateTime.monday,
              onApply: (_) {},
            ),
          ),
        ),
      ),
    );

    // January 1, 2026 is Thursday. A Monday-first 6-week grid starts on
    // Monday, Dec 29, while the old Sunday-first grid started on Dec 28.
    expect(find.bySemanticsLabel('2025-12-28'), findsNothing);
    expect(find.bySemanticsLabel('2025-12-29'), findsOneWidget);
  });

  // SUPER_RANGE_DATE_PICKER_COMPACT_DESKTOP_LAYOUT_V4
  testWidgets(
    'desktop range picker stays content-height and uses compact actions',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: _testTheme(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 760,
                child: SuperRangeDatePicker(
                  startDate: DateTime(2026, 8, 1),
                  endDate: DateTime(2026, 8, 23),
                  suggestions: SuperDateRangeSuggestion.defaults,
                  onCancel: () {},
                  onApply: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('super-range-date-picker-wide')),
        findsOneWidget,
      );

      final applySize = tester.getSize(
        find.byKey(const ValueKey('range-date-apply')),
      );
      final cancelSize = tester.getSize(
        find.byKey(const ValueKey('range-date-cancel')),
      );
      expect(applySize.height, lessThanOrEqualTo(36));
      expect(cancelSize.height, lessThanOrEqualTo(36));

      final pickerSize = tester.getSize(
        find.byKey(const ValueKey('super-range-date-picker')),
      );
      expect(pickerSize.height, lessThan(440));
    },
  );
}
