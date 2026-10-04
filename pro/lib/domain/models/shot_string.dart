class ShotString {
  final int? id;
  final int drillId;
  final int shooterId;
  final String timestamp;
  final double totalTimeSec;
  final double firstShotDelaySec;
  final String notes;

  const ShotString({
    this.id,
    this.drillId = 1,
    this.shooterId = 1,
    required this.timestamp,
    required this.totalTimeSec,
    required this.firstShotDelaySec,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'drillId': drillId,
      'shooterId': shooterId,
      'timestamp': timestamp,
      'totalTimeSec': totalTimeSec,
      'firstShotDelaySec': firstShotDelaySec,
      'notes': notes,
    };
  }

  factory ShotString.fromMap(Map<String, dynamic> map) {
    return ShotString(
      id: map['id'] as int?,
      drillId: map['drillId'] as int? ?? 1,
      shooterId: map['shooterId'] as int? ?? 1,
      timestamp: map['timestamp'] as String,
      totalTimeSec: (map['totalTimeSec'] as num).toDouble(),
      firstShotDelaySec: (map['firstShotDelaySec'] as num).toDouble(),
      notes: map['notes'] as String? ?? '',
    );
  }
}
