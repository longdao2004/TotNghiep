import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/models/repair_history.dart';
import '../../features/devices/device_list_screen.dart'; // Để lấy firebaseServiceProvider

class AddRepairHistoryScreen extends ConsumerStatefulWidget {
  final String deviceId;
  final String deviceType; // Thêm loại thiết bị

  const AddRepairHistoryScreen({
    super.key,
    required this.deviceId,
    required this.deviceType,
  });

  @override
  ConsumerState<AddRepairHistoryScreen> createState() => _AddRepairHistoryScreenState();
}

class _AddRepairHistoryScreenState extends ConsumerState<AddRepairHistoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issueController = TextEditingController();
  final _costController = TextEditingController();
  final _noteController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _issueController.dispose();
    _costController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final history = RepairHistory(
      deviceId: widget.deviceId,
      date: _selectedDate,
      issue: _issueController.text.trim(),
      cost: double.parse(_costController.text.trim()),
      aiDiagnosisNote: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    try {
      await ref.read(firebaseServiceProvider).addRepairHistory(history);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu lịch sử sửa chữa thành công')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thêm lịch sử sửa chữa'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _issueController,
                decoration: const InputDecoration(
                  labelText: 'Vấn đề/Nội dung sửa chữa',
                  hintText: 'Ví dụ: Thay màn hình, Vệ sinh máy...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.build_circle_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập nội dung' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ngày sửa chữa'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Chi phí (VNĐ)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'Vui lòng nhập chi phí';
                  if (double.tryParse(v) == null) return 'Vui lòng nhập số hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  hintText: 'Ghi chú thêm về linh kiện hoặc bảo hành...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: _isSaving ? 'Đang lưu...' : 'Lưu lịch sử',
                onPressed: _isSaving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
