import '../models/note_model.dart';

class NotesSnapshot {
  final List<NoteModel> localNotes;
  final List<NoteModel> apiNotes;

  const NotesSnapshot({this.localNotes = const [], this.apiNotes = const []});
}

abstract interface class NoteRepository {
  Future<NotesSnapshot> loadNotes();

  Future<void> addNote({required String title, required String description});

  Future<void> updateNote({
    required int id,
    required String title,
    required String description,
  });

  Future<void> deleteNote(int id);
}
