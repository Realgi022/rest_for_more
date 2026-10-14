import 'package:flutter_test/flutter_test.dart';

import 'package:rest_for_more/main.dart';

void main() {
  testWidgets('shows onboarding welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('WELCOME TO REST FOR MORE'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
