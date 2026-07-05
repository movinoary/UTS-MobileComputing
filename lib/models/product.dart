class ProductVariant {
  final String name;
  final int stock;

  ProductVariant({required this.name, required this.stock});
}

class Product {
  final String id;
  final String name;
  final String category;
  final String brand;
  final double purchasePrice;
  final double sellingPrice;
  final List<ProductVariant> variants;
  final String? imagePath;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.variants,
    this.imagePath,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? brand,
    double? purchasePrice,
    double? sellingPrice,
    List<ProductVariant>? variants,
    String? imagePath,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      variants: variants ?? this.variants,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  int get totalStock => variants.fold(0, (sum, item) => sum + item.stock);
}
