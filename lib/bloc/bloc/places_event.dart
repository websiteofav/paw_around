import 'package:equatable/equatable.dart';
import 'package:paw_around/models/places/service_type.dart';

abstract class PlacesEvent extends Equatable {
  const PlacesEvent();

  @override
  List<Object?> get props => [];
}

class LoadNearbyPlaces extends PlacesEvent {
  final double latitude;
  final double longitude;
  final ServiceType? initialFilter;

  const LoadNearbyPlaces({
    required this.latitude,
    required this.longitude,
    this.initialFilter,
  });

  @override
  List<Object?> get props => [latitude, longitude, initialFilter];
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

class FilterByServiceType extends PlacesEvent {
  final ServiceType serviceType;

  const FilterByServiceType(this.serviceType);

  @override
  List<Object?> get props => [serviceType];
}
