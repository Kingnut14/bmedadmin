import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider with ChangeNotifier {
  double _fontSize = 16.0; // Default font size
  static const double _minFontSize = 10.0; // Smallest allowed
  static const double _maxFontSize = 30.0; // Largest allowed

  double get fontSize => _fontSize;

  FontSizeProvider() {
    _loadFontSize();
  }

  Future<void> setFontSize(double newSize) async {
    // Limit font size to avoid extreme values
    if (newSize < _minFontSize) newSize = _minFontSize;
    if (newSize > _maxFontSize) newSize = _maxFontSize;

    if (_fontSize != newSize) {
      _fontSize = newSize;
      await _saveFontSize(newSize);
      notifyListeners(); // Notify only when value changes
    }
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    double? savedSize = prefs.getDouble('fontSize');

    if (savedSize != null && savedSize != _fontSize) {
      _fontSize = savedSize;
      notifyListeners(); // Notify only if different
    }
  }

  Future<void> _saveFontSize(double newSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', newSize);
  }

  // Reset to default font size
  Future<void> resetFontSize() async {
    _fontSize = 16.0;
    await _saveFontSize(_fontSize);
    notifyListeners();
  }
}
