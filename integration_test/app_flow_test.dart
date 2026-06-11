// TEST TYPE: INTEGRATION TEST
//
// This test launches the complete Flutter app and follows a real BLoC + SQLite
// user journey. It must run on an emulator or physical device.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_state_management/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user adds a BLoC note through the complete app flow', (
    tester,
  ) async {
    final uniqueTitle =
        'Integration note ${DateTime.now().millisecondsSinceEpoch}';

    await tester.pumpWidget(const ProviderScope(child: MainMenuApp()));

    await tester.tap(find.byKey(const Key('open_bloc_example')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.byKey(const Key('bloc_add_note_button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('bloc_note_title_field')),
      uniqueTitle,
    );
    await tester.enterText(
      find.byKey(const Key('bloc_note_description_field')),
      'Created by integration_test',
    );
    await tester.tap(find.byKey(const Key('bloc_save_note_button')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text(uniqueTitle), findsOneWidget);
  });
}
