import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form_field/super_form_field.dart';

void main() {
  Widget buildTestApp(Widget child) {
    final textTheme = SuperTextTheme();
    return MaterialApp(
      theme: SuperMaterialThemeData.light(
        textTheme: textTheme,
        primaryTextTheme: textTheme,
      ),
      localizationsDelegates:
          SuperFormLocalizations.localizationsDelegates,
      supportedLocales: SuperFormLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    );
  }

  testWidgets('OTP field filters, limits, completes, and saves the code', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = SuperOTPFieldController();
    addTearDown(controller.dispose);

    String? completed;
    String? saved;

    await tester.pumpWidget(
      buildTestApp(
        Form(
          key: formKey,
          child: SuperOTPFormField(
            controller: controller,
            length: 6,
            decoration: const InputDecoration(
              labelText: 'Verification code',
            ),
            onCompleted: (value) => completed = value,
            onSaved: (value) => saved = value,
          ),
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.keyboardType, TextInputType.number);
    expect(textField.autofillHints, contains(AutofillHints.oneTimeCode));
    expect(textField.inputFormatters, hasLength(2));
    expect(
      textField.inputFormatters!.last,
      isA<LengthLimitingTextInputFormatter>(),
    );

    await tester.enterText(find.byType(TextField), '12a345678');
    await tester.pump();

    expect(controller.value, '123456');
    expect(completed, '123456');
    expect(formKey.currentState!.validate(), isTrue);

    formKey.currentState!.save();
    expect(saved, '123456');
  });

  testWidgets('OTP field validates exact length and resets its controller', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = SuperOTPFieldController(initialValue: '12');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildTestApp(
        Form(
          key: formKey,
          child: SuperOTPFormField(
            controller: controller,
            initialValue: '12',
            length: 4,
            forceError: true,
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.byType(ErrorBadge), findsOneWidget);

    controller.setValue('9876');
    await tester.pump();
    expect(formKey.currentState!.validate(), isTrue);

    formKey.currentState!.reset();
    await tester.pump();
    expect(controller.value, '12');
  });

  testWidgets('OTP field supports secure alphanumeric codes', (tester) async {
    final controller = SuperOTPFieldController(initialValue: 'A7X9');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      buildTestApp(
        SuperOTPFormField(
          controller: controller,
          length: 4,
          digitsOnly: false,
          obscureText: true,
          keyboardType: TextInputType.text,
        ),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.keyboardType, TextInputType.text);
    expect(find.text('A'), findsNothing);
    expect(find.text('•'), findsNWidgets(4));
  });
}
