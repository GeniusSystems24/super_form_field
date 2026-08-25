import 'package:flutter/material.dart';
import 'package:super_core/super_core.dart';
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
  test('SuperOption supports arbitrary recursive children', () {
    const tree = SuperOption<String>(
      value: 'management_branch',
      label: 'Management',
      children: [
        SuperOption(
          value: 'users_branch',
          label: 'Users',
          children: [
            SuperOption(
              value: 'permissions_branch',
              label: 'Permissions',
              children: [SuperOption(value: 'roles', label: 'Roles')],
            ),
          ],
        ),
      ],
    );

    expect(tree.hasChildren, isTrue);
    expect(tree.children.single.hasChildren, isTrue);
    expect(tree.children.single.children.single.hasChildren, isTrue);
    expect(tree.children.single.children.single.children.single.value, 'roles');
  });

  testWidgets('branch click opens submenu instead of selecting the branch', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: _testTheme(),
        home: Scaffold(
          body: Center(
            child: SuperPopupMenuButton<String>(
              options: const [
                SuperOption(
                  value: 'export_branch',
                  label: 'Export',
                  children: [SuperOption(value: 'pdf', label: 'PDF')],
                ),
              ],
              onSelected: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Export'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(selected, isNull);
    expect(find.text('PDF'), findsOneWidget);

    await tester.tap(find.text('PDF'));
    await tester.pumpAndSettle();

    expect(selected, 'pdf');
    expect(find.text('Export'), findsNothing);
    expect(find.text('PDF'), findsNothing);
  });

  testWidgets('deep leaf selection works across cascading overlay entries', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: _testTheme(),
        home: Scaffold(
          body: Center(
            child: SuperPopupMenuButton<String>(
              options: const [
                SuperOption(
                  value: 'management_branch',
                  label: 'Management',
                  children: [
                    SuperOption(
                      value: 'users_branch',
                      label: 'Users',
                      children: [
                        SuperOption(
                          value: 'permissions_branch',
                          label: 'Permissions',
                          children: [
                            SuperOption(value: 'roles', label: 'Roles'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              onSelected: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Management'));
    await tester.pumpAndSettle();
    expect(selected, isNull);
    expect(find.text('Users'), findsOneWidget);

    await tester.tap(find.text('Users'));
    await tester.pumpAndSettle();
    expect(selected, isNull);
    expect(find.text('Permissions'), findsOneWidget);

    await tester.tap(find.text('Permissions'));
    await tester.pumpAndSettle();
    expect(selected, isNull);
    expect(find.text('Roles'), findsOneWidget);

    await tester.tap(find.text('Roles'));
    await tester.pumpAndSettle();

    expect(selected, 'roles');
    expect(find.text('Management'), findsNothing);
    expect(find.text('Users'), findsNothing);
    expect(find.text('Permissions'), findsNothing);
    expect(find.text('Roles'), findsNothing);
  });

  testWidgets('disabled branch stays visible but does not open', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: _testTheme(),
        home: const Scaffold(
          body: Center(
            child: SuperPopupMenuButton<String>(
              options: [
                SuperOption(
                  value: 'legacy_branch',
                  label: 'Legacy tools',
                  disabled: true,
                  children: [
                    SuperOption(value: 'legacy_import', label: 'Legacy import'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Legacy tools'), findsOneWidget);

    await tester.tap(find.text('Legacy tools'));
    await tester.pumpAndSettle();

    expect(find.text('Legacy import'), findsNothing);
  });

  testWidgets('nested submenu shrink-wraps to its item height', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: _testTheme(),
        home: const Scaffold(
          body: Center(
            child: SuperPopupMenuButton<String>(
              menuMaxHeight: 280,
              options: [
                SuperOption(
                  value: 'export_branch',
                  label: 'Export',
                  children: [
                    SuperOption(value: 'pdf', label: 'PDF'),
                    SuperOption(value: 'csv', label: 'CSV'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();

    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('CSV'), findsOneWidget);

    final submenu = find.ancestor(
      of: find.text('PDF'),
      matching: find.byType(OptionMenu),
    );
    expect(submenu, findsOneWidget);

    final submenuSize = tester.getSize(submenu);

    // Two rows must use their natural height instead of inheriting the
    // full-screen OverlayEntry height or consuming menuMaxHeight needlessly.
    expect(submenuSize.height, lessThan(180));
    expect(submenuSize.height, lessThan(280));
  });
}
