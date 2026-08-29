import 'dart:typed_data';

/// Transient value object handed from the Pick Location screen to the
/// Location Details screen via GoRouter's `extra:` — not Firestore-backed.
class PickedLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String? placeId;

  /// A snapshot of the map exactly as confirmed (via
  /// [GoogleMapController.takeSnapshot]), used as the background of the
  /// "Change" thumbnail on the Location Details screen. Null if the
  /// snapshot couldn't be captured — the thumbnail just falls back to a
  /// flat background in that case.
  final Uint8List? mapSnapshot;

  const PickedLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.placeId,
    this.mapSnapshot,
  });
}
