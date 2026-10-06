import 'package:flutter_test/flutter_test.dart';

import 'package:rest_for_more/main.dart';

void main() {
  testWidgets('shows the Today screen on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.pump();

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Modes'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
