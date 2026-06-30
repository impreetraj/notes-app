import 'package:flutter/material.dart';
import 'package:note_app_ikokas/model/theme_model.dart';

class ThemeState {
  final ThemeData themeData;
  final ThemeModel themeModel;

  ThemeState({required this.themeData, required this.themeModel});

  bool get isDarkMode => themeModel.isDarkMode;
}
