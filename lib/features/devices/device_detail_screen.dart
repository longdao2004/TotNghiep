import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/device.dart';
import '../../data/models/repair_history.dart';
import '../../data/remote/firebase_service.dart';
import '../repairs/add_repair_history_screen.dart';
import 'add_device_screen.dart'; // Import để chuyển hướng sửa
import 'device_list_screen.dart';

// Provider lấy lịch sử sửa chữa realtime cho từng thiết bị
final repairHistoryStreamProvider = StreamProvider.family<List<RepairHistory>, String>((ref, deviceId) {
  return ref.watch(firebaseServiceProvider).getHistoryStream(deviceId);
});

class DeviceDetailScreen extends ConsumerWidget {
  final Device device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(repairHistoryStreamProvider(device.id!));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildGeneralInfoCard(),
              _buildWarrantyCard(),
              _buildRepairHistoryCard(context, historyAsync),
              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black26,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        // Nút Chỉnh sửa thiết bị
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black26,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddDeviceScreen(device: device),
                  ),
                );
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          device.name,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        background: device.imageUrl != null
            ? Image.network(
                device.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(color: AppColors.border, child: const Icon(Icons.devices, size: 80, color: Colors.white));
  }

  Widget _buildGeneralInfoCard() {
    return _buildBaseCard(
      title: 'Thông tin chung',
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(device.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Loại: ${device.type}', style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildWarrantyCard() {
    final dateStr = DateFormat('dd/MM/yyyy').format(device.purchaseDate);
    return _buildBaseCard(
      title: 'Bảo hành',
      icon: Icons.verified_user_outlined,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Ngày mua: $dateStr'),
          Text('BH: ${device.warrantyMonths} tháng', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRepairHistoryCard(BuildContext context, AsyncValue<List<RepairHistory>> historyAsync) {
    return _buildBaseCard(
      title: 'Lịch sử sửa chữa',
      icon: Icons.history,
      child: Column(
        children: [
          historyAsync.when(
            data: (history) => history.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('Chưa có dữ liệu sửa chữa', style: TextStyle(fontStyle: FontStyle.italic)),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.issue, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(DateFormat('dd/MM/yyyy').format(item.date)),
                        trailing: Text('${NumberFormat.decimalPattern().format(item.cost)} đ', 
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Lỗi: $e'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddRepairHistoryScreen(
                      deviceId: device.id!,
                      deviceType: device.type, // Fix: Đã thêm tham số deviceType còn thiếu
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm lịch sử'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 18, color: AppColors.primary), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
