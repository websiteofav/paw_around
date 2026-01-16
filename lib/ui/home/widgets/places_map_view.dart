import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paw_around/models/places/places_model.dart';
import 'package:paw_around/ui/home/widgets/places_bottom_sheet.dart';

class PlacesMapView extends StatefulWidget {
  final double userLatitude;
  final double userLongitude;
  final List<PlacesModel> places;
  final String? selectedPlaceId;
  final Function(GoogleMapController)? onMapCreated;
  final Function(String)? onMarkerTap;
  final Function(PlacesModel)? onDirectionsTap;

  const PlacesMapView({
    super.key,
    required this.userLatitude,
    required this.userLongitude,
    required this.places,
    this.selectedPlaceId,
    this.onMapCreated,
    this.onMarkerTap,
    this.onDirectionsTap,
  });

  @override
  State<PlacesMapView> createState() => _PlacesMapViewState();
}

class _PlacesMapViewState extends State<PlacesMapView>
    with SingleTickerProviderStateMixin {
  final Map<String, BitmapDescriptor> _iconCache = {};
  late AnimationController _animationController;
  String? _animatingPlaceId;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.addListener(() {
      if (mounted) {
        setState(() {}); // Rebuild markers during animation
      }
    });
    _loadMarkerIcons();
  }

  @override
  void didUpdateWidget(PlacesMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload icons if places changed or selection changed
    if (widget.places != oldWidget.places ||
        widget.selectedPlaceId != oldWidget.selectedPlaceId) {
      _loadMarkerIcons();
      // Trigger bounce animation on selection change
      if (widget.selectedPlaceId != null &&
          widget.selectedPlaceId != oldWidget.selectedPlaceId) {
        _animateMarker(widget.selectedPlaceId!);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _animateMarker(String placeId) async {
    _animatingPlaceId = placeId;
    _animationController.reset();
    await _animationController.forward();
    _animatingPlaceId = null;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadMarkerIcons() async {
    // Clear cache to rebuild with new selection state
    _iconCache.clear();

    for (final place in widget.places) {
      final isSelected = place.placeId == widget.selectedPlaceId;
      final hue = _getMarkerHue(place.types);
      final cacheKey = '${place.placeId}_${isSelected}_$hue';

      if (!_iconCache.containsKey(cacheKey)) {
        final icon = await _createScaledMarkerIcon(hue, isSelected);
        _iconCache[cacheKey] = icon;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<BitmapDescriptor> _createScaledMarkerIcon(
      double hue, bool isSelected) async {
    // For unselected markers, use the default Google Maps marker
    if (!isSelected) {
      return BitmapDescriptor.defaultMarkerWithHue(hue);
    }

    // For selected markers, create a scaled-up version (1.2x larger)
    // We'll use the default marker as a base and scale it
    const scale = 1.2;
    const baseSize = 100.0;
    const scaledSize = baseSize * scale;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint();
    final color = _hueToColor(hue);

    // Draw marker shadow
    paint.color = Colors.black.withValues(alpha: 0.15);
    canvas.drawOval(
      Rect.fromLTWH(
        scaledSize * 0.1,
        scaledSize * 0.85,
        scaledSize * 0.8,
        scaledSize * 0.1,
      ),
      paint,
    );

    // Draw the classic Google Maps pin shape (teardrop)
    final centerX = scaledSize / 2;
    final pinTop = scaledSize * 0.1;
    final pinBottom = scaledSize * 0.85;
    final pinWidth = scaledSize * 0.3;

    final path = Path();
    // Top point
    path.moveTo(centerX, pinTop);
    // Left curve
    path.quadraticBezierTo(
      centerX - pinWidth * 0.5,
      pinTop + (pinBottom - pinTop) * 0.3,
      centerX - pinWidth * 0.4,
      pinTop + (pinBottom - pinTop) * 0.6,
    );
    // Bottom left
    path.lineTo(centerX - pinWidth * 0.2, pinBottom - scaledSize * 0.05);
    // Bottom point
    path.lineTo(centerX, pinBottom);
    // Bottom right
    path.lineTo(centerX + pinWidth * 0.2, pinBottom - scaledSize * 0.05);
    // Right curve
    path.quadraticBezierTo(
      centerX + pinWidth * 0.5,
      pinTop + (pinBottom - pinTop) * 0.3,
      centerX,
      pinTop,
    );
    path.close();

    // Fill with color
    paint.color = color;
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Add white border for selected marker
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    canvas.drawPath(path, paint);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(scaledSize.toInt(), scaledSize.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  Color _hueToColor(double hue) {
    if (hue == BitmapDescriptor.hueRed) {
      return Colors.red;
    } else if (hue == BitmapDescriptor.hueBlue) {
      return Colors.blue;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.userLatitude, widget.userLongitude),
            zoom: 14,
          ),
          onMapCreated: widget.onMapCreated,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: _buildMarkers(),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: PlacesBottomSheet(
            places: widget.places,
            selectedPlaceId: widget.selectedPlaceId,
            onDirectionsTap: widget.onDirectionsTap,
          ),
        ),
      ],
    );
  }

  Set<Marker> _buildMarkers() {
    final isAnimating = _animatingPlaceId != null;

    if (_iconCache.isEmpty) {
      // Return default markers while icons are loading
      return widget.places.map((place) {
        return Marker(
          markerId: MarkerId(place.placeId),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.address,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(place.types)),
          onTap: () {
            if (widget.onMarkerTap != null) {
              widget.onMarkerTap!(place.placeId);
              _animateMarker(place.placeId);
            }
          },
        );
      }).toSet();
    }

    return widget.places.map((place) {
      final isSelected = place.placeId == widget.selectedPlaceId;
      final isCurrentlyAnimating =
          isAnimating && place.placeId == _animatingPlaceId;

      final hue = _getMarkerHue(place.types);
      BitmapDescriptor icon;

      // Use scaled icon if selected or animating (for bounce effect)
      if (isSelected || isCurrentlyAnimating) {
        final selectedCacheKey = '${place.placeId}_true_$hue';
        icon = _iconCache[selectedCacheKey] ??
            BitmapDescriptor.defaultMarkerWithHue(hue);
      } else {
        final unselectedCacheKey = '${place.placeId}_false_$hue';
        icon = _iconCache[unselectedCacheKey] ??
            BitmapDescriptor.defaultMarkerWithHue(hue);
      }

      return Marker(
        markerId: MarkerId(place.placeId),
        position: LatLng(place.latitude, place.longitude),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: place.address,
        ),
        icon: icon,
        anchor: Offset(0.5, isSelected || isCurrentlyAnimating ? 0.9 : 1.0),
        onTap: () {
          if (widget.onMarkerTap != null) {
            widget.onMarkerTap!(place.placeId);
            _animateMarker(place.placeId);
          }
        },
      );
    }).toSet();
  }

  double _getMarkerHue(List<String> types) {
    if (types.contains('veterinary_care')) {
      return BitmapDescriptor.hueRed;
    } else if (types.contains('pet_store')) {
      return BitmapDescriptor.hueBlue;
    }
    return BitmapDescriptor.hueGreen;
  }
}
