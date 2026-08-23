import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form_field/super_form_field.dart';

void main() {
  test('text controller exposes and honors field metadata', () {
    final focus = FocusNode();
    final key = GlobalKey<FormFieldState<String>>();
    final controller = SuperTextFieldController(
      initialValue: 'A',
      focusNode: focus,
      formFieldKey: key,
      isFixed: true,
      isHiden: true,
    );

    expect(controller.isFixed.value, isTrue);
    expect(controller.focusNode, same(focus));
    expect(controller.formFieldKey, same(key));
    expect(controller.isHiden, isTrue);

    controller.setValue('B');
    expect(controller.value, 'A');

    controller.isFixed.value = false;
    controller.setValue('B');
    expect(controller.value, 'B');

    controller.dispose();
    // Externally supplied focus nodes remain caller-owned.
    focus.dispose();
  });

  test('select controller closes and guards when fixed', () {
    final controller = SuperSelectFieldController<String>(initialValue: 'a');

    controller.configure(
      options: const [
        SuperOption(value: 'a', label: 'A'),
        SuperOption(value: 'b', label: 'B'),
      ],
      validators: const [],
      forceError: false,
    );

    controller.open();
    expect(controller.isOpen, isTrue);

    controller.isFixed.value = true;
    expect(controller.isOpen, isFalse);

    controller.select(const SuperOption(value: 'b', label: 'B'));
    expect(controller.value, 'a');

    controller.dispose();
  });

  test('dropdown direct value mutation is guarded while fixed', () {
    final key = GlobalKey<FormFieldState<String>>();
    final controller = SuperDropdownEditingController<String>(
      initialValue: 'draft',
      formFieldKey: key,
      isFixed: true,
    );

    controller.value = 'posted';
    expect(controller.value, 'draft');

    controller.isFixed.value = false;
    controller.value = 'posted';
    expect(controller.value, 'posted');

    controller.dispose();
  });

  testWidgets('isHiden removes the controller-backed field from layout', (
    tester,
  ) async {
    final controller = SuperTextFieldController(
      initialValue: 'hidden',
      isHiden: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SuperTextFormField(controller: controller)),
      ),
    );

    expect(find.text('hidden'), findsNothing);

    controller.isHiden = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SuperTextFormField(controller: controller)),
      ),
    );

    expect(find.text('hidden'), findsOneWidget);
    controller.dispose();
  });
}
