import 'package:cloud_firestore/cloud_firestore.dart';

class SerialNumber {
  final String id;
  final String code;
  final String role;
  final bool used;
  final String? usedBy;
  final DateTime createdAt;

  SerialNumber({
    required this.id,
    required this.code,
    required this.role,
    this.used = false,
    this.usedBy,
    required this.createdAt,
  });

  factory SerialNumber.fromMap(Map<String, dynamic> map) {
    return SerialNumber(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      role: map['role'] ?? '',
      used: map['used'] ?? false,
      usedBy: map['usedBy'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'role': role,
      'used': used,
      'usedBy': usedBy,
      'createdAt': createdAt,
    };
  }
}