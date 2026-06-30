import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app_ikokas/dbhelper/theme_db_helper.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import 'package:note_app_ikokas/model/theme_model.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeLocalDbService dbService;

  ThemeBloc(this.dbService, {required bool initialIsDarkMode})
      : super(initialIsDarkMode ? _darkThemeState : _lightThemeState) {
    
    // No need for InitThemeEvent anymore since we pass initial state in constructor
    
    on<ToggleThemeEvent>((event, emit) async {
      final newIsDarkMode = !state.isDarkMode;
      final themeModel = ThemeModel(isDarkMode: newIsDarkMode);

      await dbService.saveTheme(themeModel);

      if (newIsDarkMode) {
        emit(_darkThemeState);
      } else {
        emit(_lightThemeState);
      }
    });
  }

  static final _lightThemeState = ThemeState(
    themeModel: ThemeModel(isDarkMode: false),
    themeData: ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      cardColor: Colors.white,
      dialogBackgroundColor: Colors.white,
      dividerColor: const Color(0xFFEEEEEE),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
        surface: const Color(0xFFF8F9FA),
        onSurface: const Color(0xFF1A1A1A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(0xFF1A1A1A),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F3F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
      ),
    ),
  );

  static final _darkThemeState = ThemeState(
    themeModel: ThemeModel(isDarkMode: true),
    themeData: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      dialogBackgroundColor: const Color(0xFF1E1E1E),
      dividerColor: const Color(0xFF2C2C2C),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
        surface: const Color(0xFF121212),
        onSurface: const Color(0xFFE0E0E0),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(0xFFE0E0E0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: TextStyle(color: Colors.grey[600]),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
      ),
    ),
  );
}
