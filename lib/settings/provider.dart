import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  String _translation = 'KJV';
  String get translation => _translation;

  bool _ttsEnabled = false;
  bool get ttsEnabled => _ttsEnabled;

  SettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    int? themeModeIndex = preferences.getInt('themeMode');
    if (themeModeIndex != null) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }
    String? translation = preferences.getString('translation');
    if (translation != null) {
      _translation = translation;
    }
    bool? ttsEnabled = preferences.getBool('ttsEnabled');
    if (ttsEnabled != null) {
      _ttsEnabled = ttsEnabled;
    }

    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt('themeMode', mode.index);
  }

  void setTranslation(String translation) async {
    _translation = translation;
    notifyListeners();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('translation', translation);
  }

  void setTtsEnabled(bool enabled) async {
    _ttsEnabled = enabled;
    notifyListeners();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool('ttsEnabled', enabled);
  }
}
