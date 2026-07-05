import '../models/cake.dart';

/// Calculates cake price from [basePrice] (price of the first/smallest size).
class CakePriceCalculator {
  /// Parses size strings like "1kg", "500g", "12 pcs" into a comparable unit.
  static double sizeUnit(String size) {
    final s = size.trim().toLowerCase();
    final kg = RegExp(r'^([\d.]+)\s*kg$').firstMatch(s);
    if (kg != null) return double.parse(kg.group(1)!);

    final g = RegExp(r'^([\d.]+)\s*g$').firstMatch(s);
    if (g != null) return double.parse(g.group(1)!) / 1000;

    final pcs = RegExp(r'^([\d.]+)\s*pcs$').firstMatch(s);
    if (pcs != null) return double.parse(pcs.group(1)!);

    return 1;
  }

  static double priceForSize(Cake cake, String size) {
    if (cake.sizes.isEmpty) return cake.basePrice;
    final baseUnit = sizeUnit(cake.sizes.first);
    final selectedUnit = sizeUnit(size);
    if (baseUnit <= 0) return cake.basePrice;
    return (cake.basePrice * (selectedUnit / baseUnit)).roundToDouble();
  }

  static String startingPriceLabel(Cake cake) {
    if (cake.sizes.isEmpty) return '';
    return ' ';
  }
}
