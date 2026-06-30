
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
      version: 4,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE notes(
            id TEXT PRIMARY KEY,
            userId TEXT,
            title TEXT,
            content TEXT,
            platform TEXT,
            timeSlot TEXT,
            scheduleDay TEXT,
            updatedAt INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          try {
            await db.execute('ALTER TABLE notes ADD COLUMN userId TEXT');
          } catch (e) {
            print("Migration v3: userId column error: $e");
          }
        }
        if (oldVersion < 4) {
          try {
            await db.execute('ALTER TABLE notes ADD COLUMN platform TEXT DEFAULT "Google"');
            await db.execute('ALTER TABLE notes ADD COLUMN timeSlot TEXT DEFAULT "09:00"');
            await db.execute('ALTER TABLE notes ADD COLUMN scheduleDay TEXT DEFAULT "Today"');
          } catch (e) {
            print("Migration v4: new columns error: $e");
          }
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

