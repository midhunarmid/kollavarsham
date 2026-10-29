import 'package:calendar/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts with the localized title', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: CalendarApp()));
    await tester.pumpAndSettle();
    expect(find.text('Malayalam Calendar'), findsOneWidget);
  });
}
