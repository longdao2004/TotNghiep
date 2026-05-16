import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/remote/firebase_service.dart'; // Import service mới
import '../../data/models/device.dart';
import 'add_device_screen.dart';

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
    // Lắng nghe stream dữ liệu
    final devicesAsyncValue = ref.watch(deviceListStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Thiết bị (Firestore Realtime)',
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
                  return _buildDeviceCard(device);
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
        label: Text('Thêm thiết bị', style: GoogleFonts.inter(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.devices, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('Chưa có thiết bị nào trên Cloud', style: GoogleFonts.inter(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(Device device) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        title: Text(device.name, style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text('${device.type} • Bảo hành ${device.warrantyMonths} tháng'),
        trailing: const Icon(Icons.chevron_right, color: AppColors.primary),
      ),
    );
  }
}
