import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/moments/pet_moment_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/services/storage_service.dart';
import 'package:paw_around/ui/moments/widgets/create_moment/moment_draft.dart';

/// Uploads the draft's photo and builds the [PetMoment] to submit.
/// Returns null if the upload fails.
class CreateMomentSubmitService {
  CreateMomentSubmitService._();

  static Future<PetMoment?> buildMoment(MomentDraft draft) async {
    final currentUser = sl<AuthRepository>().currentUser;
    if (currentUser == null) return null;

    final imageUrl = await sl<StorageService>().uploadMomentImage(
      localPath: draft.imagePath,
      userId: currentUser.uid,
    );
    if (imageUrl == null) return null;

    return PetMoment(
      id: '',
      petId: draft.pet.id,
      petName: draft.pet.name,
      imageUrl: imageUrl,
      title: draft.title,
      caption: draft.caption,
      locationName: draft.locationName,
      latitude: draft.latitude,
      longitude: draft.longitude,
      userId: currentUser.uid,
      userName: currentUser.displayName ?? 'Anonymous',
      createdAt: DateTime.now(),
    );
  }
}
