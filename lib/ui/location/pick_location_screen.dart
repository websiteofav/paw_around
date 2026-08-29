import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/addresses/picked_location.dart';
import 'package:paw_around/services/location_service.dart';
import 'package:paw_around/ui/location/widgets/current_location_pill.dart';
import 'package:paw_around/ui/location/widgets/map_center_pin.dart';
import 'package:paw_around/ui/location/widgets/pick_location_bottom_panel.dart';
import 'package:paw_around/ui/location/widgets/pick_location_search_bar.dart';

/// Screen 1 of the address-picking flow: a map with a fixed center pin the
/// user pans to their exact location, then confirms.
class PickLocationScreen extends StatefulWidget {
  final bool autoUseCurrentLocation;

  const PickLocationScreen({super.key, this.autoUseCurrentLocation = false});

  @override
  State<PickLocationScreen> createState() => _PickLocationScreenState();
}

class _PickLocationScreenState extends State<PickLocationScreen> {
  // India centroid — fallback map center until GPS/search gives a real one.
  static const LatLng _fallbackTarget = LatLng(20.5937, 78.9629);

  final _locationService = sl<LocationService>();
  final _searchController = TextEditingController();

  GoogleMapController? _mapController;
  LatLng _target = _fallbackTarget;
  String? _resolvedAddress;
  String? _resolvedArea;
  bool _isResolvingAddress = false;
  bool _isFetchingCurrentLocation = false;
  bool _isConfirming = false;
  Timer? _debounce;

  // For the search-pill / Add-new-address entries, the map's own initial
  // settle fires one "free" onCameraIdle before the user has done anything —
  // swallow just that one so we don't silently resolve/show an address the
  // user never asked for. Real drags (or a deliberate current-location tap,
  // which arms this directly) resolve normally after.
  bool _ignoredInitialIdle = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (widget.autoUseCurrentLocation) {
      _reverseGeocodeTarget();
      _goToCurrentLocation(animate: true, showErrors: true);
    }
    // Otherwise: leave the pin on the fallback position and wait for the
    // user to deliberately search, tap "Current location", or drag the map.
  }

  void _onCameraMove(CameraPosition position) => _target = position.target;

  void _onCameraIdle() {
    if (!widget.autoUseCurrentLocation && !_ignoredInitialIdle) {
      _ignoredInitialIdle = true;
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _reverseGeocodeTarget);
  }

  Future<void> _reverseGeocodeTarget() async {
    if (!mounted) return;
    setState(() => _isResolvingAddress = true);
    final geocoded = await _locationService.reverseGeocode(
        _target.latitude, _target.longitude);
    if (!mounted) return;
    setState(() {
      _resolvedAddress = geocoded?.formattedAddress;
      _resolvedArea = geocoded?.area;
      _isResolvingAddress = false;
    });
  }

  Future<void> _goToCurrentLocation(
      {required bool animate, required bool showErrors}) async {
    if (animate) setState(() => _isFetchingCurrentLocation = true);
    final result = await _locationService.getCurrentLocation();
    if (!mounted) return;
    if (animate) setState(() => _isFetchingCurrentLocation = false);

    if (result.isSuccess && result.position != null) {
      _target = LatLng(result.position!.latitude, result.position!.longitude);
      // A deliberate locate — don't let the initial-idle guard swallow the
      // address resolve that follows (relevant if this is the user's very
      // first action, before the map's own settle-idle has fired).
      _ignoredInitialIdle = true;
      final update = CameraUpdate.newLatLngZoom(_target, 16);
      if (animate) {
        await _mapController?.animateCamera(update);
      } else {
        await _mapController?.moveCamera(update);
      }
      await _reverseGeocodeTarget();
    } else if (showErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(result.errorMessage ?? AppStrings.somethingWentWrong)),
      );
    }
  }

  void _onSearchPlaceSelected(String address, double lat, double lng) {
    _target = LatLng(lat, lng);
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_target, 16));
    setState(() {
      _resolvedAddress = address;
      _resolvedArea = null;
      _isResolvingAddress = false;
    });
  }

  Future<void> _onConfirm() async {
    if (_resolvedAddress == null || _isConfirming) return;
    setState(() => _isConfirming = true);
    final snapshot = await _mapController?.takeSnapshot();
    if (!mounted) return;
    context.pushNamed(
      AppRoutes.locationDetails,
      extra: PickedLocation(
        latitude: _target.latitude,
        longitude: _target.longitude,
        address: _resolvedAddress!,
        mapSnapshot: snapshot,
      ),
    );
    setState(() => _isConfirming = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      const CameraPosition(target: _fallbackTarget, zoom: 5),
                  onMapCreated: _onMapCreated,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
                const Center(child: IgnorePointer(child: MapCenterPin())),
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: AppEdgeInsets.horizontalMedium,
                      child: Row(
                        children: [
                          _BackButton(onTap: () => context.pop()),
                          AppSpacing.horizontal12,
                          Expanded(
                            child: PickLocationSearchBar(
                              controller: _searchController,
                              onPlaceSelected: _onSearchPlaceSelected,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 24,
                  right: 24,
                  child: ConstrainedBox(
                    // Capped, not top:0 — an unbounded/full-height scroll
                    // viewport here would sit on top of the search bar in
                    // the Stack's hit-test order and swallow its taps, even
                    // while empty. This shrink-wraps to content when short
                    // and only grows (then scrolls) up to the cap.
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                    ),
                    child: SingleChildScrollView(
                      // Pins content to the bottom when it fits; scrolls up
                      // to reveal it instead of pushing it off-screen when
                      // it doesn't (long wrapped address, short device).
                      reverse: true,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CurrentLocationPill(
                            isLoading: _isFetchingCurrentLocation,
                            onTap: () => _goToCurrentLocation(
                                animate: true, showErrors: true),
                          ),
                          const SizedBox(height: 12),
                          PickLocationBottomPanel(
                            address: _resolvedAddress,
                            area: _resolvedArea,
                            isResolving: _isResolvingAddress,
                            isConfirming: _isConfirming,
                            onConfirm:
                                _resolvedAddress != null ? _onConfirm : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: const Icon(Icons.arrow_back_ios_new,
          color: AppColors.grey1000, size: 18),
    );
  }
}
