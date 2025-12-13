import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paw_around/models/places/places_model.dart';
import 'package:paw_around/ui/home/widgets/places_bottom_sheet.dart';

class PlacesMapView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(userLatitude, userLongitude),
            zoom: 14,
          ),
          onMapCreated: onMapCreated,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: _buildMarkers(),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: PlacesBottomSheet(
            places: places,
            selectedPlaceId: selectedPlaceId,
            onDirectionsTap: onDirectionsTap,
          ),
        ),
      ],
    );
  }

  Set<Marker> _buildMarkers() {
    return places.map((place) {
      return Marker(
        markerId: MarkerId(place.placeId),
        position: LatLng(place.latitude, place.longitude),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: place.address,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(_getMarkerHue(place.types)),
        onTap: () {
          if (onMarkerTap != null) {
            onMarkerTap!(place.placeId);
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
