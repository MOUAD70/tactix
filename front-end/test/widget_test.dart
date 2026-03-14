import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/features/formation/formation_screen.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('boots into the home shell with all five main sections', (WidgetTester tester) async {
    await tester.pumpWidget(const TactixApp());

    expect(find.text('Team overview'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Formation'), findsWidgets);
    expect(find.text('Players'), findsWidgets);
    expect(find.text('Training'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });

  testWidgets('opens formation board from home quick action', (WidgetTester tester) async {
    await tester.pumpWidget(const TactixApp());
    await tester.pumpAndSettle();

    expect(find.text('Team overview'), findsOneWidget);

    final quickNavigationCard = find.ancestor(
      of: find.text('Quick navigation'),
      matching: find.byType(Card),
    );
    final formationQuickAction = find.ancestor(
      of: find.descendant(of: quickNavigationCard, matching: find.text('Formation')),
      matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
    );

    await tester.ensureVisible(formationQuickAction);
    await tester.tap(formationQuickAction);
    await tester.pumpAndSettle();

    expect(find.byType(FormationBoard), findsOneWidget);
    expect(find.text('Interactive tactical board'), findsOneWidget);
    expect(find.text('Saved formations'), findsOneWidget);
  });

  testWidgets('ignores repeated taps while opening formation board', (WidgetTester tester) async {
    await tester.pumpWidget(const TactixApp());
    await tester.pumpAndSettle();

    final quickNavigationCard = find.ancestor(
      of: find.text('Quick navigation'),
      matching: find.byType(Card),
    );
    final formationQuickAction = find.ancestor(
      of: find.descendant(of: quickNavigationCard, matching: find.text('Formation')),
      matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
    );

    await tester.ensureVisible(formationQuickAction);
    await tester.tap(formationQuickAction);
    await tester.tap(formationQuickAction, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(FormationBoard), findsOneWidget);
  });
}
