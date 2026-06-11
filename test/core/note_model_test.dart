// TEST TYPE: UNIT TEST
//
// Tests the NoteModel value and mapping behavior without Flutter UI, plugins,
// or external dependencies.

import 'package:flutter_state_management/core/models/note_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteModel', () {
    test('round-trips through the database map', () {
      const note = NoteModel(
        id: 7,
        title: 'Architecture',
        description: 'Repository pattern',
        source: NoteSource.riverpod,
      );

      final restored = NoteModel.fromMap(note.toMap());

      expect(restored.id, 7);
      expect(restored.title, 'Architecture');
      expect(restored.description, 'Repository pattern');
      expect(restored.source, NoteSource.riverpod);
    });

    test('copyWith changes only supplied values', () {
      const note = NoteModel(
        id: 1,
        title: 'Old',
        description: 'Keep me',
        source: NoteSource.bloc,
      );

      final updated = note.copyWith(title: 'New');

      expect(updated.id, note.id);
      expect(updated.title, 'New');
      expect(updated.description, note.description);
      expect(updated.source, note.source);
    });
  });
}
