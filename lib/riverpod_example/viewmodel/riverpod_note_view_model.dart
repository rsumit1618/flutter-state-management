import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_state_management/core/api/api_service.dart';
import 'package:flutter_state_management/core/database/app_database.dart';
import 'package:flutter_state_management/core/models/note_model.dart';
import 'package:flutter_state_management/core/repository/note_repository.dart';
import 'package:flutter_state_management/core/repository/note_repository_impl.dart';

final riverpodNoteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(
    localDataSource: AppDatabase.instance,
    remoteDataSource: ApiService(),
    source: NoteSource.riverpod,
  );
});

final riverpodNoteViewModelProvider =
    AsyncNotifierProvider.autoDispose<RiverpodNoteViewModel, NotesSnapshot>(
      RiverpodNoteViewModel.new,
    );

class RiverpodNoteViewModel extends AutoDisposeAsyncNotifier<NotesSnapshot> {
  NoteRepository get _repository => ref.read(riverpodNoteRepositoryProvider);

  @override
  Future<NotesSnapshot> build() {
    return _repository.loadNotes();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.loadNotes);
  }

  Future<bool> addNote({required String title, required String description}) {
    return _mutate(
      () => _repository.addNote(title: title, description: description),
    );
  }

  Future<bool> updateNote({
    required int id,
    required String title,
    required String description,
  }) {
    return _mutate(
      () => _repository.updateNote(
        id: id,
        title: title,
        description: description,
      ),
    );
  }

  Future<bool> deleteNote(int id) {
    return _mutate(() => _repository.deleteNote(id));
  }

  Future<bool> _mutate(Future<void> Function() operation) async {
    state = const AsyncLoading();

    final nextState = await AsyncValue.guard(() async {
      await operation();
      return _repository.loadNotes();
    });

    state = nextState;
    return !nextState.hasError;
  }
}
