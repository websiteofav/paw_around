import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/places/place_prediction.dart';
import 'package:paw_around/repositories/places_repository.dart';
import 'package:paw_around/services/location_service.dart';
import 'package:paw_around/ui/widgets/common_text_field.dart';

/// Callback when a place is selected
typedef OnPlaceSelected = void Function(String address, double latitude, double longitude);

/// Location autocomplete field with dropdown suggestions
class LocationAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final OnPlaceSelected? onPlaceSelected;
  final bool showCurrentLocationButton;

  const LocationAutocompleteField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onPlaceSelected,
    this.showCurrentLocationButton = true,
  });

  @override
  State<LocationAutocompleteField> createState() => _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  final PlacesRepository _placesRepository = sl<PlacesRepository>();
  final LocationService _locationService = sl<LocationService>();
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();

  OverlayEntry? _overlayEntry;
  List<PlacePrediction> _predictions = [];
  bool _isLoadingCurrentLocation = false;
  Timer? _debounceTimer;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
    _loadUserLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    _removeOverlay();
    super.dispose();
  }

  Future<void> _loadUserLocation() async {
    final result = await _locationService.getCurrentLocation();
    if (result.isSuccess && result.position != null) {
      _userPosition = result.position;
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    final text = widget.controller.text.trim();

    if (text.length < 3) {
      _removeOverlay();
      setState(() {
        _predictions = [];
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _fetchPredictions(text);
    });
  }

  Future<void> _fetchPredictions(String input) async {
    final predictions = await _placesRepository.getAutocompletePredictions(
      input: input,
      latitude: _userPosition?.latitude,
      longitude: _userPosition?.longitude,
    );

    if (mounted) {
      setState(() {
        _predictions = predictions;
      });

      if (_predictions.isNotEmpty && _focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: context.findRenderObject() != null
            ? (context.findRenderObject() as RenderBox).size.width
            : MediaQuery.of(context).size.width - 40,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: AppColors.white,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _predictions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final prediction = _predictions[index];
                    return _buildPredictionTile(prediction);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildPredictionTile(PlacePrediction prediction) {
    return InkWell(
      onTap: () => _onPredictionSelected(prediction),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediction.mainText,
                    style: AppTextStyles.mediumStyle500(
                      fontSize: 14,
                      fontColor: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (prediction.secondaryText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      prediction.secondaryText,
                      style: AppTextStyles.regularStyle400(
                        fontSize: 12,
                        fontColor: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPredictionSelected(PlacePrediction prediction) async {
    _removeOverlay();
    _focusNode.unfocus();

    // Show temporary text while fetching details
    widget.controller.text = prediction.mainText;

    // Fetch place details to get coordinates
    final details = await _placesRepository.getPlaceDetails(prediction.placeId);

    if (details != null && mounted) {
      final address =
          prediction.fullText.isNotEmpty ? prediction.fullText : '${prediction.mainText}, ${prediction.secondaryText}';
      widget.controller.text = address;
      widget.onPlaceSelected?.call(
        address,
        details.latitude,
        details.longitude,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingCurrentLocation = true);
    _removeOverlay();

    final result = await _locationService.getCurrentLocation();

    if (result.isSuccess && result.position != null) {
      final lat = result.position!.latitude;
      final lng = result.position!.longitude;
      _userPosition = result.position;

      // Reverse geocode to get address
      String locationName = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      try {
        // Use geocoding package
        final placemarks = await _getAddressFromCoordinates(lat, lng);
        if (placemarks != null) {
          locationName = placemarks;
        }
      } catch (e) {
        // Use coordinates as fallback
      }

      if (mounted) {
        widget.controller.text = locationName;
        widget.onPlaceSelected?.call(locationName, lat, lng);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage ?? 'Failed to get location')),
        );
      }
    }

    setState(() => _isLoadingCurrentLocation = false);
  }

  Future<String?> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Format: "Neighborhood, City" or "Street, City"
        final parts = <String>[];
        if (place.subLocality?.isNotEmpty == true) {
          parts.add(place.subLocality!);
        } else if (place.street?.isNotEmpty == true) {
          parts.add(place.street!);
        }
        if (place.locality?.isNotEmpty == true) {
          parts.add(place.locality!);
        }
        if (parts.isNotEmpty) {
          return parts.join(', ');
        }
      }
    } catch (e) {
      // Return null on error - will fallback to coordinates
    }
    return null;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CommonTextField(
        controller: widget.controller,
        focusNode: _focusNode,
        labelText: widget.labelText ?? AppStrings.location,
        hintText: widget.hintText ?? AppStrings.searchForLocation,
        validator: widget.validator,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showCurrentLocationButton)
              IconButton(
                onPressed: _isLoadingCurrentLocation ? null : _getCurrentLocation,
                icon: _isLoadingCurrentLocation
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, color: AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
