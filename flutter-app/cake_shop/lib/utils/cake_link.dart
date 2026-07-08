/// Builds public product links like Amazon share URLs.
class CakeLink {
  static String webRootFromApiBase(String apiBaseUrl) {
    var root = apiBaseUrl.trim();
    if (root.endsWith('/api')) {
      root = root.substring(0, root.length - 4);
    }
    while (root.endsWith('/')) {
      root = root.substring(0, root.length - 1);
    }
    return root;
  }

  /// Shareable web page: https://your-server.com/p/{cakeId}
  static String productPage(String cakeId, String apiBaseUrl) {
    return '${webRootFromApiBase(apiBaseUrl)}/p/$cakeId';
  }

  /// When you already have the public web root (no /api suffix).
  static String productPageFromRoot(String cakeId, String shareBaseUrl) {
    var root = shareBaseUrl.trim();
    while (root.endsWith('/')) {
      root = root.substring(0, root.length - 1);
    }
    return '$root/p/$cakeId';
  }

  /// Opens the cake directly in the installed app.
  static String deepLink(String cakeId) => 'sweetdelights://cake/$cakeId';
}
