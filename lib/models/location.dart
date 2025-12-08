class Location {
  final int? id;
  final String name;
  final String createdAt;

  Location({
    this.id,
    required this.name,
    required this.createdAt,
  });

  // Veritabanına kaydetmek için Map'e çevir
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
    };
  }

  // Map'ten Location objesi oluştur
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
