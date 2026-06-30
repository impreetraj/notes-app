class ThemeModel {
  final bool isDarkMode;

  ThemeModel({required this.isDarkMode});

  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode ? 1 : 0,
    };
  }

  factory ThemeModel.fromMap(Map<String, dynamic> map) {
    return ThemeModel(
      isDarkMode: map['isDarkMode'] == 1,
    );
  }
}
