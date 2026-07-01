import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_form_field/super_form_field.dart';

void main() {
  testWidgets('FieldPopover defers closing outside the build frame',
      (tester) async {
    var open = false;
    late StateSetter updateOpen;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              updateOpen = setState;
              return Center(
                child: FieldPopover(
                  open: open,
                  onDismiss: () => setState(() => open = false),
                  overlayBuilder: (context) => const SizedBox(
                    width: 120,
                    height: 80,
                    child: Text('Menu content'),
                  ),
                  child: const SizedBox(
                    width: 120,
                    height: 40,
                    child: Text('Trigger'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    updateOpen(() => open = true);
    await tester.pump();
    await tester.pump();
    expect(find.text('Menu content'), findsOneWidget);

    updateOpen(() => open = false);
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.pump();
    expect(find.text('Menu content'), findsNothing);
  });
}
