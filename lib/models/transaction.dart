class Transaction {
  final int? id;
  final int personId;
  final String type; // 'debt' veya 'payment'
  final double amount;
  final String description;
  final String createdAt;

  Transaction({
    this.id,
    required this.personId,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_id': personId,
      'type': type,
      'amount': amount,
      'description': description,
      'created_at': createdAt,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      personId: map['person_id'] as int,
      type: map['type'] as String,
      amount: map['amount'] as double,
      description: map['description'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  bool isDebt() => type == 'debt';
  bool isPayment() => type == 'payment';
}
