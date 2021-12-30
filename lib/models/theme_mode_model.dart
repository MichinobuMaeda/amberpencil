import 'package:flutter/foundation.dart';

class ThemeModeModel extends ChangeNotifier {
  bool _darkMode = false;

  set darkMode(bool val) {
    if (_darkMode != val) {
      _darkMode = val;
      notifyListeners();
    }
  }

  bool get darkMode => _darkMode;
}
