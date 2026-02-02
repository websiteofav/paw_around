import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paw_around/models/moments/pet_moment_model.dart';
import 'package:paw_around/services/storage_service.dart';

class PetMomentsRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'pet_moments';

  PetMomentsRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _momentsRef =>
      _firestore.collection(_collection);

  /// Fetch all moments ordered by date (newest first)
  Future<List<PetMoment>> getMoments() async {
    final snapshot =
        await _momentsRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => PetMoment.fromFirestore(doc)).toList();
  }

  /// Stream of moments for real-time updates
  Stream<List<PetMoment>> getMomentsStream() {
    return _momentsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PetMoment.fromFirestore(doc)).toList();
    });
  }

  /// Create a new moment
  Future<PetMoment> createMoment(PetMoment moment) async {
    final docRef = await _momentsRef.add(moment.toFirestore());
    return moment.copyWith(id: docRef.id);
  }

  /// Get a single moment by ID
  Future<PetMoment?> getMomentById(String id) async {
    final doc = await _momentsRef.doc(id).get();
    if (!doc.exists) return null;
    return PetMoment.fromFirestore(doc);
  }

  /// Toggle like on a moment
  Future<void> likeMoment(String momentId, String userId) async {
    final momentRef = _momentsRef.doc(momentId);
    final moment = await getMomentById(momentId);

    if (moment == null) return;

    final currentLikes = List<String>.from(moment.likes);

    if (currentLikes.contains(userId)) {
      // Unlike: remove userId from likes array
      currentLikes.remove(userId);
    } else {
      // Like: add userId to likes array
      currentLikes.add(userId);
    }

    await momentRef.update({'likes': currentLikes});
  }

  /// Add a comment to a moment
  Future<void> addComment(
    String momentId,
    String userId,
    String userName,
    String text,
  ) async {
    final momentRef = _momentsRef.doc(momentId);
    final moment = await getMomentById(momentId);

    if (moment == null) return;

    final newComment = PetMomentComment(
      userId: userId,
      userName: userName,
      text: text,
      createdAt: DateTime.now(),
    );

    final currentComments = List<PetMomentComment>.from(moment.comments);
    currentComments.add(newComment);

    await momentRef.update({
      'comments': currentComments.map((c) => c.toMap()).toList(),
    });
  }

  /// Delete a moment (owner only)
  Future<void> deleteMoment(
    String momentId, {
    StorageService? storageService,
  }) async {
    // Get moment to check for image
    final moment = await getMomentById(momentId);
    if (moment?.imageUrl != null && moment!.imageUrl.isNotEmpty) {
      final storage = storageService ?? StorageService();
      await storage.deleteImage(moment.imageUrl);
    }

    await _momentsRef.doc(momentId).delete();
  }

  /// Delete all moments for a specific user (used for account deletion)
  Future<void> deleteAllMomentsForUser(
    String userId, {
    StorageService? storageService,
  }) async {
    final snapshot = await _momentsRef.where('userId', isEqualTo: userId).get();

    final storage = storageService ?? StorageService();

    // Delete images from storage
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final imageUrl = data['imageUrl'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await storage.deleteImage(imageUrl);
      }
    }

    // Delete all moments in a batch
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
