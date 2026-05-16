class RepairHistory {
  final String? id;
  final String deviceId;
  final DateTime date;
  final String issue;
  final double cost;
  final String? aiDiagnosisNote;

  RepairHistory({
    this.id,
    required this.deviceId,
    required this.date,
    required this.issue,
    required this.cost,
    this.aiDiagnosisNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'date': date.toIso8601String(),
      'issue': issue,
      'cost': cost,
      'aiDiagnosisNote': aiDiagnosisNote,
    };
  }

  factory RepairHistory.fromMap(Map<String, dynamic> map, String documentId) {
    return RepairHistory(
      id: documentId,
      deviceId: map['deviceId'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      issue: map['issue'] ?? '',
      cost: (map['cost'] ?? 0).toDouble(),
      aiDiagnosisNote: map['aiDiagnosisNote'],
    );
  }
}
