import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:godropme/common_widgets/app_multi_select.dart';
import 'package:godropme/constants/app_strings.dart';

void main() {
  testWidgets('AppMultiSelect opens sheet and returns selected items', (
    tester,
  ) async {
    List<String> selected = [];
    final items = ['Alpha', 'Beta', 'Gamma'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppMultiSelect(
            hint: 'Select items',
            items: items,
            selected: const [],
            onChanged: (v) => selected = v,
          ),
        ),
      ),
    );

    // Open the bottom sheet
    await tester.tap(find.text('Select items'));
    await tester.pumpAndSettle();

    // Toggle first two items
    await tester.tap(find.text('Alpha').first);
    await tester.pump();
    await tester.tap(find.text('Beta').first);
    await tester.pump();

    // Tap Done
    await tester.tap(find.text(AppStrings.done));
    await tester.pumpAndSettle();

    expect(selected, containsAll(<String>['Alpha', 'Beta']));
  });
}
