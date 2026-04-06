import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String uid;
  final String name;
  final String state;
  final String city;
  final String phoneNumber;
  final String? photoUrl;
  final DateTime? createdAt;

  const UserProfileModel({
    required this.uid,
    required this.name,
    required this.state,
    required this.city,
    required this.phoneNumber,
    this.photoUrl,
    this.createdAt,
  });

  bool get isComplete =>
      name.isNotEmpty && state.isNotEmpty && city.isNotEmpty;

  factory UserProfileModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserProfileModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      state: data['state'] as String? ?? '',
      city: data['city'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'state': state,
        'city': city,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
