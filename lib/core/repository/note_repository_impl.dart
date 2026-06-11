import '../data/note_data_sources.dart';
import '../models/note_model.dart';
import 'note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource localDataSource;
  final NoteRemoteDataSource remoteDataSource;
  final NoteSource source;

  const NoteRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.source,
  });

  @override
  Future<NotesSnapshot> loadNotes() async {
    final results = await Future.wait<List<NoteModel>>([
      localDataSource.getNotesBySource(source),
      remoteDataSource.fetchNotesFromApi(),
    ]);

    return NotesSnapshot(localNotes: results[0], apiNotes: results[1]);
  }

  @override
  Future<void> addNote({
    required String title,
    required String description,
  }) async {
    await localDataSource.insertNote(
      NoteModel(title: title, description: description, source: source),
    );
  }

  @override
  Future<void> updateNote({
    required int id,
    required String title,
    required String description,
  }) async {
    final oldNote = await localDataSource.getNoteById(id);

    if (oldNote == null || oldNote.source != source) {
      throw StateError('Note not found for ${source.name}');
    }

    await localDataSource.updateNote(
      oldNote.copyWith(title: title, description: description),
    );
  }

  @override
  Future<void> deleteNote(int id) async {
    final oldNote = await localDataSource.getNoteById(id);

    if (oldNote == null || oldNote.source != source) {
      throw StateError('Note not found for ${source.name}');
    }

    await localDataSource.deleteNote(id);
  }
}
