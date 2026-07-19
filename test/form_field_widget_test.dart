import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form_field/super_form_field.dart';

void main() {
  test('all public fields accept InputDecoration', () {
    const options = [
      SuperOption(value: 'one', label: 'One'),
      SuperOption(value: 'two', label: 'Two'),
    ];
    const decoration = InputDecoration(
      labelText: 'Label',
      hintText: 'Hint',
      helperText: 'Helper',
      prefixIcon: Icon(Icons.input),
      suffixText: 'Suffix',
    );

    final fields = <Widget>[
      const SuperTextFormField(decoration: decoration),
      const SuperNumericFormField(decoration: decoration),
      const SuperAttachmentFormField(decoration: decoration),
      const SuperDateFormField(decoration: decoration),
      const SuperSelectFormField<String>(
        decoration: decoration,
        options: options,
      ),
      const SuperMultiSelectFormField<String>(
        decoration: decoration,
        options: options,
      ),
      const SuperBoolFormField(decoration: decoration),
      const SuperChoiceFormField<String>(
        decoration: decoration,
        options: options,
      ),
    ];

    expect(fields, hasLength(8));
  });

  testWidgets('custom fields adapt label, hint, helper, and adornments', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SuperMaterialThemeData.light(),
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(24),
            child: SuperSelectFormField<String>(
              decoration: InputDecoration(
                labelText: 'Account type',
                hintText: 'Choose a type',
                helperText: 'Used for financial reporting',
                prefixIcon: Icon(Icons.account_balance_outlined),
                suffixText: 'Required',
                counterText: '1 of 5',
              ),
              options: [SuperOption(value: 'asset', label: 'Asset')],
            ),
          ),
        ),
      ),
    );

    expect(find.text('ACCOUNT TYPE'), findsOneWidget);
    expect(find.text('Choose a type'), findsOneWidget);
    expect(find.text('Used for financial reporting'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('1 of 5'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_outlined), findsOneWidget);
  });

  testWidgets('mobile date action unfocuses and opens a bottom sheet', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = SuperDateFieldController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: SuperMaterialThemeData.light(),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SuperDateFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Posting date'),
            ),
          ),
        ),
      ),
    );

    controller.focusNode.requestFocus();
    await tester.pump();
    expect(controller.focusNode.hasFocus, isTrue);
    expect(find.byIcon(SffIcons.calendar), findsOneWidget);

    await tester.tap(find.byIcon(SffIcons.calendarDays));
    await tester.pumpAndSettle();

    expect(controller.focusNode.hasFocus, isFalse);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(MiniCalendar), findsOneWidget);
  });

  testWidgets('date leading calendar fallback can be suppressed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SuperMaterialThemeData.light(),
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(24),
            child: SuperDateFormField(
              decoration: InputDecoration(prefixIcon: SizedBox.shrink()),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(SffIcons.calendar), findsNothing);
    expect(find.byIcon(SffIcons.calendarDays), findsOneWidget);
  });

  testWidgets('tablet date action retains the anchored calendar', (tester) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: SuperMaterialThemeData.light(),
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(24),
            child: SuperDateFormField(
              decoration: InputDecoration(labelText: 'Posting date'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(SffIcons.calendarDays));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(MiniCalendar), findsOneWidget);
  });

  testWidgets('numeric input is centered and steppers match field height', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SuperMaterialThemeData.light(),
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(24),
            child: SuperNumericFormField(
              initialValue: 10,
              decoration: InputDecoration(labelText: 'Quantity'),
            ),
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.textAlignVertical, TextAlignVertical.center);

    final decrementSize = tester.getSize(
      find.byKey(const ValueKey('super_numeric_decrement')),
    );
    final incrementSize = tester.getSize(
      find.byKey(const ValueKey('super_numeric_increment')),
    );
    final fieldSize = tester.getSize(find.byType(FieldBox));

    expect(decrementSize.height, fieldSize.height);
    expect(incrementSize.height, fieldSize.height);
  });
}
