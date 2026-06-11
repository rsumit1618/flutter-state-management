import 'package:flutter_state_management/core/models/note_model.dart';

enum NoteAction { add, update, delete }

const _notProvided = Object();

class NoteState {
  final List<NoteModel> localNotes;
  final List<NoteModel> apiNotes;
  final bool isLoading;
  final String? errorMessage;
  final NoteAction? completedAction;

  const NoteState({
    this.localNotes = const [],
    this.apiNotes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.completedAction,
  });

  NoteState copyWith({
    List<NoteModel>? localNotes,
    List<NoteModel>? apiNotes,
    bool? isLoading,
    Object? errorMessage = _notProvided,
    Object? completedAction = _notProvided,
  }) {
    return NoteState(
      localNotes: localNotes ?? this.localNotes,
      apiNotes: apiNotes ?? this.apiNotes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _notProvided)
          ? this.errorMessage
          : errorMessage as String?,
      completedAction: identical(completedAction, _notProvided)
          ? this.completedAction
          : completedAction as NoteAction?,
    );
  }
}
