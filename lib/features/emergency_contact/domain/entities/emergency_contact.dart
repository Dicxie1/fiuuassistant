class EmergencyContact {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String relationship;
  final DateTime createdAt;

  EmergencyContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.relationship,
    required this.createdAt,
  });
  factory EmergencyContact.fromMap(Map<String, dynamic> map, String id) {
    return EmergencyContact(
      id: id,
      userId: map['userId'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      relationship: map['relationship'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
