class Product {
  final int? id;
  final String name;
  final String imagePath;
  final int quantity;
  final String createdAt;

  Product({
    this.id,
    required this.name,
    required this.imagePath,
    required this.quantity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image_path': imagePath,
      'quantity': quantity,
      'created_at': createdAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      imagePath: map['image_path'] as String,
      quantity: map['quantity'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  // Yeni miktar ile kopyala
  Product copyWith({int? quantity}) {
    return Product(
      id: id,
      name: name,
      imagePath: imagePath,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt,
    );
  }
}
