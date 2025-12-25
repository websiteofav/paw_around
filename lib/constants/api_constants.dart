/// API Constants for external services
class ApiConstants {
  // Google Places API (New) v1
  static const String placesBaseUrl = 'https://places.googleapis.com/v1';

  // Google Places Field Mask (controls billing)
  static const String placesFieldMask = 'places.id,'
      'places.displayName,'
      'places.formattedAddress,'
      'places.shortFormattedAddress,'
      'places.location,'
      'places.rating,'
      'places.userRatingCount,'
      'places.currentOpeningHours,'
      'places.photos,'
      'places.types';

  // Places API Endpoints
  static const String nearbySearchEndpoint = '/places:searchNearby';
  static const String textSearchEndpoint = '/places:searchText';
  static const String autocompleteEndpoint = '/places:autocomplete';
  static const String placeDetailsEndpoint = '/places'; // GET /places/{placeId}

  // Autocomplete Field Mask
  static const String autocompleteFieldMask = 'suggestions.placePrediction.placeId,'
      'suggestions.placePrediction.structuredFormat.mainText.text,'
      'suggestions.placePrediction.structuredFormat.secondaryText.text,'
      'suggestions.placePrediction.text.text';

  // Place Details Field Mask (for getting coordinates)
  static const String placeDetailsFieldMask = 'id,displayName,formattedAddress,location';

  // Default Search Parameters
  static const int defaultSearchRadius = 5000; // meters
  static const int defaultMaxResults = 20;

  // Pet Service Types (official Google place types)
  static const List<String> petServiceTypes = [
    'veterinary_care',
    'pet_store',
  ];

  // Pet Service Queries (for text search - non-official types)
  static const List<String> petServiceQueries = [
    'pet groomer',
  ];
}
