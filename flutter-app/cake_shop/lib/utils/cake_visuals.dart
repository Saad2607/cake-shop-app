import '../models/cake.dart';

class CakeVisuals {
  /// Returns a network URL only when the API provides one.
  static String? networkUrlFor(Cake cake) {
    final url = cake.imageUrl.trim();
    if (url.isEmpty) return null;
    return url;
  }
}
