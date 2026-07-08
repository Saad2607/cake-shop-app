import '../models/cake.dart';

class CakeVisuals {
  static String _img(String id) =>
      'https://images.unsplash.com/photo-$id?w=800&q=80&auto=format&fit=crop';

  /// Name-matched images — each photo chosen for that specific cake.
  static const _canonicalByName = {
    'Chocolate Fudge Birthday Cake': '1578985545062-69928b1d9587',
    'Vanilla Dream Wedding Cake': '1535254973040-607b474cb50d',
    'Red Velvet Cupcake Box': '1761751361780-4acacf546346',
    'Custom Photo Cake': '1558636508-e0db3814bd1d',
    'Christmas Fruit Cake': '1524148444900-c6e6d30861e4',
    'Strawberry Shortcake': '1741429385363-82824923d3b0',
    'Black Forest Gateau': '1723476349585-fd0d13cee438',
    'Butterscotch Crunch Cake': '1761637604893-f049f46d2bcd',
    'Mango Alphonso Mousse Cake': '1779852090088-d927a8af43fa',
    'Oreo Chocolate Overload': '1767044315790-bc0fe664fd0b',
    'Gulab Jamun Fusion Cake': '1558618666-fcd25c85cd64',
    'Blueberry Cheesecake Jar': '1567327613485-fbc7bf196198',
    'Chocolate Truffle Cupcake Box': '1486427944299-d1955d23e34d',
    'Classic White Wedding Cake': '1519225421980-715cb0215aed',
    'Rose Gold Anniversary Cake': '1741887845552-005daf40e40d',
    'Cartoon Theme Kids Cake': '1741969494234-7d4bcd1002ab',
    'Corporate Logo Cake': '1626082927389-6cd097cdc6ec',
    'Diwali Mithai Fusion Cake': '1558618666-fcd25c85cd64',
    'New Year Champagne Cake': '1557925923-cd4648e211a0',
    'Tiramisu Coffee Cake': '1571877227200-a0d98ea607e9',
    'Ferrero Rocher Dream Cake': '1469533667357-006056eaf780',
    'Pineapple Fresh Cream Cake': '1643910509764-1add565de3e4',
    'Rainbow Unicorn Cake': '1734987522171-32d3475bb755',
    'Belgian Chocolate Éclair Box': '1756999319115-d05e323161c5',
  };

  static String? networkUrlFor(Cake cake) {
    final canonical = _canonicalByName[cake.name];
    if (canonical != null) return _img(canonical);

    final url = cake.imageUrl.trim();
    if (url.isEmpty) return null;
    return url;
  }
}
