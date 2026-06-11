// TEST TYPE: UNIT TEST
//
// Tests the Riverpod AsyncNotifier inside ProviderContainer. The repository
// provider is overridden, so this test does not use Flutter UI or SQLite.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_state_management/riverpod_example/viewmodel/riverpod_note_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_note_repository.dart';

void main() {
  test('AsyncNotifier loads and mutates notes through an override', () async {
    final repository = FakeNoteRepository();
    final container = ProviderContainer(
      overrides: [riverpodNoteRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(riverpodNoteViewModelProvider.future);
    final didSave = await container
        .read(riverpodNoteViewModelProvider.notifier)
        .addNote(title: 'Riverpod', description: 'AsyncNotifier');

    expect(didSave, isTrue);
    expect(
      container
          .read(riverpodNoteViewModelProvider)
          .value!
          .localNotes
          .single
          .title,
      'Riverpod',
    );
  });

  test('AsyncNotifier stores mutation failures in AsyncError', () async {
    final repository = FakeNoteRepository();
    final container = ProviderContainer(
      overrides: [riverpodNoteRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(riverpodNoteViewModelProvider.future);
    repository.error = StateError('remote failure');

    final didSave = await container
        .read(riverpodNoteViewModelProvider.notifier)
        .addNote(title: 'Failure', description: 'Expected');

    expect(didSave, isFalse);
    expect(container.read(riverpodNoteViewModelProvider).hasError, isTrue);
  });
}
