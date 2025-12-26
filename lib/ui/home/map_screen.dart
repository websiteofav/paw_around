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
import 'package:paw_around/models/places/service_type.dart';
import 'package:paw_around/services/location_service.dart';
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
      context.read<PlacesBloc>().add(FilterByServiceType(widget.initialFilter!));
    }
  }

  Future<void> _loadCurrentLocation() async {
    final result = await _locationService.getCurrentLocation();

    if (!mounted) {
      return;
    }

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
              final isMapView = state is PlacesLoaded && state.isMapView;
              return DashboardAppBar(
                title: AppStrings.petServices,
                actions: [
                  if (state is PlacesLoaded)
                    DashboardAppBarAction(
                      // Show opposite icon: map icon when in list view, list icon when in map view
                      icon: isMapView ? Icons.view_list_rounded : Icons.map_rounded,
                      onTap: () {
                        context.read<PlacesBloc>().add(const ToggleMapView());
                      },
                    ),
                ],
              );
            },
          ),

          // Filter Chips
          BlocBuilder<PlacesBloc, PlacesState>(
            builder: (context, state) {
              if (state is! PlacesLoaded) {
                return const SizedBox.shrink();
              }
              return _buildFilterChips(state);
            },
          ),

          // Content
          Expanded(
            child: BlocBuilder<PlacesBloc, PlacesState>(
              builder: (context, state) {
                if (state is PlacesLoading) {
                  return _buildLoadingState();
                }

                if (state is PlacesError) {
                  return _buildErrorState(state.message);
                }

                if (state is PlacesLoaded) {
                  return state.isMapView ? _buildMapView(state) : PlacesListView(places: state.filteredPlaces);
                }

                return _buildInitialState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(PlacesLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ServiceType.values.map((type) {
            final isSelected = state.selectedServiceType == type;
            final count = type == ServiceType.all
                ? state.places.length
                : state.places.where((p) => type.matchesTypes(p.types, placeName: p.name)).length;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                type: type,
                isSelected: isSelected,
                count: count,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required ServiceType type,
    required bool isSelected,
    required int count,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<PlacesBloc>().add(FilterByServiceType(type));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? type.color : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? type.color : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: type.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              size: 18,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              type.label,
              style: AppTextStyles.mediumStyle500(
                fontSize: 14,
                fontColor: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.white.withValues(alpha: 0.2) : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.semiBoldStyle600(
                  fontSize: 12,
                  fontColor: isSelected ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSkeletonCard(),
        );
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon skeleton
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle skeleton
                Container(
                  height: 12,
                  width: 150,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Rating skeleton
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Directions button skeleton
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
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
