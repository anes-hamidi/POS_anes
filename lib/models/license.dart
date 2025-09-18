import 'package:cloud_firestore/cloud_firestore.dart';

class License {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String type;
  final String licenseKey;
  final DateTime createdAt;
  final DateTime expiryDate;
  final bool isActive;
  final String? assignedTo; // 🔑 userId who owns the license

  License({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.type,
    required this.licenseKey,
    required this.createdAt,
    required this.expiryDate,
    required this.isActive,
    this.assignedTo,
  });

  factory License.fromJson(Map<String, dynamic> json, String id) {
    return License(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      type: json['type'] ?? '',
      licenseKey: json['licenseKey'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      expiryDate: (json['expiryDate'] as Timestamp).toDate(),    isActive: json['isActive'],
      assignedTo: json['assignedTo'], // 🔑
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'type': type,
      'licenseKey': licenseKey,
      'createdAt': createdAt,
      'expiryDate': expiryDate,
      'isActive': isActive,
      'assignedTo': assignedTo, // 🔑
    };
  }
}
