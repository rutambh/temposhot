class Drill {
  final int? id;
  final String name;
  final String description;
  final double targetParTimeSec;

  const Drill({
    this.id,
    required this.name,
    required this.description,
    required this.targetParTimeSec,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetParTimeSec': targetParTimeSec,
    };
  }

  factory Drill.fromMap(Map<String, dynamic> map) {
    return Drill(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      targetParTimeSec: (map['targetParTimeSec'] as num).toDouble(),
    );
  }
}
