// TEST TYPE: WIDGET TEST
//
// These tests render Flutter widgets in the test runtime and verify visible
// content, navigation, and interaction. They do not use a real device or the
// real SQLite plugin.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_state_management/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('main menu exposes all learning examples', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MainMenuApp()));

    expect(find.text('Flutter State Management Lab'), findsOneWidget);
    expect(find.text('BLoC Notes Example'), findsOneWidget);
    expect(find.text('GetX Notes Example'), findsOneWidget);
    expect(find.text('Riverpod Notes Example'), findsOneWidget);
    expect(find.text('Flutter Interview Concepts'), findsOneWidget);
  });

  testWidgets('concept page demonstrates local state', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MainMenuApp()));

    await tester.tap(find.byKey(const Key('open_interview_concepts')));
    await tester.pumpAndSettle();

    expect(find.text('Ephemeral state with ValueNotifier'), findsOneWidget);
    expect(find.text('Count: 0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('concept_counter_button')));
    await tester.pump();

    expect(find.text('Count: 1'), findsOneWidget);
  });
}
