import 'package:flutter_test/flutter_test.dart';
import 'package:super_form_field_example/main.dart';

void main() {
  testWidgets('opens the dedicated OTP field example screen', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Super OTP Field'), findsOneWidget);

    await tester.tap(find.text('Super OTP Field'));
    await tester.pumpAndSettle();

    expect(find.text('OTP Field Examples'), findsOneWidget);
    expect(find.text('SMS verification code'), findsOneWidget);
    expect(find.text('Secure transaction PIN'), findsOneWidget);
    expect(find.text('Alphanumeric backup code'), findsOneWidget);
    expect(find.text('Form result'), findsOneWidget);
  });
}
