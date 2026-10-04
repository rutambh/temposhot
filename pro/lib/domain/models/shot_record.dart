class ShotRecord {
  final int? id;
  final int stringId;
  final int shotNumber;
  final double splitTimeSec;
  final double cumulativeTimeSec;

  const ShotRecord({
    this.id,
    required this.stringId,
    required this.shotNumber,
    required this.splitTimeSec,
    required this.cumulativeTimeSec,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stringId': stringId,
      'shotNumber': shotNumber,
      'splitTimeSec': splitTimeSec,
      'cumulativeTimeSec': cumulativeTimeSec,
    };
  }

  factory ShotRecord.fromMap(Map<String, dynamic> map) {
    return ShotRecord(
      id: map['id'] as int?,
      stringId: map['stringId'] as int,
      shotNumber: map['shotNumber'] as int,
      splitTimeSec: (map['splitTimeSec'] as num).toDouble(),
      cumulativeTimeSec: (map['cumulativeTimeSec'] as num).toDouble(),
    );
  }
}
