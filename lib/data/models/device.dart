class Device {
  final String? id;
  final String name;
  final String type;
  final DateTime purchaseDate;
  final int warrantyMonths;
  final String? imageUrl;

  Device({
    this.id,
    required this.name,
    required this.type,
    required this.purchaseDate,
    required this.warrantyMonths,
    this.imageUrl,
  });

  // Chuyển Object sang Map để lưu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'purchaseDate': purchaseDate.toIso8601String(),
      'warrantyMonths': warrantyMonths,
      'imageUrl': imageUrl,
    };
  }

  // Chuyển từ Map (Firestore) sang Object
  factory Device.fromMap(Map<String, dynamic> map, String documentId) {
    return Device(
      id: documentId,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      purchaseDate: map['purchaseDate'] != null 
          ? DateTime.parse(map['purchaseDate']) 
          : DateTime.now(),
      warrantyMonths: map['warrantyMonths'] ?? 0,
      imageUrl: map['imageUrl'],
    );
  }

  Device copyWith({
    String? id,
    String? name,
    String? type,
    DateTime? purchaseDate,
    int? warrantyMonths,
    String? imageUrl,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
