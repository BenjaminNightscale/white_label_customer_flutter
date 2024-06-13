import 'package:flutter/material.dart';
import 'package:white_label_customer_flutter/themes/dark_mode.dart';
import 'package:white_label_customer_flutter/themes/light_mode.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = darkMode;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    _themeData = _themeData == lightMode ? darkMode : lightMode;
  }
}