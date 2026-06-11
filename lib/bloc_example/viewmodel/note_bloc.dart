import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_state_management/core/repository/note_repository.dart';

import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository repository;

  NoteBloc({required this.repository}) : super(const NoteState()) {
    on<LoadBlocNotesEvent>(_loadNotes);
    on<AddBlocNoteEvent>(_addNote);
    on<UpdateBlocNoteEvent>(_updateNote);
    on<DeleteBlocNoteEvent>(_deleteNote);
  }

  Future<void> _loadNotes(
    LoadBlocNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          errorMessage: null,
          completedAction: null,
        ),
      );

      final notes = await repository.loadNotes();

      emit(
        state.copyWith(
          localNotes: notes.localNotes,
          apiNotes: notes.apiNotes,
          isLoading: false,
          errorMessage: null,
          completedAction: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
          completedAction: null,
        ),
      );
    }
  }

  Future<void> _addNote(AddBlocNoteEvent event, Emitter<NoteState> emit) async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          errorMessage: null,
          completedAction: null,
        ),
      );

      await repository.addNote(
        title: event.title,
        description: event.description,
      );

      await _emitLoadedNotes(emit, completedAction: NoteAction.add);
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
          completedAction: null,
        ),
      );
    }
  }

  Future<void> _updateNote(
    UpdateBlocNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          errorMessage: null,
          completedAction: null,
        ),
      );

      await repository.updateNote(
        id: event.id,
        title: event.title,
        description: event.description,
      );

      await _emitLoadedNotes(emit, completedAction: NoteAction.update);
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
          completedAction: null,
        ),
      );
    }
  }

  Future<void> _deleteNote(
    DeleteBlocNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          errorMessage: null,
          completedAction: null,
        ),
      );

      await repository.deleteNote(event.id);

      await _emitLoadedNotes(emit, completedAction: NoteAction.delete);
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.toString(),
          completedAction: null,
        ),
      );
    }
  }

  Future<void> _emitLoadedNotes(
    Emitter<NoteState> emit, {
    required NoteAction completedAction,
  }) async {
    final notes = await repository.loadNotes();

    emit(
      state.copyWith(
        localNotes: notes.localNotes,
        apiNotes: notes.apiNotes,
        isLoading: false,
        errorMessage: null,
        completedAction: completedAction,
      ),
    );
  }
}
