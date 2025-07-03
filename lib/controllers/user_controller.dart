import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:get/get.dart';
import '../utils/user_session.dart';

class UserController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  Future<bool> checkUserExists(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists;
  }

  Future<void> saveInitialUserData(String userId, String email, String name, String s) async {
    try {
      final userDoc = _db.collection('users').doc(userId);

      await userDoc.set({
        'email': email,
        'name': name,
        'saldo': null,
        'fingerprintEnabled': false,
      }, SetOptions(merge: true));

      _userModel = UserModel(
        uid: userId,
        email: email,
        name: name,
        saldo: null,
        fingerprintEnabled: false,
      );

      notifyListeners();
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

// File: lib/controllers/user_controller.dart (Perbaikan)

Future<void> fetchUserData(String userId) async {
  // JANGAN gunakan `_auth.currentUser` di sini.
  // Gunakan parameter `userId` yang dikirim dari LoginScreen.
  if (userId.isEmpty) return;

  try {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      final data = doc.data()!;
      _userModel = UserModel(
        uid: userId, 
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        saldo: data['saldo'],
        fingerprintEnabled: data['fingerprintEnabled'] ?? false,
      );
      final session = Get.find<UserSession>();
      session.setUserId(userId);
      session.setUserName(_userModel!.name ?? '');

      notifyListeners();
    }
  } catch (e) {
    print('Error fetching user data: $e');
  }
}

  Future<void> updateFingerprintStatus(String userId, bool isEnabled) async {
    try {
      await _db.collection('users').doc(userId).update({
        'fingerprintEnabled': isEnabled,
      });

      if (_userModel != null && _userModel!.uid == userId) {
        _userModel = _userModel!.copyWith(fingerprintEnabled: isEnabled);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating fingerprint status: $e');
    }
  }
  
}
