// màn hình quản lý danh sách thiết bị
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/database_service.dart';
import '../../data/models/device.dart';
import 'add_device_screen.dart';

/// Provider cung cấp instance của DatabaseService
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// StateNotifier để quản lý danh sách thiết bị
class DeviceListNotifier extends StateNotifier<List<Device>> {
  final DatabaseService _dbService;

  DeviceListNotifier(this._dbService) : super([]) {
    loadDevices();
  }

  void loadDevices() {
    state = _dbService.getAllDevices();
  }

  void refresh() => loadDevices();
}

/// Provider quản lý trạng thái danh sách thiết bị
final deviceListProvider = StateNotifierProvider<DeviceListNotifier, List<Device>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return DeviceListNotifier(dbService);
});

class DeviceListScreen extends ConsumerWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Thiết bị của tôi',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: devices.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: devices.length,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemBuilder: (context, index) {
                final device = devices[index];
                return _buildDeviceCard(device);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Logic để mở màn hình thêm thiết bị mới
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Thêm thiết bị',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Widget hiển thị khi không có dữ liệu
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.devices,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có thiết bị nào',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget từng thẻ thiết bị
  Widget _buildDeviceCard(Device device) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(
          device.name,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${device.type} • Bảo hành ${device.warrantyMonths} tháng',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.primary,
        ),
        onTap: () {
          // Logic xem chi tiết
        },
      ),
    );
  }
}
