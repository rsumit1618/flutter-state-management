import '../models/note_model.dart';
import '../data/note_data_sources.dart';

class ApiService implements NoteRemoteDataSource {
  @override
  Future<List<NoteModel>> fetchNotesFromApi() async {
    await Future.delayed(const Duration(seconds: 1));

    return const [
      NoteModel(
        title: 'API Note 1',
        description: 'This note came from shared ApiService.',
        source: NoteSource.api,
      ),
      NoteModel(
        title: 'API Note 2',
        description: 'Same API service can be used in any screen.',
        source: NoteSource.api,
      ),
      NoteModel(
        title: 'API Note 3',
        description: 'Repository decides how to use API and database.',
        source: NoteSource.api,
      ),
    ];
  }
}
