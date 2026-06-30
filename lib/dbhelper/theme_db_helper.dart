import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:note_app_ikokas/model/theme_model.dart';

class ThemeLocalDbService {
  static Database? _db;

  Future<Database> get db async {
    _db ??= await init();
    return _db!;
  }

  Future<Database> init() async {
    final path = join(await getDatabasesPath(), 'settings.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE theme_settings(
            id INTEGER PRIMARY KEY,
            isDarkMode INTEGER
          )
        ''');
        
        await db.insert('theme_settings', {'id': 1, 'isDarkMode': 0});
      },
    );
  }

  Future<void> saveTheme(ThemeModel themeModel) async {
    final database = await db;
    await database.update(
      'theme_settings',
      themeModel.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<ThemeModel> getTheme() async {
    final database = await db;
    final result = await database.query('theme_settings', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return ThemeModel.fromMap(result.first);
    }
    return ThemeModel(isDarkMode: false);
  }
}
