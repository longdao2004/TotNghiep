import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/remote/firebase_service.dart';
import '../../data/models/device.dart';
import 'add_device_screen.dart';
import 'device_detail_screen.dart'; // 1. Import màn hình chi tiết

// Provider cung cấp instance của FirebaseService
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// StreamProvider để lắng nghe danh sách thiết bị realtime từ Firestore
final deviceListStreamProvider = StreamProvider<List<Device>>((ref) {
  final firestoreService = ref.watch(firebaseServiceProvider);
  return firestoreService.getDevicesStream();
});

class DeviceListScreen extends ConsumerWidget {
  const DeviceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsyncValue = ref.watch(deviceListStreamProvider);

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
      body: devicesAsyncValue.when(
        data: (devices) => devices.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                itemCount: devices.length,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemBuilder: (context, index) {
                  final device = devices[index];
                  // Sử dụng Dismissible để vuốt để xóa
                  return _buildDismissibleCard(context, ref, device);
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDeviceScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Thêm thiết bị',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  /// Widget bọc Card bằng Dismissible để vuốt xóa
  Widget _buildDismissibleCard(BuildContext context, WidgetRef ref, Device device) {
    return Dismissible(
      key: Key(device.id ?? ''),
      direction: DismissDirection.endToStart, // Vuốt từ phải sang trái
      confirmDismiss: (direction) async {
        // Hiển thị Custom Dialog xác nhận hiện đại
        return await showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon nổi bật trong vòng tròn đỏ nhạt
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: AppColors.error,
                      size: 45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tiêu đề
                  Text(
                    'Xóa thiết bị?',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Mô tả
                  Text(
                    'Bạn có chắc chắn muốn xóa thiết bị này không? Dữ liệu và hình ảnh liên quan sẽ bị xóa vĩnh viễn.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Nút bấm
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Hủy',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Xóa',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      onDismissed: (direction) {
        // Gọi hàm xóa đồng bộ cả Firestore và Storage
        ref.read(firebaseServiceProvider).deleteDevice(device.id!, device.imageUrl);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' Đã xóa ${device.name}'),
            backgroundColor: AppColors.textPrimary,
          ),
        );
      },
      // Giao diện khi đang vuốt (Background màu đỏ + Icon thùng rác)
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_sweep, color: Colors.white, size: 32),
      ),
      child: _buildDeviceCard(context, device),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.devices, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Chưa có thiết bị nào trên Cloud',
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, Device device) {
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: (device.imageUrl != null && device.imageUrl!.isNotEmpty)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  device.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.broken_image_outlined, color: Colors.grey),
                ),
              )
            : const Icon(Icons.devices, color: AppColors.primary),
        ),
        title: Text(
          device.name,
          style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${device.type} • Bảo hành ${device.warrantyMonths} tháng',
          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
        onTap: () {
          // Chuyển hướng sang màn hình chi tiết khi nhấn vào item
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceDetailScreen(device: device),
            ),
          );
        },
      ),
    );
  }
}
