import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// A saved address, stored at `users/{uid}/addresses/{id}`.
class AddressModel extends Equatable {
  final String id;
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String buildingFloor;
  final String street;
  final String area;
  final String label;
  final String? placeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AddressModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.buildingFloor,
    required this.street,
    required this.area,
    required this.label,
    this.placeId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'formattedAddress': formattedAddress,
      'buildingFloor': buildingFloor,
      'street': street,
      'area': area,
      'label': label,
      'placeId': placeId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: doc.id,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      formattedAddress: data['formattedAddress'] as String? ?? '',
      buildingFloor: data['buildingFloor'] as String? ?? '',
      street: data['street'] as String? ?? '',
      area: data['area'] as String? ?? '',
      label: data['label'] as String? ?? '',
      placeId: data['placeId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        latitude,
        longitude,
        formattedAddress,
        buildingFloor,
        street,
        area,
        label,
        placeId,
        createdAt,
        updatedAt,
      ];
}
