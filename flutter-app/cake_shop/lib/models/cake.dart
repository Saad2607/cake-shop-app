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
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name'] as String? ?? 'Artisan Cake',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      flavors: (json['flavors'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      sizes: (json['sizes'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      inStock: json['inStock'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'basePrice': basePrice,
      'imageUrl': imageUrl,
      'flavors': flavors,
      'sizes': sizes,
      'rating': rating,
      'inStock': inStock,
    };
  }

  Cake copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? basePrice,
    String? imageUrl,
    List<String>? flavors,
    List<String>? sizes,
    double? rating,
    bool? inStock,
  }) {
    return Cake(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      basePrice: basePrice ?? this.basePrice,
      imageUrl: imageUrl ?? this.imageUrl,
      flavors: flavors ?? this.flavors,
      sizes: sizes ?? this.sizes,
      rating: rating ?? this.rating,
      inStock: inStock ?? this.inStock,
    );
  }
}
