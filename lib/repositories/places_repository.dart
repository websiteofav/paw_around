import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:paw_around/constants/api_constants.dart';
import 'package:paw_around/models/places/place_prediction.dart';
import 'package:paw_around/models/places/places_model.dart';

/// Repository for Google Places API (New) - v1
/// Uses POST requests with JSON body and field masks
/// Docs: https://developers.google.com/maps/documentation/places/web-service/nearby-search
class PlacesRepository {
  static String get _apiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  /// Fetches nearby pet services (vets, pet stores, groomers)
  Future<List<PlacesModel>> getNearbyPetServices({
    required double latitude,
    required double longitude,
    int radius = ApiConstants.defaultSearchRadius,
  }) async {
    List<PlacesModel> allPlaces = [];

    // Fetch all official place types in one request
    final places = await _fetchNearbyByType(
      latitude: latitude,
      longitude: longitude,
      includedTypes: ApiConstants.petServiceTypes,
      radius: radius,
    );
    allPlaces.addAll(places);

    // Search for pet groomers and other non-official types
    for (String query in ApiConstants.petServiceQueries) {
      final queryPlaces = await searchPlaces(
        query: query,
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      allPlaces.addAll(queryPlaces);
    }

    return _removeDuplicates(allPlaces);
  }

  /// Nearby Search (New) - POST request
  Future<List<PlacesModel>> _fetchNearbyByType({
    required double latitude,
    required double longitude,
    required List<String> includedTypes,
    required int radius,
    int maxResultCount = ApiConstants.defaultMaxResults,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.placesBaseUrl}${ApiConstants.nearbySearchEndpoint}',
    );

    final body = {
      'includedTypes': includedTypes,
      'maxResultCount': maxResultCount,
      'locationRestriction': {
        'circle': {
          'center': {
            'latitude': latitude,
            'longitude': longitude,
          },
          'radius': radius.toDouble(),
        },
      },
    };

    try {
      final response = await http.post(
        url,
        headers: _buildHeaders(),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['places'] as List? ?? [];
        return results.map((place) => PlacesModel.fromJson(place)).toList();
      }
    } catch (e) {
      throw Exception('Failed to fetch nearby places: $e');
    }

    return [];
  }

  /// Text Search (New) - POST request
  Future<List<PlacesModel>> searchPlaces({
    required String query,
    required double latitude,
    required double longitude,
    int radius = ApiConstants.defaultSearchRadius,
    int maxResultCount = ApiConstants.defaultMaxResults,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.placesBaseUrl}${ApiConstants.textSearchEndpoint}',
    );

    final body = {
      'textQuery': query,
      'maxResultCount': maxResultCount,
      'locationBias': {
        'circle': {
          'center': {
            'latitude': latitude,
            'longitude': longitude,
          },
          'radius': radius.toDouble(),
        },
      },
    };

    try {
      final response = await http.post(
        url,
        headers: _buildHeaders(),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['places'] as List? ?? [];
        return results.map((place) => PlacesModel.fromJson(place)).toList();
      }
    } catch (e) {
      throw Exception('Failed to search places: $e');
    }

    return [];
  }

  /// Builds headers for new Places API
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
      'X-Goog-FieldMask': ApiConstants.placesFieldMask,
    };
  }

  /// Get photo URL from photo name (new format)
  /// Photo name format: "places/{place_id}/photos/{photo_reference}"
  String getPhotoUrl(String photoName, {int maxWidth = 400, int maxHeight = 400}) {
    return '${ApiConstants.placesBaseUrl}/$photoName/media'
        '?maxWidthPx=$maxWidth'
        '&maxHeightPx=$maxHeight'
        '&key=$_apiKey';
  }

  /// Removes duplicate places by placeId
  List<PlacesModel> _removeDuplicates(List<PlacesModel> placesList) {
    final uniquePlaces = <String, PlacesModel>{};
    for (var place in placesList) {
      uniquePlaces[place.placeId] = place;
    }
    return uniquePlaces.values.toList();
  }

  /// Autocomplete search for place predictions
  /// Returns a list of place suggestions based on user input
  Future<List<PlacePrediction>> getAutocompletePredictions({
    required String input,
    double? latitude,
    double? longitude,
    int radius = ApiConstants.defaultSearchRadius,
  }) async {
    if (input.trim().length < 2) {
      return [];
    }

    final url = Uri.parse(
      '${ApiConstants.placesBaseUrl}${ApiConstants.autocompleteEndpoint}',
    );

    final body = <String, dynamic>{
      'input': input,
    };

    // Add location bias if coordinates provided
    if (latitude != null && longitude != null) {
      body['locationBias'] = {
        'circle': {
          'center': {
            'latitude': latitude,
            'longitude': longitude,
          },
          'radius': radius.toDouble(),
        },
      };
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': ApiConstants.autocompleteFieldMask,
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final suggestions = data['suggestions'] as List? ?? [];
        return suggestions
            .where((s) => s['placePrediction'] != null)
            .map((s) => PlacePrediction.fromJson(s['placePrediction']))
            .toList();
      }
    } catch (e) {
      // Return empty list on error - don't throw to avoid UX disruption
    }

    return [];
  }

  /// Get place details by placeId (to fetch coordinates)
  Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      '${ApiConstants.placesBaseUrl}${ApiConstants.placeDetailsEndpoint}/$placeId',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'X-Goog-Api-Key': _apiKey,
          'X-Goog-FieldMask': ApiConstants.placeDetailsFieldMask,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PlaceDetails.fromJson(data);
      }
    } catch (e) {
      // Return null on error
    }

    return null;
  }
}

/// Simple model for place details (coordinates)
class PlaceDetails {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const PlaceDetails({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final displayName = json['displayName'] as Map<String, dynamic>?;

    return PlaceDetails(
      placeId: json['id'] ?? '',
      name: displayName?['text'] ?? '',
      address: json['formattedAddress'] ?? '',
      latitude: location?['latitude']?.toDouble() ?? 0.0,
      longitude: location?['longitude']?.toDouble() ?? 0.0,
    );
  }
}
