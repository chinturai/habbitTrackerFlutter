import 'package:flutter/material.dart';
import 'package:habbit_tracker/themes/dark_mode.dart';
import 'package:habbit_tracker/themes/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  // initially light mode
  ThemeData _themeData = lightMode;

  // get current theme
  ThemeData get themeData => _themeData;

  // is current theme dark ?
  bool get isDarkMode => _themeData == darkMode;

  // set the theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  // toggle the theme
  void toggleTheme() {
    if( _themeData == lightMode) {
      _themeData = darkMode;
    }
    else {
      _themeData = lightMode;
    }

    notifyListeners();
  }
}