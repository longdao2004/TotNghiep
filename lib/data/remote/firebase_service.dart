import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/device.dart';
import '../models/repair_history.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  CollectionReference get _devicesRef => _firestore.collection('devices');
  CollectionReference get _historyRef => _firestore.collection('repair_histories');

  // --- STORAGE METHODS ---

  /// Tải ảnh lên Firebase Storage và trả về URL để lưu vào Firestore
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Tạo tên file duy nhất dựa trên timestamp
      String fileName = 'device_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Tham chiếu đến thư mục 'device_images' trên Storage
      Reference ref = _storage.ref().child('device_images').child(fileName);
      
      // Thực hiện upload
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      // Lấy URL sau khi tải lên thành công
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Lỗi upload ảnh: $e');
      return null;
    }
  }

  // --- DEVICE METHODS ---

  /// Lấy Stream danh sách thiết bị (Realtime)
  Stream<List<Device>> getDevicesStream() {
    return _devicesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
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

  /// Xóa thiết bị (Xóa Firestore document và ảnh trên Storage nếu có)
  Future<void> deleteDevice(String deviceId, String? imageUrl) async {
    try {
      // 1. Xóa ảnh trên Storage nếu tồn tại
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          await _storage.refFromURL(imageUrl).delete();
        } catch (e) {
          print('Lỗi xóa ảnh Storage: $e');
        }
      }
      // 2. Xóa document trên Firestore
      await _devicesRef.doc(deviceId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // --- REPAIR HISTORY METHODS ---

  /// Lấy Stream lịch sử sửa chữa theo Device ID
  Stream<List<RepairHistory>> getHistoryStream(String deviceId) {
    return _historyRef
        .where('deviceId', isEqualTo: deviceId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RepairHistory.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Thêm bản ghi lịch sử sửa chữa
  Future<void> addRepairHistory(RepairHistory history) async {
    await _historyRef.add(history.toMap());
  }
}
