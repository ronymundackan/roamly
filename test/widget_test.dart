import 'package:flutter_test/flutter_test.dart';

import 'package:roamly/main.dart';

void main() {
  testWidgets('RoamlyApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RoamlyApp());

    // Verify that the splash screen is shown
    expect(find.text('Roamly'), findsOneWidget);
  });
}
