import '../models/note_model.dart';

abstract interface class NoteLocalDataSource {
  Future<int> insertNote(NoteModel note);

  Future<List<NoteModel>> getNotesBySource(NoteSource source);

  Future<NoteModel?> getNoteById(int id);

  Future<int> updateNote(NoteModel note);

  Future<int> deleteNote(int id);
}

abstract interface class NoteRemoteDataSource {
  Future<List<NoteModel>> fetchNotesFromApi();
}
