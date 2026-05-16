import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/models/device.dart';
import 'device_list_screen.dart';

class AddDeviceScreen extends ConsumerStatefulWidget {
  final Device? device; // Thêm tham số device để dùng cho việc chỉnh sửa

  const AddDeviceScreen({super.key, this.device});

  @override
  ConsumerState<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends ConsumerState<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController warrantyController;

  String selectedType = 'Laptop';
  DateTime selectedDate = DateTime.now();
  File? _imageFile;
  String? _currentImageUrl;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị nếu đang ở chế độ chỉnh sửa
    nameController = TextEditingController(text: widget.device?.name ?? '');
    warrantyController = TextEditingController(text: widget.device?.warrantyMonths.toString() ?? '');
    if (widget.device != null) {
      selectedType = widget.device!.type;
      selectedDate = widget.device!.purchaseDate;
      _currentImageUrl = widget.device!.imageUrl;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    warrantyController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, maxWidth: 1000, imageQuality: 85);
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');
    }
  }

  void _showPickImageDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Chọn từ thư viện'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Chụp ảnh mới'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDevice() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      String? imageUrl = _currentImageUrl;

      // Nếu người dùng chọn ảnh mới, upload lên Storage
      if (_imageFile != null) {
        imageUrl = await firebaseService.uploadImage(_imageFile!);
      }

      final deviceData = Device(
        id: widget.device?.id, // Giữ nguyên ID nếu là chỉnh sửa
        name: nameController.text.trim(),
        type: selectedType,
        purchaseDate: selectedDate,
        warrantyMonths: int.parse(warrantyController.text.trim()),
        imageUrl: imageUrl,
      );

      if (widget.device == null) {
        await firebaseService.addDevice(deviceData);
      } else {
        await firebaseService.updateDevice(deviceData);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.device == null ? 'Đã thêm thiết bị' : 'Đã cập nhật thiết bị')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.device == null ? 'Thêm thiết bị mới' : 'Chỉnh sửa thiết bị'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showPickImageDialog,
                  child: Container(
                    width: 150, height: 150,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                    child: _imageFile != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(_imageFile!, fit: BoxFit.cover))
                        : (_currentImageUrl != null
                            ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(_currentImageUrl!, fit: BoxFit.cover))
                            : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: Colors.grey), SizedBox(height: 8), Text('Thêm ảnh', style: TextStyle(color: Colors.grey))])),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên máy', prefixIcon: Icon(Icons.devices), border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên máy' : null),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Loại máy', prefixIcon: Icon(Icons.category), border: OutlineInputBorder()),
                items: ['Laptop', 'Điện thoại', 'Tablet', 'Khác'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => selectedType = v!),
              ),
              const SizedBox(height: 16),
              ListTile(contentPadding: EdgeInsets.zero, title: const Text('Ngày mua'), subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)), trailing: const Icon(Icons.calendar_today), onTap: () async {
                final date = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                if (date != null) setState(() => selectedDate = date);
              }),
              const SizedBox(height: 16),
              TextFormField(controller: warrantyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bảo hành (tháng)', prefixIcon: Icon(Icons.verified_user), border: OutlineInputBorder()), validator: (v) => int.tryParse(v!) == null ? 'Nhập số hợp lệ' : null),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PrimaryButton(text: _isSaving ? 'Đang lưu...' : 'Lưu thay đổi', onPressed: _isSaving ? null : _saveDevice),
      ),
    );
  }
}
