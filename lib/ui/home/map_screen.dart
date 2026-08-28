import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paw_around/bloc/bloc/places_bloc.dart';
import 'package:paw_around/bloc/bloc/places_event.dart';
import 'package:paw_around/bloc/bloc/places_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/places/service_type.dart';
import 'package:paw_around/services/location_service.dart';
import 'package:paw_around/ui/home/widgets/location_permission_denied_widget.dart';
import 'package:paw_around/ui/home/widgets/location_service_disabled_widget.dart';
import 'package:paw_around/ui/home/widgets/map_filter_chips.dart';
import 'package:paw_around/ui/home/widgets/place_skeleton_card.dart';
import 'package:paw_around/ui/home/widgets/places_list_view.dart';
import 'package:paw_around/ui/home/widgets/places_map_view.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/dashboard_app_bar.dart';
import 'package:paw_around/utils/url_utils.dart';

class MapScreen extends StatefulWidget {
  final ServiceType? initialFilter;

  const MapScreen({super.key, this.initialFilter});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final LocationService _locationService = sl<LocationService>();
  ServiceType? _appliedFilter;
  LocationStatus? _locationStatus;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Apply new filter when widget is updated with a different filter
    if (widget.initialFilter != null &&
        widget.initialFilter != _appliedFilter &&
        widget.initialFilter != ServiceType.all) {
      _appliedFilter = widget.initialFilter;
      context
          .read<PlacesBloc>()
          .add(FilterByServiceType(widget.initialFilter!));
    }
  }

  Future<void> _loadCurrentLocation() async {
    final result = await _locationService.getCurrentLocation();

    if (!mounted) {
      return;
    }

    // Store the location status
    setState(() {
      _locationStatus = result.status;
    });

    if (result.isSuccess && result.position != null) {
      _appliedFilter = widget.initialFilter;
      context.read<PlacesBloc>().add(LoadNearbyPlaces(
            latitude: result.position!.latitude,
            longitude: result.position!.longitude,
            initialFilter: widget.initialFilter,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // Custom App Bar
          BlocBuilder<PlacesBloc, PlacesState>(
            builder: (context, state) {
              //   final isMapView = state is PlacesLoaded && state.isMapView;
              return DashboardAppBar(
                title: AppStrings.petServices,
                showProfileAvatar: true,
                onProfileTap: () => context.pushNamed(AppRoutes.profileTab),
              );
            },
          ),
          const SizedBox(height: 8),
          // Filter Chips
          const MapFilterChips(),

          // Content
          Expanded(
            child: BlocBuilder<PlacesBloc, PlacesState>(
              builder: (context, state) {
                // Check for permission denied forever first
                if (_locationStatus == LocationStatus.permissionDeniedForever) {
                  return LocationPermissionDeniedWidget(
                    locationService: _locationService,
                    onRetry: _loadCurrentLocation,
                  );
                }

                // Check for location service disabled
                if (_locationStatus == LocationStatus.serviceDisabled) {
                  return LocationServiceDisabledWidget(
                    locationService: _locationService,
                    onRetry: _loadCurrentLocation,
                  );
                }

                if (state is PlacesLoading) {
                  return _buildLoadingState();
                }

                if (state is PlacesError) {
                  return _buildErrorState(state.message);
                }

                if (state is PlacesLoaded) {
                  return state.isMapView
                      ? _buildMapView(state)
                      : PlacesListView(places: state.filteredPlaces);
                }

                return _buildInitialState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: PlaceSkeletonCard(),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.somethingWentWrong,
              style: AppTextStyles.semiBoldStyle600(
                fontSize: 18,
                fontColor: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CommonButton(
              text: AppStrings.retry,
              onPressed: _loadCurrentLocation,
              variant: ButtonVariant.primary,
              size: ButtonSize.small,
              icon: Icons.refresh,
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_searching,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.gettingYourLocation,
            style: AppTextStyles.mediumStyle500(
              fontSize: 16,
              fontColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(PlacesLoaded state) {
    return PlacesMapView(
      userLatitude: state.userLatitude,
      userLongitude: state.userLongitude,
      places: state.filteredPlaces,
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
