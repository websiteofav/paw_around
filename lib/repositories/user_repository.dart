import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:paw_around/models/user/user_profile_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  UserRepository({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Returns true if name, state, and city are all filled in Firestore.
  Future<bool> isProfileComplete(String uid) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists) return false;
    final data = snap.data();
    if (data == null) return false;
    final name = data['name'] as String?;
    final state = data['state'] as String?;
    final city = data['city'] as String?;
    final photoUrl = data['photoUrl'] as String?;
    return name != null &&
        name.isNotEmpty &&
        state != null &&
        state.isNotEmpty &&
        city != null &&
        city.isNotEmpty &&
        photoUrl != null;
  }

  /// Fetches the user profile document. Returns null if not found.
  Future<UserProfileModel?> getProfile(String uid) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists) return null;
    return UserProfileModel.fromFirestore(snap);
  }

  /// Saves (merges) name, state, city into Firestore and updates displayName.
  Future<void> saveProfile({
    required String name,
    required String state,
    required String city,
  }) async {
    final uid = _authRepository.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    await _userDoc(uid).set(
      {
        'name': name,
        'state': state,
        'city': city,
        'phoneNumber': _authRepository.currentUser?.phoneNumber ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await _authRepository.updateDisplayName(name);
  }

  /// Uploads a profile photo to Firebase Storage and saves the URL to Firestore.
  Future<void> uploadProfilePhoto(File photo) async {
    final uid = _authRepository.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    final ref = FirebaseStorage.instance.ref('users/$uid/profile.jpg');
    await ref.putFile(photo);
    final url = await ref.getDownloadURL();

    await _userDoc(uid).set({'photoUrl': url}, SetOptions(merge: true));
  }
}
