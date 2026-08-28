import 'package:paw_around/models/pets/pet_model.dart';

/// Not-yet-submitted moment data collected on [CreateMomentScreen] and
/// carried across to [MomentPreviewScreen] before it is uploaded/posted.
class MomentDraft {
  final String imagePath;
  final String title;
  final String caption;
  final PetModel pet;
  final String locationName;
  final double? latitude;
  final double? longitude;

  const MomentDraft({
    required this.imagePath,
    required this.title,
    required this.caption,
    required this.pet,
    required this.locationName,
    this.latitude,
    this.longitude,
  });
}
