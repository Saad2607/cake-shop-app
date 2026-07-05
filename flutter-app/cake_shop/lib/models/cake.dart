class Cake {
  final String id;
  final String name;
  final String description;
  final String category;
  final double basePrice;
  final String imageUrl;
  final List<String> flavors;
  final List<String> sizes;
  final double rating;
  final bool inStock;

  Cake({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.basePrice,
    required this.imageUrl,
    required this.flavors,
    required this.sizes,
    required this.rating,
    required this.inStock,
  });

  factory Cake.fromJson(Map<String, dynamic> json) {
    return Cake(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      basePrice: (json['basePrice'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String? ?? '',
      flavors: List<String>.from(json['flavors'] ?? []),
      sizes: List<String>.from(json['sizes'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      inStock: json['inStock'] as bool? ?? true,
    );
  }
}
