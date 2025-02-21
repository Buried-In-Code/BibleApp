import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/translation.dart';
import '../utils.dart';

class SettingsConstants {
  static const Map<String, String> translations = {
    'Bible in Basic English': 'BBE',
    'English Standard Version': 'ESV',
    'King James Version': 'KJV',
    'Young\'s Literal Translation': 'YLT',
  };
}

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  late Translation _translation;
  Translation get translation => _translation;

  SettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    int? themeModeIndex = preferences.getInt('themeMode');
    if (themeModeIndex != null) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }
    String? acronym = preferences.getString('translation');
    if (acronym != null) {
      _translation = await getTranslation(acronym);
    } else {
      _translation = await getTranslation('KJV');
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt('themeMode', mode.index);
  }

  void setTranslation(String acronym) async {
    _translation = await getTranslation(acronym);
    notifyListeners();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('translation', translation.acronym);
  }
}
