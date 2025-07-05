// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  num saldo;
  bool fingerprintEnabled;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.saldo,
    this.fingerprintEnabled = false,
  });

  /// Mengubah objek UserModel menjadi Map untuk disimpan di Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'saldo': saldo,
      'fingerprintEnabled': fingerprintEnabled,
    };
  }

  /// Membuat objek UserModel dari DocumentSnapshot Firestore.
  factory UserModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id, // Mengambil UID dari ID dokumen
      name: data['name'] ?? 'No Name',
      email: data['email'] ?? 'No Email',
      saldo: data['saldo'] ?? 0,
      fingerprintEnabled: data['fingerprintEnabled'] ?? false,
    );
  }
}