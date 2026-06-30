import 'package:flutter/material.dart';

@immutable
abstract class ThemeEvent {}

class InitThemeEvent extends ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}
