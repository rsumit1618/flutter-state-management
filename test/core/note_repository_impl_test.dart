// TEST TYPE: UNIT TEST
//
// Tests repository behavior with in-memory local and remote data-source fakes.
// It deliberately avoids the real SQLite database and simulated API service.

import 'package:flutter_state_management/core/data/note_data_sources.dart';
import 'package:flutter_state_management/core/models/note_model.dart';
import 'package:flutter_state_management/core/repository/note_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeLocalDataSource local;
  late _FakeRemoteDataSource remote;
  late NoteRepositoryImpl repository;

  setUp(() {
    local = _FakeLocalDataSource();
    remote = _FakeRemoteDataSource();
    repository = NoteRepositoryImpl(
      localDataSource: local,
      remoteDataSource: remote,
      source: NoteSource.getx,
    );
  });

  test('loads local and remote notes into one snapshot', () async {
    local.notes.add(
      const NoteModel(
        id: 1,
        title: 'Local',
        description: 'SQLite',
        source: NoteSource.getx,
      ),
    );
    remote.notes.add(
      const NoteModel(
        title: 'Remote',
        description: 'API',
        source: NoteSource.api,
      ),
    );

    final result = await repository.loadNotes();

    expect(result.localNotes.single.title, 'Local');
    expect(result.apiNotes.single.title, 'Remote');
  });

  test('adds a note with the repository source', () async {
    await repository.addNote(title: 'GetX', description: 'Controller');

    expect(local.notes.single.source, NoteSource.getx);
  });

  test('rejects updates for another state-management source', () async {
    local.notes.add(
      const NoteModel(
        id: 1,
        title: 'BLoC note',
        description: 'Owned by BLoC',
        source: NoteSource.bloc,
      ),
    );

    expect(
      () => repository.updateNote(
        id: 1,
        title: 'Wrong owner',
        description: 'Should fail',
      ),
      throwsStateError,
    );
  });
}

class _FakeLocalDataSource implements NoteLocalDataSource {
  final List<NoteModel> notes = [];

  @override
  Future<int> insertNote(NoteModel note) async {
    notes.add(note.copyWith(id: notes.length + 1));
    return notes.length;
  }

  @override
  Future<List<NoteModel>> getNotesBySource(NoteSource source) async {
    return notes.where((note) => note.source == source).toList();
  }

  @override
  Future<NoteModel?> getNoteById(int id) async {
    for (final note in notes) {
      if (note.id == id) {
        return note;
      }
    }
    return null;
  }

  @override
  Future<int> updateNote(NoteModel note) async {
    final index = notes.indexWhere((item) => item.id == note.id);
    notes[index] = note;
    return 1;
  }

  @override
  Future<int> deleteNote(int id) async {
    notes.removeWhere((note) => note.id == id);
    return 1;
  }
}

class _FakeRemoteDataSource implements NoteRemoteDataSource {
  final List<NoteModel> notes = [];

  @override
  Future<List<NoteModel>> fetchNotesFromApi() async {
    return List<NoteModel>.unmodifiable(notes);
  }
}
