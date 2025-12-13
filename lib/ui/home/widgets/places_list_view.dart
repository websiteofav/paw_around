import 'package:flutter/material.dart';
import 'package:paw_around/models/places/places_model.dart';
import 'package:paw_around/ui/home/widgets/place_card.dart';

class PlacesListView extends StatelessWidget {
  final List<PlacesModel> places;
  final Function(PlacesModel)? onDirectionsTap;

  const PlacesListView({
    super.key,
    required this.places,
    this.onDirectionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: places.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PlaceCard(
            place: places[index],
            onDirectionsTap: onDirectionsTap != null ? () => onDirectionsTap!(places[index]) : null,
          ),
        );
      },
    );
  }
}
