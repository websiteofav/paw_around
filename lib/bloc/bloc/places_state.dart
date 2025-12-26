import 'package:equatable/equatable.dart';
import 'package:paw_around/models/places/places_model.dart';
import 'package:paw_around/models/places/service_type.dart';

abstract class PlacesState extends Equatable {
  const PlacesState();

  @override
  List<Object?> get props => [];
}

class PlacesInitial extends PlacesState {}

class PlacesLoading extends PlacesState {}

class PlacesLoaded extends PlacesState {
  final List<PlacesModel> places;
  final double userLatitude;
  final double userLongitude;
  final String? selectedPlaceId;
  final bool isMapView;
  final ServiceType selectedServiceType;

  const PlacesLoaded({
    required this.places,
    required this.userLatitude,
    required this.userLongitude,
    this.selectedPlaceId,
    this.isMapView = true,
    this.selectedServiceType = ServiceType.all,
  });

  /// Returns filtered places based on selected service type
  List<PlacesModel> get filteredPlaces {
    if (selectedServiceType == ServiceType.all) {
      return places;
    }
    return places
        .where((place) => selectedServiceType.matchesTypes(
              place.types,
              placeName: place.name,
            ))
        .toList();
  }

  PlacesLoaded copyWith({
    List<PlacesModel>? places,
    double? userLatitude,
    double? userLongitude,
    String? selectedPlaceId,
    bool? isMapView,
    ServiceType? selectedServiceType,
  }) {
    return PlacesLoaded(
      places: places ?? this.places,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      selectedPlaceId: selectedPlaceId,
      isMapView: isMapView ?? this.isMapView,
      selectedServiceType: selectedServiceType ?? this.selectedServiceType,
    );
  }

  @override
  List<Object?> get props => [places, userLatitude, userLongitude, selectedPlaceId, isMapView, selectedServiceType];
}

class PlacesError extends PlacesState {
  final String message;

  const PlacesError(this.message);

  @override
  List<Object?> get props => [message];
}
