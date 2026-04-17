
import 'package:note_app_ikokas/model/note_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbService {
  static Database? _db;

  Future<Database> get db async {
    _db ??= await init();
    return _db!;
  }

  Future<Database> init() async {
    final path = join(await getDatabasesPath(), 'notes.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE notes(
            id TEXT PRIMARY KEY,
            userId TEXT,
            title TEXT,
            content TEXT,
            updatedAt INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE notes ADD COLUMN userId TEXT');
        }
      },
    );
  }

  Future<void> insert(Note note) async {
    final database = await db;
    await database.insert(
      'notes',
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print("data save in sqflite");
  }

  Future<List<Note>> getNotes(String userId) async {
    final database = await db;
    final result = await database.query(
      'notes',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((e) => Note.fromMap(e)).toList();
  }

  Future<void> delete(String id) async {
    final database = await db;
    await database.delete('notes', where: 'id=?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final database = await db;
    await database.delete('notes');
  }
}

