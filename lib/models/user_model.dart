// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final num? saldo;
  final String? name;
  final bool fingerprintEnabled;

  UserModel({
    required this.uid,
    required this.email,
    this.saldo,
    this.name,
    this.fingerprintEnabled = false,
  });

  /// Method untuk membuat salinan objek UserModel dengan data yang diperbarui.
  UserModel copyWith({
    String? uid,
    String? email,
    num? saldo,
    String? name,
    bool? fingerprintEnabled,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      saldo: saldo ?? this.saldo,
      name: name ?? this.name,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
    );
  }

  /// Factory constructor untuk membuat instance UserModel dari Map (misalnya, dari Firestore).
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      saldo: map['saldo'] as num?, // Casting ke num? untuk keamanan tipe data
      name: map['name'] as String?, // Casting ke String?
      fingerprintEnabled: map['fingerprintEnabled'] ?? false,
    );
  }

  /// Method untuk mengubah instance UserModel menjadi Map.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'saldo': saldo,
      'name': name,
      'fingerprintEnabled': fingerprintEnabled,
    };
  }

  /// Factory constructor untuk membuat instance UserModel dari DocumentSnapshot.
  factory UserModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      saldo: data['saldo'] as num?,
      name: data['name'] as String?,
      fingerprintEnabled: data['fingerprintEnabled'] ?? false,
    );
  }

  // TIDAK ADA LAGI METHOD updateSession() DI SINI
}