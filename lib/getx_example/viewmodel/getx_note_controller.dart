import 'package:flutter_state_management/core/models/note_model.dart';
import 'package:flutter_state_management/core/repository/note_repository.dart';
import 'package:get/get.dart';

class GetxNoteController extends GetxController {
  final NoteRepository repository;

  GetxNoteController({required this.repository});

  final RxList<NoteModel> localNotes = <NoteModel>[].obs;
  final RxList<NoteModel> apiNotes = <NoteModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();

    loadAllNotes();
  }

  Future<void> loadAllNotes() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final notes = await repository.loadNotes();

      localNotes.assignAll(notes.localNotes);
      apiNotes.assignAll(notes.apiNotes);
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addNote({
    required String title,
    required String description,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      await repository.addNote(title: title, description: description);

      await loadAllNotes();
      return true;
    } catch (error) {
      errorMessage.value = error.toString();
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> updateNote({
    required int id,
    required String title,
    required String description,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      await repository.updateNote(
        id: id,
        title: title,
        description: description,
      );

      await loadAllNotes();
      return true;
    } catch (error) {
      errorMessage.value = error.toString();
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> deleteNote(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      await repository.deleteNote(id);

      await loadAllNotes();
      return true;
    } catch (error) {
      errorMessage.value = error.toString();
      isLoading.value = false;
      return false;
    }
  }
}
