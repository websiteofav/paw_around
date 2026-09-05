import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum LocationStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

/// Result of reverse-geocoding a lat/lng into a human-readable address.
class GeocodedAddress {
  final String formattedAddress;
  final String? area;
  final String? street;

  const GeocodedAddress({
    required this.formattedAddress,
    this.area,
    this.street,
  });
}

class LocationResult {
  final LocationStatus status;
  final Position? position;
  final String? errorMessage;

  const LocationResult({
    required this.status,
    this.position,
    this.errorMessage,
  });

  bool get isSuccess => status == LocationStatus.success;
}

class LocationService {
  /// Checks if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Checks the current location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Requests location permission from the user
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Gets the current position with permission handling
  /// Returns a LocationResult with status and position (if successful)
  Future<LocationResult> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult(
        status: LocationStatus.serviceDisabled,
        errorMessage:
            'Location services are disabled. Please enable them in settings.',
      );
    }

    // Check permission
    LocationPermission permission = await checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationResult(
          status: LocationStatus.permissionDenied,
          errorMessage:
              'Location permission denied. Please grant permission to use this feature.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return const LocationResult(
        status: LocationStatus.permissionDeniedForever,
        errorMessage:
            'Location permission permanently denied. Please enable in app settings.',
      );
    }

    // Get current position
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return LocationResult(
        status: LocationStatus.success,
        position: position,
      );
    } catch (e) {
      return LocationResult(
        status: LocationStatus.serviceDisabled,
        errorMessage: 'Failed to get location: $e',
      );
    }
  }

  /// Opens app settings for the user to enable location permission
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Opens location settings for the user to enable location services
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Calculates distance between two coordinates in meters
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Formats distance to a human-readable string
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    }
    return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
  }

  /// Reverse-geocodes a lat/lng into a human-readable address.
  /// Returns null if no placemark could be resolved.
  Future<GeocodedAddress?> reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final place = placemarks.first;

      final parts = <String>[];
      String? area;
      if (place.subLocality?.isNotEmpty == true) {
        area = place.subLocality;
        parts.add(place.subLocality!);
      } else if (place.street?.isNotEmpty == true) {
        parts.add(place.street!);
      }
      if (place.locality?.isNotEmpty == true) {
        parts.add(place.locality!);
        area ??= place.locality;
      }
      if (parts.isEmpty) return null;

      return GeocodedAddress(
        formattedAddress: parts.join(', '),
        area: area,
        street: place.street,
      );
    } catch (_) {
      return null;
    }
  }
}
