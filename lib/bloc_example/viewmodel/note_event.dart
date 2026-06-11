abstract class NoteEvent {}

class LoadBlocNotesEvent extends NoteEvent {}

class AddBlocNoteEvent extends NoteEvent {
  final String title;
  final String description;

  AddBlocNoteEvent({required this.title, required this.description});
}

class UpdateBlocNoteEvent extends NoteEvent {
  final int id;
  final String title;
  final String description;

  UpdateBlocNoteEvent({
    required this.id,
    required this.title,
    required this.description,
  });
}

class DeleteBlocNoteEvent extends NoteEvent {
  final int id;

  DeleteBlocNoteEvent({required this.id});
}
