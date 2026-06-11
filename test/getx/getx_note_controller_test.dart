// TEST TYPE: UNIT TEST
//
// Tests GetxNoteController and its reactive values with a fake repository.
// No widget tree, GetMaterialApp, SQLite database, or device is required.

import 'package:flutter_state_management/getx_example/viewmodel/getx_note_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_note_repository.dart';

void main() {
  test('loads notes and exposes reactive collections', () async {
    final repository = FakeNoteRepository();
    await repository.addNote(title: 'GetX', description: 'Reactive controller');
    final controller = GetxNoteController(repository: repository);

    await controller.loadAllNotes();

    expect(controller.localNotes.single.title, 'GetX');
    expect(controller.isLoading.value, isFalse);
  });

  test('returns false and exposes an error when a mutation fails', () async {
    final controller = GetxNoteController(
      repository: FakeNoteRepository(error: StateError('database failed')),
    );

    final result = await controller.addNote(
      title: 'Failure',
      description: 'Expected',
    );

    expect(result, isFalse);
    expect(controller.errorMessage.value, contains('database failed'));
  });
}
