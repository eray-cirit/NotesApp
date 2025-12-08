class Operation {
  final int? id;
  final int personId;
  final String operationType;
  final String description;
  final String operationDate; // Kullanıcının girdiği tarih (ISO8601)
  final String createdAt; // Kaydın oluşturulma zamanı (ISO8601)

  Operation({
    this.id,
    required this.personId,
    required this.operationType,
    required this.description,
    required this.operationDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_id': personId,
      'operation_type': operationType,
      'description': description,
      'operation_date': operationDate,
      'created_at': createdAt,
    };
  }

  factory Operation.fromMap(Map<String, dynamic> map) {
    return Operation(
      id: map['id'] as int?,
      personId: map['person_id'] as int,
      operationType: map['operation_type'] as String,
      description: map['description'] as String,
      operationDate: map['operation_date'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
