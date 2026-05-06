// model lịch sử sửa chữa
import 'package:hive/hive.dart';

part 'repair_history.g.dart';

@HiveType(typeId: 1)
class RepairHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String deviceId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String issue;

  @HiveField(4)
  final double cost;

  @HiveField(5)
  final String? aiDiagnosisNote;

  RepairHistory({
    required this.id,
    required this.deviceId,
    required this.date,
    required this.issue,
    required this.cost,
    this.aiDiagnosisNote,
  });
}
