import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:growmee/utils/user_session.dart';

class UserModel {
  final String uid;
  final String email;
  final num? saldo; // <-- PERBAIKAN: Ganti nama dan tipe datanya
  final String? name;
  final bool fingerprintEnabled;

  UserModel({
    required this.uid,
    required this.email,
    this.saldo, // <-- PERBAIKAN: Ganti nama
    this.name,
    this.fingerprintEnabled = false,
  });

  // Pastikan Anda juga menggantinya di semua fungsi lain di dalam file ini.
  // Contoh di 'copyWith':
  UserModel copyWith({
    String? uid,
    String? email,
    num? saldo, // <-- PERBAIKAN: Ganti nama dan tipe data
    String? name,
    bool? fingerprintEnabled,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      saldo: saldo ?? this.saldo, // <-- PERBAIKAN: Ganti nama
      name: name ?? this.name,
      fingerprintEnabled: fingerprintEnabled ?? this.fingerprintEnabled,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      saldo: map['saldo'],
      name: map['name'],
      fingerprintEnabled: map['fingerprintEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'saldo': saldo,
      'name': name,
      'fingerprintEnabled': fingerprintEnabled,
    };
  }

  static UserModel? fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;

    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      saldo: data['saldo'],
      name: data['name'],
      fingerprintEnabled: data['fingerprintEnabled'] ?? false,
    );
  }

  void updateSession(UserSession session) {
    session.setUserId(uid);
    session.setUserName(name ?? '');
    session.setFingerprintEnabled(fingerprintEnabled);
  }
}
