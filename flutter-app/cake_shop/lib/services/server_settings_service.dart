import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../utils/cake_link.dart';

/// How the app reaches the backend API.
enum ServerConnectionMode {
  production,
  wifi,
  usb,
  emulator,
}

/// Server connection settings. Release builds always use [ServerConnectionMode.production].
class ServerSettingsService extends ChangeNotifier {
  static const _modeKey = 'server_connection_mode';
  static const _hostKey = 'server_wifi_host';

  static const int port = 3000;

  ServerConnectionMode _mode = ServerConnectionMode.production;
  String _wifiHost = '';

  ServerConnectionMode get mode => _mode;
  String get wifiHost => _wifiHost;

  bool get usesProductionServer =>
      kReleaseMode || _mode == ServerConnectionMode.production;

  String get baseUrl {
    if (kReleaseMode) {
      return normalizeApiBaseUrl(productionApiBaseUrl);
    }

    switch (_mode) {
      case ServerConnectionMode.production:
        return normalizeApiBaseUrl(productionApiBaseUrl);
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

  /// Public web root for product share links — always cloud URL when configured.
  String get shareBaseUrl {
    final public = resolvePublicShareBaseUrl();
    if (public.isNotEmpty) return public;
    return CakeLink.webRootFromApiBase(baseUrl);
  }

  bool get hasPublicShareUrl {
    final public = resolvePublicShareBaseUrl();
    return public.isNotEmpty;
  }

  String get modeLabel {
    switch (_mode) {
      case ServerConnectionMode.production:
        return 'Cloud server';
      case ServerConnectionMode.wifi:
        return 'Wi‑Fi';
      case ServerConnectionMode.usb:
        return 'USB (adb reverse)';
      case ServerConnectionMode.emulator:
        return 'Android emulator';
    }
  }

  Future<void> load() async {
    if (kReleaseMode) {
      _mode = ServerConnectionMode.production;
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_modeKey);
    if (modeIndex != null &&
        modeIndex >= 0 &&
        modeIndex < ServerConnectionMode.values.length) {
      _mode = ServerConnectionMode.values[modeIndex];
    } else {
      _mode = ServerConnectionMode.production;
    }
    _wifiHost = prefs.getString(_hostKey) ?? '';
    notifyListeners();
  }

  Future<void> setMode(ServerConnectionMode mode) async {
    if (kReleaseMode) return;

    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_modeKey, mode.index);
    notifyListeners();
  }

  Future<void> setWifiHost(String host) async {
    if (kReleaseMode) return;

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
