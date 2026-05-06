import 'package:hive_flutter/hive_flutter.dart';
import '../models/device.dart';
import '../models/repair_history.dart';

class DatabaseService {
  // Tên các box đã được mở trong main.dart
  static const String _deviceBoxName = 'deviceBox';
  static const String _historyBoxName = 'repairHistoryBox';

  // Lấy instance của box thiết bị
  Box<Device> get _deviceBox => Hive.box<Device>(_deviceBoxName);
  
  // Lấy instance của box lịch sử sửa chữa
  Box<RepairHistory> get _historyBox => Hive.box<RepairHistory>(_historyBoxName);

  // --- QUẢN LÝ THIẾT BỊ (DEVICE) ---

  /// Lấy toàn bộ danh sách thiết bị từ Hive
  List<Device> getAllDevices() {
    return _deviceBox.values.toList();
  }

  /// Thêm thiết bị mới (Dùng id làm key để tránh trùng lặp)
  Future<void> addDevice(Device device) async {
    await _deviceBox.put(device.id, device);
  }

  /// Cập nhật thông tin thiết bị (Ghi đè dữ liệu cũ bằng key id)
  Future<void> updateDevice(Device device) async {
    await _deviceBox.put(device.id, device);
  }

  /// Xóa thiết bị theo ID
  Future<void> deleteDevice(String id) async {
    await _deviceBox.delete(id);
  }

  // --- QUẢN LÝ LỊCH SỬ SỬA CHỮA (REPAIR HISTORY) ---

  /// Lọc và lấy danh sách lịch sử sửa chữa của một thiết bị cụ thể theo deviceId
  List<RepairHistory> getHistoryByDeviceId(String deviceId) {
    return _historyBox.values
        .where((history) => history.deviceId == deviceId)
        .toList();
  }

  /// Thêm một bản ghi lịch sử sửa chữa mới
  Future<void> addRepairHistory(RepairHistory history) async {
    await _historyBox.put(history.id, history);
  }

  /// Xóa một bản ghi lịch sử sửa chữa dựa trên ID
  Future<void> deleteRepairHistory(String id) async {
    await _historyBox.delete(id);
  }
}
