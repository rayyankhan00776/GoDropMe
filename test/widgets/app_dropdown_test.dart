import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:godropme/common_widgets/app_dropdown.dart';

void main() {
  testWidgets('AppDropdown opens sheet and selects item', (tester) async {
    String? selected;
    final items = ['One', 'Two', 'Three'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppDropdown(
            hint: 'Pick',
            value: null,
            items: items,
            onSelect: (v) => selected = v,
          ),
        ),
      ),
    );

    // Tap to open the bottom sheet
    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();

    // Choose the first item
    await tester.tap(find.text('One').first);
    await tester.pumpAndSettle();

    expect(selected, 'One');
  });
}
