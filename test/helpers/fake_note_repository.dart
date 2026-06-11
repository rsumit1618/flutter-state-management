// TEST SUPPORT: FAKE DEPENDENCY
//
// This controllable in-memory repository is shared by unit tests. It is not a
// test itself and is never used by the production application.

import 'package:flutter_state_management/core/models/note_model.dart';
import 'package:flutter_state_management/core/repository/note_repository.dart';

class FakeNoteRepository implements NoteRepository {
  NotesSnapshot snapshot;
  Object? error;

  FakeNoteRepository({NotesSnapshot? snapshot, this.error})
    : snapshot = snapshot ?? const NotesSnapshot();

  @override
  Future<NotesSnapshot> loadNotes() async {
    _throwWhenConfigured();
    return snapshot;
  }

  @override
  Future<void> addNote({
    required String title,
    required String description,
  }) async {
    _throwWhenConfigured();
    final nextId = snapshot.localNotes.length + 1;
    snapshot = NotesSnapshot(
      localNotes: [
        NoteModel(
          id: nextId,
          title: title,
          description: description,
          source: NoteSource.bloc,
        ),
        ...snapshot.localNotes,
      ],
      apiNotes: snapshot.apiNotes,
    );
  }

  @override
  Future<void> updateNote({
    required int id,
    required String title,
    required String description,
  }) async {
    _throwWhenConfigured();
    snapshot = NotesSnapshot(
      localNotes: snapshot.localNotes.map((note) {
        if (note.id != id) {
          return note;
        }
        return note.copyWith(title: title, description: description);
      }).toList(),
      apiNotes: snapshot.apiNotes,
    );
  }

  @override
  Future<void> deleteNote(int id) async {
    _throwWhenConfigured();
    snapshot = NotesSnapshot(
      localNotes: snapshot.localNotes.where((note) => note.id != id).toList(),
      apiNotes: snapshot.apiNotes,
    );
  }

  void _throwWhenConfigured() {
    final configuredError = error;
    if (configuredError != null) {
      throw configuredError;
    }
  }
}
