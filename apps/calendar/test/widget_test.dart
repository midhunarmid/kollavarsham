import 'package:calendar/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const CalendarApp());
    expect(find.text('Malayalam Calendar'), findsOneWidget);
  });
}
