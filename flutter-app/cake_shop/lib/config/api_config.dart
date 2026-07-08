/// Production API URL — used automatically in release builds (no IP setup for users).
///
/// After deploying backend on Render, set your URL here OR pass at build time:
/// `flutter build apk --release --dart-define=PRODUCTION_API_URL=https://YOUR-APP.onrender.com/api`
const String productionApiBaseUrl = String.fromEnvironment(
  'PRODUCTION_API_URL',
  defaultValue: 'https://cake-shop-app-0r5r.onrender.com/api',
);

/// Public URL used in shared product links (Amazon-style). Falls back to production API root.
/// Override at build time: `--dart-define=PUBLIC_SHARE_URL=https://YOUR-APP.onrender.com`
const String publicShareBaseUrlOverride = String.fromEnvironment(
  'PUBLIC_SHARE_URL',
  defaultValue: 'https://cake-shop-app-0r5r.onrender.com',
);

/// Ensures a consistent `/api` suffix for HTTP calls.
String normalizeApiBaseUrl(String url) {
  var normalized = url.trim();
  while (normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  if (!normalized.endsWith('/api')) {
    normalized = '$normalized/api';
  }
  return normalized;
}

String webRootFromApiBase(String apiBaseUrl) {
  var root = apiBaseUrl.trim();
  if (root.endsWith('/api')) {
    root = root.substring(0, root.length - 4);
  }
  while (root.endsWith('/')) {
    root = root.substring(0, root.length - 1);
  }
  return root;
}

bool isLocalOrPrivateHost(String host) {
  if (host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2') {
    return true;
  }
  if (host.startsWith('192.168.') ||
      host.startsWith('10.') ||
      host.startsWith('172.')) {
    return true;
  }
  return false;
}

/// Root URL for share links — prefers cloud URL so WhatsApp recipients can open the page.
String resolvePublicShareBaseUrl() {
  if (publicShareBaseUrlOverride.trim().isNotEmpty) {
    final raw = publicShareBaseUrlOverride.trim();
    return raw.endsWith('/api')
        ? webRootFromApiBase(raw)
        : webRootFromApiBase('$raw/api');
  }

  final prodUri = Uri.tryParse(productionApiBaseUrl);
  if (prodUri != null && !isLocalOrPrivateHost(prodUri.host)) {
    return webRootFromApiBase(normalizeApiBaseUrl(productionApiBaseUrl));
  }

  return '';
}
