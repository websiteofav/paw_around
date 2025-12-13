import 'package:equatable/equatable.dart';

abstract class PlacesEvent extends Equatable {
  const PlacesEvent();

  @override
  List<Object?> get props => [];
}

class LoadNearbyPlaces extends PlacesEvent {
  final double latitude;
  final double longitude;

  const LoadNearbyPlaces({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class SearchPlaces extends PlacesEvent {
  final String query;

  const SearchPlaces(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectPlace extends PlacesEvent {
  final String placeId;

  const SelectPlace(this.placeId);

  @override
  List<Object?> get props => [placeId];
}

class ToggleMapView extends PlacesEvent {
  const ToggleMapView();
}