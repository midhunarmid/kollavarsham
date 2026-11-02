import 'package:calendar/data/database.dart';
import 'package:calendar/data/models.dart';
import 'package:calendar/features/people/person_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers.dart';

void main() {
  testWidgets('add, edit and delete a person', (tester) async {
    final prefs = await pumpApp(tester, settings: enSettings);
    await tapTab(tester, 'People');
    expect(find.textContaining('No people yet'), findsOneWidget);

    // Add: an empty name is refused.
    await tester.tap(find.byKey(const Key('add-person')));
    await tester.pumpAndSettle();
    expect(find.text('New person'), findsOneWidget);
    await tester.tap(find.byKey(const Key('save-person')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a name'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('person-name')), ' Midhun ');
    await tester.tap(find.byKey(const Key('relation-self')));
    await tester.tap(find.byKey(const Key('colour-2')));
    await tester.enterText(find.byKey(const Key('person-notes')), 'Born 1990');
    await tester.tap(find.byKey(const Key('save-person')));
    await tester.pumpAndSettle();

    // Saving opens the new person's detail.
    expect(find.byType(PersonScreen), findsOneWidget);
    expect(find.text('Born 1990'), findsOneWidget);
    expect(find.text('No events yet.'), findsOneWidget);
    var saved = AppDatabase(prefs).load().people.single;
    expect(saved.name, 'Midhun');
    expect(saved.relation, Relation.self);
    expect(saved.color, personColors[2]);

    // Edit.
    await tester.tap(find.byKey(const Key('edit-person')));
    await tester.pumpAndSettle();
    expect(find.text('Edit person'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('person-name')), 'Midhun M');
    await tester.tap(find.byKey(const Key('relation-family')));
    await tester.tap(find.byKey(const Key('save-person')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Midhun M'), findsOneWidget);
    saved = AppDatabase(prefs).load().people.single;
    expect(saved.relation, Relation.family);

    // Back to the list.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Midhun M'), findsOneWidget);
    expect(find.text('Family'), findsOneWidget);

    // Delete, after cancelling once.
    await tester.tap(find.text('Midhun M'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('delete-person')));
    await tester.pumpAndSettle();
    expect(find.text('Delete Midhun M?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(PersonScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('delete-person')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete')));
    await tester.pumpAndSettle();
    expect(find.textContaining('No people yet'), findsOneWidget);
    expect(AppDatabase(prefs).load().people, isEmpty);
  });

  testWidgets('the list puts the user first and is in Malayalam',
      (tester) async {
    final prefs = await testPrefs(mlSettings);
    await AppDatabase(prefs).save(const DbSnapshot(people: [
      Person(id: 1, name: 'Ajay', relation: Relation.friend),
      Person(id: 2, name: 'Amma', relation: Relation.family),
      Person(id: 3, name: 'Midhun', relation: Relation.self),
    ], nextId: 4));
    await pumpApp(tester, settings: null, prefs: prefs);
    await tapTab(tester, 'ആളുകൾ');
    final names = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((t) => (t.title! as Text).data)
        .toList();
    expect(names, ['Midhun', 'Ajay', 'Amma']);
    expect(find.text('ഞാൻ'), findsOneWidget);
    expect(find.text('സുഹൃത്ത്'), findsOneWidget);
  });

  testWidgets('a missing person shows a note', (tester) async {
    await pumpApp(tester, settings: enSettings);
    GoRouter.of(tester.element(find.byType(NavigationBar))).push('/person/99');
    await tester.pumpAndSettle();
    expect(find.text('This person is no longer in your list.'), findsOneWidget);
  });
}
