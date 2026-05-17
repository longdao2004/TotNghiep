import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/device.dart';
import '../models/repair_history.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _devicesRef => _firestore.collection('devices');
  CollectionReference get _historyRef => _firestore.collection('repair_histories');

  // --- CLOUDINARY STORAGE METHODS ---

  /// Tải ảnh lên Cloudinary và trả về URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Endpoint API Cloudinary (Unsigned upload)
      final url = Uri.parse('https://api.cloudinary.com/v1_1/dt5zivdqy/image/upload');
      
      // Tạo MultipartRequest
      final request = http.MultipartRequest('POST', url);
      
      // Thêm các fields tham số
      request.fields['upload_preset'] = 'device_preset';
      
      // Thêm file ảnh vào request
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      // Gửi request
      final streamedResponse = await request.send();
      
      // Nhận response
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Trả về secure_url (link https)
        return responseData['secure_url'] as String;
      } else {
        print('Cloudinary upload failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Lỗi khi upload ảnh lên Cloudinary: $e');
      return null;
    }
  }

  // --- DEVICE METHODS ---

  Stream<List<Device>> getDevicesStream() {
    return _devicesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Device.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addDevice(Device device) async {
    await _devicesRef.add(device.toMap());
  }

  Future<void> updateDevice(Device device) async {
    if (device.id != null) {
      await _devicesRef.doc(device.id!).update(device.toMap());
    }
  }

  /// Xóa thiết bị
  Future<void> deleteDevice(String deviceId, String? imageUrl) async {
    // Lưu ý: Xóa ảnh trên Cloudinary cần API Key/Secret hoặc token hủy, 
    // vì vậy hiện tại ta chỉ xóa document trên Firestore.
    await _devicesRef.doc(deviceId).delete();
  }

  // --- REPAIR HISTORY METHODS ---

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

  Future<void> addRepairHistory(RepairHistory history) async {
    await _historyRef.add(history.toMap());
  }
}
