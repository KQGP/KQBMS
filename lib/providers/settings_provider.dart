import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String defaultWifiHost = 'kqbms-bridge.local';
  static const int defaultWifiPort = 3333;

  ThemeMode _themeMode = ThemeMode.system;
  String _tempUnit = 'C';
  int _refreshIntervalMs = 5000;
  String? _lastDeviceId;
  bool _autoReconnect = false;
  String _transportMode = 'ble';
  String _wifiHost = defaultWifiHost;
  int _wifiPort = defaultWifiPort;

  ThemeMode get themeMode => _themeMode;
  String get tempUnit => _tempUnit;
  int get refreshIntervalMs => _refreshIntervalMs;
  String? get lastDeviceId => _lastDeviceId;
  bool get autoReconnect => _autoReconnect;
  String get transportMode => _transportMode;
  String get wifiHost => _wifiHost;
  int get wifiPort => _wifiPort;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    _tempUnit = prefs.getString('tempUnit') ?? 'C';
    _refreshIntervalMs = prefs.getInt('refreshIntervalMs') ?? 5000;
    _lastDeviceId = prefs.getString('lastDeviceId');
    _autoReconnect = prefs.getBool('autoReconnect') ?? false;
    _transportMode = prefs.getString('transportMode') == 'wifi'
        ? 'wifi'
        : 'ble';
    _wifiHost = prefs.getString('wifiHost') ?? defaultWifiHost;
    _wifiPort = prefs.getInt('wifiPort') ?? defaultWifiPort;

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

  Future<void> setTransportMode(String mode) async {
    _transportMode = mode == 'wifi' ? 'wifi' : 'ble';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transportMode', _transportMode);
    notifyListeners();
  }

  Future<void> setWifiHost(String host) async {
    final trimmed = host.trim();
    _wifiHost = trimmed.isEmpty ? defaultWifiHost : trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wifiHost', _wifiHost);
    notifyListeners();
  }

  Future<void> setWifiPort(int port) async {
    _wifiPort = port > 0 && port <= 65535 ? port : defaultWifiPort;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('wifiPort', _wifiPort);
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
