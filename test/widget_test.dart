// Basic smoke test to validate app boots to the Onboard screen.
import 'package:flutter_test/flutter_test.dart';
import 'package:godropme/main.dart';
import 'package:godropme/constants/app_strings.dart';

void main() {
  testWidgets('App boots to Onboard screen', (tester) async {
    await tester.pumpWidget(const GoDropMe());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.onboardTitle1), findsOneWidget);
    expect(find.text(AppStrings.onboardSkip), findsOneWidget);
  });
}
