import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _tempUnit = 'C';
  int _refreshIntervalMs = 5000;
  String? _lastDeviceId;
  bool _autoReconnect = false;

  ThemeMode get themeMode => _themeMode;
  String get tempUnit => _tempUnit;
  int get refreshIntervalMs => _refreshIntervalMs;
  String? get lastDeviceId => _lastDeviceId;
  bool get autoReconnect => _autoReconnect;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    
    _tempUnit = prefs.getString('tempUnit') ?? 'C';
    _refreshIntervalMs = prefs.getInt('refreshIntervalMs') ?? 5000;
    _lastDeviceId = prefs.getString('lastDeviceId');
    _autoReconnect = prefs.getBool('autoReconnect') ?? false;
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setTempUnit(String unit) async {
    _tempUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tempUnit', unit);
    notifyListeners();
  }

  Future<void> setRefreshIntervalMs(int ms) async {
    _refreshIntervalMs = ms;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('refreshIntervalMs', ms);
    notifyListeners();
  }

  Future<void> setLastDeviceId(String? id) async {
    _lastDeviceId = id;
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove('lastDeviceId');
    } else {
      await prefs.setString('lastDeviceId', id);
    }
    notifyListeners();
  }

  Future<void> setAutoReconnect(bool value) async {
    _autoReconnect = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoReconnect', value);
    notifyListeners();
  }

  String formatTemp(double celsius) {
    if (_tempUnit == 'F') {
      return '${(celsius * 9 / 5 + 32).toStringAsFixed(1)}°F';
    }
    return '${celsius.toStringAsFixed(1)}°C';
  }

  String formatTempShort(double celsius) {
    if (_tempUnit == 'F') {
      return '${(celsius * 9 / 5 + 32).toStringAsFixed(0)}°';
    }
    return '${celsius.toStringAsFixed(0)}°';
  }
}
