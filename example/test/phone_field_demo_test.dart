import 'package:flutter_test/flutter_test.dart';
import 'package:super_form_field_example/main.dart';

void main() {
  testWidgets('opens the dedicated phone field example screen', (tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Phone Text Field'), findsOneWidget);

    await tester.tap(find.text('Phone Text Field'));
    await tester.pumpAndSettle();

    expect(find.text('Phone Field Examples'), findsOneWidget);
    expect(find.text('International number'), findsOneWidget);
    expect(find.text('Country-specific rules'), findsOneWidget);
    expect(find.text('Form result'), findsOneWidget);
  });
}
