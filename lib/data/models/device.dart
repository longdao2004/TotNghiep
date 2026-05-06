//Model thiết bị
import 'package:hive/hive.dart';

part 'device.g.dart';

@HiveType(typeId: 0)
class Device extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final DateTime purchaseDate;

  @HiveField(4)
  final int warrantyMonths;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.purchaseDate,
    required this.warrantyMonths,
  });
}
