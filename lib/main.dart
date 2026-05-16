import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/models/device.dart';
import 'data/models/repair_history.dart';
import 'features/devices/device_list_screen.dart';
import 'core/theme/app_theme.dart'; // Import theme
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo Firebase bằng file cấu hình vừa sinh ra
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /*
  Hive.registerAdapter(DeviceAdapter());
  Hive.registerAdapter(RepairHistoryAdapter());
  */

  await Hive.openBox<Device>('deviceBox');
  await Hive.openBox<RepairHistory>('repairHistoryBox');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý thiết bị',
      debugShowCheckedModeBanner: false,
      // Áp dụng Design System mới tại đây
      theme: AppTheme.lightTheme,
      home: const DeviceListScreen(),
    );
  }
}
