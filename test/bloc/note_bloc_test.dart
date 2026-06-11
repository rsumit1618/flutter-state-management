// TEST TYPE: UNIT TEST
//
// Tests NoteBloc in isolation with a fake repository. No widgets, SQLite
// database, API service, or device are started.

import 'package:flutter_state_management/bloc_example/viewmodel/note_bloc.dart';
import 'package:flutter_state_management/bloc_example/viewmodel/note_event.dart';
import 'package:flutter_state_management/bloc_example/viewmodel/note_state.dart';
import 'package:flutter_state_management/core/models/note_model.dart';
import 'package:flutter_state_management/core/repository/note_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_note_repository.dart';

void main() {
  test('load event emits repository notes', () async {
    final repository = FakeNoteRepository(
      snapshot: const NotesSnapshot(
        localNotes: [
          NoteModel(
            id: 1,
            title: 'BLoC',
            description: 'Event and state',
            source: NoteSource.bloc,
          ),
        ],
      ),
    );
    final bloc = NoteBloc(repository: repository);
    addTearDown(bloc.close);

    final loadedState = bloc.stream.firstWhere(
      (state) => !state.isLoading && state.localNotes.isNotEmpty,
    );
    bloc.add(LoadBlocNotesEvent());

    expect((await loadedState).localNotes.single.title, 'BLoC');
  });

  test('add event refreshes notes and reports the completed action', () async {
    final repository = FakeNoteRepository();
    final bloc = NoteBloc(repository: repository);
    addTearDown(bloc.close);

    final completedState = bloc.stream.firstWhere(
      (state) => state.completedAction == NoteAction.add,
    );
    bloc.add(AddBlocNoteEvent(title: 'Added', description: 'From a unit test'));

    final state = await completedState;
    expect(state.localNotes.single.title, 'Added');
    expect(state.isLoading, isFalse);
  });

  test('repository errors become failure state', () async {
    final bloc = NoteBloc(
      repository: FakeNoteRepository(error: StateError('offline')),
    );
    addTearDown(bloc.close);

    final failureState = bloc.stream.firstWhere(
      (state) => state.errorMessage != null,
    );
    bloc.add(LoadBlocNotesEvent());

    expect((await failureState).errorMessage, contains('offline'));
  });
}
