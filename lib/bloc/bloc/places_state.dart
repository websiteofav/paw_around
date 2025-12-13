import 'package:equatable/equatable.dart';
import 'package:paw_around/models/places/places_model.dart';

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

  const PlacesLoaded({
    required this.places,
    required this.userLatitude,
    required this.userLongitude,
    this.selectedPlaceId,
    this.isMapView = true,
  });

  PlacesLoaded copyWith({
    List<PlacesModel>? places,
    double? userLatitude,
    double? userLongitude,
    String? selectedPlaceId,
    bool? isMapView,
  }) {
    return PlacesLoaded(
      places: places ?? this.places,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      selectedPlaceId: selectedPlaceId,
      isMapView: isMapView ?? this.isMapView,
    );
  }

  @override
  List<Object?> get props => [places, userLatitude, userLongitude, selectedPlaceId, isMapView];
}

class PlacesError extends PlacesState {
  final String message;

  const PlacesError(this.message);

  @override
  List<Object?> get props => [message];
}
