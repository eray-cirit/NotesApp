class StockHistory {
  final int? id;
  final int productId;
  final int changeAmount; // +5 veya -3 gibi
  final String description;
  final String createdAt;

  StockHistory({
    this.id,
    required this.productId,
    required this.changeAmount,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'change_amount': changeAmount,
      'description': description,
      'created_at': createdAt,
    };
  }

  factory StockHistory.fromMap(Map<String, dynamic> map) {
    return StockHistory(
      id: map['id'] as int?,
      productId: map['product_id'] as int,
      changeAmount: map['change_amount'] as int,
      description: map['description'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
