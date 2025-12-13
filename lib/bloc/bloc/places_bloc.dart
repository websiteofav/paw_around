import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/bloc/places_event.dart';
import 'package:paw_around/bloc/bloc/places_state.dart';

import 'package:paw_around/repositories/places_repository.dart';

class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  final PlacesRepository placesRepository;

  double? _userLatitude;
  double? _userLongitude;

  PlacesBloc({required this.placesRepository}) : super(PlacesInitial()) {
    on<LoadNearbyPlaces>(_onLoadNearbyPlaces);
    on<SearchPlaces>(_onSearchPlaces);
    on<SelectPlace>(_onSelectPlace);
    on<ToggleMapView>(_onToggleMapView);
  }

  Future<void> _onLoadNearbyPlaces(
    LoadNearbyPlaces event,
    Emitter<PlacesState> emit,
  ) async {
    emit(PlacesLoading());

    try {
      _userLatitude = event.latitude;
      _userLongitude = event.longitude;

      final places = await placesRepository.getNearbyPetServices(
        latitude: event.latitude,
        longitude: event.longitude,
      );

      emit(PlacesLoaded(
        places: places,
        userLatitude: event.latitude,
        userLongitude: event.longitude,
      ));
    } catch (e) {
      emit(PlacesError('Failed to load nearby places: $e'));
    }
  }

  Future<void> _onSearchPlaces(
    SearchPlaces event,
    Emitter<PlacesState> emit,
  ) async {
    if (_userLatitude == null || _userLongitude == null) {
      return;
    }

    emit(PlacesLoading());

    try {
      final places = await placesRepository.searchPlaces(
        query: event.query,
        latitude: _userLatitude!,
        longitude: _userLongitude!,
      );

      emit(PlacesLoaded(
        places: places,
        userLatitude: _userLatitude!,
        userLongitude: _userLongitude!,
      ));
    } catch (e) {
      emit(PlacesError('Failed to search places: $e'));
    }
  }

  void _onSelectPlace(SelectPlace event, Emitter<PlacesState> emit) {
    final currentState = state;
    if (currentState is PlacesLoaded) {
      emit(currentState.copyWith(selectedPlaceId: event.placeId));
    }
  }

  void _onToggleMapView(ToggleMapView event, Emitter<PlacesState> emit) {
    final currentState = state;
    if (currentState is PlacesLoaded) {
      emit(currentState.copyWith(isMapView: !currentState.isMapView));
    }
  }

  /// Get photo URL from photo name (new API format)
  String getPhotoUrl(String photoName) {
    return placesRepository.getPhotoUrl(photoName);
  }
}
