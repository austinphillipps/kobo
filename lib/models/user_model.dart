import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String role;
  final String? name;
  final String? surname;
  final String? phone;
  final String? address;

  UserModel({
    required this.uid,
    this.email,
    required this.role,
    this.name,
    this.surname,
    this.phone,
    this.address,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      role: map['role'] ?? 'client',
      name: map['name'],
      surname: map['surname'],
      phone: map['phone'],
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'surname': surname,
      'phone': phone,
      'address': address,
    };
  }
}