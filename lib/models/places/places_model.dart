import 'package:equatable/equatable.dart';

class PlacesModel extends Equatable {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? rating;
  final int? userRatingsTotal;
  final bool? isOpen;
  final String? photoName;
  final List<String> types;

  const PlacesModel({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.userRatingsTotal,
    this.isOpen,
    this.photoName,
    this.types = const [],
  });

  /// Factory for NEW Places API (v1) response
  factory PlacesModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final photos = json['photos'] as List?;
    final displayName = json['displayName'] as Map<String, dynamic>?;
    final openingHours = json['currentOpeningHours'] as Map<String, dynamic>?;

    return PlacesModel(
      placeId: json['id'] ?? '',
      name: displayName?['text'] ?? '',
      address: json['formattedAddress'] ?? json['shortFormattedAddress'] ?? '',
      latitude: location?['latitude']?.toDouble() ?? 0.0,
      longitude: location?['longitude']?.toDouble() ?? 0.0,
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['userRatingCount'],
      isOpen: openingHours?['openNow'],
      photoName: photos?.isNotEmpty == true ? photos![0]['name'] : null,
      types: List<String>.from(json['types'] ?? []),
    );
  }

  /// Factory for LEGACY Places API response (for backwards compatibility)
  factory PlacesModel.fromLegacyJson(Map<String, dynamic> json) {
    final geometry = json['geometry']['location'];
    final photos = json['photos'] as List?;

    return PlacesModel(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: json['vicinity'] ?? json['formatted_address'] ?? '',
      latitude: geometry['lat']?.toDouble() ?? 0.0,
      longitude: geometry['lng']?.toDouble() ?? 0.0,
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['user_ratings_total'],
      isOpen: json['opening_hours']?['open_now'],
      photoName: photos?.isNotEmpty == true ? photos![0]['photo_reference'] : null,
      types: List<String>.from(json['types'] ?? []),
    );
  }

  /// Returns Google Maps directions URL
  String get directionsUrl {
    final encodedName = Uri.encodeComponent(name);
    return 'https://www.google.com/maps/dir/?api=1&destination=$encodedName&destination_place_id=$placeId';
  }

  /// Returns Google Maps URL to view the place
  String get mapsUrl {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$placeId';
  }

  @override
  List<Object?> get props => [placeId, name, latitude, longitude];
}
