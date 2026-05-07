import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_button.dart';
import '../../data/models/device.dart';
import 'device_list_screen.dart';

class AddDeviceScreen extends ConsumerStatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  ConsumerState<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends ConsumerState<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final warrantyController = TextEditingController();

  String selectedType = 'Laptop';
  DateTime selectedDate = DateTime.now();
  bool _isSaving = false;

  final List<String> _deviceTypes = const [
    'Laptop',
    'Điện thoại',
    'Tablet',
    'Khác',
  ];

  @override
  void dispose() {
    nameController.dispose();
    warrantyController.dispose();
    super.dispose();
  }

  Future<void> _selectPurchaseDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null || !mounted) return;

    setState(() {
      selectedDate = pickedDate;
    });
  }

  Future<void> _saveDevice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final newDevice = Device(
      id: const Uuid().v4(),
      name: nameController.text.trim(),
      type: selectedType,
      purchaseDate: selectedDate,
      warrantyMonths: int.parse(warrantyController.text.trim()),
    );

    try {
      await ref.read(databaseServiceProvider).addDevice(newDevice);
      ref.read(deviceListProvider.notifier).refresh();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu thiết bị thành công')),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('dd/MM/yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thêm thiết bị mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Tên máy',
                  hintText: 'Ví dụ: Acer Nitro 5 AN515-45',
                  prefixIcon: Icon(Icons.devices),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên máy';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Loại máy',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _deviceTypes
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _selectPurchaseDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày mua',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    suffixIcon: Icon(Icons.expand_more),
                  ),
                  child: Text(dateText),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: warrantyController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Bảo hành',
                  hintText: 'Số tháng bảo hành',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                  suffixText: 'tháng',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  final warrantyMonths = int.tryParse(text);

                  if (text.isEmpty) {
                    return 'Vui lòng nhập thời gian bảo hành';
                  }
                  if (warrantyMonths == null || warrantyMonths < 0) {
                    return 'Vui lòng nhập số hợp lệ';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: PrimaryButton(
          text: _isSaving ? 'Đang lưu...' : 'Lưu thiết bị',
          onPressed: _isSaving ? null : _saveDevice,
        ),
      ),
    );
  }
}
