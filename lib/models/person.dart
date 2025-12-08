class Person {
  final int? id;
  final int locationId;
  final String name;
  final String createdAt;

  Person({
    this.id,
    required this.locationId,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location_id': locationId,
      'name': name,
      'created_at': createdAt,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'] as int?,
      locationId: map['location_id'] as int,
      name: map['name'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
