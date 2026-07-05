import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How the phone reaches your PC running the Node backend.
enum ServerConnectionMode {
  wifi,
  usb,
  emulator,
}

/// Saved server connection — change from the app when you switch Wi‑Fi networks.
class ServerSettingsService extends ChangeNotifier {
  static const _modeKey = 'server_connection_mode';
  static const _hostKey = 'server_wifi_host';

  static const int port = 3000;

  ServerConnectionMode _mode = ServerConnectionMode.wifi;
  String _wifiHost = '';

  ServerConnectionMode get mode => _mode;
  String get wifiHost => _wifiHost;

  String get baseUrl {
    switch (_mode) {
      case ServerConnectionMode.usb:
        return 'http://127.0.0.1:$port/api';
      case ServerConnectionMode.emulator:
        return 'http://10.0.2.2:$port/api';
      case ServerConnectionMode.wifi:
        final host = _wifiHost.trim();
        if (host.isEmpty) {
          return _platformFallbackUrl();
        }
        return 'http://$host:$port/api';
    }
  }

  /// Root URL for `/health` (not under `/api`).
  String get healthUrl {
    final root = baseUrl.endsWith('/api')
        ? baseUrl.substring(0, baseUrl.length - 4)
        : baseUrl;
    return '$root/health';
  }

  String get modeLabel {
    switch (_mode) {
      case ServerConnectionMode.wifi:
        return 'Wi‑Fi';
      case ServerConnectionMode.usb:
        return 'USB (adb reverse)';
      case ServerConnectionMode.emulator:
        return 'Android emulator';
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_modeKey);
    if (modeIndex != null &&
        modeIndex >= 0 &&
        modeIndex < ServerConnectionMode.values.length) {
      _mode = ServerConnectionMode.values[modeIndex];
    }
    _wifiHost = prefs.getString(_hostKey) ?? '';
    notifyListeners();
  }

  Future<void> setMode(ServerConnectionMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_modeKey, mode.index);
    notifyListeners();
  }

  Future<void> setWifiHost(String host) async {
    _wifiHost = host.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hostKey, _wifiHost);
    notifyListeners();
  }

  Future<void> saveWifi(String host) async {
    await setWifiHost(host);
    await setMode(ServerConnectionMode.wifi);
  }

  String _platformFallbackUrl() {
    if (kIsWeb) return 'http://127.0.0.1:$port/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:$port/api';
    return 'http://127.0.0.1:$port/api';
  }
}
