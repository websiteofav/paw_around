import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paw_around/bloc/bloc/places_bloc.dart';
import 'package:paw_around/bloc/bloc/places_event.dart';
import 'package:paw_around/bloc/bloc/places_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/services/location_service.dart';
import 'package:paw_around/ui/home/widgets/places_list_view.dart';
import 'package:paw_around/ui/home/widgets/places_map_view.dart';
import 'package:paw_around/utils/url_utils.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final LocationService _locationService = sl<LocationService>();

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final result = await _locationService.getCurrentLocation();

    if (!mounted) {
      return;
    }

    if (result.isSuccess && result.position != null) {
      context.read<PlacesBloc>().add(LoadNearbyPlaces(
            latitude: result.position!.latitude,
            longitude: result.position!.longitude,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocBuilder<PlacesBloc, PlacesState>(
        builder: (context, state) {
          if (state is PlacesLoading) {
            return _buildLoadingState();
          }

          if (state is PlacesError) {
            return _buildErrorState(state.message);
          }

          if (state is PlacesLoaded) {
            return state.isMapView ? _buildMapView(state) : PlacesListView(places: state.places);
          }

          return _buildInitialState();
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        AppStrings.petServices,
        style: AppTextStyles.appBarTitle,
      ),
      backgroundColor: AppColors.navigationBackground,
      elevation: 0,
      centerTitle: true,
      actions: [
        BlocBuilder<PlacesBloc, PlacesState>(
          builder: (context, state) {
            if (state is PlacesLoaded) {
              return IconButton(
                icon: Icon(
                  state.isMapView ? Icons.list : Icons.map,
                  color: Colors.white,
                ),
                onPressed: () {
                  context.read<PlacesBloc>().add(const ToggleMapView());
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, style: AppTextStyles.bodyText),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCurrentLocation,
            child: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_searching, size: 60, color: AppColors.primary),
          SizedBox(height: 16),
          Text(AppStrings.gettingYourLocation, style: AppTextStyles.bodyText),
        ],
      ),
    );
  }

  Widget _buildMapView(PlacesLoaded state) {
    return PlacesMapView(
      userLatitude: state.userLatitude,
      userLongitude: state.userLongitude,
      places: state.places,
      selectedPlaceId: state.selectedPlaceId,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      onMarkerTap: (placeId) {
        context.read<PlacesBloc>().add(SelectPlace(placeId));
      },
      onDirectionsTap: (model) {
        UrlUtils.launch(model.directionsUrl);
      },
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
