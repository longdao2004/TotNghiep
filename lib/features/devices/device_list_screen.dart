import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database_service.dart';
import '../../data/models/device.dart';

// Provider cung cấp instance của DatabaseService
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// StateNotifier để quản lý danh sách thiết bị
class DeviceListNotifier extends StateNotifier<List<Device>> {
  final DatabaseService _databaseService;

  DeviceListNotifier(this._databaseService) : super([]) {
    refreshDevices();
  }

  // Lấy lại danh sách thiết bị từ DB
  void refreshDevices() {
    state = _databaseService.getAllDevices();
  }

  // Có thể thêm các hàm deleteDevice, addDevice ở đây và gọi refreshDevices()
}

// Provider quản lý trạng thái danh sách thiết bị
final deviceListProvider = StateNotifierProvider<DeviceListNotifier, List<Device>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return DeviceListNotifier(dbService);
});

class DeviceListScreen extends ConsumerWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe danh sách thiết bị
    final devices = ref.watch(deviceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Thiết bị'),
        centerTitle: true,
      ),
      body: devices.isEmpty
          ? const Center(
              child: Text(
                'Chưa có thiết bị nào',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  leading: const Icon(Icons.devices),
                  title: Text(device.name),
                  subtitle: Text('Loại: ${device.type}'),
                  onTap: () {
                    // Xử lý khi nhấn vào item (ví dụ: xem chi tiết)
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Xử lý thêm thiết bị mới
        },
        tooltip: 'Thêm thiết bị',
        child: const Icon(Icons.add),
      ),
    );
  }
}
