import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/device.dart';
import '../models/repair_history.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // References to collections
  CollectionReference get _devicesRef => _firestore.collection('devices');
  CollectionReference get _historyRef => _firestore.collection('repair_histories');

  // --- STORAGE METHODS ---

  /// Tải ảnh lên Firebase Storage và trả về URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Tạo tên file duy nhất dựa trên thời gian
      String fileName = 'device_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Tham chiếu đến thư mục 'device_images'
      Reference ref = _storage.ref().child('device_images').child(fileName);
      
      // Bắt đầu upload
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      // Lấy và trả về URL sau khi upload xong
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Lỗi khi upload ảnh: $e');
      return null;
    }
  }

  // --- DEVICE METHODS ---

  /// Lấy Stream danh sách thiết bị (Realtime)
  Stream<List<Device>> getDevicesStream() {
    return _devicesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Truyền đầy đủ 2 tham số: dữ liệu map và document ID
        return Device.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Thêm thiết bị mới
  Future<void> addDevice(Device device) async {
    await _devicesRef.add(device.toMap());
  }

  /// Cập nhật thiết bị
  Future<void> updateDevice(Device device) async {
    if (device.id != null) {
      await _devicesRef.doc(device.id!).update(device.toMap());
    }
  }

  /// Xóa thiết bị
  Future<void> deleteDevice(String id) async {
    await _devicesRef.doc(id).delete();
  }

  // --- REPAIR HISTORY METHODS ---

  /// Lấy Stream lịch sử sửa chữa theo Device ID
  Stream<List<RepairHistory>> getHistoryStream(String deviceId) {
    return _historyRef
        .where('deviceId', isEqualTo: deviceId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Truyền đầy đủ 2 tham số cho RepairHistory.fromMap
        return RepairHistory.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Thêm bản ghi lịch sử sửa chữa
  Future<void> addRepairHistory(RepairHistory history) async {
    await _historyRef.add(history.toMap());
  }

  /// Xóa bản ghi lịch sử sửa chữa
  Future<void> deleteRepairHistory(String id) async {
    await _historyRef.doc(id).delete();
  }
}
