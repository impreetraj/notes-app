
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class UserLocalDbService {
  static Database? _db;

  Future<Database> get db async {
    _db ??= await init();
    return _db!;
  }

  Future<Database> init() async {
    final path = join(await getDatabasesPath(), 'users.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE users(
            uid TEXT PRIMARY KEY,
            name TEXT,
            email TEXT,
            createdAt INTEGER
          )
        ''');
      },
    );
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    final database = await db;
    await database.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final database = await db;
    final result = await database.query('users', where: 'uid = ?', whereArgs: [uid]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> deleteUser(String uid) async {
    final database = await db;
    await database.delete('users', where: 'uid = ?', whereArgs: [uid]);
  }
}
