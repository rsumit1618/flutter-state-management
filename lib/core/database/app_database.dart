import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/note_data_sources.dart';
import '../models/note_model.dart';

class AppDatabase implements NoteLocalDataSource {
  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'shared_notes_app.db');

    return openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        source TEXT NOT NULL
      )
    ''');
  }

  @override
  Future<int> insertNote(NoteModel note) async {
    final db = await database;

    return db.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<NoteModel>> getNotesBySource(NoteSource source) async {
    final db = await database;

    final result = await db.query(
      'notes',
      where: 'source = ?',
      whereArgs: [source.name],
      orderBy: 'id DESC',
    );

    return result.map((map) => NoteModel.fromMap(map)).toList();
  }

  @override
  Future<NoteModel?> getNoteById(int id) async {
    final db = await database;

    final result = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return NoteModel.fromMap(result.first);
  }

  @override
  Future<int> updateNote(NoteModel note) async {
    final db = await database;

    return db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<int> deleteNote(int id) async {
    final db = await database;

    return db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
