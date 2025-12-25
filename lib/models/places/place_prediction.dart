/// Model for Google Places Autocomplete prediction
class PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String fullText;

  const PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    required this.fullText,
  });

  /// Factory for Places API (New) Autocomplete response
  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structuredFormat = json['structuredFormat'] as Map<String, dynamic>?;
    final mainTextMap = structuredFormat?['mainText'] as Map<String, dynamic>?;
    final secondaryTextMap = structuredFormat?['secondaryText'] as Map<String, dynamic>?;
    final textMap = json['text'] as Map<String, dynamic>?;

    return PlacePrediction(
      placeId: json['placeId'] ?? json['place_id'] ?? '',
      mainText: mainTextMap?['text'] ?? '',
      secondaryText: secondaryTextMap?['text'] ?? '',
      fullText: textMap?['text'] ?? '',
    );
  }

  @override
  String toString() => 'PlacePrediction(placeId: $placeId, mainText: $mainText)';
}
