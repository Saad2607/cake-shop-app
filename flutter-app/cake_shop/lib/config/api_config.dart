/// Production API URL — used automatically in release builds (no IP setup for users).
///
/// After deploying backend on Render, set your URL here OR pass at build time:
/// `flutter build apk --release --dart-define=PRODUCTION_API_URL=https://YOUR-APP.onrender.com/api`
const String productionApiBaseUrl = String.fromEnvironment(
  'PRODUCTION_API_URL',
  defaultValue: 'http://localhost:3000/api',
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
