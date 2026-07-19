import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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

  testWidgets('mobile date typing keeps a collapsed caret and valid segments', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = SuperDateFieldController(
      initialValue: DateTime(2024, 1, 1),
    );
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
    await tester.showKeyboard(find.byType(TextField));

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.keyboardType, TextInputType.number);
    expect(textField.inputFormatters, hasLength(1));
    expect(controller.text.selection.isCollapsed, isTrue);

    Future<void> enterDigit(String digit) async {
      final oldValue = controller.text.value;
      final offset = oldValue.selection.baseOffset;
      final rawText = oldValue.text.replaceRange(offset, offset, digit);
      tester.testTextInput.updateEditingValue(
        TextEditingValue(
          text: rawText,
          selection: TextSelection.collapsed(offset: offset + 1),
        ),
      );
      await tester.pump();
      expect(controller.text.selection.isCollapsed, isTrue);
    }

    for (final digit in '2025'.split('')) {
      await enterDigit(digit);
    }
    for (final digit in '12'.split('')) {
      await enterDigit(digit);
    }
    for (final digit in '31'.split('')) {
      await enterDigit(digit);
    }

    expect(controller.text.text, '2025-12-31');
    expect(controller.value, DateTime(2025, 12, 31));
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
              initialValue: 5240,
              decoration: InputDecoration(
                labelText: 'Debit amount',
                prefixText: 'SAR',
              ),
            ),
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.textAlignVertical, TextAlignVertical.center);
    expect(textField.expands, isFalse);
    expect(textField.decoration?.isCollapsed, isTrue);
    expect(textField.decoration?.contentPadding, EdgeInsets.zero);

    final decrementFinder = find.byKey(
      const ValueKey('super_numeric_decrement'),
    );
    final incrementFinder = find.byKey(
      const ValueKey('super_numeric_increment'),
    );
    final fieldFinder = find.byType(FieldBox);

    final decrementSize = tester.getSize(decrementFinder);
    final incrementSize = tester.getSize(incrementFinder);
    final fieldSize = tester.getSize(fieldFinder);

    expect(decrementSize.width, decrementSize.height);
    expect(incrementSize.width, incrementSize.height);
    expect(decrementSize.height, fieldSize.height);
    expect(incrementSize.height, fieldSize.height);

    final decrementRect = tester.getRect(decrementFinder);
    final incrementRect = tester.getRect(incrementFinder);
    final fieldRect = tester.getRect(fieldFinder);
    final renderEditable = tester.allRenderObjects
        .whereType<RenderEditable>()
        .toSet()
        .single;
    final editableRect = renderEditable.localToGlobal(Offset.zero) &
        renderEditable.size;

    expect(
      editableRect.center.dy,
      moreOrLessEquals(fieldRect.center.dy, epsilon: 0.5),
    );
    expect(decrementRect.top, moreOrLessEquals(fieldRect.top));
    expect(decrementRect.bottom, moreOrLessEquals(fieldRect.bottom));
    expect(incrementRect.top, moreOrLessEquals(fieldRect.top));
    expect(incrementRect.bottom, moreOrLessEquals(fieldRect.bottom));
    expect(decrementRect.right, moreOrLessEquals(incrementRect.left));
    expect(incrementRect.right, moreOrLessEquals(fieldRect.right));
  });
}
